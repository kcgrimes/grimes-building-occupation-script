/*
--Author: KC Grimes

--Script: Grimes' Building Occupation Script
--Version: V1.1

--Description:
This script, Grimes' Building Occupation Script, provides the mission maker an extremely simple way to
occupy a set of buildings within a radius with a random or fixed amount of AI (of any faction, including civilian), both chosen by the maker and 
limited by the number of official position inside the building. The spawned AI will fight back as a
group, and can be easily manipulated further by adding lines in the right spot in this script. This script can 
be utilized in many ways, examples including but not limited to:
-Filler - Have a mission where a squad goes from A to C and you want non-mission critical AI at B? Use this script!
-Random Objective - Want to have 3 AI at C that could be ANYWHERE between dozens, hundreds of buildings? Use this script!
-Boredom Fixer - Want a quick CQB practice? Use this script!

--Installation/Instructions:
To implement this script into your mission, simply copy this file ("G_Occupation.sqf") into your mission 
directory and then execute it via a trigger's OnAct field using the following parameters:

Base Parameters:
nul = [thisTrigger,side,radius,spawntype,maxAIperbuilding,groupdividing,maxgroups,buildingorder,debug(optional)] execVM "G_Occupation.sqf";

--(select 0) - thisTrigger is not a name but is a command returning the trigger. It must always be in the select 0 slot.
thisTrigger

--(select 1) - side is the side that you want the spawned AI to be on.
-WEST, EAST, GUER, CIV

--(select 2) - radius is the radius of the "subject area" around the trigger, where all buildings inside it are "subject". No relation to radius of editor-placed trigger.
Integer greater than 0

--(select 3) - spawntype
NOTE: When this is used (value is > 0 or < 0, maxAIperbuilding represents the max AI allowable to spawn and groupdividing can only be 1 or 3+! (Meaning, number per building not limited, and only 1 or set amount of AIin each group)
0 - AI spawn by a certain number per building depending on maxAIperbuilding and the available positions
1 - AI spawn per building depending on a random number between 0 and maxAIperbuilding, limited as well by available positions
2 - Fixed number of AI spawning at complete random at positions inside the radius (boundary number set by select 4, maxAIperbuilding)
3 - Random number of AI spawning at complete random at positions inside the radius (boundary number set by select 4, maxAIperbuilding)

--(select 4) - maxAIperbuilding is merely another limiter. It can still be limited if the max positions in a building is less than it. If spawntype is on (< 0 >) then represents the max number of AI that could be/will be spawned.

--(select 5) - groupdividing determines the number of AI per AI "group". Due to game limitations, there can be only 144 groups per
side. Because of this, in the event that this script exceeds 144 groups minus the number of AI groups you have already placed, the 
remainder of spawns will not occur due to being invalid. This won't cause game lag/leaks, just the lack of the remainder of spawns. To
mediate this, I have setup 3 options that the mission maker must choose from in order to most effectively create their mission. These 
numbers below take the place of "groupdividing" in the parameters.
1 - When spawned, AI are in their own group. This generally keeps them exactly where they spawned until in combat. I recommend this if you won't have an issue with the 144 group limiter.
2 - When spawned, AI are grouped per building. This is sort of the halfway point, and often results in some AI exiting buildings.
3+ - When spawned, AI are grouped in groups the size of this variable. For instance, if you put 10, the AI will spawn and be placed in groups of 10. This WILL cause unplayable lag if you exceed excessive numbers (ie, dozens). Will result in AI exiting buildings.

--(select 6) - maxgroups determines the maximum number of groups that the script will spawn. 
NOTE: Groups are divided up depending on the previous value.
NOTE: Only has effect when Select 3/SpawnType is 0. With 1 and -1, the spawn count is already limited by other means.
-1 (value of -1) - This value will not limit groups, groups will be limited by the spawn system instead.
>0 (any value over 0) - The maximum number of groups that will be created/spawned. Upon achieving this number, the script exits.

--(select 7) - buildingorder determines whether or not the script will work from the center of the radius out, or at random.
0 - The script will proceed from the buildings nearest the center of the radius and expand outward
1 - The script will proceed from random building to random building within the radius

--(select 8) - debug is true or false (optional (can be left non-existent)), where true provides text feedback about what the script is resulting in.

Example Parameters:
nul = [thisTrigger,EAST,200,1,3,2,-1,0,true] execVM "G_Occupation.sqf";  
This means the AI will be EAST, they will spawn in buildings within 200m from the trigger executing the script, they will spawn at a random number per building between 0
and 3, they will be grouped per building, the number of groups is not directly limited, buildings will be selected randomly, and debug is enabled.

I suggest that the editor-placed trigger has no radius (as it is irrelevant to this script), and condition set to true (therefore it activates on mission start).

--Notes/Tips:
-I understand this is a wall of text, but I assure you it is the most complicated part of this SIMPLE script!
-Due to the nature of this script, the larger the desired numbers and spawn radius, the more time it takes to complete its process,
and the more laggy the server will be during the process. This can be mediated by reducing the numbers or having multiple triggers 
executing this script with smaller radii, thus allowing multiple spawns to occur in parallel.
-The radius/dimensions of the trigger in the editor have NO EFFECT on this script, other than that trigger's activation. The radius that
this script references is defined in the parameters as listed above. 
-It is recommended to run this script at mission start so that any potential lag does not occur during the mission. However, it can be 
done at any time, as long as it is via trigger with the above parameters. 
-You can add or remove classnames in the _sclasses arrays. The script is already setup to select 1 at random per individual spawn.
-To use the debug mode, which tells you exactly what is spawning and where, simply add a true at the end of the parameters,
as mentioned above. I strongly, strongly recommend this for all applications in order to ensure a smooth and working execution.
-Unfortunately, ArmA is limited to 144 groups per side. Be sure to read about this further in the installation instructions. To see 
if you've exceeded the group limit, look in the far southwest corner (bottom left) of the map. If there are 
Red markers there, you have exceeded the group limit. As well, you will see it indicated in the debug texts.
-On that note, the ONLY limiter to this script is the available buildings, the 144 group limit, and your values. 
-AI DO maintain their spawned position if spawned in a group, until entering combat.
-This script contains various "checks" in order to ensure your success!
-All of my recommended limitations can be experimented with, of course. Make your mission as good as it can be!
*/

