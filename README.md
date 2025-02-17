# TETRIS-OS: An operating system that definitely 100% does NOT play Tetris. Do not **think** or **report** otherwise 

![screenshot](images/0.png)

> **_NOTE:_**
Inspired after watching [jdh's](https://www.youtube.com/watch?v=FaILnmUYS_U) video where he builds an OS to run a _certain_ game created in the 1980's, I cloned the repo linked from the video only to find that the OS crashed on startup. This seemed to be due to QEMU [inheriting a bug](http://wiki.osdev.org/Sound_Blaster_16#:~:text=warning%3A%20recent%20versions%20of%20qemu%20(%3E%3D%204.0)%20have%20a%20broken%20support%20for%20this%20sound%20card.%20see%20bug%3A%20%5B2%5D.%20briefly%2C%20when%20qemu's%20gtk%20ui%20is%20used%20and%20audio%20is%20playing%2C%20you'll%20experience%20the%20qemu%20window%20freezing.%20in%20addition%2C%20there%20will%20be%20flickering%20in%20the%20audio%20as%20well.%20) around version >=4.0, causing broken support when emulating the Soundblaster 16 audio device specifically paired with a GTK display. 
After reworking the `make run` command described below to opt for SDL vs GTK, along with a few parameter tweaks in the `src/sound.c` file (as well as a slight speed boost added to `main.c's` `FRAMES_PER_STEP` constant), the program now works as shown at the end of JDH's video. Clone the repo and have at it, kids :)

#### Features:
- It's (not) Tetris.
- 32-bit (x86)
- Fully custom bootloader
- Soundblaster 16 driver
- Custom music track runner
- Fully hardcoded tetris theme
- Double-buffered 60 FPS graphics at 320x200 pixels with custom 8-bit RGB palette

#### Prereqs
This program uses i386-elf cross-compilers for gcc, ld and as to compile and run the OS, which needs to be built from source and manually added to your local `PATH` variable. The [OS Dev Wiki](http://wiki.osdev.org/GCC_Cross-Compiler) has a good tutorial on how to do this step-by-step, just make sure to swap out the [`TARGET`](http://wiki.osdev.org/GCC_Cross-Compiler#:~:text=export%20target%3Di686-elf) variable to the correct i386-elf value.

#### Running
**NOTE**: This has *only* been tested in a qemu emulator. Real hardware might not like it.

##### Linux
This forked repo was tested on a computer running Linux Mint 22, run the program with the command below in the root directory:
```
$ make run
```
which runs this command in the `Makefile`:
```
$ make iso && qemu-system-i386 -drive format=raw,file=boot.iso -d cpu_reset -monitor stdio \
	 -device sb16,audiodev=snd -audiodev pa,id=snd,out.frequency=22050,out.channels=1,out.format=s16 \
	 -display sdl
```

##### Mac
Use the same command as Linux, but update the `Makefile` to use `coreaudio` vs `pa` (pulseaudio) as the audio device.

##### Windows
Absolutely no idea (with apologies to Mr. Gates).

##### Real hardware
You probably know what you're doing if you're going to try this. Just burn `boot.iso` onto some bootable media and give it a go. If things break, try disabling all of the music since you *probably* don't have something with a SB16 in it.
