email = "popu-servers+jenkins@populate.tools "
pipeline {
    agent any
    environment {
        PATH = "$HOME/.rbenv/shims:$PATH"
        GOBIERTO_ETL_UTILS = "/var/www/gobierto-etl-utils/current/"
        DIBA_ETL = "/var/www/gobierto-etl-diba/current/"
        GOBIERTO = "/var/www/gobierto_staging/current/"
        DIBA_ID = "diba"
        WORKING_DIR="/tmp/diba"
    }
    options {
        retry(3)
    }
    stages {
        stage('Extract > Download data sources') {
            steps {
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/download/run.rb 'https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2015' ${WORKING_DIR}/providers_2015.json"
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/download/run.rb 'https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2016' ${WORKING_DIR}/providers_2016.json"
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/download/run.rb 'https://do.diba.cat/api/dataset/tercers/token/98e0ab9462ee6b20427441dbab8426b9/pag-fi/999999/camp-exercici/2017' ${WORKING_DIR}/providers_2017.json"
            }
        }
        stage('Extract > Check JSON format') {
            steps {
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/check-json/run.rb ${WORKING_DIR}/providers_2015.json"
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/check-json/run.rb ${WORKING_DIR}/providers_2016.json"
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/check-json/run.rb ${WORKING_DIR}/providers_2017.json"
            }
        }
        stage('Load > Clear previous providers') {
            steps {
              sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/gobierto_budgets/clear-previous-providers/run.rb ${DIBA_ID}"
            }
        }
        stage('Load > Import providers') {
            steps {
              sh "cd ${DIBA_ETL}; ruby operations/gobierto_budgets/import-providers/run.rb ${DIBA_ID} ${WORKING_DIR}/providers_2015.json"
              sh "cd ${DIBA_ETL}; ruby operations/gobierto_budgets/import-providers/run.rb ${DIBA_ID} ${WORKING_DIR}/providers_2016.json"
              sh "cd ${DIBA_ETL}; ruby operations/gobierto_budgets/import-providers/run.rb ${DIBA_ID} ${WORKING_DIR}/providers_2017.json"
            }
        }
        stage('Load > Publish activity') {
            steps {
              sh "echo ${DIBA_ID} > ${WORKING_DIR}/organization_id.txt"
              sh "cd ${GOBIERTO}; bin/rails runner ${GOBIERTO_ETL_UTILS}/operations/gobierto/publish-activity/run.rb budgets_updated ${WORKING_DIR}/organization_id.txt"
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
