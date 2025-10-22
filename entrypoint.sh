#!/bin/bash
set -euo pipefail

# Ensure logrotate state exists
mkdir -p /var/lib/logrotate
touch /var/lib/logrotate/status

# LOGROTATE_SCHEDULE default: daily at 02:00
# Format: cron schedule (e.g. "0 * * * *" for hourly, "0 2 * * *" for daily at 02:00)
SCHEDULE="${LOGROTATE_SCHEDULE:-0 2 * * *}"

# Write cron file to run logrotate using system-wide config
cat >/etc/cron.d/logrotate-sidecar <<EOF
SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
$SCHEDULE root /usr/sbin/logrotate /etc/logrotate.conf >/dev/null 2>&1
EOF

chmod 0644 /etc/cron.d/logrotate-sidecar

# Start crond in foreground with moderate verbosity
exec /usr/sbin/crond -n -l 8