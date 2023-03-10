#! /bin/bash

source tests/generate_report.sh
source tests/general_test_functions.sh
source tests/test_library.sh

function run_all_tests() {
  local test_dir="tests"
  local test_files=("${test_dir}/test_library.sh")
  local test_cases=($(get_test_cases "${test_files[@]}"))

  OLDIFS=${IFS}
	IFS=$'\n'
  for test_case in ${test_cases[@]}
  do
    ${test_case}
  done
  IFS=${OLDIFS}
}

function run_tests() {
	run_all_tests
	
	OLDIFS=${IFS}
	IFS=$'\n'
	local tests=($(get_tests))
	IFS=${OLDIFS}
	
	generate_report "${tests[@]}"
}

run_tests