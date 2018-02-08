/*
Author: KC Grimes
Script: Grimes Building Occupation Script
Version: V1.1
*/

if (!isServer) exitWith {};
private ["_sclasses","_timer","_rndmnum","_debug","_groupsize","_spawntocount","_egrp","_bcountvar","_maxnumgroups","_numgroups","_ecountvar","_barray","_etospawn","_buildings"];

if ((count _this) < 6) exitWith {player sideChat "G_Occupation - All 6 initial parameters must be filled out in the trigger!"};

sleep 1;

_trigger = _this select 0;

_sside = _this select 1;
switch (_sside) do
{
	case west: 
	{
		_sclasses = ["B_Soldier_F"];
	};
	case east:
	{
		_sclasses = ["O_Soldier_F"];
	};
	case resistance:
	{
		_sclasses = ["I_Soldier_F"];
	};
	case civilian:
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