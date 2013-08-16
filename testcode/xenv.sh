#!/bin/bash


Usage() {
	echo 'Pls make sure the 3 rules:
  1, This script must be put into root folder of project.
                          proRoot
                             |
               +--------+----+----+--------+
               |        |         |        |
              env.sh   cdk3    openwrtv5  mppv5
  2, Dont call it from diff working directory. 
  3, Run it: source ./env.sh $platform
       E.g:   . env.sh 58
             Or
              . env.sh 18'
}

PRO_ROOT=`pwd`

MPP_ROOT=$PRO_ROOT/mppv5/trunk
OPENWRT_ROOT=$PRO_ROOT/openwrtv5
export MPP_ROOT

# May be reset late.
CDK_ROOT=$PRO_ROOT/cdk3

if [ "$#" = 0 ]; then
	Usage
	return
fi

# If call me in a diff working directory OR code is not complete.
if [ ! -d "mppv5" -o ! -d "openwrtv5" -o ! -d "cdk3" ]; then
	Usage
	return
fi

cd $OPENWRT_ROOT/package/semptian
if [ -L "mpp" ]; then
	echo "#### Skip mpp link ####"
else
	ln -sv $MPP_ROOT/openwrt/package/mpp mpp
fi

if [ -L "mvswitch" ]; then
	echo "#### Skip mvswitch link ####"
elif [ -d "$PRO_ROOT/mvswitch" ]; then
	ln -sv $PRO_ROOT/mvswitch mvswitch
fi

case "$1" in
	"58")
		echo '58 platform.'
		cd $OPENWRT_ROOT/package/semptian/oct-linux-csr/src
		rm -f Makefile
	   	ln -sv Makefile.58 Makefile

		cd $OPENWRT_ROOT/package/semptian/phy_opr/src
		rm -f Makefile
		ln -sv Makefile.58 Makefile

		cd $OPENWRT_ROOT/target/linux/octeon/image/
		rm -f Makefile
		ln -sv Makefile_58 Makefile

		cd $OPENWRT_ROOT/semptian/
		rm -f config-2.6.32
		ln -sv config-2.6.32-58 config-2.6.32

		cd $OPENWRT_ROOT/package/base-files/files/etc/
		rm -f rc.local
		ln -sv rc.local.58 rc.local

		cd $OPENWRT_ROOT
		cp -fv semptian/openwrt_v5_config .config

		cd $CDK_ROOT
		. env-setup --verbose OCTEON_CN68XX
		;;
	"18")
		echo '18 platform.'
		CDK_ROOT=$PRO_ROOT/cdk2
		cd $OPENWRT_ROOT/package/semptian/oct-linux-csr/src
		rm -f Makefile
		ln -sv Makefile.18 Makefile

		cd $OPENWRT_ROOT/package/semptian/phy_opr/src
		rm -f Makefile
		ln -sv Makefile.18 Makefile

		cd $OPENWRT_ROOT/target/linux/octeon/image/
		rm -f Makefile
		ln -sv Makefile_18 Makefile

		cd $OPENWRT_ROOT/semptian/
		rm -f config-2.6.32
		ln -sv config-2.6.32-18 config-2.6.32

		cd $OPENWRT_ROOT/package/base-files/files/etc/
		rm -f rc.local
		ln -sv rc.local.18 rc.local

		cd $OPENWRT_ROOT
		cp -fv semptian/mpp_veryok_config .config

		cd $CDK_ROOT
		. env-setup --verbose OCTEON_CN56XX_PASS2
		;;

	"clean"|"distclean")
		cd $OPENWRT_ROOT && make "$1"
		cd $PRO_ROOT/cdk3/linux/kernel_2.6/linux/ && make "$1"
		cd $PRO_ROOT/OCTEON-SDK/linux/kernel_2.6/linux/ && make "$1"
		;;
	*)
		Usage
		cd $PRO_ROOT
		return
		;;
esac

cd $PRO_ROOT
echo done
