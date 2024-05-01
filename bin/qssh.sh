#! /bin/bash

#[example]
##Minimum configs
#hostname = '10.23.0.123'
#user = 'foo'
#password = 'foobar'
#note = 'Example connection'
#
## Optional to override defauls / set extended behavior
#
## SSH port number
#port = 22
## For externam connections
#use_proxy = true
## Use existing ssh config like `ssh <host>`
#ssh_config = 'example'
## Also check rdp port status to inform if booted to Windows (we assume)
#dual_boot = true
## Optional way to disable the config (you can also commend the block)
#enabled = false
## Optional args for ssh
#options = '-c aes<t_co>-cbc'

parse_toml() {
    declare config_path=$1;
    declare -gA CONFIG=();
    declare -g HEADERS=();
    # Filter out comments so they aren't interpreted.
    declare lines="$(grep -oP "^[^#].+" $config_path)";
    # Match everything between `[` and `]` as table headers.
    declare headers=($(grep -oP "(?<=^\[)\S+?(?=\])" $config_path));
    for i in $(seq ${#headers[@]}); do
        h="${headers[$((i-1))]}";
        HEADERS+=($h);
        next="${headers[$i]}";
        # Use headers to match individual tables.
        #declare table=$(echo $lines | grep -oP "\[$h(\n|.)+?(?=(\[|\Z))");
        if [[ "$next" ]]; then
            declare table="$(echo "$lines" | \
                tr "\n" " " | \
                grep -oP "\[$h(\n|.)+?(?=(\[$next|\Z))")";
        else
            declare table="$(echo "$lines" | \
                tr "\n" " " | \
                grep -oP "\[$h(\n|.)+?(?=(\Z))")";
        fi
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

require_val() {
    declare key="$1";
    declare val="$2";
    if ! [[ "$val" ]]; then
        echo "Option '$key' requires an argument";
        echo "Try '--help' for more information.";
        exit 1;
    fi
}

parse_args() {
    args="$@";
    declare -Ag ARGS=();
    declare keys=($(echo $args | grep -oP "\B\-\S+"));
    for i in $(seq 1 ${#keys[@]}); do
        declare key="${keys[$((i-1))]}";
        # 1. Use variable keys to match everything up to the next 
        #    variable key as the variable value.
        # 2. Remove leading/trailing whitespace.
        declare val="$(\
            echo $args | \
            grep -oP "(?<=$key\s).+?(?=${keys[$i]}(\s|\Z))" | \
            grep -oP "\S.*" | grep -oP ".*\S" \
        )";
        ARGS["$key"]="$val";
    done
}

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

pad_var() {
	declare var="$1";
	declare -i padding=$2;

	declare var_len=($(echo "$var" | grep -o "."));
	for i in $(seq ${#var_len[@]} $padding); do
		var+=" ";
	done

	printf "$var";
}

print_connections() {
    declare connections="";
    
    # Color formatting for output
    RED='\033[0;31m';
    GREEN='\033[0;32m';
    NC='\033[0m'; # No color

    connections+="#"`
        `"\t$(pad_var "NAME" 20)"`
        `"\t$(pad_var "HOST" 15)"`
        `"\t$(pad_var "NOTE" 24)"`
        `"\t$(pad_var "OS" 7)"`
        `"\t$(pad_var "STATUS" 7)\n";

    connections+=""`
        `"------------------------------------------------------------"`
        `"----------------------------------------------------\n";

    for i in ${!HEADERS[@]}; do
        h=${HEADERS[$i]};
        
        declare enabled="${CONFIG["${h}.enabled"]}";
        declare dual_boot="${CONFIG["${h}.dual_boot"]}";
        declare port="${CONFIG["${h}.port"]}";
        declare host="${CONFIG["${h}.hostname"]}";
        declare user="${CONFIG["${h}.user"]}";
        declare note="${CONFIG["${h}.note"]}";
        declare use_proxy="${CONFIG["${h}.use_proxy"]}";

        # Set defaults
        [[ "$enabled" ]] || enabled=true;
        [[ "$dual_boot" ]] || dual_boot=false;
        [[ "$port" ]] || port=22;
        [[ "$use_proxy" ]] || use_proxy=false;

        nc_args="";
        nc_status="${RED}OFFLINE${NC}";
        os="";

        if ! ( $enabled ); then
            continue;
        elif ( $use_proxy ); then
            proxy="-X connect -x $HTTP_PROXY";
            nc_args+="$proxy";
        fi

        if ( is_online "$host" "$port" "$nc_args" ); then
            os="Linux";
            nc_status="${GREEN}ONLINE${NC}";
        fi
        if ( $dual_boot ); then
            if ( is_online "$host" "3389" "$nc_args" ); then
                os="Windows";
                nc_status="${GREEN}ONLINE${NC}";
            fi
        fi

        h="$(pad_var "$h" 20)";
        host="$(pad_var "$host" 15)";
        note="$(pad_var "$note" 24)";
        os="$(pad_var "$os" 7)";
        nc_status="$(pad_var "$nc_status" 7)";

        connections+="$i\t$h\t$host\t$note\t$os\t$nc_status\n";
    done         

    printf "$connections";
}

print_help() {
    lines=(\
        "Usage: qssh [OPTION] SHORTCUT" \
        "" \
        "  qssh - ssh monitoring dashboard." \
        "" \
        "Options:" \
        "  -h, --help\tShow this message and exit." \
        "  -m INTERVAL\tEnable monitoring mode." \
    );

    for i in ${!lines[@]}; do
        line=${lines[$i]};
        printf "$line\n";
    done
}

main() {
    declare args="$@";
    declare arg_count=($@);
    declare arg_count=${#arg_count[@]};

    # Declare vars and define default values.
    declare config_path=~/bin/qssh.toml;
    declare mon=false;
    declare mon_int=30;

    parse_args $args;
    parse_toml $config_path;

    for key in "${!ARGS[@]}"; do
        val="${ARGS[$key]}";
        case $key in
            "-m")
                mon=true;
                if [[ "$val" ]]; then
                    mon_int=$val;
                fi
                declare connections="$(print_connections \
                    "$config_path" &)";
                printf "$connections";
                while true; do
                    declare connections="$(print_connections \
                        "$config_path" &)";
                    sleep $((mon_int/2));
                    clear;
                    printf "$connections";
                    sleep $((mon_int/2));
                done
                ;;
            "-h")
                print_help;
                #TODO: (if sourced)
                #break;
                exit 0;
                ;;
            "--help")
                print_help;
                #TODO: (if sourced)
                #break;
                exit 0;
                ;;
            *)
                echo "Invalid option '$key'";
                echo "Try '--help' for more information.";
                #TODO: (if sourced)
                #break;
                exit 1;
                ;;
        esac
    done

    if ! [[ "${!ARGS[@]}" ]]; then
        if [[ $arg_count -eq 0 ]]; then
            print_connections "$config_path";
        else
            if ( $(echo "${!HEADERS[@]}" | grep -qs "$@") ); then
                h=${HEADERS["$@"]};
                ssh_args="-o StrictHostKeyChecking=accept-new";

                declare port="${CONFIG["${h}.port"]}";
                declare host="${CONFIG["${h}.hostname"]}";
                declare user="${CONFIG["${h}.user"]}";
                declare password="${CONFIG["${h}.password"]}";

                # Set defaults
                [[ "$port" ]] || port=22;
                ssh_args+=" ${CONFIG["${h}.options"]}";

                if [[ "${CONFIG["$h.ssh_config"]}" ]]; then
                    host=${CONFIG["$h.ssh_config"]};
                    ssh $host;
                else
                    sshpass -f <(printf '%s\n' $password) \
                        ssh ${ssh_args} ${user}@${host};
                fi
            else
                echo "No such shortcut '$@'";
            fi
        fi
    fi
}

main $@;
