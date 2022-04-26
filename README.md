# octoprint-libcamera

This repository is a demonstration of how I was able to use a libcamera Raspberry Pi camera ((https://www.arducam.com/16mp-autofocus-camera-for-raspberry-pi/)[ArduCam 16MP Autofocus Camera]) with OctoPrint.

## Why Not Official Instructions?

https://www.arducam.com/docs/cameras-for-raspberry-pi/raspberry-pi-libcamera-guide/autofocus-camera-solution-using-on-octopi/

The official instructions from ArduCam for using libcamera with OctoPrint involve:

* Downloading a nightly build of OctoPi
* Installing the IMX519 kernel driver
* Replacing the system version of mjpg\_streamer with a custom version
* Replacing the system version of webcamd with a custom version

I did not like this approach for several reasons:

* I would rather use a stable build of OctoPi for controlling something as sensitive and potentially dangerous as a 3D printer
* The changes made to the OctoPi image are not trivially reversible
* Upgrading OctoPi can lead to undefined behavior (e.g. mjpg\_streamer is replaced during an upgrade)

## Raspbian Bullseye

Instead of starting with an OctoPi image, I opted to use the official 64-bit version of Raspbian Buster and run mjpg\_streamer and OctoPrint in separate containers.

### mjpg\_streamer

mjpg\_streamer was the most difficult part of this project to get working. The Dockerfile used to get mjpg\_streamer running is under `mjpg_streamer/Dockerfile`.

The key components to note about this Dockerfile are:

* The raspbian package repository is added so that `libcamera-dev` can be installed, which is needed to compile `mjpg_streamer`
* All inputs and outputs other than `input_libcamera` and `output_http` are removed.
  * This is partially to reduce compile time, but mostly to remove the OpenCV dependency. Installing `libopencv-dev` involves downloading almost an entire gigabyte of dependencies!
* I was lazy and used `--privileged` to pass all devices through to the container in `docker-compose.yaml`. This is not safe and probably not what you want to do.
  * Do as I say, not as I do.
* I also mounted `/run/udev` to the container in read-only mode. This was based on comments in https://github.com/kbingham/libcamera/issues/35

### octoprint

I used the official OctoPrint image here. Things to note:

* I used `--privileged` here again to pass through devices to OctoPrint. Again, don't do this.
* I mounted a couple of other volumes to get the NavbarTemp plugin to recognize and read the Pi's SoC temperature.
  * `/proc/cpuinfo:/proc/cpuinfo:ro`
  * `/usr/bin/vcgencmd:/usr/bin/vcgencmd:ro`
  * `/usr/lib/aarch64-linux-gnu/libvcos.so.0:/usr/lib/aarch64-linux-gnu/libvcos.so.0:ro
  * `/usr/lib/aarch64-linux-gnu/libvchiq_arm.so.0:/usr/lib/aarch64-linux-gnu/libvchiq_arm.so.0:ro`
