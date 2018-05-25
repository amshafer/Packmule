#! /bin/sh

# ###############################################
#
# bsdpack: The freebsd install packing script
#
# Austin Shafer - 2017
#     ashaferian@gmail.com
#
# ###############################################

# ###############################################
#
# Copyright 2018 Austin Shafer. All rights reserved
#
# Redistribution and use in source and binary forms, with
# or without modification, are permitted provided that the
# following conditions are met:
#
# 1. Redistributions of source code must retain the above 
# copyright notice, this list of conditions and the following 
# disclaimer.
#
# 2. Redistributions in binary form must reproduce the above 
# copyright notice, this list of conditions and the following 
# disclaimer in the documentation and/or other materials provided 
# with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its 
# contributors may be used to endorse or promote products derived 
# from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ###############################################

# This program is designed to fill an freebsd installation image 
# with any packages supplied by the user. This results in an image
# which holds extra utilities installed by the user.

# The script mounts the .iso image under /mnt/bsd_iso and copies
# the file system to /tmp/bsd_iso_work. Packages and software is
# added to under /tmp/bsd_iso_work and written to a new .iso image

MNTDIR=/mnt/bsd_iso
WORKROOT=/tmp/bsd_iso_work
PKGROOT=/tmp/bsd_iso_pkgs
DISTDIR=${WORKROOT}/usr/freebsd-dist

ISONAME=""
PLIST=""
MD_DEV=4
# TODO will probably require changing per system
DISK_PARTITION="vtbd0"
PKG='pkg -r '"${PKGROOT}"

# non interactive pkg
export ASSUME_ALWAYS_YES=yes

# ################################################ 
# Function declarations
# ################################################ 
# prints out the command and runs it
cmd() {
    echo "$@"
    "$@"
}

# ################################################ 
# mounts ISONAME at MNTDIR
mount_img() {
    echo "Mounting ${ISONAME} at ${MNTDIR}"
    
    # NOTE:
    #       md node should be /dev/md${MD_DEV} for default
    # create vnode to mount under
    mdconfig -a -t vnode -f ${ISONAME} -u ${MD_DEV}
    mount -t cd9660 /dev/md${MD_DEV} ${MNTDIR}
}

# ################################################ 
# unmounts ISONAME at MNTDIR
 unmount_img() {
    echo "Unmounting ${ISONAME} from ${MNTDIR}"
    
    umount ${MNTDIR}
    # delete vnode (default is /dev/md${MD_DEV})
    mdconfig -d -u ${MD_DEV}
}

# ################################################ 
# writes WORKROOT to a new .iso file
write_new_img() {
    
    # change name from FreeBSD___.iso to FreeBSD___-packed.iso
    NEWISONAME="$(basename ${ISONAME} | sed -e 's/.iso//g')-custom.iso"

    echo "Writing new install package ./${NEWISONAME}"
    
    TARGET="$(echo "${NEWISONAME}" | cut -f4 -d'-')"
    # terrible way of hacking the iso label out of the iso name
    VOLUME_LABEL="$(echo "${NEWISONAME}" | cut -f 2-4 -d'-' \
                                         | cut -f -2 -d'.' \
                                         | sed -e 's/-/_/g' -e 's/\./_/g' \
                                         | awk '{print toupper($1)}')"

    echo "VOLUME_LABEL = ${VOLUME_LABEL}"
    
    # run machine dependent script to build install .iso
    sh /usr/src/release/${TARGET}/mkisoimages.sh -b ${VOLUME_LABEL} \
                                      ${NEWISONAME} ${WORKROOT}
}

# ################################################ 
# removes directory listings
remove_dirs() {
    rm -rf ${WORKROOT}
    rm -rf ${PKGROOT}
}

# ################################################ 
# sets up unattended install defaults
install_config() {
    # custom install actions are placed in /etc/installerconfig script
    CONFIG=${WORKROOT}/etc/installerconfig
    touch ${CONFIG}
    echo "echo \"Custom Preamble -------\"" >> ${CONFIG}
    echo "PARTITIONS=${DISK_PARTITION}" >> ${CONFIG}
    echo "DISTRIBUTIONS=\"base.txz kernel.txz ports.txz custom-pkgs.txz\"" >> ${CONFIG}
    
    # configure internet for downloads
    # echo "dhclient vtnet0" >> ${CONFIG}
    
    echo "" >> ${CONFIG}
    
    # special case rc.conf modifications
    echo "#! /bin/sh" >> ${CONFIG}
    
    # keep installer from rebooting (usefull for vms)
    echo "poweroff" >> ${CONFIG}
}

# ################################################ 
# BEGIN MAIN
# ################################################ 

# create directories if needed
remove_dirs
mkdir -p ${MNTDIR}
mkdir -p ${WORKROOT}
mkdir -p ${PKGROOT}

if [ "$#" -lt 2 ]; then
    echo "Usage: sh bsdpack.sh /path/to/.iso /path/to/plist"
    exit
fi

# read in command arguments

# install ports tree flag
if [ "x$1" = "x-p" ]; then
    echo "Installing ports enabled"
    # ignore this flag for now (TODO: add ports)
    shift
fi

ISONAME=$1; shift
PLIST=$1; shift

# mount the .iso
mount_img

# copy image to r/w direcotry ${WORKROOT}
echo "--------------------------------------------------"
echo "Copying filesystem from ${MNTDIR} to ${WORKROOT}..."
echo "--------------------------------------------------"
cp -R ${MNTDIR}/* ${WORKROOT}/

# use pkg to fill new image tree
echo "--------------------------------------------------"
echo "Installing packages in ${WORKROOT}..."
echo "--------------------------------------------------"

# configure installation
install_config

# install packages in directory to tar
PACKAGES=`cat ${PLIST}`
for p in ${PACKAGES}; do
    cmd ${PKG} install $p
done

# pack up the custom stuff as a distribution tar
echo "--------------------------------------------------"
echo "Creating distribution file ${DISTDIR}/custom-pkgs.txz..."
echo "--------------------------------------------------"
cd ${PKGROOT}
tar -cvJpf ${DISTDIR}/custom-pkgs.txz ./
cd -

# pretty self explanatory by the function name
echo "--------------------------------------------------"
write_new_img
echo "--------------------------------------------------"

# unmount and free vnode
echo "--------------------------------------------------"
echo "Deleting ${WORKROOT}..."
echo "--------------------------------------------------"
remove_dirs
unmount_img
