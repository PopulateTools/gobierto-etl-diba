email = "popu-servers+jenkins@populate.tools "
pipeline {
    agent any
    environment {
        PATH = "/home/ubuntu/.rbenv/shims:$PATH"
        GOBIERTO_ETL_UTILS = "/var/www/gobierto-etl-utils/current/"
        DIBA_ETL = "/var/www/gobierto-etl-diba/current/"
        GOBIERTO = "/var/www/gobierto_staging/current/"
        DIBA_ID = "diba"
        WORKING_DIR="/tmp/diba"
    }
    stages {
        stage('Extract > Download data sources') {
            steps {
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/download/run.rb 'https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2016-12' ${WORKING_DIR}/budgets-2016-income.json"
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/download/run.rb 'https://do.diba.cat/api/dataset/ingressos/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2017-12' ${WORKING_DIR}/budgets-2017-income.json"
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/download/run.rb 'https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2016-12'  ${WORKING_DIR}/budgets-2016-expenses.json"
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/download/run.rb 'https://do.diba.cat/api/dataset/despeses/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-instantania/2017-12'  ${WORKING_DIR}/budgets-2017-expenses.json"
            }
        }
        stage('Extract > Check JSON format') {
            steps {
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/check-json/run.rb ${WORKING_DIR}/budgets-2016-income.json"
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/check-json/run.rb ${WORKING_DIR}/budgets-2017-income.json"
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/check-json/run.rb ${WORKING_DIR}/budgets-2016-expenses.json"
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/check-json/run.rb ${WORKING_DIR}/budgets-2017-expenses.json"
            }
        }
        stage('Load > Remove previous data') {
            steps {
              sh "echo ${DIBA_ID} > ${WORKING_DIR}/organization.id.txt"
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/gobierto_budgets/clear-budgets/run.rb ${WORKING_DIR}/organization_id.txt"
            }
        }
        stage('Load > Import income data') {
            steps {
              sh "cd ${GOBIERTO}; bin/rails runner ${DIBA_ETL}/operations/gobierto_budgets/import-budgets/run.rb ${WORKING_DIR}/budgets-2016-income.json 2016"
              sh "cd ${GOBIERTO}; bin/rails runner ${DIBA_ETL}/operations/gobierto_budgets/import-budgets/run.rb ${WORKING_DIR}/budgets-2017-income.json 2017"
            }
        }
        stage('Load > Import expenses data') {
            steps {
              sh "cd ${GOBIERTO}; bin/rails runner ${DIBA_ETL}/operations/gobierto_budgets/import-budgets/run.rb ${WORKING_DIR}/budgets-2016-expenses.json 2016"
              sh "cd ${GOBIERTO}; bin/rails runner ${DIBA_ETL}/operations/gobierto_budgets/import-budgets/run.rb ${WORKING_DIR}/budgets-2017-expenses.json 2017"
            }
        }
        stage('Load > Calculate totals') {
            steps {
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/gobierto_budgets/update_total_budget/run.rb '2016 2017' ${WORKING_DIR}/organization.id.txt"
            }
        }
        stage('Load > Calculate bubbles') {
            steps {
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/gobierto_budgets/bubbles/run.rb ${WORKING_DIR}/organization.id.txt"
            }
        }
        stage('Load > Calculate annual data') {
            steps {
              sh "cd ${GOBIERTO}; bin/rails runner ${GOBIERTO_ETL_UTILS}/operations/gobierto_budgets/annual_data/run.rb '2016 2017' ${WORKING_DIR}/organization.id.txt"
            }
        }
        stage('Load > Publish activity') {
            steps {
              sh "cd ${GOBIERTO}; bin/rails runner ${GOBIERTO_ETL_UTILS}/operations/gobierto/publish-activity/run.rb budgets_updated ${WORKING_DIR}/organization.id.txt"
            }
        }
        stage('Load > Clear cache') {
            steps {
              sh "cd ${GOBIERTO}; bin/rails runner ${GOBIERTO_ETL_UTILS}/operations/gobierto/clear-cache/run.rb"
            }
        }
    }
    post {
        failure {
            echo 'This will run only if failed'
            mail body: "Project: ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} - URL de build: ${env.BUILD_URL}",
                charset: 'UTF-8',
                subject: "ERROR CI: Project name -> ${env.JOB_NAME}",
                to: email

        }
    }
}
