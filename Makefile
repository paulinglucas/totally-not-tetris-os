CC=i386-elf-gcc
ASM=i386-elf-as
LD=i386-elf-ld

GFLAGS=
CCFLAGS=-m32 -std=c11 -O2 -g -Wall -Wextra -Wpedantic -Wstrict-aliasing
CCFLAGS+=-Wno-pointer-arith -Wno-unused-parameter
CCFLAGS+=-nostdlib -nostdinc -ffreestanding -fno-pie -fno-stack-protector
CCFLAGS+=-fno-builtin-function -fno-builtin
ASFLAGS=
LDFLAGS=

BOOTSECT_SRCS=\
	src/stage0.S

BOOTSECT_OBJS=$(BOOTSECT_SRCS:.S=.o)

KERNEL_C_SRCS=$(wildcard src/*.c)
KERNEL_S_SRCS=$(filter-out $(BOOTSECT_SRCS), $(wildcard src/*.S))
KERNEL_OBJS=$(KERNEL_C_SRCS:.c=.o) $(KERNEL_S_SRCS:.S=.o)

BOOTSECT=bootsect.bin
KERNEL=kernel.bin
ISO=boot.iso

all: dirs bootsect kernel

dirs:
	mkdir -p bin

clean:
	rm ./**/*.o
	rm ./*.iso
	rm ./**/*.bin

run:
	make iso && qemu-system-i386 -drive format=raw,file=boot.iso -d cpu_reset -monitor stdio \
	 -device sb16,audiodev=snd -audiodev pa,id=snd,out.frequency=22050,out.channels=1,out.format=s16 \
	 -display sdl

%.o: %.c
	$(CC) -o $@ -c $< $(GFLAGS) $(CCFLAGS)

%.o: %.S
	$(ASM) -o $@ -c $< $(GFLAGS) $(ASFLAGS)

bootsect: $(BOOTSECT_OBJS)
	$(LD) -o ./bin/$(BOOTSECT) $^ -Ttext 0x7C00 --oformat=binary

kernel: $(KERNEL_OBJS)
	$(LD) -o ./bin/$(KERNEL) $^ $(LDFLAGS) -T src/link.ld

iso: bootsect kernel
	dd if=/dev/zero of=boot.iso bs=512 count=2880
	dd if=./bin/$(BOOTSECT) of=boot.iso conv=notrunc bs=512 seek=0 count=1
	dd if=./bin/$(KERNEL) of=boot.iso conv=notrunc bs=512 seek=1 count=2048
