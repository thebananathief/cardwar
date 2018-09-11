
/*-------------------------------------------------*\
|  Copyright © 2017 by Roach, All rights reserved.  |
\*-------------------------------------------------*/


SWEP.PrintName					= "Possessor"
SWEP.Author 					= "Roach"
SWEP.Contact					= "http://steamcommunity.com/id/hjdin"
SWEP.Purpose					= "Controlling R-Base Nextbots."
SWEP.Instructions				= "Left Click to control the Nextbot you are looking at."
SWEP.Category					= "R-Base"
if (CLIENT) then
	SWEP.Slot						= 5
	SWEP.SlotPos					= 1
end
if (SERVER) then
	SWEP.AutoSwitchTo				= false
	SWEP.AutoSwitchFrom				= false
end

SWEP.ViewModel					= "models/weapons/v_physcannon.mdl"
SWEP.WorldModel					= "models/weapons/w_physics.mdl"
SWEP.HoldType 					= "physgun"
SWEP.Spawnable					= true
SWEP.AdminSpawnable				= true

SWEP.Primary.ClipSize 				= -1
SWEP.Primary.DefaultClip			= -1
SWEP.Primary.Automatic 				= false
SWEP.Primary.Ammo 					= "none"
SWEP.Secondary.ClipSize 			= -1
SWEP.Secondary.DefaultClip			= -1
SWEP.Secondary.Automatic 			= false
SWEP.Secondary.Ammo 				= "none"

function SWEP:Initialize()self:SetWeaponHoldType(self.HoldType)end

function SWEP:PrimaryAttack()
	if CLIENT or self.Owner:IsNPC() then return end
	local tra = {}
	tra.start = self.Owner:GetShootPos()
	tra.endpos = self.Owner:GetShootPos() +self.Owner:GetAimVector()*10000
	tra.filter = self.Owner
	local tr = util.TraceLine(tra) 
	
	local v = tr.Entity
	local ply = self.Owner
	if IsValid(v) and (!v:IsNPC() and !v:IsPlayer()) then
		if !v.CanBePossessed then return end
		if string.find(v.Base, "r_base") then
				v:SetEnemy(nil)
				v.Possessor = ply
				v.IsPossessed = true
				
				local Spectator = ents.Create("prop_dynamic")
				if v:GetClass() == "nbnz_bo2_avo" then
					Spectator:SetPos((v:GetPos() + Vector(0,0,100)) + v:GetForward() * -50)
				else
					Spectator:SetPos((v:GetPos() +Vector(0,0,v:OBBMaxs().z +20)) + (Vector(0,0,-20)))
				end
				Spectator:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
				Spectator:SetParent(v)
				Spectator:SetRenderMode(RENDERMODE_TRANSALPHA)
				Spectator:Spawn()
				Spectator:SetColor(Color(0,0,0,0))
				Spectator:SetNoDraw(false)
				Spectator:DrawShadow(false)
				
				ply:Spectate(OBS_MODE_CHASE)
				ply:SpectateEntity(Spectator)
				ply:SetNoTarget(true)
				ply:DrawShadow(false)
				ply:SetNoDraw(true)
				ply:SetMoveType(MOVETYPE_OBSERVER)
				ply:DrawViewModel(false)
				ply:DrawWorldModel(false)
				ply:StripWeapons()
				if !game.SinglePlayer() then
					ply:PrintMessage(HUD_PRINTTALK, "Note: Possession has only been tested in Singleplayer. Multiplayer may be unpredictable.")
				end
		else
			ply:PrintMessage(HUD_PRINTTALK, "Sorry, you cannot possess that!")
		end
	end
	self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end