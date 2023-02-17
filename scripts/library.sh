#! /bin/bash

source scripts/helpers.sh

NOT_FOUND=4

function generate_sidebar() {
    local selected_category=$1
    local categories=( "${@:2}" )

    local categories_list=()

    local category
    for category in ${categories[@]}
    do
        local category_classes="pokemon-category"
        if [[ $category == $selected_category ]]
        then
            category_classes="pokemon-category ${selected_category} selected"
        fi

        local anchor=$( anchor "${category}.html" "${category}" "${category_classes}" )
        local li=$( create_html "li" "${anchor}" )
        categories_list[${#categories_list[@]}]="$li"
    done

    create_html "ul" "${categories_list[*]}"
}

function generate_pokemon_image() {
    local pokemon_name=$1

    local img_path="images/${pokemon_name}.png"
    local img_element="$(img "${img_path}" "${pokemon_name}")"

    create_html "div" "${img_element}" "class='pokemon-image'"
}

function generate_pokemon_types() {
    local types=("${@}")

    local type_list=()
    local type
    for type in ${types[@]}
    do
        local type_html=$( create_html "div" "${type}" "class='${type}'" )
        type_list[${#type_list[@]}]=${type_html}
    done

    create_html "div" "${type_list[*]}" "class='pokemon-types'"
}

function generate_pokemon_stats() {
    local stats=("${@}")

    local stats_labels=("Speed" "HP" "Base XP" "Attack" "Defense" "Weight")

    local stats_rows=()

    local index=0
    while [[ $index -lt ${#stats[@]} ]]
    do
        local stat_columns="<td>${stats_labels[$index]}</td>"
        stat_columns+="<td>${stats[$index]}</td>"

        local stat_row=$( create_html "tr" "${stat_columns}" )
        stats_rows[${#stats_rows[@]}]=${stat_row}
        index=$(( $index + 1 ))
    done

    local tbody=$( create_html "tbody" "${stats_rows[*]}" )
    create_html "table" "${tbody}" "class='pokemon-stats'"
}

function generate_pokemon_card() {
    local pokemon_details=$1

    local pokemon_id=$( get_pokemon_id "${pokemon_details}" )
    local pokemon_name=$( get_pokemon_name "${pokemon_details}" )
    local pokemon_types=($( get_pokemon_types "${pokemon_details}" ))
    local pokemon_stats=($( get_pokemon_stats "${pokemon_details}" ))
    
    local image_html=$( generate_pokemon_image "${pokemon_name}" )
    local types_html=$( generate_pokemon_types "${pokemon_types[@]}" )
    local stats_html=$(generate_pokemon_stats "${pokemon_stats[@]}")

    local h1=$( create_html "h1" "${pokemon_name}" "class='pokemon-name'" )
    local header_contents="${h1}${types_html}"
    local header=$( create_html "header" "${header_contents}" )

    local section=$( create_html "section" "${header}${stats_html}" "class='pokemon-card-details'" )

    local attributes="id='${pokemon_id}' class='pokemon-card'"
    create_html "article" "${image_html}${section}" "${attributes}"
}

function generate_pokemon_cards() {
    local pokemons=("${@}")

    local pokemon_cards=()
    local pokemon_detail
    for pokemon_detail in ${pokemons[@]}
    do
       generate_pokemon_card "${pokemon_detail}" 
    done
}

function generate_html_page() {
    local template=$1
    local selected_category=$2
    local categories=($3)
    local pokemons=("${@:4}")
    
    local sidebar=$(generate_sidebar "${selected_category}" "${categories[@]}")
    local pokemon_cards=$( generate_pokemon_cards "${pokemons[@]}" )

    sed "s:__SIDEBAR__:${sidebar}:;
         s:__POKEMON_CARDS__:${pokemon_cards}:
         " <<< $template
}

function generate_html_pages() {
    local template=$1
    local target_dir=$2
    local pokemons=("${@:3}")

    local categories=( all $( get_categories "${pokemons[@]}"))
    
    local category
    for category in ${categories[@]}
    do  
        echo "${category}.html"
        local dest_file="${target_dir}/${category}.html"
        local filtered_pokemons=(${pokemons[@]})

        if [[ $category != "all" ]]; then
            filtered_pokemons=($( filter_pokemons "${category}" "${pokemons[@]}" ))
        fi

        generate_html_page "${template}" "${category}" "${categories[*]}" "${filtered_pokemons[@]}" > "${dest_file}"
    done
}

function setup_target_dir() {
    local target_dir=$1
    local resources_dir=$2

    rm -rf ${target_dir} 2> /dev/null
   
    echo "Creating html directory"
    mkdir ${target_dir}

    echo "Copying styles and images"
    cp ${resources_dir}/style.css ${target_dir}/
    cp -r ${resources_dir}/images ${target_dir}/
}

function main() {
    local file_path=$1
    local resources_dir=$2
    local target_dir=$3

    if [[ ! -f ${file_path} ]]; then
        echo "Error : Pokemon data file not found"
        exit ${NOT_FOUND}
    fi

    local template=$( cat ${resources_dir}/template.html )
    local pokemons=( $(tail -n+2 "${file_path}" 2> /dev/null) )
    
    setup_target_dir ${target_dir} ${resources_dir}

    echo "Generating HTML files"
    generate_html_pages "${template}" "${target_dir}" "${pokemons[@]}"
}