#! /bin/bash

source scripts/library.sh

DATA_FILE="data/pokemon.csv"
#DATA_FILE="data/pokemon_big.csv"
RESOURCES_DIR="resources"
TARGET_DIR="html"

main "${DATA_FILE}" "${RESOURCES_DIR}" "${TARGET_DIR}" 
open ${TARGET_DIR}/all.html
