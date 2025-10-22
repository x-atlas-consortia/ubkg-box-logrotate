FROM registry.access.redhat.com/ubi8/ubi:8.8

# Install logrotate and cron (cronie)
RUN yum -y install logrotate cronie && yum clean all && rm -rf /var/cache/yum

# Add logrotate config and entrypoint
COPY ubkg.logrotate /etc/logrotate.d/ubkg
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Ensure expected directories exist
RUN mkdir -p /var/log/ubkgbox /var/log/neo4j /var/lib/logrotate

VOLUME ["/var/log/ubkgbox", "/var/log/neo4j", "/var/lib/logrotate"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]