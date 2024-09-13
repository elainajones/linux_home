#! /usr/bin/env bash

is_online() {
    declare host="$1";
    declare port="$2";
    declare args="$3";

    args+=" -4 -d -z -w 1";
    nc $args $host $port &> /dev/null;
    if [[ $? == 0 ]]; then
        return 0;
    fi

    return 1;
}

parse_toml() {
    declare config_path=$1;
    declare -gA CONFIG=();
    # Filter out comments so they aren't interpreted.
    declare lines="$(grep -oP "^[^#].+" $config_path)";
    # Match everything between `[` and `]` as table headers.
    declare headers=($(grep -oP "(?<=^\[)\S+?(?=\])" $config_path));
    for i in $(seq ${#headers[@]}); do
        h="${headers[$((i-1))]}";
        next="${headers[$i]}";
        # Use headers to match individual tables.
        #declare table=$(echo $lines | grep -oP "\[$h(\n|.)+?(?=(\[|\Z))");
        declare table="$(echo "$lines" | \
            tr "\n" " " | \
            grep -oP "\[$h\].+?(?=(\[$next\]|\Z))" \
        )";
        # Match strings on the left of `=` sign as variables.
        declare keys=($(\
            echo "$table" | \
            tr "\n" " " | \
            grep -oP "\S+\s?(?==)" | \
            grep -oP "\S.*" | grep -oP ".*\S" \
        ));
        # Iterate through table string, matching everything between
        # key and following key as key value.
        for i in $(seq 1 ${#keys[@]}); do
            declare key="${keys[$((i-1))]}";
            # 1. Use variable keys to match everything up to the next
            #    variable key as the variable value.
            # 2. Match everything to the right of the `=` sign.
            # 3. Remove leading/trailing whitespace.
	        # 4. Remove quotes from strings conditionally.
            declare val="$(\
                echo "$table" | \
                tr "\n" " " | \
                grep -oP "(?<=${key})\s?=.+?(?=${keys[$i]}(\s?=|\Z))" | \
                grep -oP "(?<==).+" | \
                grep -oP "\S.*" | grep -oP ".*\S" | \
                grep -oP "(?<=\"|\'|\b).+(?=\"|\'|\b)" \
            )";

            # Remove quotes from header names.
            # Due to limitations of data types in bash (of which this script)
            # is already exploiting, all tablenames are strings anyway.
            h="$(echo "$h" | tr -d "\"\'")"
            if ! [[ "$val" ]]; then
                # Don't save undefined variables.
                continue;
            elif [[ "${CONFIG[$h]}" ]]; then
                # Append key if key list is not empty.
                CONFIG["$h"]+=" ${key}";
            else
                # Write key list with first key.
                CONFIG["$h"]="$key";
            fi
            # Define `header.key=value` keypairs.
            CONFIG["${h}.${key}"]="$val";
        done
    done
}
