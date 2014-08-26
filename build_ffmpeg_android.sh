#!/bin/bash

export FFMPEG_VERSION=64e4bd7414fc05745e1a723b4da0a44fe7b0558b

ffmpeglocalPath=`pwd`
export configure_test_file_name=.eagle_configured

function clean_gpl
{
rm -r -f libpostproc
rm -r -f libavfilter/libmpcodecs
rm -f libavcodec/x86/idct_mmx*
rm -f libavcodec/libutvideo*.cpp
rm -f libavdevice/x11grab.c
rm -f libswresample/swresample-test.c
rm -f doc/texi2pod.pl
rm -f libavfilter/f_ebur128.c
rm -f libavfilter/vf_blackframe.c
rm -f libavfilter/vf_boxblur.c
rm -f libavfilter/vf_colormatrix.c
rm -f libavfilter/vf_cropdetect.c
rm -f libavfilter/vf_delogo.c
rm -f libavfilter/vf_geq.c
rm -f libavfilter/vf_histeq.c
rm -f libavfilter/vf_hqdn3d.c
rm -f libavfilter/vf_kerndeint.c
rm -f libavfilter/vf_mcdeint.c
rm -f libavfilter/vf_mp.c
rm -f libavfilter/vf_owdenoise.c
rm -f libavfilter/vf_perspective.c
rm -f libavfilter/vf_phase.c
rm -f libavfilter/vf_pp.c
rm -f libavfilter/vf_pullup.c
rm -f libavfilter/vf_sab.c
rm -f libavfilter/vf_smartblur.c
rm -f libavfilter/vf_spp.c
rm -f libavfilter/vf_stereo3d.c
rm -f libavfilter/vf_super2xsai.c
rm -f libavfilter/vf_tinterlace.c
rm -f libavfilter/vsrc_mptestsrc.c
}

function build_one
{
mkdir $PREFIX
./configure \
--prefix=$PREFIX \
--disable-doc \
--disable-programs \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-ffserver \
--disable-avdevice \
--disable-symver \
--disable-devices \
--disable-outdevs \
--disable-indevs \
--disable-debug \
--disable-static \
--disable-decoder=mpeg1_vdpau \
--disable-decoder=mpeg1video \
--disable-decoder=mpeg2_crystalhd \
--disable-decoder=mpeg2video \
--disable-decoder=mpeg4 \
--disable-decoder=mpeg4_crystalhd \
--disable-decoder=mpeg4_vdpau \
--disable-decoder=mpeg_vdpau \
--disable-decoder=mpeg_xvmc \
--disable-decoder=mpegvideo \
--disable-decoder=msmpeg4_crystalhd \
--disable-decoder=msmpeg4v1 \
--disable-decoder=msmpeg4v2 \
--disable-decoder=msmpeg4v3 \
--disable-encoders \
--enable-encoder=png \
--enable-encoder=bmp \
--enable-encoder=mjpeg \
--enable-encoder=ljpeg \
--enable-shared \
--enable-avformat \
--enable-avcodec \
--enable-avutil \
--enable-swresample \
--enable-swscale \
--cross-prefix=$ANDROID_TOOLCHAIN/bin/arm-linux-androideabi- \
--target-os=linux \
--arch=arm \
--enable-cross-compile \
--sysroot=$ANDROID_SYSROOT \
--extra-cflags="-O3 -enable-pthreads -fPIC -DANDROID -DPIC -fasm -fno-short-enums -fno-strict-aliasing -I${ANDROID_TOOLCHAIN}/include $OPTIMIZE_CFLAGS " \
--extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -lc -lm -ldl -llog" \
$ADDITIONAL_CONFIGURE_FLAG
echo "... Done. make -j$COMPILER_NUM_THREADS"
make -j$COMPILER_NUM_THREADS
echo "... Done. make -j$COMPILER_NUM_THREADS install"
make -j$COMPILER_NUM_THREADS install
}

if [ -d "ffmpeg_source" ]; then
	echo "ffmpeg cloned."
else
	echo "ffmpeg not cloned... cloning"
	git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg_source
fi

cd ffmpeg_source

remote=$(
    git ls-remote -h origin master |
    awk '{print $1}'
)
local=$(git rev-parse HEAD)

echo -e "* FFmpeg Status:\n\t- Local Revision: \t$local \n\t- Remote Revision: \t$remote"
if [ "$LIBRARY_UPDATE" = true -o "$FFMPEG_VERSION" != "$local" ]
then
	if [ "$local" != "$remote" ]
	then
		echo "FFmpeg not up-to-date"
		echo "Cleaning old FFmpeg configuration... "
		rm config.mak
		rm config.fate
		rm config.log
		rm config.h
		rm -r android
		echo "... Done. Make Clean..."
		make clean
		rm $configure_test_file_name
		echo "... Done. Updating FFmpeg..."
		git reset --hard
		git checkout master
		git pull
		echo "Done."
	else
		echo "FFmpeg up-to-date"
	fi
fi
if [ -f $configure_test_file_name ]; then
	echo "ffmpeg configured and built."
else
	echo "ffmpeg not configured. configuring and building ffmpeg..."
	if [ "$LIBRARY_UPDATE" = true ]
	then
		git checkout master
	else
		git checkout $FFMPEG_VERSION
	fi
	clean_gpl
	chmod +x configure
	chmod +x version.sh
	patch < ../configure.patch
	#arm v7n
	CPU=armv7-a
	OPTIMIZE_CFLAGS="-mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -marm -mvectorize-with-neon-quad -march=$CPU -I${ANDROID_SYSROOT}/usr/include"
	PREFIX=./android/$CPU
	ADDITIONAL_CONFIGURE_FLAG=--enable-neon
	build_one

	cat ../Template_Android.mk > $PREFIX/Android.mk
	rm -r -f $ANDROID_NDK_ROOT/sources/eagle/ffmpeg
	mkdir $ANDROID_NDK_ROOT/sources/eagle
	mkdir $ANDROID_NDK_ROOT/sources/eagle/ffmpeg
	cp -R ./android $ANDROID_NDK_ROOT/sources/eagle/ffmpeg/
	cp ../copy_lib_to_device.sh	$ANDROID_NDK_ROOT/sources/eagle/ffmpeg/android/armv7-a/lib/copy_lib_to_device.sh
	echo "To copy the FFmpeg libraries to the device you can use the script $ANDROID_NDK_ROOT/sources/eagle/ffmpeg/android/armv7-a/lib/copy_lib_to_device.sh"
	touch $configure_test_file_name && echo "ffmpeg configured and built."
fi

cd $ffmpeglocalPath