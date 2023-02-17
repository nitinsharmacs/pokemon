#! /bin/bash

source tests/generate_report.sh
source tests/general_test_functions.sh
source scripts/library.sh

TEST_DATA="tests/data"
RESOURCES_DIR="resources"

function test_get_categories() {
	local test_description=$1
	local expected=$2
	local pokemon_data=("${@:3}")
	
	local actual=$( get_categories "${pokemon_data[@]}")
	local test_result=$( verify_expectations "$actual" "$expected" )
	append_test_case $test_result "get_categories|$test_description|$inputs|$expected|$actual"
}

function test_cases_get_categories() {
	local data=("1|bulbasaur|grass,poison|45|45|64|49|49|69" "2|ivysaur|grass,poison|60|60|142|62|63|130" "3|venusaur|grass,fairy|80|80|236|82|83|1000")
	local test_description="should give all the categories present in the data"
	local expected="fairy grass poison"

	test_get_categories "$test_description" "$expected" "${data[@]}"

    data=()
	test_description="should give no categories for empty data"
	expected=""

	test_get_categories "$test_description" "$expected" "${data[@]}"
}

function test_filter_pokemons() {
	local test_description=$1
    local selected_category=$2
	local expected=($3)
	local pokemon_data=("${@:4}")
	
	local actual=($( filter_pokemons "${selected_category}" "${pokemon_data[@]}"))

	local test_result=$( verify_expectations "${actual[*]}" "${expected[*]}" )
    local inputs="Selected category: ${selected_category}"
	append_test_case $test_result "filter_pokemons|$test_description|$inputs|${expected[*]}|${actual[*]}"
}

function test_cases_filter_pokemons() {
	local data=("1|bulbasaur|grass,poison|45|45|64|49|49|69" "2|ivysaur|grass,poison|60|60|142|62|63|130" "3|venusaur|grass,fairy|80|80|236|82|83|1000")
	local expected=("1|bulbasaur|grass,poison|45|45|64|49|49|69" "2|ivysaur|grass,poison|60|60|142|62|63|130")
    local selected_category="poison"
	local test_description="should filter pokemon data by selected category"

	test_filter_pokemons "$test_description" ${selected_category}  "${expected[*]}" "${data[@]}"

	test_description="should give empty pokemon data for category not found"
	expected=()
    local selected_category="water"

	test_filter_pokemons "$test_description" ${selected_category} "${expected[*]}" "${data[@]}"
}

function test_get_field() {
	local test_description=$1
	local expected=$2
	local field=$3
	local pokeomon_details=$4

	local actual=$( get_field "${field}" "${pokemon_details}")

	local test_result=$( verify_expectations "${actual}" "${expected}" )
    local inputs="Field: ${field}"
	append_test_case $test_result "get_field|$test_description|$inputs|${expected}|${actual}"
}

function test_cases_get_field() {
	local pokemon_details="1|bulbasaur|grass,poison|45|45|64|49|49|69"
	local test_description="should give the data of provided field"
	local expected=1

	test_get_field "$test_description" "$expected" 1 "${pokemon_details}"

	local test_description="should give the data of provided multiple fields"
	local expected="45|45|64|49|49|69"

	test_get_field "$test_description" "$expected" "4-" "${pokemon_details}"
}

function test_create_html() {
	local test_description=$1
	local expected=$2
	local tag=$3
	local class=$4
	local content=$5

	local actual=$( create_html "$tag" "$content" "$class" )
	local test_result=$( verify_expectations "$actual" "$expected" )
	append_test_case $test_result "create_html|$test_description|$inputs|$expected|$actual"
}

function test_cases_create_html() {
	local test_description="should create the html element"
	local tag="li"
	local attributes="class=\"some-class\" id=\"12\""
	local content="here is some content"
	local expected="<li class=\"some-class\" id=\"12\">here is some content</li>"

	test_create_html "$test_description" "$expected" "$tag" "$attributes" "$content"

	test_description="should create the html element without attribute"
	tag="li"
	attributes=""
	content="here is some content"
	expected="<li >here is some content</li>"

	test_create_html "$test_description" "$expected" "$tag" "$attributes" "$content"
}

