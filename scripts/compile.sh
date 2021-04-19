#!/usr/bin/env bash

CURRENT_PATH=$(pwd)

mkdir -p "$CURRENT_PATH/public"

# $1 - path to project
# $2 - folder name to store the documentation in
function generate_and_copy() {
    if [[ ! -d "$1" ]]; then
        echo "ERROR: Could not find directory for $2."
        echo "ERROR: Expected $2 to be located at $1"
    fi

    cd "$1"

    npm run docs

    rm -rf "$CURRENT_PATH/public/$2"
    mv docs/ "$CURRENT_PATH/public/$2"

    cd "$CURRENT_PATH"
}

generate_and_copy "../sdk" "sdk"
generate_and_copy "../server" "server"

cp "$CURRENT_PATH/static/index.html" "$CURRENT_PATH/public/index.html"
