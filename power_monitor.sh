#!/bin/bash

# Configuration
TARGET_IP="192.168.0.43"
FAILURE_THRESHOLD=3
ALERT_RECIPIENT="raymond" # Telegram recipient
TELEGRAM_SCRIPT="/home/pi/telegram-send-file/tgsnd.py"

FAIL_COUNT=0
# Function to send alert using Telegram or log if it doesn't exist
send_alert() {
  local message="$1"
  if [[ -x "$TELEGRAM_SCRIPT" ]]; then
      echo "$message" | python "$TELEGRAM_SCRIPT" "$ALERT_RECIPIENT"
  else
    echo "$(date) - Telegram script not found: $message" >&2
  fi
}


send_alert "Power monitoring on $(hostname) started at $(date)"

while true; do
  ping -c 1 "$TARGET_IP" > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo "$(date) - Ping failed to $TARGET_IP. Count: $FAIL_COUNT"
    
    # Send an alert on the first failure
    if [[ $FAIL_COUNT -eq 1 ]]; then
        send_alert "Power Outage Detected on $(hostname) at $(date) (ping failed). Alerting $ALERT_RECIPIENT."
    fi

    if [[ $FAIL_COUNT -ge $FAILURE_THRESHOLD ]]; then
      echo "$(date) - Ping failed $FAILURE_THRESHOLD times. Shutting down..."
      send_alert "Shutting down on $(hostname) at $(date) due to sustained power outage."
      sudo shutdown --poweroff now
      exit 0 # Exit the script
    fi
  else
     if [[ $FAIL_COUNT -gt 0 ]]; then
        send_alert "Power Recovered on $(hostname) at $(date). Ping successful to $TARGET_IP. Alerting $ALERT_RECIPIENT."
     fi
    FAIL_COUNT=0 # Reset the failure count on success
    echo "$(date) - Ping successful to $TARGET_IP. Resetting failure count."
  fi
  sleep 300  # Sleep for 5 minutes
done
