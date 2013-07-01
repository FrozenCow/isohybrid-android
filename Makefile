PROGRAM=isohybrid
NDK=/opt/android-ndk
TOOLCHAIN=$(NDK)/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-
CC=$(TOOLCHAIN)gcc

UUID=e2fsprogs/lib/uuid
SYSLINUX=syslinux

CFLAGS=--sysroot=$(NDK)/platforms/android-14/arch-arm -I$(UUID)/..
LDFLAGS=--sysroot=$(NDK)/platforms/android-14/arch-arm

ISOHYBRID_SRCS := $(SYSLINUX)/utils/isohdpfx.c $(SYSLINUX)/utils/isohybrid.c
ISOHYBRID_OBJS := isohdpfx.o isohybrid.o

UUID_OBJS := clear.o \
	compare.o \
	copy.o \
	gen_uuid.o \
	isnull.o \
	pack.o \
	parse.o \
	unpack.o \
	unparse.o \
	uuid_time.o

UUID_CFLAGS := $(CFLAGS) \
	-DHAVE_INTTYPES_H \
	-DHAVE_UNISTD_H \
	-DHAVE_ERRNO_H \
	-DHAVE_NETINET_IN_H \
	-DHAVE_SYS_IOCTL_H \
	-DHAVE_SYS_MMAN_H \
	-DHAVE_SYS_MOUNT_H \
	-DHAVE_SYS_PRCTL_H \
	-DHAVE_SYS_RESOURCE_H \
	-DHAVE_SYS_SELECT_H \
	-DHAVE_SYS_STAT_H \
	-DHAVE_SYS_TYPES_H \
	-DHAVE_STDLIB_H \
	-DHAVE_STRDUP \
	-DHAVE_MMAP \
	-DHAVE_UTIME_H \
	-DHAVE_GETPAGESIZE \
	-DHAVE_LSEEK64 \
	-DHAVE_LSEEK64_PROTOTYPE \
	-DHAVE_EXT2_IOCTLS \
	-DHAVE_LINUX_FD_H \
	-DHAVE_TYPE_SSIZE_T \
	-DHAVE_SYS_TIME_H \
	-DHAVE_SYS_PARAM_H \
	-DHAVE_SYSCONF

all: $(PROGRAM)

isohybrid: $(ISOHYBRID_OBJS) $(UUID_OBJS)
	$(CC) $(UUID_OBJS) $(ISOHYBRID_OBJS) $(LDFLAGS) -o $(PROGRAM)

%.o: $(UUID)/%.c
	$(CC) $(UUID_CFLAGS) -c $< -o $@

%.o: $(SYSLINUX)/utils/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(SYSLINUX)/utils/isohdpfx.c: $(SYSLINUX)/mbr/isohdpfx.bin
	$(MAKE) -C $(SYSLINUX)/utils isohdpfx.c

$(SYSLINUX)/mbr/isohdpfx.bin:
	$(MAKE) -C $(SYSLINUX)/mbr

clean:
	rm -f *.o $(PROGRAM)
	$(MAKE) -C $(SYSLINUX)/mbr clean
	$(MAKE) -C $(SYSLINUX)/utils clean
