#!/bin/bash

# Configuration
TARGET_IP="192.168.0.43"
FAILURE_THRESHOLD=3
ALERT_RECIPIENT="raymond" # Telegram recipient
TELEGRAM_SCRIPT="/home/pi/telegram-send-file/tgsnd.py"

FAIL_COUNT=0

while true; do
  ping -c 1 "$TARGET_IP" > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo "$(date) - Ping failed to $TARGET_IP. Count: $FAIL_COUNT"
    
    # Send an alert on the first failure
    if [[ $FAIL_COUNT -eq 1 ]]; then
        echo "Power Outage Detected (ping failed). Alerting $ALERT_RECIPIENT." | "$TELEGRAM_SCRIPT" "$ALERT_RECIPIENT"
    fi

    if [[ $FAIL_COUNT -ge $FAILURE_THRESHOLD ]]; then
      echo "$(date) - Ping failed $FAILURE_THRESHOLD times. Shutting down..."
      echo "Shutting down due to sustained power outage." | "$TELEGRAM_SCRIPT" "$ALERT_RECIPIENT"
      shutdown -h now
      exit 0 # Exit the script
    fi
  else
    FAIL_COUNT=0 # Reset the failure count on success
    echo "$(date) - Ping successful to $TARGET_IP. Resetting failure count."
  fi
  sleep 300  # Sleep for 5 minutes
done
