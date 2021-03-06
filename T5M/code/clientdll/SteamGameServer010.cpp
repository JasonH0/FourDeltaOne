// ==========================================================
// alterIWnet project
// 
// Component: aiw_client
// Sub-component: steam_api
// Purpose: ISteamGameServer010 implementation
//
// Initial author: NTAuthority
// Started: 2010-09-28
// ==========================================================

#include "StdInc.h"
#include "SteamGameServer010.h"

static void SteamGS_OnValidateTicket(NPAsync<NPValidateUserTicketResult>* async)
{
	NPValidateUserTicketResult* result = async->GetResult();

	if (result->result == ValidateUserTicketResultOK)
	{
		GSClientApprove_t* retvals = (GSClientApprove_t*)malloc(sizeof(GSClientApprove_t));
		retvals->m_SteamID = CSteamID(result->id);
		CSteamBase::ReturnCall(retvals, sizeof(GSClientApprove_t), GSClientApprove_t::k_iCallback, 0);

		//SteamGS_AddToGroupQueue(result->id, result->groupID);
	}
	else
	{
		GSClientDeny_t* retvals = (GSClientDeny_t*)malloc(sizeof(GSClientDeny_t));

		retvals->m_SteamID = CSteamID(result->id);
		retvals->m_eDenyReason = k_EDenyNoLicense;

		CSteamBase::ReturnCall(retvals, sizeof(GSClientDeny_t), GSClientDeny_t::k_iCallback, 0);
	}
}

void CSteamGameServer010::LogOn() {
	
}

void CSteamGameServer010::LogOff() {
	
}

bool CSteamGameServer010::LoggedOn() {
	
	return true;
}

bool CSteamGameServer010::Secure() {
	
	return false;
}

CSteamID CSteamGameServer010::GetSteamID() {
	
	NPID npID;
	NP_GetNPID(&npID);
	return CSteamID(npID);
}

bool CSteamGameServer010::SendUserConnectAndAuthenticate( uint32 unIPClient, const void *pvAuthBlob, uint32 cubAuthBlobSize, CSteamID *pSteamIDUser ) {
	
	NPAsync<NPValidateUserTicketResult>* async = NP_ValidateUserTicket(pvAuthBlob, cubAuthBlobSize, unIPClient, pSteamIDUser->ConvertToUint64());
	async->SetCallback(SteamGS_OnValidateTicket, NULL);
	return true;
}

CSteamID CSteamGameServer010::CreateUnauthenticatedUserConnection() {
	
	NPID npID;
	NP_GetNPID(&npID);
	return CSteamID(npID);
}

void CSteamGameServer010::SendUserDisconnect( CSteamID steamIDUser ) {
	
}

bool CSteamGameServer010::UpdateUserData( CSteamID steamIDUser, const char *pchPlayerName, uint32 uScore ) {
	
	return true;
}

bool CSteamGameServer010::SetServerType( uint32 unServerFlags, uint32 unGameIP, uint16 unGamePort, uint16 unSpectatorPort, uint16 usQueryPort, const char *pchGameDir, const char *pchVersion, bool bLANMode ) {
	
	return true;
}

void CSteamGameServer010::UpdateServerStatus( int cPlayers, int cPlayersMax, int cBotPlayers, const char *pchServerName, const char *pSpectatorServerName, const char *pchMapName ) {
	
}

void CSteamGameServer010::UpdateSpectatorPort( uint16 unSpectatorPort ) { }

void CSteamGameServer010::SetGameTags( const char *pchGameType ) { }

bool CSteamGameServer010::GetUserAchievementStatus( CSteamID steamID, const char *pchAchievementName ) {
	
	return false;
}

void CSteamGameServer010::GetGameplayStats( ) {}

SteamAPICall_t CSteamGameServer010::GetServerReputation( )
{
	return 0;
}

bool CSteamGameServer010::RequestUserGroupStatus( CSteamID steamIDUser, CSteamID steamIDGroup ) {
	
	return false;
}

uint32 CSteamGameServer010::GetPublicIP() {
	
	return 0;
}

void CSteamGameServer010::SetGameData( const char *pchGameData) {
	
}

EUserHasLicenseForAppResult CSteamGameServer010::UserHasLicenseForApp( CSteamID steamID, AppId_t appID ) {
	return k_EUserHasLicenseResultHasLicense;
}
