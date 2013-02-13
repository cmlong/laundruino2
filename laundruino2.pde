/*
#  The Laundruino 2
#  
#  The Laundruino 2 is a modification of the Laundruino created by
#  Michael Clemens (http://github.com/exitnode). The Laundruino 2 
#  reads the analog value from a photocell connected to an xbee module. 
#  The analog value is transmitted from xbee at the washer to the xbee 
#  on the arduino / ethernet sheild stack (some xbee code used from
#  Robert Faludi's 'Building Wireless Sensor Networks' book). Currently 
#  the ethernet shield is running as a web server per Michael Clemens's 
#  design.
#
#  TODO
#
#  1. Switch from web server to an email-to-sms gateway
#  2. Add a second analog channel to read dryer cycle
#  3. Log length of cycle times and date/timestamp to watch for patterns
#     and eventually interface to power monitoring system
#
########################################################################
#
#  Laundruino 
#
#  Copyright (C) 2011 Michael Clemens
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <SPI.h>
#include <Ethernet.h>

#define VERSION "1.03"

byte mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 
  192, 168, 1, 250 };
byte gateway[] = { 
  192, 168, 1, 1 };
byte subnet[] = { 
  255, 255, 255, 0 };
int analogValue1 = 0;
// int analogValue2 = 0;
long laundryIsDoneSince = -1;
boolean LEDonWasher;
// boolean LEDonDryer;
EthernetServer server(80);


void setup()
{
  Ethernet.begin(mac, ip, gateway, subnet);
  server.begin();
  Serial.begin(9600);
}


void loop()
{
  // listen for incoming clients
  EthernetClient client = server.available();

// make sure everything we need is in the buffer
  if (Serial.available() >= 21) {
    // look for the start byte
    if (Serial.read() == 0x7E) {
      // read the variables that we're not using out of the buffer
      for (int i = 0; i<18; i++) {
        byte discard = Serial.read();
      }
      // Read first analog value for washer
      int analogHigh1 = Serial.read();
      int analogLow1 = Serial.read();
      analogValue1 =  analogLow1 + (analogHigh1 * 256);
      
      /*
      * Read next analog value for dryer
      * int analogHigh2 = Serial.read();
      * int analogLow2 = Serial.read();
      * analogValue2 =  analogLow2 + (analogHigh2 * 256);
      */
    }
  }

  /*
   * The values in this section will probably
   * need to be adjusted according to your
   * photoresistor, ambient lighting, etc.
   * For example, if you find that the darkness 
   * threshold is too dim, change the 350 value
   * to a larger number.
   */

  // darkness means washer laundry cycle is over
  if (analogValue1 > 0 && analogValue1 <= 350) {
    LEDonWasher = true;
  }
  // bright light means laundry cycle is active
  if (analogValue1 > 350 && analogValue1 <= 1023) {
    LEDonWasher = false;
  }

  /*
  * // darkness means dryer laundry cycle is over
  * if (analogValue2 > 0 && analogValue2 <= 350) {
  *  LEDonDryer = true;
  * }
  * // bright light means laundry cycle is active
  * if (analogValue2 > 350 && analogValue2 <= 1023) {
  *  LEDonDryer = false;
  *
  * }
  */
  
  if (LEDonWasher)
  {
    if (laundryIsDoneSince==-1){
      laundryIsDoneSince = millis();
    }
  } 
  else {
    laundryIsDoneSince=-1;
  } 

  if (client) {
    // Some code is taken frpm the official HTTPServer example
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        if (c == '\n' && currentLineIsBlank) {
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();
          client.println("<br /><br /><br /><br /><br /><br /><br /><br />");
          client.println("<table align=center><tr><td align=center>");
          if (LEDonWasher) {
            long minutesDone = ((millis()-laundryIsDoneSince)/1000/60)+1;
            client.print("<font color='#00C000' size='13'><b>&#9786;</b></font>"); // Smiley :)
            client.print("<br /><br />");
            if (minutesDone > 1) {
              client.print("...since "); 
              client.print(minutesDone);
              client.print(" minutes!");            
            }
          } 
          else {
            client.print("<font color='#Co0000' size='6'><b>Nope, not yet...</b></font>");
          }
          client.println("</td></tr></table>");
          break;
        }
        if (c == '\n') {
          currentLineIsBlank = true;
        } 
        else if (c != '\r') {
          currentLineIsBlank = false;
        }
      }
    }
    // close the connection:
    client.stop();
  }
  delay(2000);
}
