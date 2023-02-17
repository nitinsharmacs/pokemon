#! /bin/bash

function get_categories() {
    local pokemon_data=("${@}")

    local categories_field=$( echo "${pokemon_data[@]}" | tr " " "\n" | cut -f3 -d"|" )
    local categories=($( echo "${categories_field}" | tr "," "\n" | sort | uniq | tr "\n" " " ))

    echo "${categories[@]}"
}

function filter_pokemons() {
    local selected_category=$1
    local pokemon_data=(${@:2})

    local filtered_data=$( echo "${pokemon_data[@]}" | tr " " "\n" | grep "^.*|.*|.*${selected_category}.*|")

    echo "${filtered_data}"
}

function create_html() {
    local tag=$1
    local content=$2
    local attribute=$3
    echo -n "<$tag ${attribute}>$content</$tag>"
}

function img() {
    local image=$1
    local img_name=$2

    echo -n "<img src='${image}' alt='${img_name}' title='${img_name}'/>"
}

function anchor() {
    local href=$1
    local content=$2
    local classes=$3

    echo -n "<a href='${href}' class='${classes}'>${content}</a>"
}

function get_field() {
    local field=$1
    local pokemon_details=$2

    cut -f${field} -d"|" <<< ${pokemon_details}
}

function get_pokemon_id() {
    local pokemon_details=$1

    get_field 1 "${pokemon_details}"
}

function get_pokemon_name() {
    local pokemon_details=$1
    
    get_field 2 "${pokemon_details}"
}

function get_pokemon_types() {
    local pokemon_details=$1

    get_field 3 "${pokemon_details}" | tr "," " "
}

function get_pokemon_stats() {
    local pokemon_details=$1

    get_field "4-" "${pokemon_details}"  | tr "|" " " 
}