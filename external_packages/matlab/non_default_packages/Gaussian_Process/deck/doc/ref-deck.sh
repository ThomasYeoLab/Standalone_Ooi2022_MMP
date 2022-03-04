#!/bin/bash
#
# Print function reference for module +dk
#

iscmd() { 
    [ -n "$(which "$1" 2>/dev/null)" ] && echo 1
}
header() {
    echo -e "\n$1\n--------------------------------------------------\n"
}
listdir() {
    local target=$1
    shift 1
    echo "$(basename "$target")/"
    ./lsfiles -d "$target" -C 20 -L 80 --prefix '    ' "$@"
    echo ''
}
listfiles() {
    local target=$1
    shift 1
    echo "$(basename "$target")/"
    ./lsfiles -C 20 -L 80 --prefix '    ' "$@"
    echo ''
}
addext() {
    for f in "$@"; do
        echo "${f}.m"
    done
}

# ------------------------------------------------------------------------

dkctn=($(addext c2s s2c unwrap wrap))
dkfun=($(addext call deal forward kvfun mapfun pass reduce swap))
dklog=($(addext assert debug disp info log reject verb warn))
dksys=($(addext here path))

dkrem=( "${dkctn[@]}" "${dkfun[@]}" "${dklog[@]}" "${dksys[@]}" )

# ------------------------------------------------------------------------

header "STRUCTURE"

    tree ../+dk -L 1 --dirsfirst

header "GENERAL UTILITIES"
    listdir ../+dk -x README.md realpath "${dkrem[@]}"
    listdir ../+dk/+util -x README.md

header "FUNCTIONAL PROGRAMMING"
    listfiles +dk -f "${dkfun[@]}"
    listdir ../+dk/+bsx -x README.md

header "STRUCT, CELL, STRING"
    listfiles +dk -f "${dkctn[@]}"
    listdir ../+dk/+str -x README.md
    listdir ../+dk/+struct -x README.md

header "ASSERTION, LOGGING"
    listfiles +dk -f "${dklog[@]}"
    listdir ../+dk/+is -x README.md
    listdir ../+dk/+logger -x README.md

header "SYSTEM, PATH, FILE"
    listfiles +dk -f "${dksys[@]}"
    listdir ../+dk/+env -x README.md
    listdir ../+dk/+fs -x README.md

header "FIGURE, COLOUR, UI"
    listdir ../+dk/+cmap -x README.md
    listdir ../+dk/+color -x README.md
    listdir ../+dk/+fig -x README.md
    listdir ../+dk/+screen -x README.md
    listdir ../+dk/+ui -x README.md
    listdir ../+dk/+widget -x README.md

header "NUMERICS"
    listdir ../+dk/+num -x README.md

header "TIME AND DATE"
    listdir ../+dk/+time -x README.md

header "OTHER"
    listdir ../+dk/+ds -x README.md
    listdir ../+dk/+obj -x README.md
    listdir ../+dk/+json -x README.md
