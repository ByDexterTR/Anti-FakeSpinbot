#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

float c_mYaw[65] = { 0.0, ... }, c_Sens[65] = { 0.0, ... };

ConVar Penaltytype = null, Bantime = null;

#define LoopClientsNoBots(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1) && !IsFakeClient(%1))

public Plugin myinfo = 
{
	name = "Anti-FakeSpinbot", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	Penaltytype = CreateConVar("sm_fsb_penalty_type", "0", "0 = Kick | 1 = Ban", 0, true, 0.0, true, 1.0);
	Bantime = CreateConVar("sm_fsb_ban_time", "10", "if it has to be banned, how many minutes? [ 0 = Perma ]", 0, true, 0.0);
	AutoExecConfig(true, "Anti-Fakespinbot", "ByDexter");
}

public void OnMapStart()
{
	CreateTimer(1.0, Timer_Control, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Control(Handle timer, any data)
{
	LoopClientsNoBots(client)
	{
		QueryClientConVar(client, "m_yaw", OnYawRetrieved);
		QueryClientConVar(client, "sensitivity", OnSensitivityRetrieved);
		if (c_mYaw[client] / c_Sens[client] >= 90.0)
		{
			c_mYaw[client] = 0.0;
			c_Sens[client] = 0.0;
			if (!Penaltytype.BoolValue)
			{
				KickClient(client, "Fake SpinBot detected");
			}
			else
			{
				if (Bantime.IntValue == 0)
				{
					BanClient(0, 0, BANFLAG_AUTO, "Fake Spinbot", "Fake SpinBot detected, you are permanently suspended", "sm_ban", client);
				}
				else
				{
					char BanFormat[256];
					Format(BanFormat, 256, "Fake SpinBot detected, you are suspended for %d minutes", Bantime.IntValue);
					BanClient(0, Bantime.IntValue, BANFLAG_AUTO, "Fake Spinbot", BanFormat, "sm_ban", client);
				}
			}
		}
	}
}

public void OnYawRetrieved(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	float mYaw = StringToFloat(cvarValue);
	if (c_mYaw[client] != mYaw)
	{
		c_mYaw[client] = mYaw;
	}
}

public void OnSensitivityRetrieved(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	float Sens = StringToFloat(cvarValue);
	if (c_Sens[client] != Sens)
	{
		c_Sens[client] = Sens;
	}
} 