function test_generate_sidebar() {
	local test_description=$1
	local expected=$2
	local selected_category=$3
	local expected_file=$4
	local pokemon_categories=( "${@:5}" )

	local actual
	local actual_file="${TEST_DATA}/generate_sidebar/actual"

	generate_sidebar "$selected_category" "${pokemon_categories[@]}" > $actual_file
	diff $expected_file $actual_file &> /dev/null
	actual=$?

	local test_result=$( verify_expectations "$actual" "$expected" )
	append_test_case $test_result "generate_sidebar|$test_description|$inputs|$expected|$actual"
}

function test_cases_generate_sidebar() {
	local pokemon_categories=( fairy grass poison )
	local test_description="should generate the sidebar"
	local expected=0
	local selected_category="all"
    local expected_file="${TEST_DATA}/generate_sidebar/expected"

	test_generate_sidebar "${test_description}" "${expected}" "${selected_category}" "${expected_file}" "${pokemon_categories[@]}"

    pokemon_categories=( all fairy grass )
	test_description="should generate the sidebar with selected category"
	expected=0
	selected_category="all"
    expected_file="${TEST_DATA}/generate_sidebar/expected2"

	test_generate_sidebar "${test_description}" "${expected}" "${selected_category}" "${expected_file}" "${pokemon_categories[@]}"
}

function test_generate_pokemon_image() {
	local test_description=$1
	local expected=$2
	local pokemon_name=$3

    local actual
	local actual_file="${TEST_DATA}/generate_pokemon_image/actual"
	local expected_file="${TEST_DATA}/generate_pokemon_image/expected"

	generate_pokemon_image "${pokemon_name}" > ${actual_file}
	diff $expected_file $actual_file &> /dev/null
	actual=$?

	local test_result=$( verify_expectations "$actual" "$expected" )
	append_test_case $test_result "generate_pokemon_image|$test_description|$inputs|$expected|$actual"

}

function test_cases_generate_pokemon_image() {
	local test_description="should generate the pokemon image html"
	local expected=0
	local pokemon_name="bulbasaur"
	test_generate_pokemon_image "${test_description}" "${expected}" "${pokemon_name}"
}

function test_generate_pokemon_types() {
	local test_description=$1
	local expected=$2
	local pokemon_types=(${@:3})

    local actual
	local actual_file="${TEST_DATA}/generate_pokemon_types/actual"
	local expected_file="${TEST_DATA}/generate_pokemon_types/expected"

	generate_pokemon_types "${pokemon_types[@]}" > ${actual_file}
	diff $expected_file $actual_file &> /dev/null
	actual=$?

	local test_result=$( verify_expectations "$actual" "$expected" )
    local inputs="${pokemon_types[*]}"
	append_test_case $test_result "generate_pokemon_types|$test_description|$inputs|$expected|$actual"

}

function test_cases_generate_pokemon_types() {
	local test_description="should generate the pokemon types html"
	local expected=0
	local pokemon_types=( grass poison )
	test_generate_pokemon_types "${test_description}" "${expected}" "${pokemon_types[@]}"
}

function test_generate_pokemon_stats() {
	local test_description=$1
	local expected=$2
	local pokemon_stats=(${@:3})

    local actual
	local actual_file="${TEST_DATA}/generate_pokemon_stats/actual"
	local expected_file="${TEST_DATA}/generate_pokemon_stats/expected"

	generate_pokemon_stats "${pokemon_stats[@]}" > ${actual_file}
	diff $expected_file $actual_file &> /dev/null
	actual=$?

	local test_result=$( verify_expectations "$actual" "$expected" )
    local inputs="${pokemon_stats[*]}"
	append_test_case $test_result "generate_pokemon_stats|$test_description|$inputs|$expected|$actual"

}

function test_cases_generate_pokemon_stats() {
	local test_description="should generate the pokemon stats html"
	local expected=0
	local pokemon_stats=( 45 45 64 49 49 69 )
	test_generate_pokemon_stats "${test_description}" "${expected}" "${pokemon_stats[@]}"
}


function test_generate_pokemon_card() {
	local test_description=$1
	local expected=$2
	local pokemon_details=$3

    local actual
	local actual_file="${TEST_DATA}/generate_pokemon_card/actual"
	local expected_file="${TEST_DATA}/generate_pokemon_card/expected"

	generate_pokemon_card "${pokemon_details}" > ${actual_file}
	diff $expected_file $actual_file &> /dev/null
	actual=$?

	local test_result=$( verify_expectations "$actual" "$expected" )
	append_test_case $test_result "generate_pokemon_card|$test_description|$inputs|$expected|$actual"

}

