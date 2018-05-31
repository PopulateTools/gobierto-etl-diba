#!/bin/bash

# Extract > Download data sources
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/1/pag-fi/10000/camp-exercici/2016"     /tmp/diba/providers_2016_1.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/10001/pag-fi/20000/camp-exercici/2016" /tmp/diba/providers_2016_2.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/20001/pag-fi/30000/camp-exercici/2016" /tmp/diba/providers_2016_3.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/30001/pag-fi/40000/camp-exercici/2016" /tmp/diba/providers_2016_4.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/40001/pag-fi/50000/camp-exercici/2016" /tmp/diba/providers_2016_5.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/50001/pag-fi/60000/camp-exercici/2016" /tmp/diba/providers_2016_6.json

cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/1/pag-fi/10000/camp-exercici/2017"     /tmp/diba/providers_2017_1.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/10001/pag-fi/20000/camp-exercici/2017" /tmp/diba/providers_2017_2.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/20001/pag-fi/30000/camp-exercici/2017" /tmp/diba/providers_2017_3.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/30001/pag-fi/40000/camp-exercici/2017" /tmp/diba/providers_2017_4.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/40001/pag-fi/50000/camp-exercici/2017" /tmp/diba/providers_2017_5.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/50001/pag-fi/60000/camp-exercici/2017" /tmp/diba/providers_2017_6.json
cd $DEV/gobierto-etl-utils/; ruby operations/download/run.rb "https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-ini/60001/pag-fi/70000/camp-exercici/2017" /tmp/diba/providers_2017_7.json

# Extract > Check JSON format
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2016_1.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2016_2.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2016_3.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2016_4.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2016_5.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2016_6.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017_1.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017_2.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017_3.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017_4.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017_5.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017_6.json
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/diba/providers_2017_7.json

# Load > Remove previous data
cd $DEV/gobierto-etl-utils/; ruby operations/gobierto_budgets/clear-previous-providers/run.rb diba

# Load > Load providers and invoices data
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2016_1.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2016_2.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2016_3.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2016_5.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2016_5.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2016_6.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2017_1.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2017_2.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2017_3.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2017_4.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2017_5.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2017_6.json
cd $DEV/gobierto-etl-diba/; ruby operations/gobierto_budgets/import-providers/run.rb diba /tmp/diba/providers_2017_7.json

# Load > Publish activity
echo "diba" > /tmp/mataro/organization.id.txt
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/publish-activity/run.rb providers_updated /tmp/mataro/organization.id.txt
