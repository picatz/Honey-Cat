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

### Credits
Kent 'picat' Gruber