function test_cases_generate_pokemon_card() {
	local test_description="should generate the pokemon card html"
	local expected=0
	local pokemon_details="1|bulbasaur|grass,poison|45|45|64|49|49|69"
	test_generate_pokemon_card "${test_description}" "${expected}" "${pokemon_details}"
}

function test_generate_pokemon_cards() {
	local test_description=$1
	local expected=$2
	local pokemon_data=("${@:3}")

	local actual

	local actual_file="${TEST_DATA}/generate_pokemon_cards/actual"
	local expected_file="${TEST_DATA}/generate_pokemon_cards/expected"

	generate_pokemon_cards "${pokemon_data[@]}" > ${actual_file}
	diff $expected_file $actual_file &> /dev/null
	actual=$?

	local test_result=$( verify_expectations "$actual" "$expected" )
	append_test_case $test_result "generate_pokemon_cards|$test_description|$inputs|$expected|$actual"
}

function test_cases_generate_pokemon_cards() {
	local test_description="should generate the pokemon cards html"
	local expected=0
	local pokemon_data=("1|bulbasaur|grass,poison|45|45|64|49|49|69" "2|ivysaur|grass,poison|60|60|142|62|63|130")
	test_generate_pokemon_cards "${test_description}" "${expected}" "${pokemon_data[@]}"
}

function test_generate_html_page() {
	local test_description=$1
	local expected=$2
	local html_template=$3
    local selected_category=$4
    local categories=($5)
	local pokemon_data=( "${@:6}" )

    local actual_file="${TEST_DATA}/generate_html_page/actual"
    local expected_file="${TEST_DATA}/generate_html_page/expected"

	generate_html_page "${html_template}" "${selected_category}" "${categories[*]}" "${pokemon_data[@]}" > ${actual_file}

	local actual
    diff ${expected_file} ${actual_file}
 	actual=$?

	local test_result=$( verify_expectations "$actual" "$expected" )
	append_test_case $test_result "generate_html_page|$test_description|$inputs|$expected|$actual"
}

function test_cases_generate_html_page() {
	local test_description="should generate the html page"
	local expected=0
	local html_template=$( cat ${RESOURCES_DIR}/template.html )
	local pokemon_data=("1|bulbasaur|grass,poison|45|45|64|49|49|69" "2|ivysaur|grass,poison|60|60|142|62|63|130")
    local selected_category="grass"
    local categories=(all grass poison)
	test_generate_html_page "${test_description}" "${expected}" "${html_template}" "${selected_category}" "${categories[*]}"  "${pokemon_data[@]}"
}
function test_generate_html_pages() {
	local test_description=$1
	local expected=$2
	local html_template=$3
	local build_dir=$4
	local pokemon_data=( "${@:5}" )

	local categories=(all grass)
	local actual=0
	local diff_exit_status
	generate_html_pages "${html_template}" ${build_dir} "${pokemon_data[@]}" > /dev/null

	for category in ${categories[@]}
	do
		diff ${TEST_DATA}/generate_html_pages/expected_build/${category}.html ${build_dir}/${category}.html
		diff_exit_status=$?
		actual=$(( ${actual} + ${diff_exit_status} ))
	done

	local test_result=$( verify_expectations "$actual" "$expected" )
	append_test_case $test_result "generate_html_pages|$test_description|$inputs|$expected|$actual"
}

function test_cases_generate_html_pages() {
	local test_description="should generate the html pages"
	local expected=0
	local html_template=$( cat "${RESOURCES_DIR}/template.html" )
	local build_dir="${TEST_DATA}/generate_html_pages/actual_build"
	local pokemon_data=("1|bulbasaur|grass,poison|45|45|64|49|49|69" "2|ivysaur|grass,poison|60|60|142|62|63|130")
	test_generate_html_pages "${test_description}" "${expected}" "${html_template}" "${build_dir}" "${pokemon_data[@]}"
}

function run_all_tests() {
	test_cases_get_categories
    test_cases_filter_pokemons
	test_cases_get_field
	test_cases_generate_sidebar
	test_cases_create_html
    test_cases_generate_pokemon_image
    test_cases_generate_pokemon_types
    test_cases_generate_pokemon_stats
    test_cases_generate_pokemon_card
	test_cases_generate_pokemon_cards
	test_cases_generate_html_page
	test_cases_generate_html_pages
}

function test_library() {
	run_all_tests
	
	OLDIFS=${IFS}
	IFS=$'\n'
	local tests=($(get_tests))
	IFS=${OLDIFS}
	
	generate_report "${tests[@]}"
}