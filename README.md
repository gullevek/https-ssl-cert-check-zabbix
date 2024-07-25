# SSL Cert Check

Script to check validity and expiration of TLS/SSL certificate on remote host. Supports: TLS SNI and STARTTLS for protocols like SMTP; internationalized domain names with Punycode(uses [libidn](https://www.gnu.org/software/libidn/)); allowing self-signed certs as valid; JSON output; supports any additional `s_client` [options](https://www.openssl.org/docs/manmaster/man1/openssl-s_client.html).

May be used standalone or with Zabbix. See the "Zabbix integration" section below.

```bash
user@host:~$ ./ssl_cert_check.sh valid google.com
1

# Check 74.125.131.138 on port 443 for days left before certificate expiration
# TLS SNI(Server Name Indication) is set to google.com
# Check timeout is 15 seconds(default is 5)
# TLS protocol version is forced to 1.2, no auto-negotiation
user@host:~$ ./ssl_cert_check.sh expire 74.125.131.138 443 google.com 15 tls1_2
56

# JSON output of the certificate
user@host:~$ ./ssl_cert_check.sh json google.com
{"subject": "*.google.com", "expire_days": 55, "valid": 1, "notBefore": "May 22 08:17:22 2023 GMT", "notAfter": "Aug 14 08:17:21 2023 GMT", "serial": "9E597D0FC727BF680A4E0D576D46E909", "fingerprint": "25:36:C1:2F:11:C0:8D:64:42:51:0A:96:50:CA:72:2E:DC:E9:8F:22", "signatureAlgorithm": "sha256WithRSAEncryption", "issuer": "C = US, O = Google Trust Services LLC, CN = GTS CA 1C3", "subjectAlternativeNames": "*.google.com,*.appengine.google.com,*.bdn.dev,*.origin-test.bdn.dev,*.cloud.google.com,*.crowdsource.google.com,*.datacompute.google.com,*.google.ca,*.google.cl,*.google.co.in,*.google.co.jp,*.google.co.uk,*.google.com.ar,*.google.com.au,*.google.com.br,*.google.com.co,*.google.com.mx,*.google.com.tr,*.google.com.vn,*.google.de,*.google.es,*.google.fr,*.google.hu,*.google.it,*.google.nl,*.google.pl,*.google.pt,*.googleadapis.com,*.googleapis.cn,*.googlevideo.com,*.gstatic.cn,*.gstatic-cn.com,googlecnapps.cn,*.googlecnapps.cn,googleapps-cn.com,*.googleapps-cn.com,gkecnapps.cn,*.gkecnapps.cn,googledownloads.cn,*.googledownloads.cn,recaptcha.net.cn,*.recaptcha.net.cn,recaptcha-cn.net,*.recaptcha-cn.net,widevine.cn,*.widevine.cn,ampproject.org.cn,*.ampproject.org.cn,ampproject.net.cn,*.ampproject.net.cn,google-analytics-cn.com,*.google-analytics-cn.com,googleadservices-cn.com,*.googleadservices-cn.com,googlevads-cn.com,*.googlevads-cn.com,googleapis-cn.com,*.googleapis-cn.com,googleoptimize-cn.com,*.googleoptimize-cn.com,doubleclick-cn.net,*.doubleclick-cn.net,*.fls.doubleclick-cn.net,*.g.doubleclick-cn.net,doubleclick.cn,*.doubleclick.cn,*.fls.doubleclick.cn,*.g.doubleclick.cn,dartsearch-cn.net,*.dartsearch-cn.net,googletraveladservices-cn.com,*.googletraveladservices-cn.com,googletagservices-cn.com,*.googletagservices-cn.com,googletagmanager-cn.com,*.googletagmanager-cn.com,googlesyndication-cn.com,*.googlesyndication-cn.com,*.safeframe.googlesyndication-cn.com,app-measurement-cn.com,*.app-measurement-cn.com,gvt1-cn.com,*.gvt1-cn.com,gvt2-cn.com,*.gvt2-cn.com,2mdn-cn.net,*.2mdn-cn.net,googleflights-cn.net,*.googleflights-cn.net,admob-cn.com,*.admob-cn.com,googlesandbox-cn.com,*.googlesandbox-cn.com,*.safenup.googlesandbox-cn.com,*.gstatic.com,*.metric.gstatic.com,*.gvt1.com,*.gcpcdn.gvt1.com,*.gvt2.com,*.gcp.gvt2.com,*.url.google.com,*.youtube-nocookie.com,*.ytimg.com,android.com,*.android.com,*.flash.android.com,g.cn,*.g.cn,g.co,*.g.co,goo.gl,www.goo.gl,google-analytics.com,*.google-analytics.com,googlecommerce.com,*.googlecommerce.com,ggpht.cn,*.ggpht.cn,urchin.com,*.urchin.com,youtu.be,youtube.com,*.youtube.com,youtubeeducation.com,*.youtubeeducation.com,youtubekids.com,*.youtubekids.com,yt.be,*.yt.be,android.clients.google.com,developer.android.google.cn,developers.android.google.cn,source.android.google.cn", "wildcard": 0, "return_code": 0, "return_text": "ok"}

```

Formatted JSON

```json
{
  "subject": "*.google.com",
  "expire_days": 55,
  "valid": 1,
  "notBefore": "May 22 08:17:22 2023 GMT",
  "notAfter": "Aug 14 08:17:21 2023 GMT",
  "serial": "9E597D0FC727BF680A4E0D576D46E909",
  "fingerprint": "25:36:C1:2F:11:C0:8D:64:42:51:0A:96:50:CA:72:2E:DC:E9:8F:22",
  "signatureAlgorithm": "sha256WithRSAEncryption",
  "issuer": "C = US, O = Google Trust Services LLC, CN = GTS CA 1C3",
  "subjectAlternativeNames": "... domain list ...",
  "wildcard": 0,
  "return_code": 0,
  "return_text": "ok"
}
```

- [SSL Cert Check](#ssl-cert-check)
  - [Usage](#usage)
  - [Return values](#return-values)
    - [`expire` or `valid`](#expire-or-valid)
    - [`json`: JSON output](#json-json-output)
  - [Examples](#examples)
  - [Zabbix integration](#zabbix-integration)
  - [Support for Internationalized Domain Names with Punycode](#support-for-internationalized-domain-names-with-punycode)
  - [Using with busybox, like Alpine-based Docker images](#using-with-busybox-like-alpine-based-docker-images)

## Usage

`ssl_cert_check.sh valid|expire|json <hostname or IP> [port[/starttls protocol]] [domain for TLS SNI] [check timeout (seconds)] [tls_version|tls_auto,[self_signed_ok]] [ s_client_option1 ] [ ... ] [ s_client_optionN ]`

- `[port]` optional, default is 443
- `[starttls protocol]` optional, use protocol-specific message to switch to TLS communication. See `man s_client` option `-starttls` for supported protocols, like `smtp`, `ftp`, `ldap`.
- `[domain for TLS SNI]` optional, default is `<hostname or IP>`.
[SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)*(Server Name Indication) is used to specify certificate domain name if it differs from the hostname.*
- `[check timeout (seconds)]` optional, default is 5 seconds
- `[tls_version|tls_auto,[self_signed_ok]]` predefined options comma (`,`) separated, flag is optional. Set what is needed, no order of parameters is present of the available options below.
  - `[tls_version]` if it is not given a TLS version will be negotiated. Override the TLS version as you need, like: `tls1_2`, `tls1_3`, `no_tls1`, `dtls` and so on. See the "TLS Version Options" section of [man openssl](https://www.openssl.org/docs/man3.0/man1/openssl.html) or [man s_client](https://www.openssl.org/docs/man3.0/man1/s_client.html) for the available options.
  - `[self_signed_ok]` is optional. When this flag is set all self-signed certificates will be seen as valid. Otherwise these will be rendered invalid. It will allow OpenSSL return codes `18`, `19`, `20` & `21`. See the `Diagnostics` section at [OpenSSL Doc: verify](https://www.openssl.org/docs/man1.0.2/man1/verify.html).
  - [tls_auto] means auto negotiating TLS protocol. That is the default, this option is used as separator if you want to speficy additional s_client options after it.
- `[ s_client_option1 ] [ ... ] [ s_client_optionN ]` is optional. But all other parameters are required to be set. Everything you append after all parameters will be added/appended on the OpenSSL s_client command. See all s_client options at [OpenSSL Doc: s_client](https://www.openssl.org/docs/man1.0.2/man1/s_client.html).

## Return values

### `expire` or `valid`

- `1|0`  for validity check: 1 - valid, 0 - invalid, expired or unavailable
- `N`  number of days left for expiration check. Zero or negative value means certificate is expired
- `-65535`  site was unavailable for check timeout or incorrect script parameters

### `json`: JSON output

- JSON object with a summary of the result, which can be used by Zabbix (JSONPath)
  - `expire_days`: the amount of days before the certificate is expired
  - `valid`: see `valid` check
  - `return_code`: the OpenSSL return code
  - `return_text`: the OpenSSL return text which gives helpful insights
  - `subject`: should match with domain queried (CN = is removed)
  - `notBefore`: in default rfc_822 date format
  - `notAfter`: in default rfc_822 date format
  - `serial`: serial number
  - `fingerprint`: cert fingerprint
  - `signatureAlgorithm`: the algorithm used to create this certificate
  - `issuer`: the issuer full string (C = , O = , CN = )
  - `subjectAlternativeNames`: all alterntaive names excluding subject
  - `wildcard`: 1 if cert is a wildcard cert, else 0
- JSON object with the error code and message
  - `error_code`: $error_code
  - `error_message`: The output of the error message

Exit code is always 0, otherwise zabbix agent fails to get the item value.

If the script is running without terminal(from zabbix), error messages are not printed, only the exit code. The reason is that zabbix merges stdout and strerr to get an item value.

## Examples

```bash
user@host:~$ ./ssl_cert_check.sh valid google.com
1

user@host:~$ ./ssl_cert_check.sh valid imap.gmail.com 993
1

# SMTP on port 587 with STARTTLS to switch to TLS communication
user@host:~$ ./ssl_cert_check.sh valid smtp.gmail.com 587/smtp
1

user@host:~$ ./ssl_cert_check.sh valid self-signed.badssl.com
0

# Expired certificate is not valid
user@host:~$ ./ssl_cert_check.sh valid expired.badssl.com
0

user@host:~$ ./ssl_cert_check.sh expire google.com
56

user@host:~$ ./ssl_cert_check.sh expire expired.badssl.com
-2606

# JSON output of the certificate (can be combined with/piped to `jq`)
user@host:~$ ./ssl_cert_check.sh json google.com
{"expire_days": 55, "valid": 1, "notBefore": "May 22 08:17:22 2023 GMT", "notAfter": "Aug 14 08:17:21 2023 GMT", "serial": "9E597D0FC727BF680A4E0D576D46E909", "fingerprint": "25:36:C1:2F:11:C0:8D:64:42:51:0A:96:50:CA:72:2E:DC:E9:8F:22", "signatureAlgorithm": "sha256WithRSAEncryption", "issuer": "C = US, O = Google Trust Services LLC, CN = GTS CA 1C3", "subjectAlternativeNames": "*.google.com,*.appengine.google.com,*.bdn.dev,*.origin-test.bdn.dev,*.cloud.google.com,*.crowdsource.google.com,*.datacompute.google.com,*.google.ca,*.google.cl,*.google.co.in,*.google.co.jp,*.google.co.uk,*.google.com.ar,*.google.com.au,*.google.com.br,*.google.com.co,*.google.com.mx,*.google.com.tr,*.google.com.vn,*.google.de,*.google.es,*.google.fr,*.google.hu,*.google.it,*.google.nl,*.google.pl,*.google.pt,*.googleadapis.com,*.googleapis.cn,*.googlevideo.com,*.gstatic.cn,*.gstatic-cn.com,googlecnapps.cn,*.googlecnapps.cn,googleapps-cn.com,*.googleapps-cn.com,gkecnapps.cn,*.gkecnapps.cn,googledownloads.cn,*.googledownloads.cn,recaptcha.net.cn,*.recaptcha.net.cn,recaptcha-cn.net,*.recaptcha-cn.net,widevine.cn,*.widevine.cn,ampproject.org.cn,*.ampproject.org.cn,ampproject.net.cn,*.ampproject.net.cn,google-analytics-cn.com,*.google-analytics-cn.com,googleadservices-cn.com,*.googleadservices-cn.com,googlevads-cn.com,*.googlevads-cn.com,googleapis-cn.com,*.googleapis-cn.com,googleoptimize-cn.com,*.googleoptimize-cn.com,doubleclick-cn.net,*.doubleclick-cn.net,*.fls.doubleclick-cn.net,*.g.doubleclick-cn.net,doubleclick.cn,*.doubleclick.cn,*.fls.doubleclick.cn,*.g.doubleclick.cn,dartsearch-cn.net,*.dartsearch-cn.net,googletraveladservices-cn.com,*.googletraveladservices-cn.com,googletagservices-cn.com,*.googletagservices-cn.com,googletagmanager-cn.com,*.googletagmanager-cn.com,googlesyndication-cn.com,*.googlesyndication-cn.com,*.safeframe.googlesyndication-cn.com,app-measurement-cn.com,*.app-measurement-cn.com,gvt1-cn.com,*.gvt1-cn.com,gvt2-cn.com,*.gvt2-cn.com,2mdn-cn.net,*.2mdn-cn.net,googleflights-cn.net,*.googleflights-cn.net,admob-cn.com,*.admob-cn.com,googlesandbox-cn.com,*.googlesandbox-cn.com,*.safenup.googlesandbox-cn.com,*.gstatic.com,*.metric.gstatic.com,*.gvt1.com,*.gcpcdn.gvt1.com,*.gvt2.com,*.gcp.gvt2.com,*.url.google.com,*.youtube-nocookie.com,*.ytimg.com,android.com,*.android.com,*.flash.android.com,g.cn,*.g.cn,g.co,*.g.co,goo.gl,www.goo.gl,google-analytics.com,*.google-analytics.com,googlecommerce.com,*.googlecommerce.com,ggpht.cn,*.ggpht.cn,urchin.com,*.urchin.com,youtu.be,youtube.com,*.youtube.com,youtubeeducation.com,*.youtubeeducation.com,youtubekids.com,*.youtubekids.com,yt.be,*.yt.be,android.clients.google.com,developer.android.google.cn,developers.android.google.cn,source.android.google.cn", "wildcard": 1, "return_code": 0, "return_text": "ok"}

# NOTE: an error message is shown to stderr only when running on a terminal
# Without terminal(from zabbix), only the result is printed to stdout
user@host:~$ ./ssl_cert_check.sh expire unavailable.example.com
-65535
ERROR: Failed to get certificate

# Check 74.125.131.138:443 for a valid certificate for google.com
# TLS SNI(Server Name Indication) is set to google.com
# Check timeout is 10 seconds(default is 5)
user@host:~$ ./ssl_cert_check.sh valid 74.125.131.138 443 google.com 10
1

# Check a certificate on an endpoint only accepting TLS 1.2 and use TLS 1.2, which is valid.
user@host:~$ ./ssl_cert_check.sh valid tls-v1-2.badssl.com 1012 tls-v1-2.badssl.com 10 tls1_2
1

# Check a certificate on an endpoint only accepting TLS 1.2, but use TLS 1.1, which is invalid.
user@host:~$ ./ssl_cert_check.sh valid tls-v1-2.badssl.com 1012 tls-v1-2.badssl.com 10 tls1_1
-65535
ERROR: Failed to get certificate

# Check a self-signed certificate endpoint using TLS 1.2, without assuming self-signed is valid.
user@host:~$ ./ssl_cert_check.sh json self-signed.badssl.com 443 self-signed.badssl.com 10 tls1_2
{"expire_days": 708, "valid": 0, "return_code": 18, "return_text": "self signed certificate", ...}

# Check a self-signed certificate endpoint using TLS 1.2, with assuming self-signed is valid.
user@host:~$ ./ssl_cert_check.sh json self-signed.badssl.com 443 self-signed.badssl.com 10 tls1_2,self_signed_ok
{"expire_days": 708, "valid": 1, "return_code": 18, "return_text": "self signed certificate", ...}

```

## Zabbix integration

Example of Zabbix [user parameters](https://www.zabbix.com/documentation/current/manual/config/items/userparameters): `userparameters_ssl_cert_check.conf` in `zabbix_integration_examples` directory.

`basic` - basic template and userparameter for monitoring of one SSL cert per host

- copy userparameters_ssl_cert_check.conf file into /etc/zabbix/zabbix_agentd.d on host
- import template in zabbix server, assign to host, fill macros on that host

`advanced` - advanced template and userparameter for monitoring of multiple ssl certs per hosts

- copy userparameters_ssl_cert_check.conf file into /etc/zabbix/zabbix_agentd.d
- copy disocver_ssl_certs.sh script to /etc/zabbix/scripts/ and run an init with `disocver_ssl_certs.sh create` if apache is used, else the ssl_cert_list needs to be created by hand
- import template in zabbix server, assign to host, either run discovery or wait

## Support for Internationalized Domain Names with Punycode

If `idn` executable([libidn](https://www.gnu.org/software/libidn/)) is available, unicode host and domain names be will supported by converting to [Punycode](https://en.wikipedia.org/wiki/Punycode) representation. Absence of `idn` does not break the script, but unicode domains will not be supported.

## Using with busybox, like Alpine-based Docker images

Busybox `date` can not parse date format from `openssl`. If you are using the script in busybox, for example in Alpine-based Docker images, install `coreutils` and `bash` packages.

**P.S.**

If this code is useful for you - don't forget to put a star on it's [github repo](https://github.com/selivan/https-ssl-cert-check-zabbix).
