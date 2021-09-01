# SPDX-License-Identifier: GPL-2.0
#
# Makefile for the ntfs3 filesystem support.
#

KMODNAME=ntfs3
KMODVER=v27_20210901.lore

obj-$(CONFIG_NTFS3_FS) += ntfs3.o

ntfs3-objs :=	attrib.o \
		attrlist.o \
		bitfunc.o \
		bitmap.o \
		dir.o \
		fsntfs.o \
		frecord.o \
		file.o \
		fslog.o \
		inode.o \
		index.o \
		lznt.o \
		namei.o \
		record.o \
		run.o \
		super.o \
		upcase.o \
		xattr.o \
		lib/decompress_common.o \
		lib/lzx_decompress.o \
		lib/xpress_decompress.o \

ifeq ($(KERNELRELEASE),)
	KERNELRELEASE ?= $(shell uname -r)
endif
KDIR ?= /lib/modules/${KERNELRELEASE}/build
MDIR ?= /lib/modules/${KERNELRELEASE}
PWD  := $(shell pwd)

export CONFIG_NTFS3_FS := m
export CONFIG_NTFS3_64BIT_CLUSTER := n
export CONFIG_NTFS3_LZX_XPRESS := y
export CONFIG_NTFS3_FS_POSIX_ACL := y

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

help:
	$(MAKE) -C $(KDIR) M=$(PWD) help

dkms:
	mkdir -p /usr/src/${KMODNAME}-${KMODVER}/
	cp -R . /usr/src/${KMODNAME}-${KMODVER}/
	dkms add -m ${KMODNAME} -v ${KMODVER}
	dkms build -m ${KMODNAME} -v ${KMODVER}
	dkms install -m ${KMODNAME} -v ${KMODVER}

dkms-uninstall:
	dkms remove -m ${KMODNAME} -v ${KMODVER}

install: ntfs3.ko
	rm -f ${MDIR}/kernel/fs/ntfs3/ntfs3.ko
	install -m644 -b -D ntfs3.ko ${MDIR}/kernel/fs/ntfs3/ntfs3.ko
	depmod -aq

uninstall:
	rm -rf ${MDIR}/kernel/fs/ntfs3
	depmod -aq

.PHONY : all clean install uninstall
