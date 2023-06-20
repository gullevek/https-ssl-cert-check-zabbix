# Zabbix Templates

## `basic`

`basic` template creates validity and expiration items and triggers for macros `{$EXPIRESWITHIN}`, `{$EXPIRESWITHIN_CRITICAL}`, `{$IPADDR}`, `{$SSLDOMAIN}`, `{$SSLPORT}`, `{$TIMEOUT}`, `{$UPDATEINTERVAL}`. Macros are defined in the template and should be re-defined for every host using this template.

## `advanced`

`advanced` template uses autodiscovery from file `/etc/zabbix/scripts/ssl_cert_list`, example file provided. Parameter names are self-descriptive. This way a single zabbix host can make checks for multiple SSL endpoints.  `{$EXPIRESWITHIN}`, `{$EXPIRESWITHIN_CRITICAL}` and `{$UPDATEINTERVAL}` as set like for basic, `{$SSLPORT_DEFAULT}` and `{$TIMEOUT_DEFAULT}` are used to fill default values in discover script
