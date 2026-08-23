#!/bin/sh
# Find a useful CPU temperature without relying on unstable hwmon numbers.

find_hwmon_sensor() {
  for wanted in k10temp zenpower coretemp cpu_thermal cpu-thermal thinkpad; do
    for directory in /sys/class/hwmon/hwmon*; do
      [ -r "$directory/name" ] || continue
      name=$(cat "$directory/name" 2>/dev/null) || continue
      [ "$name" = "$wanted" ] || continue

      fallback=""
      for input in "$directory"/temp*_input; do
        [ -r "$input" ] || continue
        [ -n "$fallback" ] || fallback=$input
        label_file=${input%_input}_label
        label=$(cat "$label_file" 2>/dev/null || printf '')
        case "$label" in
          Tctl|Tdie|CPU|Package*|Core*) printf '%s\n' "$input"; return 0 ;;
        esac
      done
      [ -n "$fallback" ] && { printf '%s\n' "$fallback"; return 0; }
    done
  done
  return 1
}

find_thermal_zone() {
  for zone in /sys/class/thermal/thermal_zone*; do
    [ -r "$zone/type" ] && [ -r "$zone/temp" ] || continue
    type=$(cat "$zone/type" 2>/dev/null) || continue
    case "$type" in
      x86_pkg_temp|cpu-thermal|cpu_thermal|soc-thermal|acpitz)
        printf '%s\n' "$zone/temp"
        return 0
        ;;
    esac
  done
  return 1
}

sensor=$(find_hwmon_sensor || find_thermal_zone) || exit 0
raw=$(cat "$sensor" 2>/dev/null) || exit 0
case "$raw" in ''|*[!0-9-]*) exit 0 ;; esac

[ "$raw" -gt 1000 ] && temperature=$(( (raw + 500) / 1000 )) || temperature=$raw
[ "$temperature" -gt 0 ] && [ "$temperature" -lt 150 ] || exit 0

class="normal"
[ "$temperature" -ge 70 ] && class="warning"
[ "$temperature" -ge 85 ] && class="critical"

source=${sensor%/temp*}
source=${source##*/}
printf '{"text":"󰔏 %s°C","tooltip":"CPU temperature: %s°C\\nSensor: %s","class":"%s"}\n' \
  "$temperature" "$temperature" "$source" "$class"
