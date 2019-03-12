#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Absolute path to a file containing a CSV of providers
#  - 1: Absolute path to a transformed file
#
# Samples:
#
#   ruby operations/gobierto_budgets/transform-providers/run.rb input.json output.json
#

if ARGV.length != 2
  raise "At least one argument is required"
end

data_file = ARGV[0]
output_file = ARGV[1]

def parse_diba_date(year)
  return Date.new(year.to_i, 12, 31)
rescue ArgumentError
  puts $!
  puts year
end

puts "[START] transform-providers/run.rb data_file=#{data_file}"

nitems = 0

output_data = []
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
    output_data << attributes.merge(base_attributes)
  rescue ArgumentError
    puts item
  end
end

File.write(output_file, output_data.to_json)

puts "[END] transform-providers/run.rb imported #{nitems} items"
