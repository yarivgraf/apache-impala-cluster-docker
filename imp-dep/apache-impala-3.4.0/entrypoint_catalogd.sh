#!/bin/bash

. /etc/profile.d/globals.sh;/opt/impala/bin/catalogd -log_dir=/opt/impala/logs -catalog_service_host=$IP -state_store_host=$IP
