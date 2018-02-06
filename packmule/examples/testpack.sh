#! /bin/sh

# runs packmule with proper command arguments
# Austin Shafer - 2017

USER=ashafer
INSTALLDISK="~${USER}/hyve/.iso/FreeBSD-11.1-RELEASE-amd64-disc1.iso"
YAML_FILE="exampleconfig.yml"

./packmule -y ${YAML_FILE} ${INSTALLDISK}
