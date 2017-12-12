A set of basic bhyve vm scripts. These are very specific and not flexible. They are included as an example of the FreeBSD Handbook's method for starting a vm.

Required Files:
	 ~/hyve - location to install vm.
	 ~/hyve/bsdguest - location of my particular vm
	 ~/hyve/bsdguest/custom-bsd.img - img used as filesystem for vm

Network Interfaces:
	bridge0 - has members alc0 and tap0
		      (replace alc0 with your interface)
	tap0 - should be created by installbsdguest

Scripts:
	installbsdguest - takes installation .iso as an argument
	runbsdguest - runs vm in ~/hyve/bsdguest/custom-bsd.img

NOTE: set USER in the scripts to your username if using sudo
NOTE: scripts must be run as root