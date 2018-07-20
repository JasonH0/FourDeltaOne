#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.isTeamSpeaking["allies"] = false;
	level.isTeamSpeaking["axis"] = false;
	
	level.speakers["allies"] = [];
	level.speakers["axis"] = [];
	
	level.bcSounds = [];
	level.bcSounds["reload"] = "1_inform_reloading_generic";
	level.bcSounds["frag_out"] = "1_inform_attack_grenade";
	level.bcSounds["flash_out"] = "1_inform_attack_flashbang";
	level.bcSounds["smoke_out"] = "1_inform_attack_smoke";
	level.bcSounds["conc_out"] = "1_inform_attack_stun";
	level.bcSounds["knife_out"] = "mp_knife_use";
	level.bcSounds["semtex_out"] = "mp_semtex_use";
	level.bcSounds["tacins_plant"] = "mp_tactical_insertion";
	level.bcSounds["c4_plant"] = "1_inform_attack_thwc4";
	level.bcSounds["claymore_plant"] = "1_inform_plant_claymore";
	level.bcSounds["kill"] = "1_inform_killfirm_infantry";
	level.bcSounds["casualty"] = "1_inform_casualty_generic";

	level thread onPlayerConnect();	
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill ( "connected", player );

		player thread onPlayerSpawned();
	}
}


onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		
		// help players be stealthy in splitscreen by not announcing their intentions
		if ( level.splitscreen )
			continue;
		
		self thread claymoreTracking();
		self thread reloadTracking();
		self thread grenadeTracking();
	}
}


claymoreTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	while(1)
	{
		self waittill( "begin_firing" );
		weaponName = self getCurrentWeapon();
		if ( weaponName == "claymore_mp" )
			level thread sayLocalSound( self, "claymore_plant" );
	}
}


reloadTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill ( "reload_start" );
		level thread sayLocalSound( self, "reload" );
	}
}


grenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill ( "grenade_fire", grenade, weaponName );
		
		if ( weaponName == "frag_grenade_mp" )
			level thread sayLocalSound( self, "frag_out" );
		else if ( weaponName == "flash_grenade_mp" )
			level thread sayLocalSound( self, "flash_out" );
		else if ( weaponName == "concussion_grenade_mp" )
			level thread sayLocalSound( self, "conc_out" );
		else if ( weaponName == "smoke_grenade_mp" )
			level thread sayLocalSound( self, "smoke_out" );
		else if ( weaponName == "semtex_mp" )
			level thread sayLocalSound( self, "semtex_out" );
		else if ( weaponName == "throwingknife_mp" )
			level thread sayLocalSound( self, "knife_out" );
		else if ( weaponName == "c4_mp" )
			level thread sayLocalSound( self, "c4_plant" );
		else if ( weaponName == "flare_mp" )
			level thread sayLocalSound( self, "tacins_plant" );
	}
}


sayLocalSoundDelayed( player, soundType, delay )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	
	wait ( delay );
	
	sayLocalSound( player, soundType );
}


sayLocalSound( player, soundType )
{
	player endon ( "death" );
	player endon ( "disconnect" );

	if ( isSpeakerInRange( player ) )
		return;
		
	if( player.team != "spectator" )
	{	
		prefix = maps\mp\gametypes\_teams::getTeamVoicePrefix( player.team );
		soundAlias = prefix + level.bcSounds[soundType];
		player thread doSound( soundAlias );
	}
}


doSound( soundAlias )
{
	team = self.pers["team"];
	level addSpeaker( self, team );

	if (level.players.size > 1) // workaround to play sounds in 1-player (local testing)
	{
		self playSoundToTeam( soundAlias, team, self );
	}
	else
	{
		self playSoundToTeam( soundAlias, team );
	}

	self thread timeHack( soundAlias ); // workaround because soundalias notify isn't happening
	self waittill_any( soundAlias, "death", "disconnect" );
	level removeSpeaker( self, team );
}


timeHack( soundAlias )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	wait ( 2.0 );
	self notify ( soundAlias );
}


isSpeakerInRange( player )
{
	player endon ( "death" );
	player endon ( "disconnect" );

	distSq = 1000 * 1000;

	// to prevent player switch to spectator after throwing a granade causing damage to someone and result in attacker.pers["team"] = "spectator"
	if( isdefined( player ) && isdefined( player.pers["team"] ) && player.pers["team"] != "spectator" )
	{
		for ( index = 0; index < level.speakers[player.pers["team"]].size; index++ )
		{
			teammate = level.speakers[player.pers["team"]][index];
			if ( teammate == player )
				return true;
				
			if ( distancesquared( teammate.origin, player.origin ) < distSq )
				return true;
		}
	}

	return false;
}


addSpeaker( player, team )
{
	level.speakers[team][level.speakers[team].size] = player;
}


// this is lazy... fix up later by tracking ID's and doing array slot swapping
removeSpeaker( player, team )
{
	newSpeakers = [];
	for ( index = 0; index < level.speakers[team].size; index++ )
	{
		if ( level.speakers[team][index] == player )
			continue;
			
		newSpeakers[newSpeakers.size] = level.speakers[team][index]; 
	}
	
	level.speakers[team] = newSpeakers;
}
