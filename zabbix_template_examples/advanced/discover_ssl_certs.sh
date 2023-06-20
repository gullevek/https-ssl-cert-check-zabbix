#!/usr/bin/env bash

# discover local SSL cert files

# Currently only works with apache

# Parameters: read/create
# Options: for read/create $1: path to ssl_cert_list, default /etc/zabbix/scripts/
# Options for create $2: ssl port, default 443; $3: timeout, default 10

error_code=-65535

function error() {
	echo "{\"error_code\": $error_code, \"error_message\": \"$*\"}";
	exit 0;
}

BASE_FOLDER=$(dirname $(readlink -f $0))"/";
SSL_CERT_LIST_FOLDER="${2-/etc/zabbix/scripts/}";
if [ -z "${SSL_CERT_LIST_FOLDER}" ] || [ ! -d "${SSL_CERT_LIST_FOLDER}" ]; then
	error_code=10;
	error "Folder \"${SSL_CERT_LIST_FOLDER}\" does not exist";
fi;
SSL_CERT_LIST="${SSL_CERT_LIST_FOLDER}/ssl_cert_list";

if [ "$1" = "read" ]; then
	# if we have a legacy cert list, print and exit
	if [ -f "${SSL_CERT_LIST}" ]; then
		cat "${SSL_CERT_LIST}";
		exit 0;
	else
		error_code=20;
		error "Could not read \"${SSL_CERT_LIST}\". Was it created?";
	fi;
fi;

if [ "$1" != "create" ]; then
	error_code=30;
	error "Only read/create are allowed as parameters";
fi;

# must be root to create
if [ $(id -u) -ne 0 ]; then
	error_code=40;
	error "Create run must be called as root user";
fi;

# check system: apache2 or nginx
# and os for how to get data
apachectl="apachectl";
# no apachectl
error_code=41;
type "$apachectl" >/dev/null || error "Not found in \$PATH: $apachectl";
# no mod info installed
if [[ -z $("$apachectl" -L 2>/dev/null | grep mod_info) ]]; then
	error_code=42;
	error "apache2 mod_info not installed";
fi;

SSL_PORT="${3:-443}"
TIMEOUT="${4:-10}";

echo "{ \"data\": [" > "${SSL_CERT_LIST}";
trigger_ssl_collect=0;
element_written=0;
while read line; do
	if echo "${line}" | grep -q "<VirtualHost " && echo "${line}" | grep -q ":443>"; then
		trigger_ssl_collect=1;
		if [ $element_written -eq 1 ]; then
			echo "," >> "${SSL_CERT_LIST}";
		fi;
	elif [ $trigger_ssl_collect -eq 1 ] && echo "${line}" | grep -q "ServerName "; then
		server_name=$(echo "${line}" | cut -d ":" -f 1 | cut -d " " -f 2- | sed -e 's/^[[:space:]]*//');
		# echo "S: $server_name";
		echo "{" >> "${SSL_CERT_LIST}";
		echo "\"{#IPADDR}\": \"${server_name}\"," >> "${SSL_CERT_LIST}";
		echo "\"{#SSLPORT}\": \"${SSL_PORT}\"," >> "${SSL_CERT_LIST}";
		echo "\"{#SSLDOMAIN}\": \"${server_name}\"," >> "${SSL_CERT_LIST}";
		echo "\"{#TIMEOUT}\": \"${TIMEOUT}\"," >> "${SSL_CERT_LIST}";
		element_written=1;
	elif [ $trigger_ssl_collect -eq 1 ] && echo "${line}" | grep -q "SSLCertificateFile"; then
		server_cert_file=$(echo "${line}" | cut -d " " -f 2- | sed -e 's/^[[:space:]]*//');
		trigger_ssl_collect=0;
		echo "\"{#CERTFILE}\": \"${server_cert_file}\"" >> "${SSL_CERT_LIST}";
		echo "}" >> "${SSL_CERT_LIST}";
	fi;

done <<< $(
	$apachectl -DDUMP_CONFIG \
	| grep -vE "^[ ]*#[ ]*[0-9]+:$"
);
echo "]}" >> "${SSL_CERT_LIST}";
cat "${SSL_CERT_LIST}";
exit 0;

# __END__
