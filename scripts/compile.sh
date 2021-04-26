#!/usr/bin/env bash

CURRENT_PATH=$(pwd)

mkdir -p "$CURRENT_PATH/public"

# $1 - path to project
# $2 - outputted folder name
# $3 - folder name to store the documentation in
# $4 - npm task for generating documentation
function generate_and_copy() {
    if [[ ! -d "$1" ]]; then
        echo "ERROR: Could not find directory for $3."
        echo "ERROR: Expected $3 to be located at $1 in $2"
    fi

    cd "$1"

    npm run $4

    rm -rf "$CURRENT_PATH/public/$3"
    mv "$2" "$CURRENT_PATH/public/$3"

    cd "$CURRENT_PATH"
}

generate_and_copy "../sdk" "docs" "sdk" "docs"
generate_and_copy "../server" "docs" "server" "docs"
generate_and_copy "../server" "docs-api" "api" "docs:api"
generate_and_copy "../mobile" "docs" "mobile" "docs"

# Insomnia documenter expects the config to be located at
# the root of the webserver.
mv "$CURRENT_PATH/public/api/insomnia.json" "$CURRENT_PATH/public/insomnia.json"

cp "$CURRENT_PATH/static/index.html" "$CURRENT_PATH/public/index.html"
