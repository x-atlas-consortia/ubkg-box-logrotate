# ubkg-box-logrotate
logrotate sidecar service for ubkg-box container application

# Sidecar logrotate (UBI9) for containerized apps

This sidecar image runs `crond` and invokes `logrotate` on a schedule you control via the `LOGROTATE_SCHEDULE` environment variable (cron format).

Files:
- Dockerfile : builds the sidecar image (UBI9).
- entrypoint.sh : installs a cron job and runs `crond` in foreground.
- myapp.logrotate : sample rotation for `/var/log/myapp/*.log`.
- docker-compose.yml : example to run your app + sidecar.

Build and run
1. Build the sidecar image:
   `./build_ubkg-box-logrotate.sh build`
2. Build a multi-architecture image:
   `./build_ubkg-box-logrotate.sh push`

Configuration
- LOGROTATE_SCHEDULE (cron): default "0 * * * *" (hourly). Set to "0 2 * * *" for daily at 02:00.
- If your app can reopen logs on SIGHUP, prefer signalling in a `postrotate` instead of `copytruncate`. Example:
  ```
  /var/log/myapp/*.log {
      daily
      rotate 7
      compress
      missingok
      notifempty
      create 0640 root root
      sharedscripts
      postrotate
          kill -HUP $(cat /var/run/myapp.pid) 2>/dev/null || true
      endscript
  }
  ```

SELinux and mounts
- If mounting host paths on an SELinux-enabled host, use the :Z or :z mount option (docker run) or `:Z` in compose to relabel, e.g. `- /path/on/host:/var/log/myapp:Z`.
- The sidecar only needs read/write access to the log directory.

Testing
- Force a debug run of logrotate inside the sidecar:
  docker-compose exec logrotate /usr/sbin/logrotate -d /etc/logrotate.conf

- Force an immediate rotation (not via cron):
  docker-compose exec logrotate /usr/sbin/logrotate -f /etc/logrotate.conf

- Inspect rotated files:
  docker-compose exec logrotate ls -l /var/log/myapp

Notes
- Using a sidecar centralizes rotation for logs produced by the app container and avoids running cron inside every app container.
- If you prefer rotating docker engine's container logs, consider docker logging driver options (`--log-opt max-size`, `--log-opt max-file`) instead.
