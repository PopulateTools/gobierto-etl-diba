#!/bin/bash

# Extract > Download data sources
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2015"     /tmp/diba/providers_2015.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2016" /tmp/diba/providers_2016.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2017" /tmp/diba/providers_2017.json

# Extract > Check JSON format
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2015.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2016.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017.json

# Load > Remove previous data
cd $DEV/gobierto-etl-utils/; ruby operations/gobierto_budgets/clear-previous-providers/run.rb diba

# Load > Load providers and invoices data
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2015.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2016.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2017.json

# Load > Publish activity
echo "diba" > /tmp/mataro/organization.id.txt
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/publish-activity/run.rb providers_updated /tmp/mataro/organization.id.txt

# Load > Clear cache
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/clear-cache/run.rb
