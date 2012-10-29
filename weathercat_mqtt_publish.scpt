tell application "WeatherCat"
	
	-- Change these variables as you desire
	set loopDelay to 60 -- 20 seconds
	set mqttServer to "127.0.0.1"
	set mqttChannel to "weather/merewether/"
	
	set oldCurrentConditions to ""
	set oldDriverStatus to ""
	
	set quantum to 0.1 -- Used for rounding data to 1 decimal place
	
	
	-- Initialise the previous values list
	set previousValues to {} -- array/list of previous values
	repeat NumberOfChannels times
		set end of previousValues to ""
	end repeat
	
	repeat -- run around this loop forever, once every x seconds
		
		-- Get the Station Driver Status (true or false)
		set driverStatus to StationDriverStatus
		if oldDriverStatus is not driverStatus then
			do shell script "/usr/local/bin/mosquitto_pub -h " & mqttServer & " -t '" & mqttChannel & "text/station_driver_status/' -m " & driverStatus
		end if
		set oldDriverStatus to driverStatus
		
		-- Get the Current Conditions (text)
		
		set currConditions to CurrentConditions
		if oldCurrentConditions is not currConditions then
			do shell script "/usr/local/bin/mosquitto_pub -h " & mqttServer & " -t '" & mqttChannel & "text/current_conditions/' -m " & currConditions
		end if
		set oldCurrentConditions to currConditions
		
		repeat with theIncrementValue from 1 to NumberOfChannels
			set WorkingChannel to theIncrementValue
			set wcname to WorkingChannelName
			set wcvalue to (round WorkingChannelValue / quantum) * quantum
			set wcstatus to WorkingChannelStatus
			
			-- Set the previous value from the list
			set wcpreviousvalue to item theIncrementValue of previousValues
			
			-- If the WeatherCat channel is OK and the value has changed then publish
			if wcstatus is true and wcpreviousvalue is not wcvalue then
				do shell script "/usr/local/bin/mosquitto_pub -h " & mqttServer & " -t '" & mqttChannel & "channel/" & wcname & "/' -m " & wcvalue
			end if
			set item theIncrementValue of previousValues to wcvalue
			
		end repeat
		
		delay loopDelay
	end repeat
end tell