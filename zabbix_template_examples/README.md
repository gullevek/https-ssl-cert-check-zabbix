# Zabbix Templates

Both have warning triggrer for invalid cert and warning for `{$EXPIRESWITHIN}`, high alert for `{$EXPIRESWITHIN_CRITICAL}` and critical if the expired days is negative.

## `basic`

`basic` template creates validity and expiration items and triggers for macros `{$EXPIRESWITHIN}`, `{$EXPIRESWITHIN_CRITICAL}`, `{$IPADDR}`, `{$SSLDOMAIN}`, `{$SSLPORT}`, `{$TIMEOUT}`, `{$UPDATEINTERVAL}`. Macros are defined in the template and should be re-defined for every host using this template.

## `advanced`

`advanced` template uses autodiscovery from file `/etc/zabbix/scripts/ssl_cert_list`, example file provided. Parameter names are self-descriptive. This way a single zabbix host can make checks for multiple SSL endpoints.  `{$EXPIRESWITHIN}`, `{$EXPIRESWITHIN_CRITICAL}` and `{$UPDATEINTERVAL}` as set like for basic.

For discover script (discover_ssl_certs.sh) the macro `{$SSL_CERT_LIST_FOLDER}` can be set to change the location for the ssl_cert_list file

### Discover script call options

#### `read`

if no path is set `/etc/zabbix/scripts/` is used

`./discover_ssl_certs.sh create <optional path to ssl_cert_list>`

#### `create`

`./discover_ssl_certs.sh create <optional path to ssl_cert_list> <ssl port> <time out> <ip addr to check>`

If not the actual outside ip address should be used the ip address can be set to 127.0.0.1 so that the local interface is used.
