/*
 *	Shows the hive, armory and command console health at all times to all players in NS Combat.
 *
 *	Note:		The plugin automatically disables itself in classic mode and when Tournament
 *			Mode is enabled.
 *
 *	Commands:	None
 *
 *	Cvars:		hc_sound	Set to 0 to disable the CC less than 33% HP warning siren. 1 to enable
 *    
 *	Requires:	ns2amx Module 1.0
 *
 *	Author:		Cheesy Peteza  
 *	Date:		8-September-2004
 *	Email:		cheesy@yoclan.com
 *	irc:		#yo-clan (QuakeNet)
 *
 */

#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <ns>

#define MARINE			1
#define ALIEN			2
#define HUD_CHANNEL		3	// 1-4 imessage(1) ScrollMsg(2) ns2amx menus(3 & 4)
#define MAX_ARMORY		6
#define DIEING_HP		33	// (Percentage)
#define MIN_CCWARNING_RPT_TIME	10.0	// How long to wait before playing the CC warning sound again
#define CC_WARNING_TIME		5.0	// How long to play the CC warning sound
#define SND_STOP		(1<<5)

new ccwarningsound[] = "ambience/warn3.wav"	// The half-life wav used for playing the CC warning sound

enum building {
	B_ID,
	B_LASTHP,
	B_MAXHP
}

new g_hive[building], g_cc[building], g_armory[MAX_ARMORY][building]
new g_maxplayers, g_numarmory
new g_lastcchp, Float:g_lastwarningtime

public plugin_init() {
	register_plugin( "Hive/CC Status", "2.3", "Cheesy Peteza" )
	register_cvar( "hiveccstatus_version", "2.3", FCVAR_SERVER )

	if ( !validMap() )			// Disable plugin for MvM & AvA
		return PLUGIN_CONTINUE

	register_cvar( "hc_sound", "1")

	if (ns_is_combat()) {
		register_event( "Countdown", "startThePlugin", "a")		// The max structure health isn't set
										// until a player joins a team
		g_cc[B_ID] = ns_get_build("team_command",0, 1)
		g_hive[B_ID] = ns_get_build("team_hive",0, 1)
		g_numarmory = ns_get_build("team_armory")
		for (new i=0; i<g_numarmory; ++i) 
			g_armory[i][B_ID] = ns_get_build("team_armory",0, i+1)
		g_maxplayers = get_maxplayers()
	}
	return PLUGIN_CONTINUE
}

public plugin_modules() {
	require_module("engine")
	require_module("ns")
	require_module("fakemeta")
}

public startThePlugin() {
	g_cc[B_MAXHP] = pev(g_cc[B_ID], pev_max_health)
	g_hive[B_MAXHP] = pev(g_hive[B_ID], pev_max_health)
	for (new i=0; i<g_numarmory; ++i) 
		g_armory[i][B_MAXHP] = pev(g_armory[i][B_ID], pev_max_health)

	register_event( "ResetHUD", "WaitShowStatus", "b")
	register_event( "HideWeapon", "WaitShowStatus", "b") // Not perfect, but an easy way to detect who just died
	set_task( 1.0, "UpdateStatus",_,_,_, "b" )

	return PLUGIN_HANDLED
}

public UpdateStatus() {
	new teamsToUpdate
	new ccHealth = floatround(entity_get_float(g_cc[B_ID], EV_FL_health) / float(g_cc[B_MAXHP]) * 100 )
	new hiveHealth = floatround(entity_get_float(g_hive[B_ID], EV_FL_health) / float(g_hive[B_MAXHP]) * 100 )
	new armoryHealth[MAX_ARMORY]

	for (new i=0; i<g_numarmory; ++i)
		armoryHealth[i] = floatround(entity_get_float(g_armory[i][B_ID], EV_FL_health) / float(g_armory[i][B_MAXHP]) * 100 )

	if ( ccHealth != g_cc[B_LASTHP] ) {
		g_cc[B_LASTHP] = ccHealth
		teamsToUpdate |= MARINE
	}

	if ( hiveHealth != g_hive[B_LASTHP] ) {
		g_hive[B_LASTHP] = hiveHealth
		teamsToUpdate |= ALIEN
	}

	for (new i=0; i<g_numarmory; ++i) {
		if ( armoryHealth[i] != g_armory[i][B_LASTHP] ) {
			g_armory[i][B_LASTHP] = armoryHealth[i]
			teamsToUpdate |= MARINE
		}
	}

	ShowTeamStatus( teamsToUpdate )

	return PLUGIN_HANDLED
}

