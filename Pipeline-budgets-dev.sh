#!/bin/bash

# Extract > Download data sources
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2016-12" /tmp/diba/budgets-2016-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2017-12" /tmp/diba/budgets-2017-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2016-12"  /tmp/diba/budgets-2016-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2017-12"  /tmp/diba/budgets-2017-expenses.json

# Extract > Check JSON format
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2016-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2017-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2016-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2017-expenses.json

# Load > Remove previous data
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/clear-budgets/run.rb diba

# Load > Import income data
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2016-income.json 2016
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2017-income.json 2017

# Load > Import expenses data
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2016-expenses.json 2016
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2017-expenses.json 2017

# Load > Calculate totals
echo "diba" > /tmp/diba/organization.id.txt
cd $DEV/gobierto-etl-utils/; ruby operations/gobierto_budgets/update_total_budget/run.rb "2016 2017" /tmp/diba/organization.id.txt

# Load > Calculate bubbles
cd $DEV/gobierto-etl-utils/; ruby operations/gobierto_budgets/bubbles/run.rb /tmp/diba/organization.id.txt

# Load > Calculate annual data
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto_budgets/annual_data/run.rb "2016 2017" /tmp/diba/organization.id.txt

# Load > Publish activity
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/publish-activity/run.rb budgets_updated /tmp/diba/organization.id.txt

# Load > Clear cache
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/clear-cache/run.rb
