#! /bin/bash
#
#
# NAME
#       qcd - quickly cd
#
# SYNOPSIS
#       qcd [OPTION] SHORTCUT
#
# DESCRIPTION
#       Bash utility for saving directory paths for corresponding
#       directory shortcut names. The directory shortcut names are
#       used in place of the full paths for a more convenient method
#       of navigating to frequently used directories.
#
#       -h      print help and exit
#       -a      add shortcut for current dir
#       -d	    delete shortcut
#
# AUTHOR
#       Written by Elaina Jones
#
# You will need to source this file for it to work properly since
# directory changes otherwise occur in a subshell rather than taking
# effect in the current process. The use of inner functions are
# defined to avoid polluting global namespace.

qcd() {
    print_help() {
        lines=(\
            "Usage: qcd [OPTION] SHORTCUT" \
            "" \
            "  qcd - quickly cd using saved directory shortcuts." \
            "" \
            "Options:" \
            "  -h, --help\tShow this message and exit." \
            "  -a SHORTCUT\tAdd shortcut for current directory." \
            "  -d SHORTCUT\tDelete shortcut." \
            "  --update\tNEW! Updates legacy data file to TOML." \
        );

        for i in ${!lines[@]}; do
            line=${lines[$i]};
            printf "$line\n";
        done
    }
    require_val() {
        declare key="$1";
        declare val="$2";
        if ! [[ "$val" ]]; then
            echo "Option '$key' requires an argument";
            echo "Try '--help' for more information.";
            return 1;
        fi
        return 0
    }
    parse_args() {
        args="$@";
        declare -gA ARGS=();
        declare keys=($(echo $args | grep -oP "\B\-\S+"));
        for i in $(seq 1 ${#keys[@]}); do
            declare key="${keys[$((i-1))]}";
            # 1. Use variable keys to match everything up to the next
            #    variable key as the variable value.
            # 2. Remove leading/trailing whitespace.
            #TODO: var is only first arg after key. Fine for most cases.
            if [[ "${keys[$i]}" ]]; then
                declare val="$(\
                    echo $args | \
                    grep -oP "(?<=$key\s).+?(?=${keys[$i]}\s)" | \
                    grep -oP "\S.*" | grep -oP ".*\S" \
                )";
            else
                declare val="$(\
                    echo $args | \
                    grep -oP "(?<=$key\s).+?(?=\Z)" | \
                    grep -oP "\S.*" | grep -oP ".*\S" \
                )";
            fi
            ARGS["$key"]="$val";
        done
    }
    parse_toml() {
        declare config_path=$1;
        declare -gA CONFIG=();
        declare -g CONFIG_HEADERS=();
        # Filter out comments so they aren't interpreted.
        declare lines="$(grep -oP "^[^#].+" $config_path)";
        # Match everything between `[` and `]` as table headers.
        declare headers=($(grep -oP "(?<=^\[)\S+?(?=\])" $config_path));
        for i in $(seq ${#headers[@]}); do
            h="${headers[$((i-1))]}";
            CONFIG_HEADERS+=("$(echo "$h" | tr -d "\"\'")");
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
    parse_toml_table() {
        return 0
    }
    print_shortcuts() {
        if [[ ${#CONFIG[@]} -eq 0 ]]; then
            echo "No saved directories";
        else
            for h in ${CONFIG_HEADERS[@]}; do
                val="${CONFIG["${h}.path"]}";
                printf "$h\t$val\n";
            done
        fi
    }
    read_config() {
        declare config_path=$1;
        if [[ -f $config_path ]]; then
            parse_toml $config_path;
        fi
    }
    write_config() {
        # Clear the config.
        printf "" > $config_path;
        declare config_path=$1;
        for h in ${CONFIG_HEADERS[@]}; do
            # Write table header
            echo "[$h]" >> $config_path
            for key in ${CONFIG["$h"]}; do
                val="${CONFIG["${h}.${key}"]}";
                # Write key = val
                echo "${key} = \"$val\"" >> $config_path;
            done
            # Add newline to space tables.
            printf "\n" >> $config_path;
        done
    }
    # Adds shortcut for current directory to cd_shortcuts.
    add_shortcut() {
        declare shortcut="$1";
        # Don't overwrite existing shortcuts
        if [[ "$shortcut" ]]; then
            if ! [[ "${CONFIG[$shortcut]}" ]]; then
                CONFIG["$shortcut"]="path run_after run_before";
                CONFIG["${shortcut}.path"]="$PWD";
                CONFIG["${key}.run_after"]="";
                CONFIG["${key}.run_before"]="";
                echo "Added '$shortcut'";
            else
                echo "Shortcut already exists";
            fi
        fi
    }
    delete_shortcut() {
        declare shortcut="$1";
        if [[ "${CONFIG["$shortcut"]}" ]]; then
            for key in ${CONFIG["$shortcut"]}; do
                unset CONFIG["${shortcut}.${key}"];
            done
            unset CONFIG["$shortcut"];
            echo "Deleted '$shortcut'";
        else
            echo "No such shortcut";
        fi
    }
    update_config() {
        declare config_path=~/bin/qcd.dat;
        if [[ -f $config_path ]]; then
            declare -gA CONFIG=();
            declare -g CONFIG_HEADERS=();
            source $config_path;
        fi
        for key in ${!CONFIG[@]}; do
            CONFIG_HEADERS+=("$key")
            val="${CONFIG["$key"]}";
            echo "$val"
            unset CONFIG["$key"];
            CONFIG["$key"]='path run_after run_before';
            CONFIG["${key}.path"]="$val";
            CONFIG["${key}.run_after"]="";
            CONFIG["${key}.run_before"]="";
        done
    }

    parse_args "$@";
    declare arg_count=($@);
    declare arg_count=${#arg_count[@]};

    declare config_path=~/bin/qcd.toml;
    mkdir -p $(dirname $config_path);
    read_config $config_path;

    for key in "${!ARGS[@]}"; do
        val="${ARGS[$key]}";
        case $key in
            "--update")
                update_config;
                write_config $config_path;
                break;
                ;;
            "-a")
                require_val "$key" "$val";
                add_shortcut "$val";
                write_config $config_path;
                break;
                ;;
            "-d")
                require_val "$key" "$val";
                delete_shortcut "$val";
                write_config $config_path;
                break;
                ;;
            "-h")
                print_help;
                break;
                ;;
            "--help")
                print_help;
                break;
                ;;
            *)
                echo "Invalid option '$key'";
                echo "Try '--help' for more information.";
                break;
        esac
    done

    if ! [[ "${!ARGS[@]}" ]]; then
        if [[ $arg_count -eq 0 ]]; then
            print_shortcuts;
        else
            if [[ "${CONFIG["$@"]}" ]]; then
                dir_name="${CONFIG["$@"]}";
                if [[ -d "$dir_name" ]]; then
                    cd "$dir_name";
                else
                    echo "Directory moved or missing";
                fi
            else
                echo "No such shortcut '$@'";
            fi
        fi
    fi
}

