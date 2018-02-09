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
3. Execute by putting this line of code in the trigger's On Activation field:

```
null = [thisTrigger,east,200,1,3,2,-1,0,true] execVM "G_Occupation.sqf";  
```

Parameters:
null = [thisTrigger,side,radius,spawntype,maxAIperbuilding,groupdividing,maxgroups,buildingorder,debug(optional)] execVM "G_Occupation.sqf";

(select 0) - thisTrigger is not a name but is a command returning the trigger. It must always be in the select 0 slot.
thisTrigger

(select 1) - side is the side that you want the spawned AI to be on.
west, east, resistance, civilian

(select 2) - radius is the radius of the "subject area" around the trigger, where all buildings inside it are "subject". No relation to radius of editor-placed trigger.
Integer greater than 0

(select 3) - spawntype
NOTE: When this is used (value is > 0 or < 0, maxAIperbuilding represents the max AI allowable to spawn and groupdividing can only be 1 or 3+! (Meaning, number per building not limited, and only 1 or set amount of AIin each group)
0 - AI spawn by a certain number per building depending on maxAIperbuilding and the available positions
1 - AI spawn per building depending on a random number between 0 and maxAIperbuilding, limited as well by available positions
2 - Fixed number of AI spawning at complete random at positions inside the radius (boundary number set by select 4, maxAIperbuilding)
3 - Random number of AI spawning at complete random at positions inside the radius (boundary number set by select 4, maxAIperbuilding)

(select 4) - maxAIperbuilding is merely another limiter. It can still be limited if the max positions in a building is less than it. If spawntype is on (< 0 >) then represents the max number of AI that could be/will be spawned.

(select 5) - groupdividing determines the number of AI per AI "group". Due to game limitations, there can be only 144 groups per
side. Because of this, in the event that this script exceeds 144 groups minus the number of AI groups you have already placed, the 
remainder of spawns will not occur due to being invalid. This won't cause game lag/leaks, just the lack of the remainder of spawns. To
mediate this, I have setup 3 options that the mission maker must choose from in order to most effectively create their mission. These 
numbers below take the place of "groupdividing" in the parameters.
1 - When spawned, AI are in their own group. This generally keeps them exactly where they spawned until in combat. I recommend this if you won't have an issue with the 144 group limiter.
2 - When spawned, AI are grouped per building. This is sort of the halfway point, and often results in some AI exiting buildings.
3+ - When spawned, AI are grouped in groups the size of this variable. For instance, if you put 10, the AI will spawn and be placed in groups of 10. This WILL cause unplayable lag if you exceed excessive numbers (ie, dozens). Will result in AI exiting buildings.

(select 6) - maxgroups determines the maximum number of groups that the script will spawn. 
NOTE: Groups are divided up depending on the previous value.
NOTE: Only has effect when Select 3/SpawnType is 0. With 1 and -1, the spawn count is already limited by other means.
-1 (value of -1) - This value will not limit groups, groups will be limited by the spawn system instead.
>0 (any value over 0) - The maximum number of groups that will be created/spawned. Upon achieving this number, the script exits.

(select 7) - buildingorder determines whether or not the script will work from the center of the radius out, or at random.
0 - The script will proceed from the buildings nearest the center of the radius and expand outward
1 - The script will proceed from random building to random building within the radius

(select 8) - debug is true or false (optional (can be left non-existent)), where true provides text feedback about what the script is resulting in.

Example Parameters:
null = [thisTrigger,east,200,1,3,2,-1,0,true] execVM "G_Occupation.sqf";  
This means the AI will be east, they will spawn in buildings within 200m from the trigger executing the script, they will spawn at a random number per building between 0
and 3, they will be grouped per building, the number of groups is not directly limited, buildings will be selected randomly, and debug is enabled.

I suggest that the editor-placed trigger has no radius (as it is irrelevant to this script), and condition set to true (therefore it activates on mission start).

Notes/Tips:
* I understand this is a wall of text, but I assure you it is the most complicated part of this SIMPLE script!
* Due to the nature of this script, the larger the desired numbers and spawn radius, the more time it takes to complete its process, and the more laggy the server will be during the process. This can be mediated by reducing the numbers or having multiple triggers executing this script with smaller radii, thus allowing multiple spawns to occur in parallel.
* The radius/dimensions of the trigger in the editor have NO EFFECT on this script, other than that trigger's activation. The radius that this script references is defined in the parameters as listed above. 
* It is recommended to run this script at mission start so that any potential lag does not occur during the mission. However, it can be done at any time, as long as it is via trigger with the above parameters. 
* You can add or remove classnames in the _sclasses arrays. The script is already setup to select 1 at random per individual spawn.
* To use the debug mode, which tells you exactly what is spawning and where, simply add a true at the end of the parameters, as mentioned above. I strongly, strongly recommend this for all applications in order to ensure a smooth and working execution.
* Unfortunately, ArmA is limited to 144 groups per side. Be sure to read about this further in the installation instructions. To see if you've exceeded the group limit, look in the far southwest corner (bottom left) of the map. If there are Red markers there, you have exceeded the group limit. As well, you will see it indicated in the debug texts.
* On that note, the ONLY limiter to this script is the available buildings, the 144 group limit, and your values. 
* AI DO maintain their spawned position if spawned in a group, until entering combat.
* This script contains various "checks" in order to ensure your success!
* All of my recommended limitations can be experimented with, of course. Make your mission as good as it can be!

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