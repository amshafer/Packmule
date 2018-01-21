bsdpack fills a FreeBSD installation .iso with custom packages. The added packages are installed along with the regular contents of FreeBSD. Useful for generating install images with all your normal utilities included.

	Usage: sh bsdpack.sh <FreeBSD-installation.iso> <plist>

The "plist" argument is a file containing a list of the names of packages to install. More specifically, this is a list of packages to be installed by the "pkg" tool. These package names must be recognized by "pkg" so it is recommended they are found by "pkg search".

Because bsdpack adds an /etc/installerconfig to the new installation .iso when the image is installed it will do so automatically. This is primarily for convenience but can be disabled if necessary by commenting out the install_config function call.

The tool works in five major stages:

    1) the .iso is mounted under ${MNTDIR}
    
    2) contents of the read-only .iso are copied into ${WORKROOT}

    3) the plist is read and each package is installed under ${PKGROOT}
       	   ${PKGROOT} is compressed and added to ${WORKROOT}/usr/freebsd-dist
	   to be installed as a distribution file

    4) The ${WORKROOT} is written into a installation .iso by the appropriate script

    5) the .iso is unmounted and all directories are cleaned up

