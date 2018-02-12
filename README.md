## Grimes Building Occupation Script

The Grimes Building Occupation Script provides the ArmA 3 mission maker an extremely simple way to occupy a set of buildings within a radius with a random or fixed amount of AI (of any faction, including civilian), both chosen by the maker and limited by the number of official position inside the building. The spawned AI will fight back as a group, and can be easily manipulated further by adding lines in the right spot in this script. This script can be utilized in many ways, examples including but not limited to:
* Filler - Have a mission where a squad goes from A to C and you want non-mission critical AI at B? Use this script!
* Random Objective - Want to have 3 AI at C that could be ANYWHERE between dozens, hundreds of buildings? Use this script!
* Boredom Fixer - Want a quick CQB practice? Use this script!

This package includes an application of the script, in debug mode, as part of an example mission. 

This README is intended to provide detailed information as to the purpose, function, FAQs, and minor troubleshooting for this script in addition to installation, uninstallation, and maintenance tips. For further information or specifics in the code, the user should read the comments to the code within the script files. 

## Author Information

Kent “KC” Grimes of Austin, Texas, United States is the author of the Grimes Building Occupation Script. The script was made in order to allow for quick yet proper "filling of space" in missions where combat in general is intended, without having to go through the headache of placing individual units and positioning them correctly. 

The purpose of this script is to save time while encouraging randomized gameplay and limitless mission construction. 

BIS Forums Topic: https://forums.bohemia.net/forums/topic/164755-grimes-building-occupation-script/

## Installation

At this time, there is no “installer” for the script, and it is instead a simple series of actions and file moves.  

1. Obtain the script files
	1. github: https://github.com/kcgrimes/grimes-building-occupation-script
	1. Armaholic: http://www.armaholic.com/page.php?id=25268
2. Simply copy the file "G_Occupation.sqf" into your mission directory
3. Create a trigger in the area of where you want buildings occupied
4. Execute by putting this line of code in the trigger's On Activation field:

```
null = [thisTrigger,east,200,1,3,2,-1,0,true] execVM "G_Occupation.sqf";  
```

5. Modify execution parameters as desired using the following rules:

Parameters:
null = [thisTrigger, side, radius, spawnType, maxToSpawn, groupOption, maxGroups, buildingOrder, debug(optional)] execVM "G_Occupation.sqf";

(select 0) - thisTrigger - A command (not a name) returning the trigger. It must always be in the select 0 slot.
Value: thisTrigger

(select 1) - side - The side that you want the spawned AI to be on.
Value: west, east, resistance, civilian

(select 2) - radius - The radius of the "subject area" around the trigger, where all buildings inside it are "subject buildings". No relation to the radius of the editor-placed trigger.
Value: Integer greater than 0

(select 3) - spawnType - The method by which AI will spawn.
Value:
NOTE: For spawnType values of 0 or 1, maxToSpawn represents the max AI allowed to spawn per building (as opposed to the area) and groupOption can be any setting.
0 - AI spawn by a certain number per building depending on maxToSpawn and the available positions
1 - AI spawn per building depending on a random number between 0 and maxToSpawn, limited as well by available positions
NOTE: For spawnType values of 2 or 3, maxToSpawn represents the max AI allowed to spawn in the area (as opposed to building) and groupOption can only be 1 or 3+ (number per building can only be limited by available positions).
2 - Fixed number of AI spawning at random at positions inside the radius (boundary number set by select 4, maxToSpawn)
3 - Random number of AI spawning at random at positions inside the radius (boundary number set by select 4, maxToSpawn)

(select 4) - maxToSpawn - Used to limit the maximum number of AI to spawn per building or in the subject area, depending on the value of spawnType (described in spawnType section).
Value: Integer greater than 0

(select 5) - groupOption - The number of AI per AI "group". Due to game limitations, there can be only 288 groups per side. Because of this, in the event that this script exceeds 288 groups minus the number of AI groups you have already placed, the script will exit and the remaining spawns will not occur. 
Value:
1 - When spawned, AI are in their own group. 
2 - When spawned, AI are grouped per building. When spawnType is 2 or 3, AI are in their own group. 
3+ - When spawned, AI are grouped in groups the size of this variable. For instance, if you use 10, the AI will spawn and be placed in groups of 10, possibly between multiple buildings.

(select 6) - maxGroups - The maximum number of groups that the script will spawn before exiting. 
Value:
NOTE: Groups are divided up depending on the groupOption value.
-1 (value of -1) - Unlimited groups for the script, however groups will still be limited by the spawn system (288 per side).
>0 (any value over 0) - The maximum number of groups that will be created. Upon achieving this number, the script exits.

(select 7) - buildingOrder - Determines whether or not the script will work from the center of the radius out, or at random.
Value:
0 - The script will proceed from the buildings nearest the center of the radius and expand outward
1 - The script will proceed from building to building at random within the radius

(select 8) - debug - Debug is true or false (optional; can be left non-existent).
Value:
true - Provides text feedback via chat about what the script is resulting in.
false - No debug; for production.

Example Parameters:
null = [thisTrigger,east,200,1,3,2,-1,1,true] execVM "G_Occupation.sqf";  
This means the AI will be east, they will spawn in buildings within 200m from the trigger executing the script, they will spawn at a random number per building between 0 and 3, they will be grouped per building, the number of groups is not directly limited, buildings will be selected randomly, and debug is enabled.

Notes/Tips:
* Due to the nature of this script, the larger the desired numbers and spawn radius, the more time it takes to complete its process, and the more laggy the server will be during the process. This can be mediated by reducing the numbers or having multiple triggers executing this script with smaller radii, thus allowing multiple spawns to occur in parallel.
* The radius/dimensions of the trigger in the editor have no effect on this script, other than that trigger's activation. The radius that this script references is defined in the parameters as listed above. 
* It is recommended to run this script at mission start so that any potential lag does not occur during the mission. However, it can be done at any time, as long as it is via trigger with the above parameters. 
* You can add or remove classnames in the _sclasses arrays. The script is already setup to select 1 at random per individual spawn.
* To use the debug mode, which tells you exactly what is spawning and where, simply add a true at the end of the parameters, as mentioned above. At least one run with debug enabled is recommended in order to ensure a smooth and working production version.
* Unfortunately, ArmA is limited to 288 groups per side. Be sure to read about this further in the installation instructions. Group numbers are provided in the debug texts.
* On that note, the limiters to this script is the available buildings, the 288 group limit, and your values. 
* AI will maintain their spawned position if spawned in a group, until entering combat.
* This script contains various "checks" in order to ensure your success!
* All of the recommended limitations can be experimented with, of course. Make your mission as good as it can be!

## Documentation

This README is intended to provide detailed information as to the purpose, function, FAQs, and minor troubleshooting for this script in addition to installation, uninstallation, and maintenance tips. For further information or specifics in the code, the user should read the comments to the code within the script files. Any further questions or comments can be directed to the author. 

## Tests

The script is designed to exit upon critical failure and it will attempt to announce the problem in chat. These types of failures are intended for development, and should never be encountered down the road if they were not encountered at launch, save for software updates. Upon setup or completion of modifications, it is recommended that the user, before launch, run the script with debug enabled.

## Contributors

Contributions are welcomed and encouraged. Please follow the below guidelines:
* Use the Pull Request feature
* Document any additional work
* Provide reasonable commit history comments
* Test all modifications locally and online

## License

MIT License

Copyright (c) 2014-2018 Kent "KC" Grimes. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.