/*
Author: KC Grimes
Script: Grimes Building Occupation Script
Version: V1.2
*/

//Script should only run on the server
if (!isServer) exitWith {};

//Make sure all required parameters are defined
if ((count _this) < 8) exitWith {systemChat "G_Occupation - All 8 initial parameters must be filled out in the trigger!"};

//Wait for mission init
sleep 1;

//Define local variables from execution parameters
_trigger = _this select 0;
_side = _this select 1;
//Define classnames to use based on selected side
_sClasses = [];
switch (_side) do
{
	case west: 
	{
		_sClasses = ["B_Soldier_F"];
	};
	case east:
	{
		_sClasses = ["O_Soldier_F"];
	};
	case resistance:
	{
		_sClasses = ["I_Soldier_F"];
	};
	case civilian:
	{
		_sClasses = ["C_Man_1"];
	};
};
_triggerRadius = _this select 2;
_spawnType = _this select 3;
_maxToSpawn = _this select 4;
_groupOption = _this select 5;
private ["_groupSize"];
if (_groupOption >= 3) then {
	//Create variable to track "script group" size
	_groupSize = 0;
};
//Limit max number of groups to engine max of 144 per side
_maxNumGroups = ((_this select 6) min 144);
if (_maxNumGroups == -1) then {
	_maxNumGroups = 144;
};
//Create variable for counting groups
_numGroups = 0;
_buildingOrder = _this select 7;
_debug = _this select 8;
private ["_unitCount", "_buildingCount", "_timer"];
//Check if optional debug param was defined
if (isNil "_debug") then {
	//Debug was not defined
	//bug - An undefined variable comes here, and a bad value is converted to false without debug message
	_debug = false;
};
//Check if debug was incorrectly defined, and exit if so
if (typeName _debug != "BOOL") exitWith {systemChat "G_Occupation - Select 8 must be a boolean or not defined!"};

if (_debug) then {
	//Debug was defined as true
	//Define variables for debug counting
	_unitCount = 0;
	_buildingCount = 0;
	//Initialize the debug timer
	systemChat "Debug: Beginning spawn via G_Occupation! Counts and Timer starting!";
	_timer = time;
};

//Check for values within required limits, and exit with an error message if not
if (typeName _trigger != "OBJECT") exitWith {systemChat "G_Occupation - Select 0 must be thisTrigger!"};
if (typeName _side != "SIDE") exitWith {systemChat "G_Occupation - Select 1 must be a side!"};
if ((typeName _triggerRadius != "SCALAR") || (_triggerRadius <= 0)) exitWith {systemChat "G_Occupation - Select 2 must be a positive number greater than 0!"};
if ((typeName _spawnType != "SCALAR") || !(_spawnType in [0,1,2,3])) exitWith {systemChat "G_Occupation - Select 3 must be a number!"};
if ((typeName _maxToSpawn != "SCALAR") || (_maxToSpawn <= 0)) exitWith {systemChat "G_Occupation - Select 4 must be a positive number greater than 0!"};
if ((typeName _groupOption != "SCALAR") || (_groupOption <= 0)) exitWith {systemChat "G_Occupation - Select 5 must be a positive number greater than 0!"};
if ((typeName _maxNumGroups != "SCALAR") || (_maxNumGroups == 0)) exitWith {systemChat "G_Occupation - Select 6 must be a number that is not 0!"};
if ((typeName _buildingOrder != "SCALAR") || !(_buildingOrder in [0,1])) exitWith {systemChat "G_Occupation - Select 7 must be a number!"};

//Define position of the trigger
_triggerPos = getPos _trigger;

if (_debug) then {
	//Create border around trigger radius
	_debugMkr = createMarker ["G_Occupation_Radius", _triggerPos];
	_debugMkr setMarkerShape "ELLIPSE";
	_debugMkr setMarkerBrush "Border";
	_debugMkr setMarkerSize [_triggerRadius, _triggerRadius];
};

//Function to randomize an array because BIS_fnc_arrayShuffle isn't working nor are any involving pushBack and deleteAt
//Source: Killzone_Kid KK_fnc_arrayShuffleFY EDIT http://killzonekid.com/arma-scripting-tutorials-arrays-part-4-arrayshuffle/
KK_fnc_arrayShuffleFY = {
    private ["_el","_rnd"];
    for "_i" from count _this - 1 to 0 step -1 do {
        _el = _this select _i;
        _rnd = floor random (_i + 1);
        _this set [_i, _this select _rnd];
        _this set [_rnd, _el];
    }; 
    _this
};

//Obtain array of buildings within the radius of the trigger position
_buildings = nearestObjects [_triggerPos, ["building"], _triggerRadius];
//Check if buildings are to be cycled at random per param
if (_buildingOrder == 1) then {
	//Randomize the array
	_buildings = _buildings call KK_fnc_arrayShuffleFY;
};

