#!/bin/bash
# Copy it to the container:
#   docker cp helper-scripts/influxdb.sh addon_a0d7b954_influxdb:/data/
#

set -eo pipefail

# read password
# read db
# display option
## show all entities
## drop series, i.e. a entity
## delet a series,
DB=${DB:-homeassistant}
USERNAME=${USERNAME:-homeassistant}

function set_db()
{
    read -p "Database($DB): " _DB
    if [ -n "$_DB" ]; then
        DB=$_DB
    fi
    unset _DB
}

function set_username()
{
    read -p "Username($USERNAME): " _USERNAME
    if [ -n "$_USERNAME" ]; then
        USERNAME=$_USERNAME
    fi
    unset _USERNAME
}

function set_password()
{
    local prompt
    prompt="Password: "
    stty -echo

    while IFS= read -p "$prompt" -r -s -n 1 ch; do
        if [[ $ch == $'\0' ]]; then
            break
        fi
        prompt='*'
        PASSWORD+="$ch"
    done
    stty echo
    echo
}

function query()
{
    influx -format csv -database "$DB" -username "$USERNAME" -password "$PASSWORD" -execute "$*"
}

set_db
set_username
set_password

# Get all measurements
# Sets global variables:
#   - MEASUREMENTS
#
function print_and_set_measurements()
{
    # Get all measurements
    readarray -s 1 -t MEASUREMENTS < <(
        query 'SHOW MEASUREMENTS ON "homeassistant"' | awk -F '[,]' '{ print $2 }' | sort
    )
    echo "Total measurements: ${#MEASUREMENTS[@]}"
    printf "%s\n" "${MEASUREMENTS[@]}"
    echo
}

# Get all entitiy_id from each measurement
# Sets global variables:
#   - ENTITIES
#
function print_and_set_entities()
{
    print_and_set_measurements
    declare -a ENTITIES
    for m in "${MEASUREMENTS[@]}"; do
        readarray -s 1 -t entities < <(
            query "SHOW TAG VALUES ON \"homeassistant\" FROM \"$m\" WITH KEY = \"entity_id\"" | awk -F '[,]' '{ print $3 }'
        )
        ENTITIES+=("${entities[@]}")
    done
    IFS=$'\n' ENTITIES=($(sort <<<"${ENTITIES[*]}")); unset IFS
    echo "Total entities: ${#ENTITIES[@]}"
    printf "%s\n" "${ENTITIES[@]}"
    echo
}


function drop_series()
{
    print_and_set_entities
    if (( $# == 0)); then
        return 0
    fi
    for e in "$@"; do
        if [[ ${ENTITIES[*]} =~ $e ]]; then
            echo -n "Dropping series \"$e\"..."
            query "DROP SERIES WHERE \"entity_id\"='"$e"'"
            echo "done"
        fi
    done
}

function drop_measurement()
{
    print_and_set_measurements
    if (( $# == 0)); then
        return 0
    fi
    for m in "$*"; do
        if [[ ${MEASUREMENTS[*]} =~ $m ]]; then
            echo -n "Dropping measurement \"$m\"..."
            query "DROP MEASUREMENT \"$m\""
            echo "done"
        fi
    done
}

# TODO(cschwarzgruber): add possibility to filter ENTITIES by regex
# drop_series marantz marantz_power_state
drop_measurement

exit 0
