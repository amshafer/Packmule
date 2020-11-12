PACKMULE(1) - FreeBSD General Commands Manual

# NAME

**packmule** - Creates and packs custom FreeBSD installation images

# SYNOPSIS

**packmule**
\[-DR] \[-y config.yml] \[--no-pkg-scripts -I] &lt;FreeBSD.iso&gt;

# DESCRIPTION

Packmule packs a FreeBSD installation (.iso) image with custom content, making it useful for generating install images with all your normal utilities included. The added packages are installed along with the regular contents of FreeBSD. The generated images have the form **\*-packed.iso**. Installation can proceed as normal with the packed software showing up on the newly installed system alongside the FreeBSD base.

Packmule will install packages and custom content described by the config YAML file. This makes describing a packing list very readable and efficient. The default config is the file **./packmule.yml**. The config file can be specified with the "-y" argument. There are two major sections of the config, PKGS and CUSTOM. PKGS should simply be a list of package names to be installed with the "pkg" utility. CUSTOM should be a list of key-value pairs for installing software not installable by PKGS. CUSTOM's keys should be a location of a file to install on the computer running packmule. The values should be the location to install the key files at under the installation image. During distribution extraction **bsdinstall(8)** should show **packmule-pkgs.txz** alongside the other archives as it extracts the added content. Packmule can also create an unattended installation image from a regular installation image using the INSTALLERCONFIG section of the configuration file.

Packmule is written in Perl, and all variables starting with **$** in this doc reference the variable names used in the Packmule script. These variables are included to help the reader follow both the script itself and the debugging output if they should choose to read it. The leading **$** is kept to differentiate these Perl variables from environment variables.

# OPTIONS

**-U**

> Build USB memstick images instead of an iso. This is the same as the FreeBSD-\*.img images available for download online. They have a different partition layout and internally require a different script to build.

**-R**

> The Remove flag. Shortcut to unmount packmule's resources and remove its working directories. Use this to clean up the mule's droppings that are left behind after an error.

**-D**

> The Debug flag. Useful for development. Does everything except tar **$pkgroot** and create the installation iso. This can be used to see exactly what packmule does as far as installing and copying packages.

**-y** *config.yml*

> The '-y' flag specifies the input YAML file to use as a packing list. The default configuation file is './packmule.yml'. The pathname of the config file to use must follow the '-y' flag.

**-I,--no-pkg-scripts**

> Used as a workaround to pkg pre-install failures, specifically those caused by failing to create a new user or group. If you encounter pkg install failures try using this option. See the LIMITATIONS section for more info.

# CONFIGURATION

Packmule is configured using the **YAML** configuration language. The default configuration file is **./packmule.yml** but it is recommended to specify a different path using the **-y** argument. The three main sections are as follows:

*PKGS*

> This section holds names of packages to be installed through the **pkg(8)** tool. They are installed in the new image using the **$workroot** directory as the root.

*CUSTOM*

> Individual files or directories to be copied into the new image. Values are separated by **:**, with the value on the left being the source file and the value on the right being the destination. (** /path/to/src : /install/location**)

*LIVE\_CD\_PKGS*

> Same as **PKGS**, but intalls onto the live cd image instead of the host.

*LIVE\_CD\_CUSTOM*

> Same as **CUSTOM**, but intalls onto the live cd image instead of the host.

*INSTALLERCONFIG*

> A path to an **installerconfig** script to be used for an unattended installation. More information about unattended installations and installerconfigs can be found in **bsdinstall(8)**

Here is an example configuration (config.yml):
\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**PKGS:**
 \- perl5-5.24.3
 \- nethack36
 \- gnome3

**CUSTOM:**
 /root/.shrc : /root/.shrc
 /etc/hosts : /etc/hosts

**LIVE\_CD\_PKGS**
 /etc/rc.conf : /etc/rc.conf

**INSTALLERCONFIG** : ~user/installerconfig
\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

The above example is much smaller than what is useful. This configuration will install perl, nethack, and gnome3 in the installation image. It also copies individual files such as resolv.conf and hosts. This is useful for installing custom configuration files automatically on a system, particularly in the case of VM's. A installation image could use this to include your rc.conf, .bashrc, .emacs, etc.

# TIPS

If you plan on running packmule with **sudo(8)** ensure that all home directory shortcuts contain the name of the user who they belong to. (i.e. ~/ would be replaced with ~username/) It is even better to simply use absolute pathnames to avoid confusion.

# HOW IT WORKS:

Packmule was reborn out of a shell script called bsdpack.sh. bsdpack was rewritten because of its overcomplicated configuration setup and inefficient string operations. Packmule added the use of YAML and Perl's regex functionality. The underlying install loading functions remained the same.

The tool works in five major stages:
    1\) the .iso is mounted under **$mntdir**
    2\) contents of the read-only .iso are copied into **$workroot**
    3\) the plist is read and each package is installed under **$pkgroot**
           **$pkgroot** is compressed and added to **$workroot/usr/freebsd-dist**
           to be installed as a distribution file
    4\) The **$workroot** is written into a installation .iso by the appropriate **mkisoimages.sh** script
    5\) the .iso is unmounted and all directories are cleaned up

# LIMITATIONS:

        The main limitation of packmule is that user and group creation may fail during the pre-install scripts on certian packages. An example of this is the mongodb package. Packmule uses 'pkg -r' to install packages under the **$pkgroot** directory (/tmp/bsd-iso-pkg/). The '-r' flag is not a full chroot, meaning that the passwd db files must go through a hack involving copying them into **$pkgroot** and then back to **$workroot**. This is clumsy and not ideal, but is necessary to have packages create groups upon installation. For packages that have issues of this type, use the '--no-pkg-scripts' flag to ignore the pre-installation scripts. This limits the usefulness but is a useful workaround.
         As an example, mongodb attempts to create a user and a group before it is installed. Packmule will successfully create these, but the pre-install script for the mongodb pkg still fails under certain conditions. Because packmule does not do a full chroot when installing, mongodb's pre-install script will check if the host machine has a mongodb user/group. If it does not, the script fails even though packmule has made the user/group in the installation image's passwd db. Running '-I' keeps this error from occurring but means the user must manually create the user/group after installation.

# AUTHORS

Austin Shafer
&lt;ashafer@badland.io&gt;

FreeBSD 13.0-CURRENT - January 3, 2019
