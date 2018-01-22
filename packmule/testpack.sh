#! /bin/sh

# runs bsdpack.sh with proper command arguments
# Austin Shafer - 2017

USER=ashafer
INSTALLDISK="~${USER}/hyve/.iso/FreeBSD-11.1-RELEASE-amd64-disc1.iso"
PACK_LIST="~${USER}/bin/bsdpack/bsdplist.txt"

packmule ${INSTALLDISK} ${PACK_LIST}
