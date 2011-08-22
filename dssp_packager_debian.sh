#!/usr/bin/env bash
########################################################################
# dssp_packager - Roll your own DSSP debian package!
#
# https://github.com/sseemayer/dssp_packager
########################################################################


# FTP URLs to get DSSP from
dssp_64='ftp://ftp.cmbi.ru.nl/pub/software/dssp/dssp-2-linux-amd64.gz'
dssp_32='ftp://ftp.cmbi.ru.nl/pub/software/dssp/dssp-2-linux-i386.gz'


builddir=build

# fail : Exit with an error message
function fail {
	echo "ERROR: $1" 1>&2;
	exit 1
}

# ensure_installed : Make sure a Debian Package is installed or exit
function ensure_installed {

	dpkg -l $1 > /dev/null 2>&1
	INSTALLED=$?

	if [ $INSTALLED == '0' ]; then
		echo "$1 is installed, OK"
	else
		echo -e "\nPackage $1 is not installed, please install by typing (as root):"
		echo -e "\n\t# apt-get install $1\n"
		exit 1
	fi

}

# Determine version to download according to architecture
if [ $(uname -m) == "x86_64" ]; then
	dssp_tarball_url=$dssp_64
else 
	dssp_tarball_url=$dssp_32
fi


echo Checking environment...
test -d debian_template || fail "Could not find template in debian_template!"

echo Checking required packages...
ensure_installed build-essential
ensure_installed wget

if [ -d $builddir ]; then
	echo -e "\nFinished dependency checking. Cleaning up workspace in $builddir"
	rm -rf $builddir || fail "Could not remove old build directory!"
else
	echo -e "\nFinished dependency checking."
fi

echo -e "\nMaking new work directory in $builddir"
mkdir -p $builddir || fail "Could not create work directory!"

echo -e "\nDownloading DSSP..."
wget -O $builddir/dssp.gz $dssp_tarball_url || fail "Could not download DSSP!"

echo -e "\nFinished downlading. Extracting..."
(gunzip -f $builddir/dssp.gz && chmod +x $builddir/dssp) || fail "Could not extract DSSP!"

echo -e "\nFinished extracting. Building package..."
cp -r debian_template/ $builddir/debian || fail "Could not copy over template!"