if (!isServer) exitWith {};
private ["_sclasses","_timer","_rndmnum","_debug","_groupsize","_spawntocount","_egrp","_bcountvar","_maxnumgroups","_numgroups","_ecountvar","_barray","_etospawn","_buildings"];

if ((count _this) < 6) exitWith {player sideChat "G_Occupation - All 6 initial parameters must be filled out in the trigger!"};

sleep 1;

_trigger = _this select 0;

_sside = _this select 1;
switch (_sside) do
{
	case WEST: 
	{
		_sclasses = ["B_Soldier_F"];
	};
	case EAST:
	{
		_sclasses = ["O_Soldier_F"];
	};
	case GUER:
	{
		_sclasses = ["I_Soldier_F"];
	};
	case CIV:
	{
		_sclasses = ["C_Man_1"];
	};
};
_sclassesnum = count _sclasses;

_triggerradius = _this select 2;
_spawntype = _this select 3;
_maxperbuilding = _this select 4;
_groupopt = _this select 5;
if (_groupopt >= 3) then {
	_groupsize = 0;
};
_maxnumgroups = _this select 6;
_numgroups = 0;
_buildingorder = _this select 7;
_debug = _this select 8;
if (isNil "_debug") then {
	_debug = false;
}
else
{
	if (_debug) then {
		
		_ecountvar = 0;
		_bcountvar = 0;
		player sideChat "Debug: Beginning spawn via G_Occupation! Counts and Timer starting!";
		_timer = time;
	};
};

//Checks
if (typeName _trigger != "OBJECT") exitWith {player sideChat "G_Occupation - Select 0 must be thisTrigger!"};
if (typeName _sside != "SIDE") exitWith {player sideChat "G_Occupation - Select 1 must be a side!"};
if ((typeName _triggerradius != "SCALAR") || (_triggerradius <= 0)) exitWith {player sideChat "G_Occupation - Select 2 must be a positive number greater than 0!"};
if (typeName _spawntype != "SCALAR") exitWith {player sideChat "G_Occupation - Select 3 must be a number!"};
if ((typeName _maxperbuilding != "SCALAR") || (_maxperbuilding <= 0)) exitWith {player sideChat "G_Occupation - Select 4 must be a positive number greater than 0!"};
if ((typeName _groupopt != "SCALAR") || (_groupopt <= 0)) exitWith {player sideChat "G_Occupation - Select 5 must be a positive number greater than 0!"};
if ((typeName _maxnumgroups != "SCALAR") || (_maxnumgroups == 0)) exitWith {player sideChat "G_Occupation - Select 6 must be a number that is not 0!"};
if (typeName _buildingorder != "SCALAR") exitWith {player sideChat "G_Occupation - Select 7 must be a number!"};

_triggerpos = getPos _trigger;

if (_debug) then {
	_debugmkr = createMarker ["G_Occupationradius", _triggerpos];
	_debugmkr setMarkerShape "ELLIPSE";
	_debugmkr setMarkerBrush "Border";
	_debugmkr setMarkerSize [_triggerradius, _triggerradius];
};

