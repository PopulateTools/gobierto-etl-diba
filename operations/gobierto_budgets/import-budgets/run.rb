#!/usr/bin/env ruby

data_file = ARGV[0]
year = ARGV[1].to_i

puts "[START] import-budgets/run.rb data_file=#{data_file} year=#{year}"

# Script for import available DiBa budget lines data in Elastic Search
# and generate from the same data custom budget lines categories for
# economic area
#
# The script doesn't accept arguments and expects a site with 'diba'
# organization_id. Provides to GobiertoBudgets::JsonParser the specific
# decorator to process DiBa origin data and generate ES entries.
#
# It has to be executed as a Gobierto runner

require "bundler/setup"
Bundler.require

require "json"
require_relative "../../../lib/gobierto_budgets/budget_data_decorator"

module Diba
  class BudgetImporter
    def initialize(opts = {})
      @site = opts[:site]
      @year = opts[:year]
      @data = opts[:data_file] ? GobiertoBudgets::JsonParser.new(File.read(opts[:data_file]), BudgetDataDecorator, site: @site, year: @year) : []
    end

    def import_categories!
      area = GobiertoBudgets::EconomicArea
      @data.collection.each do |item|
        translation =  { "ca" => item.name }
        category = @site.custom_budget_lines_categories.find_or_create_by(area_name: area.area_name,
                                                                          kind: @data.kind,
                                                                          code: item.code(area, 4))
        if category.custom_name_translations != translation
          category.update_attribute(:custom_name_translations, translation)
          puts "=== Added name for category of area #{ category.area_name }, kind #{ category.kind } and code #{ category.code }:  #{ translation }"
        end
      end
    end

    def import!
      areas = [GobiertoBudgets::EconomicArea]
      areas << GobiertoBudgets::FunctionalArea if @data.kind == GobiertoData::GobiertoBudgets::EXPENSE

      indices = [
        GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST,
        GobiertoData::GobiertoBudgets::ES_INDEX_EXECUTED,
        GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED
      ]

      total_results = []
      areas.each do |area|
        indices.each do |index|
          result = @data.budgets_for(area, index)
          # Remove levels > 3
          result.delete_if{ |i| i[:index][:data][:level] > 3 }
          total_results = total_results + result
        end

        if @data.kind == GobiertoData::GobiertoBudgets::EXPENSE
          index = GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST
          if (partition_result = @data.economic_partitions_for(area, index))
            # Remove levels > 3
            partition_result.delete_if{ |i| i[:index][:data][:level] > 3 }

            total_results = total_results + partition_result
          end
        end
      end

      total_count = total_results.count
      total_results = total_results.uniq
      uniq_total_count = total_results.count

      GobiertoData::GobiertoBudgets::SearchEngineWriting.client.bulk( body: total_results.uniq)
      puts "=== Loaded #{ total_results.count } entries. #{ total_count - uniq_total_count } duplicated."
    end
  end
end

site = Site.find_by(organization_id: 'diba')

puts "\n\n\n===== Importing income for #{ site.organization_name }..."
importer = Diba::BudgetImporter.new(data_file: data_file, year: year, site: site)
puts "==== Generating ES entries..."
importer.import!
puts "==== Generating custom categories..."
importer.import_categories!

puts "[END] import-budgets/run.rb"
