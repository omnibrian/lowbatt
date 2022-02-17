#!/usr/bin/env bash
#
# Script for notifying on low battery

set -euo pipefail

name=lowbatt

usage() {
  cat <<EOF
Usage: ${name} [--help] <command> <args>

Script for automatically notifying the user of battery status at set thresholds.

Available options:
  --help  Print this help message and exit

Available commands:
  get     Display current configuration
  set     Set a value in the configuration file
  invoke  Internal command for service to call
EOF
}

if [[ "$@" == *--help* ]] ; then
  usage
  exit
fi

log() {
  echo -e "$(date -Iseconds): ${1-}" | tee >(logger -t "${name}") >&2
}

msg() {
  echo >&2 -e "${1-}"
}

# config
config_file=/etc/lowbatt.conf
config_values=(
  low_threshold
  danger_threshold
  critical_threshold
)

# default values
low_threshold=30
danger_threshold=20
critical_threshold=10

battery_name="BAT0"
battery_folder="/sys/class/power_supply/${battery_name}"
battery_status_file="${battery_folder}/status"
battery_percent_file="${battery_folder}/capacity"

lock_file=/tmp/${name}.lock

# invoke logic
notify-send-all() {
  loginctl list-sessions --no-legend | while read line ; do
    user=$(echo $line | cut -d' ' -f3)
    uid=$(echo $line | cut -d' ' -f2)
    sudo -u ${user} sh -c "DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/${uid}/bus\" DISPLAY=\":0\" notify-send -u critical \"${1}\" \"${2}\""
  done
}

check-notify() {
  if [[ -f "${lock_file}" ]] ; then
    last_notify="$(cat ${lock_file})"
  else
    last_notify=100
  fi

  battery_percent=$(cat ${battery_percent_file})
  if [[ ${last_notify} -gt ${!1} ]] && [[ ${battery_percent} -le ${!1} ]] ; then
    log "Battery is below ${!1}% (${1}), sending notification"
    notify-send-all "${2}" "Battery below ${!1}%"
    echo "${battery_percent}" > ${lock_file}
    return 0
  fi

  return 1
}

# handle command
if [[ ${#} -lt 1 ]] ; then
  usage
  msg "\nNo command passed in"
  exit 1
fi

case "${1-}" in
  get)
    if [[ -f "${config_file}" ]] ; then
      source "${config_file}"
    fi

    for name in "${config_values[@]}" ; do
      echo "${name}=${!name}"
    done
    ;;
  set)
    if [[ ${#} -lt 3 ]] ; then
      msg "You need to include the parameter to set and its value: ${0} ${1} low_threshold 30"
      exit 1
    fi

    if [[ -f "${config_file}" ]] ; then
      source "${config_file}"
    fi

    valid_name=false
    for name in "${config_values[@]}" ; do
      if [[ "${name}" == "${2}" ]] ; then
        valid_name=true
      fi
    done

    if [[ "${valid_name}" != "true" ]] ; then
      msg "Invalid config value, must be one of: ${config_values[*]}"
      exit 1
    fi

    touch "${config_file}"
    if grep "^${2}=" "${config_file}" &>/dev/null ; then
      sed "s/^${2}=.*/${2}=${3}/" -i "${config_file}"
    else
      echo "${2}=${3}" >> "${config_file}"
    fi

    msg "Configuration file updated"
    ;;
  invoke)
    if [[ "$(cat ${battery_status_file})" != "Discharging" ]] ; then
      if [[ -f "${lock_file}" ]] ; then
        msg "Battery isn't discharging, removing lock file"
        rm ${lock_file}
      fi
    else
      if [[ -f "${config_file}" ]] ; then
        source "${config_file}"
      fi

      check-notify critical_threshold "Critical battery level" || \
      check-notify danger_threshold "Very low battery" || \
      check-notify low_threshold "Low battery" || \
      true
    fi
    ;;
  *)
    usage
    echo >&2 -e "\nUnknown command: ${1-}"
    exit 1
    ;;
esac