ShowTeamStatus( teamsToUpdate ) {
	for (new id=1 ; id <= g_maxplayers ; ++id) {
		if (!is_valid_ent(id)) continue

		if (pev(id, pev_team) == MARINE) {
			if (teamsToUpdate & MARINE)
				ShowMarineStatus( id )
		} else if (pev(id, pev_team) == ALIEN) {
			if (teamsToUpdate & ALIEN)
				ShowAlienStatus( id )
		}
	}
}

public ShowMarineStatus( id ) {
	new hudline[256], temp[64], bool:dieing = false

	format(hudline, 255, "Armory:")

	for (new i=0; i<g_numarmory; ++i) {
		format(temp, 63, " %i%%%%", g_armory[i][B_LASTHP])
		add(hudline, 255, temp)
	}
	format(temp, 63, "^nCommand Console: %i%%%%", g_cc[B_LASTHP])
	add(hudline, 255, temp)

	if (g_cc[B_LASTHP] <= DIEING_HP) dieing = true

	if ( dieing && (g_lastcchp > DIEING_HP) && get_cvar_num("hc_sound") ) {
		if ((get_gametime() - g_lastwarningtime) >= MIN_CCWARNING_RPT_TIME) {
			g_lastwarningtime = get_gametime()
			playCCWarning()
		}
	}
	g_lastcchp = g_cc[B_LASTHP]

	set_hudmessage(dieing?255:0, dieing?0:75, dieing?0:100, 0.6, is_user_alive(id)?0.92:0.85, dieing?1:0, 1.0, 3600.0, 1.0, 1.0, HUD_CHANNEL)
	show_hudmessage( id, hudline )
}

public ShowAlienStatus( id ) {
	new bool:dieing
	if (g_hive[B_LASTHP] <= DIEING_HP) dieing = true

	set_hudmessage(dieing?255:160, dieing?0:100, dieing?0:0, 0.85, is_user_alive(id)?0.95:0.9, dieing?1:0, 1.0, 3600.0, 1.0, 1.0, HUD_CHANNEL)
	show_hudmessage( id, "Hive: %i%%", g_hive[B_LASTHP] )
}

public WaitShowStatus( id ) {
	if (pev(id, pev_team) == MARINE) 
		set_task( 1.0, "ShowMarineStatus", id )
	else if (pev(id, pev_team) == ALIEN)
		set_task( 1.0, "ShowAlienStatus", id )

	return PLUGIN_HANDLED
}

public plugin_precache()
	precache_sound(ccwarningsound)

public playCCWarning() {
	for (new id=1; id<=g_maxplayers; id++) {
		if (!is_valid_ent(id)) continue
		if (pev(id, pev_team) == MARINE) {
			client_cmd(id, "play %s", ccwarningsound)
			set_task(CC_WARNING_TIME, "stopCCWarning")
		}
	}
}

public stopCCWarning() {
	for (new id=1; id<=g_maxplayers; id++) {
		if (!is_valid_ent(id)) continue
		if (pev(id, pev_team) == MARINE) {
			client_cmd(id, "stopsound")
		}
	}
}

validMap() {
	new numcc, numhive

	numcc = ns_get_build("team_command",0)
	numhive = ns_get_build("team_hive",0)

	if ( (numcc == 1) && (numhive == 1) )
		return 1

	return 0
}