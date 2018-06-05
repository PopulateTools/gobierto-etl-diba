# frozen_string_literal: true

class BudgetDataDecorator < BaseDecorator
  CODE_REGEXP = /(?<lv1>\A.)(?<lv2>.)(?<lv3>.)(?<lv4>..\z)/
  INDEXES_MAP = {
    ::GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST => %w(ci),
    ::GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED => %w(cf),
    ::GobiertoData::GobiertoBudgets::ES_INDEX_EXECUTED => %w(o dr)
  }.freeze

  def self.detect_kind(kind_name)
    {
      "Ingressos" => ::GobiertoData::GobiertoBudgets::INCOME,
      "Despeses" => ::GobiertoData::GobiertoBudgets::EXPENSE
    }[kind_name]
  end

  def self.collection_extractor
    ->(json) { json["elements"] }
  end

  def self.population_extractor
    ->(json) { nil }
  end

  def self.kind_extractor
    ->(json) { json["nom"] }
  end

  def initialize(item)
    @object = item
    @all_codes = {
      GobiertoBudgets::EconomicArea => parse_code(object["economic"]),
      GobiertoBudgets::FunctionalArea => parse_code(object["funcional"]),
      GobiertoBudgets::CustomArea => parse_code(object["organic"])
    }
    @amounts = INDEXES_MAP.transform_values do |attributes|
      parse_amount(object[attributes.find { |attr| object.has_key?(attr) }])
    end
  end

  def name
    object["descripcio"]
  end

  def code(area, level)
    @all_codes[area][level]
  end

  def amount(index)
    @amounts[index]
  end

  protected

  def parse_code(code)
    { match: CODE_REGEXP.match(code) }.tap do |r|
      r[1] = r[:match][:lv1]
      r[2] = r[1] + r[:match][:lv2]
      r[3] = r[2] + r[:match][:lv3]
      r[4] = "#{ r[3] }-#{ r[:match][:lv4] }"
    end
  end

  def parse_amount(amount)
    return 0 if amount.blank?
    amount.strip.gsub(/[.,]/, "." => "", "," => ".").to_f.round(2)
  end
end
