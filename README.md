WeatherCatMosquittoBridge
=========================

Bridges Trixology's WeatherCat to mosquitto (MQTT) publish.


Created by: Mangrove Mike (Michael Barwell) October 2012

The Applescript will run on OSX (sort of obviously) which is the only OS for
WeatherCat (http://trixology.com/weathercat) .

This simple Applescript accesses the WeatherCat Applescript interface and runs through
each WeatherCat channel which is then published to a MQTT server.

Subsequent updates to value of the WeatherCat channel are also published.

It uses mosquitto_pub to publish the stream. By replacing the 'do shell' call to 
mosquitto the routine can be used to feed any OS command.

To run this code:
1. Make sure you have WeatherCat up and running and talking to your weather station
2. Open Applications --> Utilities --> AppleScript Editor
3. Open the file weathercat_mqtt_publish.scp
4. Alter the script for your MQTT server and channels
5. 'Run'

Subscribe to the channels you are publishing to and write some funky code to do 
something with it. Try some python, perl and especially Arduino to monitor the world.

Extra Info
----------

For more details about mosquitto head to http://mosquitto.org .
Also make sure you also check out http://mqtt.org .

If you want to install mosquitto on your Mac checkout brew (http://mxcl.github.com/homebrew)
and then install brew.

From there install Mosquitto

	brew install mosquitto

This will install the mosquitto server and clients.




Thanks
------
Special thanks for invention, ongoing support and development for mqtt and mosquitto to:
Andy Stanford-Clark
Roger Light
Andy Piper
Nicholas O'Leary






