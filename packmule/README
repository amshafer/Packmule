				packmule
                              Austin Shafer

Packmule fills a FreeBSD installation .iso with custom packages. The added packages are 
installed along with the regular contents of FreeBSD. Useful for generating install images 
with all your normal utilities included.

	Usage: packmule [-y config.yml] <FreeBSD-installation.iso>

Packmule will install packages and custom content described by the config YAML file. This 
makes describing a packing list very readable and efficient.  The default config is the file 
./packmule.yml. The config file can be specified with the "-y" argument. There are two major 
sections of the config, PKGS and CUSTOM. PKGS should simply be a list of package names to be 
installed with the "pkg" utility. CUSTOM should be a list of hashes for installing software not 
installable by PKGS. CUSTOM's keys should be a location of a file to install on the computer 
running packmule. The values should be the location to install the key files at under the 
installation image. 

Here is an example config.yml:

---
PKGS:						# installs using "pkg"
 - perl5-5.24.3					# pkg install perl5-5.24.3
 - nethack36					# pkg install nethack36
 - gnome3					# pkg install gnome3
CUSTOM:						# copy custom files into install image
 /etc/resolv.conf : /etc/resolv.conf  		# copy host's resolv.conf to image 
 /etc/hosts : /etc/hosts			# copy host's hosts to image 

The above example is much smaller than what is useful. This configuration will install perl, 
nethack, and gnome3 in the installation image. It also copies in useful files such as resolv.conf 
and hosts. This is useful for installing custom configuration files automatically on a system, 
particularly in the case of VM's. A installation image could use this to include your rc.conf, 
.bashrc, .emacs, etc.

Packmule was reborn out of a shell script called bsdpack.sh. bsdpack was rewritten because of its 
overcomplicated configuration setup and inefficient string operations. Packmule added the use of 
YAML and Perl's regex functionality. The underlying install loading functions remained the same. 

The tool works in five major stages:

    1) the .iso is mounted under $mntdir
    
    2) contents of the read-only .iso are copied into $workroot

    3) the plist is read and each package is installed under $pkgroot
       	   $pkgroot is compressed and added to $workroot/usr/freebsd-dist
	   to be installed as a distribution file

    4) The $workroot is written into a installation .iso by the appropriate script

    5) the .iso is unmounted and all directories are cleaned up

