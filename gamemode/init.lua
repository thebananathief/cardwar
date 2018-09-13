AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("setup.lua")
util.AddNetworkString("SendReady")

timey = false
roundInProg = false
loadoutRed = {}
loadoutBlue = {}
local currentStage = 0
local sBeacons = {}
npcsRed = {}
npcsBlue = {}
local readyRed = false
local readyBlue = false

local function AutospawnProps()
	local mapName = game.GetMap()
	local mapData = MapData[mapName]

	if mapData then
		for _, v in pairs(mapData) do
			local entType = v.class or "prop_physics"
			local newEnt = ents.Create(entType)

			if v.ang then
				newEnt:SetAngles(v.ang)
			end

			if v.pos then
				newEnt:SetPos(v.pos)
			end

			if v.team then
				newEnt:SetcwTeam(v.team)
			end

			if v.class == "cw_spawnbeacon" then
				table.insert(sBeacons, newEnt)
			end

			newEnt:Spawn()
			newEnt:Activate()
		end
	end
end

hook.Add("InitPostEntity", "Autospawn Props On Load", AutospawnProps)

function GM:Initialize()
end

function TeleportPlayers()
	for k, v in pairs(team.GetPlayers(0)) do
		if currentStage == 0 then
			v:SetPos(stageTPs[1].pos)
		elseif currentStage == 1 then
			v:SetPos(stageTPs[3].pos)
		else
			v:SetPos(stageTPs[5].pos)
		end
	end

	for k, v in pairs(team.GetPlayers(1)) do
		if currentStage == 0 then
			v:SetPos(stageTPs[2].pos)
		elseif currentStage == 1 then
			v:SetPos(stageTPs[4].pos)
		else
			v:SetPos(stageTPs[6].pos)
		end
	end
end

function StartRound()
	roundInProg = true
	--TPing players
	TeleportPlayers()

	--Spawning npcs based on their beacons
	if currentStage == 0 then
		sBeacons[1]:SpawnTeam()
		sBeacons[2]:SpawnTeam()
	elseif currentStage == 1 then
		sBeacons[3]:SpawnTeam()
		sBeacons[4]:SpawnTeam()
	else
		sBeacons[5]:SpawnTeam()
		sBeacons[6]:SpawnTeam()
	end
	for k, v in pairs(npcsRed) do
		npcsRed[k]:SetColor(Color(255, 0, 0))
	end

	for k, v in pairs(npcsBlue) do
		npcsBlue[k]:SetColor(Color(0, 0, 255))
	end
end

function EndRound()
	for k, v in pairs(npcsRed) do
		v:Remove()
	end

	for k, v in pairs(npcsBlue) do
		v:Remove()
	end

	roundInProg = false
	readyRed = false
	readyBlue = false

	if currentStage < 2 then
		currentStage = currentStage + 1
	else
		currentStage = 0
	end

	net.Start("SendReady")
	net.WriteBool(readyRed)
	net.WriteBool(readyBlue)
	net.Broadcast()
	table.Empty(npcsRed)
	table.Empty(npcsBlue)
end

hook.Add("OnNPCKilled", "NPC Death Function", function(npc, attacker, inflictor)
	if table.HasValue(npcsRed, npc) then
		table.RemoveByValue(npcsRed, npc)
	elseif table.HasValue(npcsBlue, npc) then
		table.RemoveByValue(npcsBlue, npc)
	end

	if roundInProg then
		local ended = false
		if #npcsRed < 1 and !ended then
			ended = true
			timer.Simple(2, function()
				EndRound()
				ended = false
			end)
			team.AddScore(1, 1)

			for k, v in pairs(player.GetAll()) do
				v:SendLua("chat.AddText(Color(255,255,255), 'Blue Team has won the round!')")
			end
		elseif #npcsBlue < 1 and !ended then
			ended = true
			timer.Simple(2, function()
				EndRound()
				ended = false
			end)
			team.AddScore(0, 1)

			for k, v in pairs(player.GetAll()) do
				v:SendLua("chat.AddText(Color(255,255,255), 'Red Team has won the round!')")
			end
		end
	end
end)

function GM:CreateTeams()
	team.SetUp(0, "Red Team", Color(255, 0, 20), true)
	team.SetUp(1, "Blue Team", Color(20, 0, 255), true)
end

--function GM:PlayerSpawnSENT() return false end
function GM:PlayerSpawnEffect()
	return false
end

function GM:PlayerSpawnProp()
	return false
end

function GM:PlayerSpawnRagdoll()
	return false
end

function GM:PlayerSpawnSWEP()
	return false
end

function GM:PlayerSpawnVehicle()
	return false
end

function GM:PlayerSpawnSWEP()
	return false
end

function GM:PlayerGiveSWEP()
	return false
end

function GM:PlayerNoClip()
	local noc = GetConVar("sbox_noclip"):GetInt() > 0 or game.SinglePlayer()
	return noc
end

function GM:PlayerLoadout(ply)
	ply:Give("weapon_crowbar")
	ply:SetTeam(math.random(0, 1))

	return true
end

hook.Add("KeyPress", "Keypress Functions", function(ply, key)
	if (key == IN_RELOAD) then
		local ent = ents.Create("cw_card")
		local trace = ply:GetEyeTrace()
		ent:SetPos(trace.HitPos + Vector(0, 0, 50))
		ent:Spawn()
	end
end)

hook.Add("PlayerButtonDown", "PlayerButtonDown Functions", function(ply, button)
	if (button == KEY_F1) then
		if (ply:Team() == 0) then
			if readyRed then
				ply:SendLua("chat.AddText(Color(255,255,255), 'Your team is already ready!')")

				return
			end

			if (#loadoutRed < 1) then
				ply:SendLua("chat.AddText(Color(255,255,255), 'Put a card on a pedestial!')")

				return
			end

			readyRed = true
			ply:SendLua("chat.AddText(Color(255,255,255), 'Your team is ready!')")
		else
			if readyBlue then
				ply:SendLua("chat.AddText(Color(255,255,255), 'Your team is already ready!')")

				return
			end

			if (#loadoutBlue < 1) then
				ply:SendLua("chat.AddText(Color(255,255,255), 'Put a card on a pedestial!')")

				return
			end

			readyBlue = true
			ply:SendLua("chat.AddText(Color(255,255,255), 'Your team is ready!')")
		end

		net.Start("SendReady")
		net.WriteBool(readyRed)
		net.WriteBool(readyBlue)
		net.Broadcast()

		if (readyRed and readyBlue and not roundInProg) then
			StartRound()
		end
	end

	if (button == KEY_F2) then
		ply:SendLua("chat.AddText(Color(255,255,255), 'Team Swapped')")

		if ply:Team() == 0 then
			ply:SetTeam(1)
		else
			ply:SetTeam(0)
		end
	end

	if (button == KEY_Q) then
		PrintTable(npcsRed)
		PrintTable(npcsBlue)
	end
end)
