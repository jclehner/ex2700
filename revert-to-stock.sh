#!/bin/sh

pad_kb() {
	local file="$1"
	local kb="$2"
	local max=$(($kb*1024))
	local len=$(wc -c "$file" | awk '{ print $1 }')

	if [ $len -gt $max ]; then
		echo >&2 "Error: \"$file\" exceeds $kb kb"
		exit 1
	fi

	dd if=/dev/zero bs=$(($max-$len)) count=1 >> "$file"
}

if ! grep -q "EX2700" /proc/cpuinfo && test -z "$I_AM_NOT_A_FREAK"; then
	echo >&2 "Error: wrong device, you freak!"
	exit 1
fi

cd /tmp
rm -f firmware.bin language.bin
wget -O - ftp://updates1.netgear.com/ex2700/ww/EX2700-V1.0.1.8.img | tail -c+129 > firmware.bin || exit 1
wget -O language.bin ftp://updates1.netgear.com/ex2700/ww/EX2700-V1.0.0.43Eng-Language-table || exit 1

pad_kb firmware.bin 3520
pad_kb language.bin 128

cat language.bin >> firmware.bin
rm language.bin

# add padding for "pot" and "config" partitions too
pad_kb firmware.bin $((3520+128+64+64))

echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!! This will revert your device to stock firmware !!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo
echo -n "Press enter to continue, or Ctrl-C to abort. "
read answer

echo "Flashimg image. No turning back now!"
mtd write -r /tmp/firmware.bin firmware