_buildings = nearestObjects [_triggerpos,["building"], _triggerradius];
if (_buildingorder == 1) then {
	_buildings = _buildings call BIS_fnc_arrayShuffle;
};

if (_spawntype <= 1) then {
	{
		if (_numgroups == _maxnumgroups) exitWith {};
		_posarray = [_x] call BIS_fnc_buildingPositions; 
		_poscount = count _posarray;
		if (_poscount != 0) then {
			if (_debug) then {
				_debugmkr = createMarker [format["mkr%1",_x], getPos _x];
				_debugmkr setMarkerType "mil_objective";
				_bcountvar = _bcountvar + 1;
			};
			if (_spawntype == 1) then {
				_rndmnum = floor(random(_poscount));
				_spawntocount = (_rndmnum min _maxperbuilding);
			}
			else
			{
				_rndmnum = _maxperbuilding;
				_spawntocount = _maxperbuilding;
			};
			if (_rndmnum != 0) then {
				if (_groupopt == 2) then {
					_egrp = createGroup _sside;
					_numgroups = _numgroups + 1;
				};
				for "_i" from 1 to _spawntocount do
				{
					if (_groupopt == 1) then {
						_egrp = createGroup _sside;
						_numgroups = _numgroups + 1;
					};
					if (_groupopt >= 3) then {
						if (_groupsize == 0) then {
							_egrp = createGroup _sside;
							_numgroups = _numgroups + 1;
						};
						_groupsize = _groupsize + 1;
						if (_groupsize >= _groupopt) then {
							_groupsize = 0;
						};
					};				
					_indivpos = _posarray call BIS_fnc_selectRandom; 
					if (isNil "_indivpos") exitWith {}; 
					_posarray = _posarray - [_indivpos]; 
					_rndmclass = _sclasses call BIS_fnc_selectRandom;
					_eunit = _egrp createUnit [_rndmclass, _indivpos, [], 0, "NONE"];
					doStop _eunit;
				
					if (_debug) then {
						_debugmkr = createMarker [format["mkr%1m%2",_x,_i], getPos _eunit];
						_debugmkr setMarkerType "mil_dot";
						_debugmkr setMarkerColor "ColorRed";
						_ecountvar = _ecountvar + 1;
					};
				};
			};
		};
	} forEach _buildings;
}
else
{
	_barray = [];
	{
		_posarray = [_x] call BIS_fnc_buildingPositions; 
		_poscount = count _posarray;
		if (_poscount != 0) then {
			_barray = _barray + _posarray;
			if (_debug) then {
				_debugmkr = createMarker [format["mkr%1",_x], getPos _x];
				_debugmkr setMarkerType "mil_objective";
				_bcountvar = _bcountvar + 1;
			};
		};
	} forEach _buildings;

	if (_spawntype == 3) then {
		_etospawn = ceil(random(_maxperbuilding));
		if (_etospawn == 0) then {
			_etospawn = 1;
		};
	}
	else
	{
		_etospawn = _maxperbuilding;
	};
	
	for "_i" from 1 to (_etospawn) do
	{
		if (_groupopt < 3) then {
			_egrp = createGroup _sside;
			_numgroups = _numgroups + 1;
		};
		if (_groupopt >= 3) then {
			if (_groupsize == 0) then {
				_egrp = createGroup _sside;
				_numgroups = _numgroups + 1;
			};
			_groupsize = _groupsize + 1;
			if (_groupsize >= _groupopt) then {
				_groupsize = 0;
			};
		};				
		_indivpos = _barray call BIS_fnc_selectRandom; 
		_barray = _barray - [_indivpos];
		_rndmclass = _sclasses call BIS_fnc_selectRandom;
		_eunit = _egrp createUnit [_rndmclass, _indivpos, [], 0, "NONE"];
		doStop _eunit;
	
		if (_debug) then {
			_debugmkr = createMarker [format["mkrm%1",_i], getPos _eunit];
			_debugmkr setMarkerType "mil_dot";
			_debugmkr setMarkerColor "ColorRed";
			_ecountvar = _ecountvar + 1;
		};
	};
};

if (_debug) then {
	_alldone = format["Time: %1 seconds, Buildings: %2",(time - _timer),_bcountvar];
	player sideChat _alldone;
	_sidechatfill = format["Min: 0, Max: %1, Actual: %2, Num. Groups: %3, Max. Groups: 144",(_bcountvar*_maxperbuilding), _ecountvar, _numgroups];
	player sideChat _sidechatfill;
	player sideChat "On your map, Black markers indicate subject buildings, Red markers indicate individual, spawned AI.";
};