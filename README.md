# Honey Cat

Honey Cat is a simple, easy to use honey pot that sets up what looks like is a service, but is really a honey pot on a user specified port. It is built with with BASH, Net Cat. Lolcat support is also a thing because people need it, obviously. 

TODO: 
* Ban ips listed in output file with iptables.
* Log parser.
* Better stats.

---

## Installation
You're going to need to install the following ruby gems:                                                                     
`gem install lolcat`

---

## Usage
Quickly Setup Honey Pot
`./hcat.sh -p <PORT>`

Use Output File "output.txt"
`./hcat.sh -p <PORT> -o output.txt`

View Help
`./hcat.sh -h`

---

## Help Menu
HONEY CAT ... BASH + NC + LOVE 

-p <PORT(1-65535)>
	Define the port to setup honeypot on.
-o <FILE>
	Output unique IP addrs to file. 
-b <BANNER>
	Set a custom banner for your honeypot.
-s 
	Use default ssh banner. 
-w 
	Use default web server banner.
-l
	Use lolcat if available.
-v
	Display version.
-h
	Display this menu.
---

### Credits
Kent 'picat' Gruber