//Function to check if group number exeeds  maximum allowed groups by definition and engine
G_fnc_checkNumGroups = {
	private ["_numGroups","_maxNumGroups","_side","_maxGroupsAchieved","_realNumGroups"];
	_numGroups = _this select 0;
	_maxNumGroups = _this select 1;
	_side = _this select 2;
	//Default return is false
	_maxGroupsAchieved = false;
	//Start existing group count for side at 0
	_realNumGroups = 0;
	//Cycle through all existing groups
	{
		//Check if the group is on the defined side
		if (side _x == _side) then {
			//Add group to the count
			_realNumGroups = _realNumGroups + 1;
		};
	} forEach allGroups;
	//Check if the number of groups is maxed out by definition or engine max of 144
	if ((_numGroups >= _maxNumGroups) || (_realNumGroups >= 144)) then {
		//Max exceeded, return true
		_maxGroupsAchieved = true;
	};
	_maxGroupsAchieved;
};

//bug - Replace this massive if/then with smaller if/thens, more functions, and overall fewer lines
//Check if _spawnType setting 0 or 1
if (_spawnType in [0,1]) then {
	//_spawnType setting 0 or 1
	scopeName "spawnTypeScope";
	//Cycle through each building in the building array
	{
		//Obtain array of positions within subject building
		_posArray = [_x] call BIS_fnc_buildingPositions;
		//Count number of positions in the array
		_posCount = count _posArray;
		//Make sure there are positions existing inside the building
		if (_posCount != 0) then {
			//Positions do exist
			//bug - Building gets tagged before break out due exiting when max groups achieved
			if (_debug) then {
				//Create marker for building
				_debugMkr = createMarker [format ["mkr%1", _x], getPos _x];
				_debugMkr setMarkerType "mil_objective";
				//Add building to the count
				_buildingCount = _buildingCount + 1;
			};
			
			//Default _spawnType 0
			_unitsToSpawn = _maxToSpawn;
			if (_spawnType == 1) then {
				//_spawnType 1
				//Select the smaller out of a random number between 0 and available positions, and the defined max
				_unitsToSpawn = ((round(random(_posCount))) min _maxToSpawn);
			};
			
			//Check if 1 or more units are to spawn in subject building
			if (_unitsToSpawn != 0) then {
				//1 or more units will be spawning in subject building
				//Check if _groupOption 2 is being used
				private ["_aiGrp"];
				if (_groupOption == 2) then {
					//Create single group for all units in the building
					//Check if max number of groups achieved
					_maxGroupsAchieved = [_numGroups, _maxNumGroups, _side] call G_fnc_checkNumGroups;
					if (_maxGroupsAchieved) then {
						//Max achieved, so break out
						breakTo "spawnTypeScope";
					};
					_aiGrp = createGroup _side;
					//Add group to the count
					_numGroups = _numGroups + 1;
				};
				//Cycle for each count in _unitsToSpawn
				for "_i" from 1 to _unitsToSpawn do
				{
					//Handle groups as defined by _groupOption if not grouped by building
					if (_groupOption == 1) then {
						//Create a group for each individual unit in the subject building
						//Check if max number of groups achieved
						_maxGroupsAchieved = [_numGroups, _maxNumGroups, _side] call G_fnc_checkNumGroups;
						if (_maxGroupsAchieved) then {
							//Max achieved, so break out
							breakTo "spawnTypeScope";
						};
						_aiGrp = createGroup _side;
						//Add group to the count
						_numGroups = _numGroups + 1;
					};
					if (_groupOption >= 3) then {
						//Group has a fixed size
						//Check if script's "global group" is empty
						if (_groupSize == 0) then {
							//Create a new group
							//Check if max number of groups achieved
							_maxGroupsAchieved = [_numGroups, _maxNumGroups, _side] call G_fnc_checkNumGroups;
							if (_maxGroupsAchieved) then {
								//Max achieved, so break out
								breakTo "spawnTypeScope";
							};
							_aiGrp = createGroup _side;
							//Add group to the count
							_numGroups = _numGroups + 1;
						};
						//Add this unit to the "global group"'s size
						_groupSize = _groupSize + 1;
						//Check if the "global group" has achieved the max defined in _groupOption
						if (_groupSize >= _groupOption) then {
							//Max is achieved, so reset the "global group" to empty for next cycle
							_groupSize = 0;
						};
					};
					//The group to spawn this unit in is now defined as _aiGrp
					//Randomly obtain single position from array of building positions
					_indivPos = selectRandom _posArray;
					//If this fails, there are no more positions available, so exit the cycle for this building
					if (isNil "_indivPos") exitWith {};
					//Remove the selected position from the array of building positions for next cycle
					_posArray = _posArray - [_indivPos];
					//Randomly select a classname from the array of classnames
					_rndmClass = selectRandom _sClasses;
					//Spawn a unit of randomly selected class at the randomly selected building position,
					//with no special attributes
					_aiUnit = _aiGrp createUnit [_rndmClass, _indivPos, [], 0, "NONE"];
					//Keep the unit in place until an order is given by the squad leader
					doStop _aiUnit;

					if (_debug) then {
						//Create a marker on the unit's spawn location
						_debugMkr = createMarker [format ["mkr%1m%2", _x, _i], getPos _aiUnit];
						_debugMkr setMarkerType "mil_dot";
						_debugMkr setMarkerColor "ColorRed";
						//Add the unit to the unit count
						_unitCount = _unitCount + 1;
					};
				};
			};
		};
	} forEach _buildings;
}
else
{
	//_spawnType setting 2 or 3
	scopeName "spawnTypeScope";
	//Cycle through each building in the building array
	//Create empty array to store building positions
	_allPosArray = [];
	{
		//Obtain array of positions within subject building
		_posArray = [_x] call BIS_fnc_buildingPositions; 
		//Count number of positions in the array
		_posCount = count _posArray;
		//Make sure there are positions existing inside the building
		if (_posCount != 0) then {
			//Positions do exist
			//Add array of positions in subject building to overall array of positions
			_allPosArray = _allPosArray + _posArray;
			if (_debug) then {
				//Create marker for building
				_debugMkr = createMarker [format ["mkr%1", _x], getPos _x];
				_debugMkr setMarkerType "mil_objective";
				//Add building to the count
				_buildingCount = _buildingCount + 1;
			};
		};
	} forEach _buildings;
	
	//Default _spawnType 2
	_unitsToSpawn = _maxToSpawn;
	
	if (_spawnType == 3) then {
		//_spawnType 3
		//Select a random number between 0 and the defined maximum
		_unitsToSpawn = round(random(_maxToSpawn));
	};
	
	//Check if 1 or more units are to spawn in subject area
	if (_unitsToSpawn != 0) then {
		//1 or more units will be spawning in subject area
		private ["_aiGrp"];
		for "_i" from 1 to (_unitsToSpawn) do
		{
			if (_groupOption in [1,2]) then {
				//Create a group for each individual unit in the subject area
				//Check if max number of groups achieved
				_maxGroupsAchieved = [_numGroups, _maxNumGroups, _side] call G_fnc_checkNumGroups;
				if (_maxGroupsAchieved) then {
					//Max achieved, so break out
					breakTo "spawnTypeScope";
				};
				_aiGrp = createGroup _side;
				//Add group to the count
				_numGroups = _numGroups + 1;
			};
			if (_groupOption >= 3) then {
				//Group has a fixed size
				//Check if script's "global group" is empty
				if (_groupSize == 0) then {
					//Create a new group
					//Check if max number of groups achieved
					_maxGroupsAchieved = [_numGroups, _maxNumGroups, _side] call G_fnc_checkNumGroups;
					if (_maxGroupsAchieved) then {
						//Max achieved, so break out
						breakTo "spawnTypeScope";
					};
					_aiGrp = createGroup _side;
					//Add group to the count
					_numGroups = _numGroups + 1;
				};
				//Add this unit to the "global group"'s size
				_groupSize = _groupSize + 1;
				//Check if the "global group" has achieved the max defined in _groupOption
				if (_groupSize >= _groupOption) then {
					//Max is achieved, so reset the "global group" to empty for next cycle
					_groupSize = 0;
				};
			};
			//The group to spawn this unit in is now defined as _aiGrp
			//Randomly obtain single position from array of all building positions
			_indivPos = selectRandom _allPosArray;
			//If this fails, there are no more positions available, so exit the cycle for this area
			if (isNil "_indivPos") exitWith {};
			//Remove the selected position from the array of all building positions for next cycle
			_allPosArray = _allPosArray - [_indivPos];
			//Randomly select a classname from the array of classnames
			_rndmClass = selectRandom _sClasses;
			//Spawn a unit of randomly selected class at the randomly selected building position,
			//with no special attributes
			_aiUnit = _aiGrp createUnit [_rndmClass, _indivPos, [], 0, "NONE"];
			//Keep the unit in place until an order is given by the squad leader
			doStop _aiUnit;
		
			if (_debug) then {
				//Create a marker on the unit's spawn location
				_debugMkr = createMarker [format["mkrm%1", _i], getPos _aiUnit];
				_debugMkr setMarkerType "mil_dot";
				_debugMkr setMarkerColor "ColorRed";
				//Add the unit to the unit count
				_unitCount = _unitCount + 1;
			};
		};
	};
};

if (_debug) then {
	//Output results of script
	//Output final time and number of subject buildings
	systemChat format ["Time: %1 seconds, Buildings: %2", (time - _timer), _buildingCount];
	//Define max number of possible AI spawns based on spawnType setting
	_max = (_buildingCount * _maxToSpawn);
	if (_spawnType in [2,3]) then {
		_max = _maxToSpawn;
	};
	//Output minimum and maximum number of possible groups and AI spawns, along with the actual numbers
	systemChat format ["Min: 0, Max: %1, Actual: %2, Num. Groups: %3, Max. Groups: %4", _max, _unitCount, _numGroups, _maxNumGroups];
	//Output map viewing instructions
	systemChat "On your map, Black markers indicate subject buildings and Red markers indicate individually spawned AI.";
};