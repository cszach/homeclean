#!/bin/bash

# A function to compare semantic versions
#
# :param $1: The first version
# :param $2: The second version
# :return: 1 if the first version is greater than the second, 0 if they are
# the same, -1 if the first version is less than the second
function compare_semver() {
    a1=$(echo $1 | cut -d. -f1)
    a2=$(echo $1 | cut -d. -f2)
    a3=$(echo $1 | cut -d. -f3 | cut -d- -f1)
    a_stage=$(echo $1 | cut -d- -f2)

    b1=$(echo $2 | cut -d. -f1)
    b2=$(echo $2 | cut -d. -f2)
    b3=$(echo $2 | cut -d. -f3 | cut -d- -f1)
    b_stage=$(echo $2 | cut -d- -f2)

    [ "$a1" -gt "$b1" ] && return 1
    [ "$a1" -lt "$b1" ] && return -1

    [ "$a2" -gt "$b2" ] && return 1
    [ "$a2" -lt "$b2" ] && return -1

    [ "$a3" -gt "$b3" ] && return 1
    [ "$a3" -lt "$b3" ] && return -1

    # Stages: alpha < beta < rc < release
    # Luckily for us, this is also their lexical order

    [[ "$a_stage" < "$b_stage" ]] && return 1
    [[ "$a_stage" > "$b_stage" ]] && return -1

    return 0
}

function install() {
    DIR="$HOME/.local/bin"

    [ -f "$DIR/homeclean" ] && rm "$DIR/homeclean"
    cp homeclean "$DIR"
}

# If the first parameter is -h or --help, print the help message and exit
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [OPTION]"
    echo "Install homeclean to $HOME/.local/bin."
    echo
    echo "  -h, --help         display this help and exit"
    echo "      --force        ignore all warnings"
    exit 0
fi

FORCE=false

[ "$1" = "--force" ] && FORCE=true

# If homeclean is not found in this directory, exit
if [ ! -f homeclean ]; then
    echo "homeclean not found in this directory."
    exit 1
fi

[ -f "$HOME/.local/bin/homeclean" ] && CURRENT_VERSION=$( homeclean --version )
NEW_VERSION=$( ./homeclean --version )

# If the new version is at stage dev, warn the user
if [ "$( echo "$NEW_VERSION" | cut -d- -f2 )" == "dev" ]
then
    echo "Warning: You are installing a development version of homeclean."
    echo "This version may be unstable and may not work properly."

    [ $FORCE = false ] && \
        { echo "Use --force to install anyway."; exit 2; }

    echo "Installing homeclean $NEW_VERSION..."
    install
    echo "Done."
    exit 0
fi

# SHA256 HASHES OF VERSIONS

HASH_0_1_0_ALPHA="54ae91626b7092d8f4dd5feabd23321a82e369c560c437be1bb1ee96cb85bdca"

# Get the hash of the new version

major=$(echo "$NEW_VERSION" | cut -d. -f1)
minor=$(echo "$NEW_VERSION" | cut -d. -f2)
patch=$(echo "$NEW_VERSION" | cut -d. -f3 | cut -d- -f1)
stage=$(echo "$NEW_VERSION" | cut -d- -f2)

hash_name="HASH_${major}_${minor}_${patch}_${stage^^}"
NEW_VERSION_HASH=${!hash_name}

# CHECK HASH

if [ -z "$NEW_VERSION_HASH" ]
then
    echo "Warning: No hash found for version $NEW_VERSION."
    [ $FORCE = false ] && \
        { echo "Use --force to install anyway."; exit 3; }
elif [ "$( sha256sum ./homeclean | cut -d' ' -f1 )" != "$NEW_VERSION_HASH" ]
then
    echo "Caution: The hash of the new version does not match the expected hash."
    [ $FORCE = false ] && \
        { echo "Use --force to install anyway."; exit 4; }
fi

# INSTALL

compare_semver "$NEW_VERSION" "$CURRENT_VERSION"

case $? in
    1)
        [ -z "$CURRENT_VERSION" ] \
            && echo "Installing homeclean $NEW_VERSION..." \
            || echo "Upgrading homeclean from $CURRENT_VERSION to $NEW_VERSION..."

        install
        ;;
    0)
        echo "New version $NEW_VERSION is the same as current version $CURRENT_VERSION."
        read -p "Reinstall? " confirm

        case "$confirm" in
            [yY][eE][sS]|[yY]) install;;
            *) exit 0
        esac
        ;;
    -1)
        echo "Warning: New version $NEW_VERSION is older than current version $CURRENT_VERSION."

        [ $FORCE = false ] && \
            { echo "Use --force to install anyway."; exit 5; }

        echo " Downgrading homeclean from $CURRENT_VERSION to $NEW_VERSION..."
        install
        ;;
esac

echo "Done."
exit 0
