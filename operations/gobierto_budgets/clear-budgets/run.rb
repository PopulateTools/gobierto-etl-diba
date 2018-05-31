#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Organization ID to remove data
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/clear-budgets/run.rb 8019

if ARGV.length != 1
  raise "At least one argument is required"
end

indices = [
  GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST,
  GobiertoData::GobiertoBudgets::ES_INDEX_EXECUTED,
  GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED
]

types = [
  GobiertoData::GobiertoBudgets::TOTAL_BUDGET_TYPE,
  GobiertoData::GobiertoBudgets::ECONOMIC_BUDGET_TYPE,
  GobiertoData::GobiertoBudgets::FUNCTIONAL_BUDGET_TYPE,
  GobiertoData::GobiertoBudgets::CUSTOM_BUDGET_TYPE
]

organization_id = ARGV[0].to_s

puts "[START] clear-budgets/run.rb organization_id=#{organization_id}"

terms = [
  {term: { organization_id: organization_id }}
]

query = {
  query: {
    filtered: {
      filter: {
        bool: {
          must: terms
        }
      }
    }
  },
  size: 10_000
}

count = 0
indices.each do |index|
  types.each do |type|
    response = GobiertoData::GobiertoBudgets::SearchEngine.client.search index: index, type: type, body: query
    while response['hits']['total'] > 0
      delete_request_body = response['hits']['hits'].map do |h|
        count += 1
        { delete: h.slice("_index", "_type", "_id") }
      end
      GobiertoData::GobiertoBudgets::SearchEngine.client.bulk index: index, type: type, body: delete_request_body
      response = GobiertoData::GobiertoBudgets::SearchEngine.client.search index: index, type: type, body: query
    end
  end
end

puts "[END] clear-budgets/run.rb. Deleted #{count} items"
