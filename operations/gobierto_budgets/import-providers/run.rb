#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Organization ID
#  - 1: Absolute path to a file containing a CSV of providers
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/import-providers/run.rb 8019 input.json
#

if ARGV.length != 2
  raise "At least one argument is required"
end

index = GobiertoData::GobiertoBudgets::ES_INDEX_POPULATE_DATA_PROVIDERS
type =  GobiertoData::GobiertoBudgets::POPULATE_DATA_PROVIDERS_TYPE

organization_id = ARGV[0].to_s
data_file = ARGV[1]
index_request_body = []

def parse_diba_date(year)
  return Date.new(year.to_i, 12, 31)
rescue ArgumentError
  puts $!
  puts year
end

puts "[START] import-providers/run.rb data_file=#{data_file}"

nitems = 0

index_request_body = []
base_attributes = {
  location_id: "diba",
  province_id: nil,
  autonomous_region_id: nil
}

data = JSON.parse(File.read(data_file))
data['elements'].each do |item|
  begin
    date = parse_diba_date(item['exercici'])
    attributes = base_attributes.merge({
      value: item['sum'].tr('.', '').to_f,
      date: date.strftime("%Y-%m-%d"),
      payment_date: date.strftime("%Y-%m-%d"),
      invoice_id: SecureRandom.uuid,
      provider_id: item['nif'].try(:strip),
      provider_name: item['nom_tercer'].try(:strip),
      paid: true,
      subject: item['denom_aplic'].try(:strip),
      freelance: item['nif'] !~ /\A[A-Z]/i,
      economic_budget_line_code: nil,
      functional_budget_line_code: nil,
    })

    nitems += 1
    id = [attributes[:location_id], date.year, attributes[:invoice_id]].join('/')
    index_request_body << {index: {_id: id, data: attributes}}
  rescue ArgumentError
    puts item
  end
end

GobiertoData::GobiertoBudgets::SearchEngine.client.bulk index: index, type: type, body: index_request_body

puts "[END] import-providers/run.rb imported #{nitems} items"
