DSSP_packager
=============

Check out the DSSP homepage at http://swift.cmbi.ru.nl/gv/dssp/

Since the DSSP license does not allow users to redistribute DSSP, it is not possible for third parties to create a DSSP package for their Linux distribution and distribute DSSP in this form for easier installation.

DSSP_packager is a shell script that helps users in creating their own Debian package for personal use.

Licensing
---------

DSSP_packager is released under the GNU GPL 3, but by using DSSP_packager, you also agree to the stricter DSSP license agreement. In particular, this means that you may not redistribute DSSP or the DSSP package which you have generated.

If you're interested in using DSSP, please check our their [License](http://swift.cmbi.ru.nl/gv/dssp/HTML/license.html). **You will have to fill out their license agreement and fax / snail mail it back to them before using DSSP_packager** or you are not allowed to download DSSP!

Please make sure to also [cite DSSP](http://swift.cmbi.ru.nl/gv/dssp/DSSP_1.html) in your work!

Usage
-----

DSSP_packager will require the following to be installed on the build system (should be a Debian system, too):

* apt, dpkg
* wget, gunzip, sed
* gpg

On the system running the DSSP package, make sure to install a libstdc++6 version greater than 4.6 - this is not available in Debian squeeze, so install it from testing instead.

Support, Bugs
-------------

This is a very early version, so I expect plenty of bugs - If you think I made a mistake, feel free to add new entries to the [issue tracker](https://github.com/sseemayer/dssp_packager/issues)

You can also contact me with general installation questions at seemayer (at) rostlab (dot) org.
