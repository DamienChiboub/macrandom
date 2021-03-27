macrandom repository contains an AppleScript and a plist file that allow to generate a new mac address 
at each start after asking the Wi-Fi key.


Store the macramdom.scpt file somewhere and modify the last ProgramArgument of com.macrandom.plist :

 <string>/Users/USERNAME/Somewhere/macrandom.scpt</string>

Store the plist file in the following path, enter your USERNAME :

/Users/USERNAME/Library/LaunchAgents/


Add/Remove to the computer start :

launchctl load -w /Users/USERNAME/Library/LaunchAgents/com.macrandom.plist

launchctl unload -w /Users/USERNAME/Library/LaunchAgents/com.macrandom.plist

And it's done.
