#!/bin/bash

. /etc/profile.d/globals.sh;/opt/impala/bin/impalad -log_dir=/opt/impala/logs -state_store_port=24000 -state_store_host=$IP -catalog_service_host=$IP -be_port=22000
