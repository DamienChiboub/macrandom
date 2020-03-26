-- macrandom.scpt is an AppleScript that use 'do shell script' command to allocate a random mac address to your wifi en1 adapter.
-- it ask the wifi key and you have to specify your wifi network to the bssid variable.

delay 1

say "Enter your Wi-Fi key" using "Allison"
set reset to "for i in {1..5};do wreset=$(echo -n $[RANDOM%10]$[RANDOM%10]$[RANDOM%10]$[RANDOM%10]$[RANDOM%10] | md5);unset wreset;echo $wreset;done;"
set bssid to "dvi-"

-- POPUP variable wifi return the user entry, and variable btn return Arreter or Continuer, autoclose 30 seconds, hidden field
set {wifi, btn} to {text returned, button returned} of (display dialog "Entrez la clef wifi" giving up after 3 default answer "" with icon stop buttons {"Arreter", "Continuer"} with hidden answer)
-- ENDPOPUP

if btn is "" then -- IF NO CLICK
	if wifi is "" then -- IF VAR WIFI EMPTY
		say "No interaction"
		display dialog "Aucun clic détecté" with icon stop buttons {"Ok"} default button "Ok" giving up after 1
	else
		set wifi to do shell script "" & (reset) & ""
		say "You have to click on continu" using "Allison"
		display dialog "Aucun clic détecté" with icon stop buttons {"Ok"} default button "Ok" giving up after 1
	end if -- END IF VAR WIFI EMPTY
else
	if btn is "Arreter" then -- IF CLICK ARRETER BTN
		set wifi to do shell script "" & (reset) & ""
		delay 1
		say "The script has been manually cancelled" using "Allison"
		display dialog "Script annulé" with icon stop buttons {"Ok"} default button "Ok" giving up after 1
	else
		set wcnx to "networksetup -setairportnetwork en1 " & (bssid) & " "
		
		try
			do shell script "networksetup -setairportpower airport off;networksetup -setairportpower airport on;sudo ifconfig en1 ether 00-31-2C-$[RANDOM%10]$[RANDOM%10]-$[RANDOM%10]$[RANDOM%10]-$[RANDOM%10]$[RANDOM%10]" with administrator privileges
		on error e number n
			set wifi to do shell script "" & (reset) & ""
			say "Authentification cancelled" using "Allison"
			display dialog e with icon stop buttons {"Ok"} default button "Ok" giving up after 1
			error number -128 #quits the script here	
		end try
		
		do shell script " " & (wcnx) & " " & (wifi) & "" -- Connect to wifi network with en1 adapter and prompted wifi key
		delay 10 -- delay needed before generating logs, wifi auth is not instantaneous particulary with mac randomization
		do shell script "now=$(date);cmd=$(ifconfig en1 | grep ether);ip=$(networksetup -getinfo Wi-Fi | grep 'IP' | grep 192);router=$(networksetup -getinfo Wi-Fi | grep 'Router:' | grep '192');var=$(echo $now - $cmd - $ip - $router);echo $var >> /Users/dvi/test.cmd;nl /Users/dvi/test.cmd > /Users/dvi/Desktop/resultat.log;echo " & (wcnx) & "" & (wifi) & " >> /Users/dvi/Desktop/file1" -- logs stored in mac os user environment
		
		set wifi to do shell script "" & (reset) & ""
		set connected to (do shell script "ping -c 1 google.fr >/dev/null && echo yes || echo no") as boolean
		
		if connected is true then -- IF URL REACHABLE (TRUE)
			say "Connected with a new mac address. Don't forget to keep an eye on our reverse engineering Youtube channel! Follow-us on Twitter or Linkedin! Thanks!" using "Allison"
			do shell script "echo " & (connected) & " >> /Users/dvi/Desktop/file"
		else -- URL REACHABLE (FALSE)
			say "You are not connected" using "Allison"
			do shell script "echo " & (connected) & " >> /Users/dvi/Desktop/file"
		end if -- END IF URL REACHABLE
		
	end if -- END IF CLICK ARRETER BTN
end if -- END IF NO CLICK


-- article @ https://www.linkedin.com/company/reverse-engineering-lab/
-- posted @ https://github.com/DamienChiboub/macrandom

(*  

Add this plist file to /Users/USERNAME/Library/LaunchAgents/com.macrandom.plist

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Disabled</key>
        <false/>
        <key>Label</key>
        <string>macaddress.job</string>
        <key>ProgramArguments</key>
   <array>
       <string>/usr/bin/osascript</string>
       <string>/Users/dvi/Desktop/macrandom.scpt</string>
   </array>
	<key>RunAtLoad</key>
       <true />
		
</dict>
</plist>


Add/Remove to the startup :
launchctl load -w /Users/USERNAME/Library/LaunchAgents/com.macrandom.plist
launchctl unload -w /Users/USERNAME/Library/LaunchAgents/com.macrandom.plist

--
Pop up wifi key : you have to enter the key and click on Continuer
If no click : reset wifi, end
If click on Arreter : reset wifi, popup autocloseable, wi-fi off, open and close terminal, end
If click on Continuer : popup administrator username/password, wi-fi off/on, allocate random wi-fi mac address, connect to wifi "dvi-", generate temp.cmd and resultat.log, reset wifi, test ping url, generate file with connected state, end
--

- macrandom.scpt allow to generate a random mac address for your wi-fi adapter (last 3 octets)
- wifi adapter is en1, bssid dvi-, ip class c, log storage in user session and desktop
- google.fr is used to confirm or not the connected state but it's not an efficient test (dns issue, icmp filter, can be down,..)
- export this script as an application or use a plist with launchd (launchctl) to load it at each start
- we reset the wifi variable 

*)
