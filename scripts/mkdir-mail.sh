#!/bin/bash

set -ex

# One-time script to execute on EMAIL_NODE to make directory 
# necessary for mailserver to mount.

mkdir -p /var/docker-mailserver
mkdir -p /var/mail
mkdir -p /var/mail-state
mkdir -p /var/log/mail
mkdir -p /usr/local/pgsql/data
mkdir -p /usr/local/redis/data

chown -R 1000:1000 /var/docker-mailserver
chown -R 1000:1000 /var/mail
chown -R 1000:1000 /var/mail-state
chown -R 1000:1000 /var/log/mail
chown -R 1000:1000 /usr/local/pgsql/data
chown -R 1000:1000 /usr/local/redis/data
