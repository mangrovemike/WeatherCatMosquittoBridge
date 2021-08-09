property _ucChars_ : "AÄÁÀÂÃÅĂĄÆBCÇĆČDĎĐEÉÈÊËĚĘFGHIÍÌÎÏJKLĹĽŁMNÑŃŇ" & ¬
	"OÖÓÒÔÕŐØPQRŔŘSŞŠŚTŤŢUÜÚÙÛŮŰVWXYÝZŽŹŻÞ"

property _lcChars_ : "aäáàâãåăąæbcçćčdďđeéèêëěęfghiíìîïjklĺľłmnñńň" & ¬
	"oöóòôõőøpqrŕřsşšśtťţuüúùûůűvwxyýzžźżþ"

on idle
	try
		with timeout of 30 seconds
			tell application "WeatherCat"

				-- Change these variables as you desire
				set loopDelay to 90 -- 60 seconds 
				set mqttServer to "127.0.0.1"
				set mqttChannel to "weather/wirrimbi/"
				set mqttSession to "WeatherCatData"

				set oldCurrentConditions to ""
				set oldDriverStatus to ""

				set quantum to 0.1 -- Used for rounding data to 1 decimal place


				-- Initialise the previous values list
				set previousValues to {} -- array/list of previous values
				repeat NumberOfChannels times
					set end of previousValues to ""
				end repeat

				-- Get the Station Driver Status (true or false)
				set driverStatus to StationDriverStatus
				if oldDriverStatus is not driverStatus then
					do shell script "/usr/local/bin/mosquitto_pub -q 1 --disable-clean-session -i " & mqttSession & " -h " & mqttServer & " -t '" & mqttChannel & "text/station_driver_status/' -m " & driverStatus
				end if
				set oldDriverStatus to driverStatus

				-- Get the Current Conditions (text)

				set currConditions to CurrentConditions
				if oldCurrentConditions is not currConditions then
					do shell script "/usr/local/bin/mosquitto_pub -q 1 --disable-clean-session -i " & mqttSession & " -h " & mqttServer & " -t '" & mqttChannel & "text/current_conditions/' -m '" & currConditions & "'"
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
					if wcname is not missing value and wcstatus is true and wcpreviousvalue is not wcvalue then

						set wcnamecleaned to my replaceString(wcname, " ", "_")
						set wcnamecleaned to my replaceString(wcnamecleaned, ".", "")
						set wcnamecleaned to my replaceString(wcnamecleaned, "(", "")
						set wcnamecleaned to my replaceString(wcnamecleaned, ")", "")

						set wcnamecleaned to my lowerString(wcnamecleaned)

						do shell script "/usr/local/bin/mosquitto_pub -q 1 --disable-clean-session -i " & mqttSession & " -h " & mqttServer & " -t '" & mqttChannel & "channel/" & wcnamecleaned & "/' -m " & wcvalue
					end if
					set item theIncrementValue of previousValues to wcvalue

				end repeat
			end tell
		end timeout
	end try
	return loopDelay
end idle

on replaceString(theText, oldString, newString)
	set AppleScript's text item delimiters to oldString
	set tempList to every text item of theText
	set AppleScript's text item delimiters to newString
	set theText to the tempList as string
	set AppleScript's text item delimiters to ""
	return theText
end replaceString

on lowerString(theText)
	local upper, lower, theText
	try
		return my translateChars(theText, my _ucChars_, my _lcChars_)
	on error eMsg number eNum
		error "Can't lowerString: " & eMsg number eNum
	end try
end lowerString

on translateChars(theText, fromChars, toChars)
	local Newtext, fromChars, toChars, char, newChar, theText
	try
		set Newtext to ""
		if (count fromChars) ≠ (count toChars) then
			error "translateChars: From/To strings have different lenght"
		end if
		repeat with char in theText
			set newChar to char
			set x to offset of char in fromChars
			if x is not 0 then set newChar to character x of toChars
			set Newtext to Newtext & newChar
		end repeat
		return Newtext
	on error eMsg number eNum
		error "Can't translateChars: " & eMsg number eNum
	end try
end translateChars

