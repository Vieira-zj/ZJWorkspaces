#!/bin/bash
set -u

project_path=$(pwd)
run_dir="tests/smoke"
outputs_dir="outputs"
pytest_options="-v -s --cache-clear --junit-xml=${outputs_dir}/junit.xml"

function show_pytest_markers {
    pytest --markers
}

function show_pytest_fixtures {
    pytest --fixtures
}

function move_pytest_log {
    local log_file="pytest.log"
    cd ${project_path}
    for path in $(find tests/ -name ${log_file}); do
        mv "${project_path}/${path}" outputs
    done
    mv ${log_file} outputs
}

function pytest_dryrun_tests {
    pytest ${pytest_options} --setup-plan ${run_dir}
    move_pytest_log
}

function pytest_run_tests {
    pytest ${pytest_options} tests/test_hello.py

    # pytest ${pytest_options} ${run_dir}
    # pytest ${pytest_options} ${run_dir}/test_datasource.py::TestDataSource::test_get_datasource
    # pytest ${pytest_options} ${run_dir}/test_user.py::TestUser::test_user_list_all
    move_pytest_log
}

allure_dir="outputs/allure"
allure_results_dir="${allure_dir}/results"
allure_reports_dir="${allure_dir}/reports"

function pytest_run_with_allure {
    pytest -v -s --cache-clear --clean-alluredir --alluredir ${allure_results_dir} tests/test_hello.py
    # pytest -v -s ---cache-clear -alluredir ${allure_results_dir} ${run_dir}
    move_pytest_log
}

function open_allure_report {
    allure generate ${allure_results_dir} -o ${allure_reports_dir} --clean
    allure open ${allure_reports_dir}

    # allure serve ${allure_results_dir}
}

function run_docker_allure_server {
    cd ${allure_dir}
    docker run --name allure --rm -d -p 5050:5050 -e CHECK_RESULTS_EVERY_SECONDS=3 -e KEEP_HISTORY=1 \
        -v ${PWD}/results:/app/allure-results -v ${PWD}/reports:/app/default-reports \
        frankescobar/allure-docker-service

    # get projects:
    # curl -X GET "http://localhost:5050/allure-docker-service/projects" -H "accept: */*"
    # generate report:
    # curl -X GET "http://localhost:5050/allure-docker-service/generate-report?project_id=default" -H "accept: */*"
    # latest report:
    # http://localhost:5050/allure-docker-service/latest-report?project_id=default
}

#
# main
#

if [[ $1 == "show" ]]; then
    # show_pytest_markers
    show_pytest_fixtures
    exit 0
fi

if [[ $1 == "pytest" ]]; then
    # pytest_dryrun_tests
    pytest_run_tests
    # pytest_run_with_allure
    exit 0
fi

if [[ $1 == "report" ]]; then
    open_allure_report
    # run_docker_allure_server
    exit 0
fi

echo "pytest done."
