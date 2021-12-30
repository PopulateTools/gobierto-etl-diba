#!/bin/bash

set -e

# Reset working dir
rm -rf /tmp/diba
mkdir /tmp/diba

# Extract > Download data sources
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2015" /tmp/diba/providers_2015.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2016" /tmp/diba/providers_2016.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2017" /tmp/diba/providers_2017.json

# Extract > Check JSON format
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2015.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2016.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017.json

# Load > Remove previous data
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/clear-previous-providers/run.rb diba

# Load > Load providers and invoices data
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/transform-providers/run.rb /tmp/diba/providers_2015.json /tmp/diba/providers_2015_transformed.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/transform-providers/run.rb /tmp/diba/providers_2016.json /tmp/diba/providers_2016_transformed.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/transform-providers/run.rb /tmp/diba/providers_2017.json /tmp/diba/providers_2017_transformed.json

# Load > Import invoices
for file in /tmp/diba/*_transformed.json; do
  cd $DEV/gobierto-etl-utils/; ruby operations/gobierto_budgets/import-invoices/run.rb $file
done

# Load > Publish activity
echo "diba" > /tmp/diba/organization_id.txt
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/publish-activity/run.rb providers_updated /tmp/diba/organization_id.txt

# Load > Clear cache
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/clear-cache/run.rb --site-organization-id "diba" --namespace "GobiertoBudgets"
