#!/usr/bin/env bash
########################################################################
# dssp_packager - Roll your own DSSP debian package!
#
# https://github.com/sseemayer/dssp_packager
########################################################################


# FTP URLs to get DSSP from
dssp_64='ftp://ftp.cmbi.ru.nl/pub/software/dssp/dssp-2-linux-amd64.gz'
dssp_32='ftp://ftp.cmbi.ru.nl/pub/software/dssp/dssp-2-linux-i386.gz'
version='2.0'


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
		echo -e "\nPackage $1 is not installed, please install by typing (as root):" 2>&1
		echo -e "\n\t# apt-get install $1\n" 2>&1
		exit 1
	fi

}

# Determine version to download according to architecture
if [ $(uname -m) == "x86_64" ]; then
	dssp_tarball_url=$dssp_64
	architecture='amd64'
else 
	dssp_tarball_url=$dssp_32
	architecture='i386'
fi

echo Checking required packages...
ensure_installed build-essential
ensure_installed wget
ensure_installed gnupg


identity=$(gpg -k | grep uid | cut -b 22- | head -n1);
builddir=build
timestamp=$(date -R)

echo -e "\nChecking GPG Private Key..."
if [ "$identity" == "" ]; then
	echo -e "No GPG private key was found!\nPlease use gpg --gen-key to generate one!\n\n" 1>&2
	exit 1
else 
	echo -e "Will use identity: $identity\n"
	read -p "Is this OK (Y/n)? "
	
	if [ "$REPLY" != "y" -a "$REPLY" != "Y" -a "$REPLY" != "" ]; then
		echo -e "\nPlease make sure that the identity you with to use is the first one in your gpg -k output." >&2
		exit 1
	fi
fi

echo -e "\nChecking environment..."
test -d debian_template || fail "Could not find template in debian_template!"


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

echo -e "\nFinished extracting. Customizing Debian Package..."
cp -r debian_template/ $builddir/debian || fail "Could not copy over template!"

# this is required or dh_installdocs will fail
touch $builddir/README

for file in $( find $builddir/debian -type f ); do

	sed -i "s/%IDENTITY%/$identity/g" $file
	sed -i "s/%VERSION%/$version/g" $file
	sed -i "s/%TIMESTAMP%/$timestamp/g" $file
	sed -i "s/%ARCHITECTURE%/$architecture/g" $file

done;


echo "\nFinished customization. Building package..."
pushd $builddir
dpkg-buildpackage || fail "Could not build package!"
popd

echo -e "\nALL DONE. Find the package at dssp_${version}_${architecture}.deb\n\nNote: dssp requires libstdc++6 version >= 4.6. This is _not_ available in Debian squeeze, you will have to enable testing."
