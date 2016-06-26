Sonos Remote
============

While Sonos is a great solution for wireless speaker it sometimes lacks the support of a remote control. For easy tasks as play/pause, volume up/down, next/previous song it is easier to press a button on a remote than fiddling on your phone.

With just a Raspberry Pi and an old apple remote (or any other remote) this is quite easy to achieve.


Setup
-----

Components used:

- Raspberry Pi
- IR Receiver Sensor - TSOP38238
- Apple Remote A1156


Hardware
--------

Connect your Sensor to 3.3V, GND and GPIO 18. Please refer to [the excellent Adafruit Tutorial](https://learn.adafruit.com/using-an-ir-remote-with-a-raspberry-pi-media-center/hardware) to see an illustration.

If you are using another remote check [the list](http://lirc.sourceforge.net/remotes/) and edit `lircd.conf` and `lircrc` accordingly.


Autmatic Install on Raspbian Jessie
-----------------------------------

The install script `install.sh` is a convenient way for automatic install of all required software and configuration of the system. *For detailed instructions refer to the next section.*

- Clone this repository on your Raspberry Pi running Raspbian Jessie
```
git clone https://github.com/prebm/SonosRemote.git
```
- Execute `install.sh` with root privileges
```
sudo ./install.sh
```
- When prompted enter the desired Sonos zone the remote will work for.
- Reboot your Raspberry Pi and have fun!


Manual Install with Instructions for older Raspbians
----------------------------------------------------

The following section describes how to install the IR Receiver Sensor and the requried software to your Raspberry Pi. At the end, there is a part with instructions how to enable the daemon for automatic start at boot for older versions of Raspbian with init.d and newer versions (starting with Jessie) with systemd.

Please refer to the link section at the end of this Readme. It contains useful links for troubleshooting.

- Install GIT:
```
sudo apt-get install git
```
- Install PIP:
```
sudo apt-get install python-pip
```
- Install [`lirc`](http://sourceforge.net/projects/lirc/):
```
sudo apt-get install lirc
```
- Install [`python-lirc`](https://github.com/tompreston/python-lirc):
```
sudo apt-get install python-lirc
```
- Install [`SoCo`](https://github.com/SoCo/SoCo):
```
sudo pip install soco
```
- Clone this repository. **Note:** at the moment there are some paths hardcoded to the install path `/home/pi/SonosRemote/`. If you choose another path to your files, be sure to change the paths respectively.
```
git clone https://github.com/prebm/SonosRemote.git
```

I am running Raspbian 7.8 with the Kernel 4.1.7, for Kernels before 3.18 one step is different

- Depending on your Kernel (`uname -a`):
	- **≥ 3.18**: Edit `/boot/config.txt` and uncomment the line
	```
    dtoverlay=lirc-rpi
    ```
	- **pre 3.18**: Add following lines to `/etc/modules`:
    ```
    lirc_dev
    lirc_rpi
    ```
- Change the following lines in `/etc/lirc/hardware.conf`
```
LIRCD_ARGS="--uinput"
DRIVER="default"
DEVICE="/dev/lirc0"
MODULES="lirc_rpi"
```
- Copy `lircd.conf` to `/etc/lirc/` - or search your remote from [the list](http://lirc.sourceforge.net/remotes/)
- Copy `lircrc` to `/etc/lirc/` - edit accordingly if you are using another remote
- Reboot `sudo reboot`
- Get the IP for the Sonos you want to control and put it in `config.py`:
```
$ get_sonos_ip.py
Player: Kitchen at IP: <SoCo object at ip 192.168.1.46>
```
- Make sure `sore.py` is executable
```
sudo chmod +x sore.py
```
- **For Raspbian Wheezy**
    - Copy `sore` to `/etc/init.d` and edit the paths if necessary
    - Make `/etc/init.d/sore` executable
    ```
    sudo chmod +x sore
    ```
    - and register the init script to start at boot with
    ```
    sudo update-rc.d sore defaults
    ```
- **For Raspbian Jessie**
	- Copy `sore.service` to `/etc/systemd/system/` and edit the paths if necessary
	```
    sudo cp sore.service /etc/systemd/system/
    ```
    - Make sure `/etc/systemd/system/sore.service` has the required rights
    ```
    sudo chmod 664 sore.service
    ```
    - reload systemd daemon and enable the service
    ```
    sudo systemctl daemon-reload
    sudo systemctl enable sore.service
    ```
- Reboot your Raspberry Pi and have fun!


Running
-------

We installed a service to run at boot. So after booting your Raspberry Pi everything should work out of the box. You can use the following commands:

- **For Raspbian Jessie**
```
sudo systemctl status sore.service
sudo systemctl start sore.service
sudo systemctl stop sore.service
```
- **For Raspbian Wheezy**
```
sudo /etc/init.d/sore start
sudo /etc/init.d/sore stop
sudo /etc/init.d/sore restart
sudo /etc/init.d/sore status
```

Troubleshooting
---------------

I have added a basic logging mechanism which logs to sore.log. To save disk space it is deactivated. Activate it and check the logs for any useful messages by uncommenting the following line in `sore.py`

```
# logging.basicConfig(filename="/home/pi/SonosRemote/sore.log", level=logging.INFO)
```

If the service is not starting up at boot, try to restart it manually. It is a known issue that the startup at boot is not working if you are running Jessie.

Links
-----

*LIRC*
- http://www.dkographicdetails.com/myPi/?p=20
- https://learn.adafruit.com/using-an-ir-remote-with-a-raspberry-pi-media-center/
- http://alexba.in/blog/2013/01/06/setting-up-lirc-on-the-raspberrypi/
- http://www.spech.de/blog/article/universalfernbedienungrpi
- http://www.lirc.org/html/configure.html#lircrc_format
- http://lirc.sourceforge.net/remotes/apple/A1156

- https://github.com/tompreston/python-lirc

*Sonos*
- https://github.com/SoCo/SoCo

*Service*
- http://blog.scphillips.com/posts/2013/07/getting-a-python-script-to-run-in-the-background-as-a-service-on-boot/