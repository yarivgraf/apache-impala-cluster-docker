#!/bin/bash

. /etc/profile.d/globals.sh;/opt/impala/bin/statestored -log_dir=/opt/impala/logs -state_store_port=24000 -state_store_host=$IP
