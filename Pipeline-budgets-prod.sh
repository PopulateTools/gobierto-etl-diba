#!/bin/bash

DEV=/var/www/

# Extract > Download data sources
cd $DEV/gobierto-etl-utils/current/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2015-12" /tmp/diba/budgets-2015-income.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2016-12" /tmp/diba/budgets-2016-income.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2017-12" /tmp/diba/budgets-2017-income.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2018-5"  /tmp/diba/budgets-2018-income.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2015-12"  /tmp/diba/budgets-2015-expenses.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2016-12"  /tmp/diba/budgets-2016-expenses.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2017-12"  /tmp/diba/budgets-2017-expenses.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2018-5"   /tmp/diba/budgets-2018-expenses.json

# Extract > Check JSON format
cd $DEV/gobierto-etl-utils/current/; ruby operations/check-json/run.rb /tmp/diba/budgets-2015-income.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/check-json/run.rb /tmp/diba/budgets-2016-income.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/check-json/run.rb /tmp/diba/budgets-2017-income.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/check-json/run.rb /tmp/diba/budgets-2018-income.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/check-json/run.rb /tmp/diba/budgets-2015-expenses.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/check-json/run.rb /tmp/diba/budgets-2016-expenses.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/check-json/run.rb /tmp/diba/budgets-2017-expenses.json
cd $DEV/gobierto-etl-utils/current/; ruby operations/check-json/run.rb /tmp/diba/budgets-2018-expenses.json

# Load > Remove previous data
cd $DEV/gobierto-etl-diba/current/; ruby operations/gobierto_budgets/clear-budgets/run.rb diba

# Load > Import income data
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-diba/current/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2015-income.json 2015
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-diba/current/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2016-income.json 2016
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-diba/current/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2017-income.json 2017
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-diba/current/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2018-income.json 2018

# Load > Import expenses data
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-diba/current/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2015-expenses.json 2015
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-diba/current/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2016-expenses.json 2016
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-diba/current/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2017-expenses.json 2017
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-diba/current/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2018-expenses.json 2018

# Load > Calculate totals
echo "diba" > /tmp/diba/organization.id.txt
cd $DEV/gobierto-etl-utils/current/; ruby operations/gobierto_budgets/update_total_budget/run.rb "2015 2016 2017 2018" /tmp/diba/organization.id.txt

# Load > Calculate bubbles
cd $DEV/gobierto-etl-utils/current/; ruby operations/gobierto_budgets/bubbles/run.rb /tmp/diba/organization.id.txt

# Load > Calculate annual data
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-utils/current/operations/gobierto_budgets/annual_data/run.rb "2015 2016 2017 2018" /tmp/diba/organization.id.txt

# Load > Publish activity
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-utils/current/operations/gobierto/publish-activity/run.rb budgets_updated /tmp/diba/organization.id.txt

# Load > Clear cache
cd $DEV/gobierto/current/; bin/rails runner $DEV/gobierto-etl-utils/current/operations/gobierto/clear-cache/run.rb
