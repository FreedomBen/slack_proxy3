#!/usr/bin/env bash

IMG='postgres:10.4-alpine'
NAME='slack_proxy3_postgres'

# 'Z' flag in volume mount explained:
# https://prefetch.net/blog/2017/09/30/using-docker-volumes-on-selinux-enabled-servers/

# Mounting /etc/passwd is needed for initdb:
# See:  https://github.com/docker-library/docs/tree/aa1959a855a9b1025057d7efc9e01553ca83a257/postgres#arbitrary---user-notes

die () 
{
    echo "$@"
    exit 1
}

mkdir -p pgdata || die "Could not create pgdata directory for volume"
# This is a little safer than bind mounting in /etc/passwd, which got corrupted
# and rendered my system unbootable.  That's worse than having an extra file
# hanging aroud, trust me
cp /etc/passwd pg_passwd

docker run \
  --rm \
  --interactive \
  --tty \
  --publish '5432:5432' \
  --user "$(id -u):$(id -g)" \
  --volume "$(pwd)/pg_passwd:/etc/passwd:ro,Z" \
  --volume "$(pwd)/pgdata:/var/lib/postgresql/data:Z" \
  --env POSTGRES_USER=postgres \
  --env POSTGRES_PASSWORD=password \
  --name "$NAME" \
  $IMG

  #--volume "/etc/passwd:/etc/passwd:ro,Z" \

rm -f pg_passwd
