#!/bin/bash

set -e

DEV=$DEV_DIR

# Reset working dir
rm -rf /tmp/diba
mkdir /tmp/diba

source .env

# Set organization_id
echo "diba" > /tmp/diba/organization_id.txt

# Extract > Download data sources
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2015-12" /tmp/diba/budgets-2015-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2016-12" /tmp/diba/budgets-2016-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2017-12" /tmp/diba/budgets-2017-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2018-12" /tmp/diba/budgets-2018-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2019-1" /tmp/diba/budgets-2019-income.json

cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2015-12"  /tmp/diba/budgets-2015-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2016-12"  /tmp/diba/budgets-2016-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2017-12"  /tmp/diba/budgets-2017-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2018-12"  /tmp/diba/budgets-2018-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2019-1"  /tmp/diba/budgets-2019-expenses.json

# Extract > Check JSON format
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2015-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2016-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2017-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2018-income.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2019-income.json

cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2015-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2016-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2017-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2018-expenses.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/budgets-2019-expenses.json

# Load > Remove previous data
cd $DEV/gobierto-etl-utils/; ruby operations/gobierto_budgets/clear-budgets/run.rb /tmp/diba/organization_id.txt

# Load > Import income data
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2015-income.json 2015
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2016-income.json 2016
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2017-income.json 2017
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2018-income.json 2018
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2019-income.json 2019

# Load > Import expenses data
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2015-expenses.json 2015
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2016-expenses.json 2016
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2017-expenses.json 2017
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2018-expenses.json 2018
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-diba/operations/gobierto_budgets/import-budgets/run.rb /tmp/diba/budgets-2019-expenses.json 2019

# Load > Calculate totals
cd $DEV/gobierto-etl-utils/; ruby operations/gobierto_budgets/update_total_budget/run.rb "2015 2016 2017 2018 2019" /tmp/diba/organization_id.txt

# Load > Calculate bubbles
cd $DEV/gobierto-etl-utils/; ruby operations/gobierto_budgets/bubbles/run.rb /tmp/diba/organization_id.txt

# Load > Calculate annual data
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto_budgets/annual_data/run.rb "2015 2016 2017 2018 2019" /tmp/diba/organization_id.txt

# Load > Publish activity
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/publish-activity/run.rb budgets_updated /tmp/diba/organization_id.txt

# Load > Clear cache
cd $DEV/gobierto/; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/clear-cache/run.rb --site-organization-id "diba" --namespace "GobiertoBudgets"
