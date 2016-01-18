Random notes on the stock firmware
==================================

The stock mtd layout is as follows:
````
dev:    size   erasesize  name
mtd0: 00030000 00010000 "u-boot"
mtd1: 00010000 00010000 "u-boot-env"
mtd2: 000f0000 00010000 "kernel"
mtd3: 00280000 00010000 "rootfs"
mtd4: 00030000 00010000 "rootfs_data"
mtd5: 00020000 00010000 "language"
mtd6: 00010000 00010000 "pot"
mtd7: 00010000 00010000 "config"
mtd8: 00010000 00010000 "art"
mtd9: 00370000 00010000 "firmware"
````

The most recent firmware (v1.0.1.8) can be downloaded here:

ftp://updates1.netgear.com/ex2700/ww/EX2700-V1.0.1.8.img
ftp://updates1.netgear.com/ex2700/ww/EX2700-V1.0.0.43Eng-Language-table

### /dev/mtd5 (language)

The first four bytes contain a 3-character language identifier (`Eng` for
English), followed by a newline (`0x0a`). Starting at offset 0x04, this 
partition essentially contains a `.tar` file which in turn contains a
`.tar.gz` (yes, really) called `language_table.tar.gz`. This tarball contains
a javascript file with translations for the web interface.

### /dev/mtd6 (config)

This partition stores the configuration of the stock firmware. The partition
uses the following header:

````
struct hdr_config {
	uint8_t magic[4]; // { 0x24, 0x02, 0x14, 0x20 }
	uint16_t len; // length of configuration data (file length - 7)
	uint16_t zero; // always zero
	uint32_t unknown; // checksum maybe?
````

### /dev/mtd7 (art)

Stores data such as mac addresses, hardware id, etc. Some of these entries can
be set via `artmtd`. Starting at offset `0x1500` is the EEPROM data for the WiFi
adapter. Some intersting offsets:

* `0x00`: LAN MAC address
* `0x06`: WAN MAC address (same as LAN MAC address)
* `0x0c`: WLA MAC adddres (ff:ff:ff:ff:ff)
* `0x12`: WPS pin (9 characters)
* `0x1a`: serial number (14 characters)
* `0x28`: region number (`word`, `0x0002` is world-wide)
* `0x3e`: board model id (NUL byte delimited string)
* `0x48`: default SSID (NUL byte delimited string)

