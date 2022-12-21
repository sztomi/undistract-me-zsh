# Largely based on https://github.com/jml/undistract-me and especially its zsh
# fork: https://github.com/rgreenblatt/undistract-me
#
# Generates a notification for any command that takes longer than this amount
# of seconds to return to the shell.  e.g. if UMZ_COMMAND_TIMEOUT=10,
# then 'sleep 11' will always generate a notification.


# --- Configuration ---
# (this odd `:` syntax is the colon builtin; this syntax basically sets default values for these
# environment variables.)

# Commands that take longer than this value (in seconds) will trigger a notification. 
: ${UMZ_COMMAND_TIMEOUT:=10}

# Controls if a sound should be played along with the notification. 
# `0` means no, any other value means yes.
: ${UMZ_PLAY_SOUND:=0}

# Sound file to play upon completion (if `UMZ_PLAY_SOUND` is set to a non-zero value)
: ${UMZ_SOUND_FILE:=/usr/share/sounds/freedesktop/stereo/complete.oga}

function umz_init() {
  function get_now() {
    local secs
    if ! secs=$(printf "%(%s)T" -1 2>/dev/null); then
      secs=$(\date +'%s')
    fi
    echo $secs
  }

  function active_window_id() {
    if [[ -n $DISPLAY ]]; then
      xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}'
      return
    fi
    echo nowindowid
  }

  function sec_to_human() {
    local H=''
    local M=''
    local S=''

    local h=$(($1 / 3600))
    [ $h -gt 0 ] && H="${h} hour" && [ $h -gt 1 ] && H="${H}s"

    local m=$((($1 / 60) % 60))
    [ $m -gt 0 ] && M=" ${m} min" && [ $m -gt 1 ] && M="${M}s"

    local s=$(($1 % 60))
    [ $s -gt 0 ] && S=" ${s} sec" && [ $s -gt 1 ] && S="${S}s"

    echo $H$M$S
  }

  function precmd() {
    if [[ -n "$__udm_last_command_started" ]]; then
      local now current_window

      now=$(get_now)
      current_window=$(active_window_id)
      if [[ $current_window != $__udm_last_window ]] ||
        [[ ! -z "$IGNORE_WINDOW_CHECK" ]] ||
        [[ $current_window == "nowindowid" ]]; then
        local time_taken=$(($now - $__udm_last_command_started))
        local time_taken_human=$(sec_to_human $time_taken)
        local appname=$(basename "${__udm_last_command%% *}")
        if [[ $time_taken -gt $UMZ_COMMAND_TIMEOUT ]] &&
          [[ -n $DISPLAY ]] &&
          [[ ! " $LONG_RUNNING_IGNORE_LIST " == *" $appname "* ]]; then
          local icon=dialog-information
          local urgency=low
          if [[ $__preexec_exit_status != 0 ]]; then
            icon=dialog-error
            urgency=normal
          fi
          notify=$(command -v notify-send)
          if [ -x "$notify" ]; then
            $notify \
              -i $icon \
              -u $urgency \
              "Command completed in $time_taken_human" \
              "$__udm_last_command"
            if [[ "$UMZ_PLAY_SOUND" != 0 ]]; then
              paplay /usr/share/sounds/freedesktop/stereo/complete.oga
            fi
          else
            echo -ne "\a"
          fi
        fi
        if [[ -n $LONG_RUNNING_COMMAND_CUSTOM_TIMEOUT ]] &&
          [[ -n $LONG_RUNNING_COMMAND_CUSTOM ]] &&
          [[ $time_taken -gt $LONG_RUNNING_COMMAND_CUSTOM_TIMEOUT ]] &&
          [[ ! " $LONG_RUNNING_IGNORE_LIST " == *" $appname "* ]]; then
          # put in brackets to make it quiet
          export __preexec_exit_status
          ($LONG_RUNNING_COMMAND_CUSTOM \
            "\"$__udm_last_command\" took $time_taken_human" &)
        fi
      fi
    fi
  }

  function preexec() {
    # use __udm to avoid global name conflicts
    __udm_last_command_started=$(get_now)
    __udm_last_command=$(echo "$1")
    __udm_last_window=$(active_window_id)
  }
}

umz_init