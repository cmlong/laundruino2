laundruino2
===========

Reports laundry cycle completion utilizing a wireless network and arduino

The Laundruino 2 is a modification of the Laundruino created by
Michael Clemens (http://github.com/exitnode). The Laundruino 2 
reads the analog value from a photocell connected to an xbee module. 
The analog value is transmitted from xbee at the washer to the xbee 
on the arduino / ethernet sheild stack (some xbee code used from
Robert Faludi's 'Building Wireless Sensor Networks' book). Currently 
the ethernet shield is running as a web server per Michael Clemens's 
design.

TODO

1. Switch from web server to an email-to-sms gateway
2. Add a second analog channel to read dryer cycle
3. Log length of cycle times and date/timestamp to watch for patterns
   and eventually interface to power monitoring system
