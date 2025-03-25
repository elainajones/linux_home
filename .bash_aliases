if [[ -f ~/bin/qcd-SOURCEME.sh ]]; then
    source ~/bin/qcd-SOURCEME.sh;
fi

alias c='clear'
alias la='ls -AX --color --classify --group-directories-first'
alias lla='ls -lAshLX --color --classify --group-directories-first'
alias les='less -~KMQR-'
alias lsd='ls -d */'

alias sba='source ~/.bash_aliases; exec bash'
alias vba='vim ~/.bash_aliases'
alias vsc='vim ~/.ssh/config'

alias rkh='ssh-keygen -R'

alias gpge='gpg --armour -e'

# (un)mount mtp devices (ie Android)
alias mmtp='jmtpfs ~/mtp && echo Device mounted at ~/mtp/ && thunar ~/mtp/'
alias ummtp='fusermount -u ~/mtp/'

alias oprts='sudo netstat -ntupl'

alias ghist='history | grep'
alias gba='grep -P "^alias" ~/.bash_aliases'

# Functions:
# grepin {{{
grepin() {
    declare pattern="$1";
    grep -Rinw "." -e "$pattern";
}
# }}}
# passgen {{{
passgen() {
    declare pw_len=${1:-20};
    # Extra presets for dumb char restrictions.
    declare -A profile=(\
        ["1"]="{}[]<>~_\\-\\\\/|:=+?" \
    );
    
    rm_chars="\n;,.\"\`\'";
    if [[ "$2" ]]; then
        rm_chars+="${profile[$2]}";
    fi

    # Lazy stack overflow magic
    # https://stackoverflow.com/questions/27799024
    pass=$(LC_CTYPE=C < /dev/urandom tr -cd [:graph:] |\
        tr -d "$rm_chars" | fold -w $pw_len | head -n 1);
    
    echo $pass | less;
}
# }}}
# cstash/cpop {{{
cstash() {
    path="$PWD/${1}";
    data="/home/$(whoami)/bin/cstash.dat";
    mkdir -p $(dirname $data) && touch $data;
    source $data;
    
    if ! [[ "$1" ]]; then
        true
    elif [[ -e "$path" ]]; then
        CSTASH+=("$path");

        printf "CSTASH=(\n" > $data;
        for i in ${!CSTASH[@]}; do
            path="${CSTASH[$i]}";
            printf "\t\"$path\"\n" >> $data;
        done
        printf ")" >> $data;

        echo "Stashed $path";
    fi
}
cpop() {
    declare data="/home/$(whoami)/bin/cstash.dat";
    mkdir -p $(dirname $data) && touch $data;
    source $data;

    if [[ ${#CSTASH[@]} > 0 ]]; then
        path="${CSTASH[-1]}";
        cp -rvp $path $PWD
        unset 'CSTASH[-1]';
        echo "${CSTASH[@]}"

        printf "CSTASH=(\n" > $data;
        for i in ${!CSTASH[@]}; do
            path="${CSTASH[$i]}";
            printf "\t\"$path\"\n" >> $data;
        done
        printf ")" >> $data;
    else
        echo "Stash is empty";
    fi
}
# }}}
# ovpn {{{
ovpn() {
    declare opt=$1;
    declare root_dir="/etc/openvpn/ovpn-locations";
    configs=($(ls $root_dir/*));

    if ! [[ "$opt" ]]; then
        for i in $(seq 0 $((${#configs[@]}-1))); do
            name=$(basename ${configs[$i]});
            printf "[$i]\t$name\n";
        done
    elif [[ "$(seq 0 $((${#configs[@]}-1)) | grep -wo $opt)" ]]; then
        sudo openvpn ${configs[$opt]};
    else
        echo "Invalid option"
    fi
}
# }}}
# doff {{{
doff() {
    declare opt=${1:-"-h"};

    if [[ "$opt" == "-h" ]]; then
    	echo "doff: used to power off block devices";
        echo "Usage: doff [/dev/sdX]";
        printf "\t-h\tPrint this help and exit.\n";
    elif [[ -b $opt ]]; then
        udisksctl power-off -b $opt;
    else
        echo "Invalid option";
    fi
    unset opt;
}
# }}}
# chrootm {{{
chrootm() {
    declare opt=${1:-"-h"};

    if [[ "$opt" = "-h" ]]; then
    	echo "chroot-mnt: used to mount the necessary filesystems for chroot";
        echo "Usage: cm [chroot root]";
        printf "\t-h\tPrint this help and exit.\n";
    elif [[ -d $opt ]]; then
        sudo mount --types proc /proc $opt/proc;
	    sudo mount --rbind /sys $opt/sys;
	    sudo mount --make-rslave $opt/sys;
	    sudo mount --rbind /dev $opt/dev;
	    sudo mount --make-rslave $opt/dev;
	    sudo mount --bind /run $opt/run;
	    sudo mount --make-slave $opt/run;
	    printf "Filesystems mounted.\n"
	    printf "Remember to source /etc/profile after chroot.\n"
    else
        printf "Invalid option\n";
    fi
    
    unset opt
}
# }}}
# remouse {{{
remouse() {
    # Dumb fix if the mouse broke after hibernation on Debian.
    # Keeping this just in case.
    sudo modprobe -r usbhid;
    sudo modprobe -r psmouse;
    sudo modprobe usbhid;
    sudo modprobe psmouse;
}
# }}}
# mcc {{{
mcc() {
    # I forgot how this works
    # TODO: Some sort of help?
    declare path_in=${1};
    declare old_hex=${2};
    declare new_hex=${3};
    declare path_out=${4:-$(pwd)};

    for i in $(ls $path_in);
    do
        convert $path_in/$f -alpha deactivate \
            -fuzz 0% -fill "#$new_hex" -opaque "#$old_hex" \
            -alpha activate $path_out/$i;
    done;
}
# }}}
# tres {{{
tres() {
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "Usage: tres [dir:-pwd] [depth:-2] [optional tree flag]"
    else
        tree -aFCthR ${3} --dirsfirst --du --filelimit 200 \
            -L ${2:-2} -I ".git|*.swp" ${1:-$pwd} | \
            less -~KMQR-;
    fi
}
#}}}
# lac {{{
lac() {
    declare -i total=$(la ${1:-$pwd} | wc -l);
    declare -i f_num=$(find ${1:-$pwd} -maxdepth 1 -type f | wc -l);
    declare -i dir_num=$(find ${1:-$pwd} -maxdepth 1 -type d | wc -l);

    echo "$dir_num director$(
        if (( DIRECTORY_COUNT != 1 )); then
            echo "ies"
        else
            echo "y"
        fi
    ), $f_num file$(
        if (( $f_num != 1 )); then
            echo "s"
        fi
    ), $total total";
}
# }}}
# md2pdf {{{
md2pdf() {
    pandoc "$1" \
        -f gfm \
        -V linkcolor:blue \
        -V geometry:a4paper \
        -V geometry:margin=2cm \
        -V mainfont="DejaVu Serif" \
        -V monofont="DejaVu Sans Mono" \
        --pdf-engine=xelatex \
        --highlight-style ~/bin/monochrome.theme \
        --include-in-header ~/bin/chapter-break.tex \
        --include-in-header ~/bin/inline-code.tex \
        --include-in-header ~/bin/bullet-list.tex \
        --css=github-pandoc.css \
        -o "$2"
}
# }}}

# WSL
#alias p='/mnt/c/Program\ Files/PowerShell/7/pwsh.exe'
#alias e='/mnt/c/Windows/explorer.exe .'
#alias npp='/mnt/c/Program\ Files/Notepad++/notepad++.exe'
#wmv() {
#    temp="$(mktemp -d -p /mnt/c/Users/v-elajones/AppData/Local/Temp/)";
#    cp -rpT $PWD $temp;
#    cd $temp;
#    qcd -d temp
#    qcd -a temp
#    p;
#}
