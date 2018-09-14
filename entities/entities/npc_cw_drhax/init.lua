AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Configure()
	self.Model = "models/player/breen.mdl"
	--	AI stuff
	self.Hitpoints = 200
	self.Damage = 0
	self.AttackRange = 500
	self.AttackInterval = 3
	self.SightRange = 25000
	self.Speed = 100
	--	Weapon stuff
	--self.PrimaryWeapon		= "weapon_demo_nadelauncher"
end

function ENT:LoadAnimations()
	self.AnimSet = {
		idle = "idle_all_01",
		attack = "idle_magic",
		run = "run_all_01"
	}
end

function ENT:LoadSoundPack()
	self.soundpack = {
		attack = {"vo/npc/male01/hacks01.wav", "vo/npc/male01/hacks02.wav"}
	}
end

function ENT:CustomInit()
end

function ENT:OnSpawn()
end

function ENT:CustomThink()
end

function ENT:CustomChaseEnemy(target)
end

function ENT:CustomIdleSound()
end

function ENT:PrimaryAttack()
	self:MovementFunctions(self.AnimSet.attack, 0)
	self:EmitSound(self.soundpack.attack[math.random(1, #self.soundpack.attack)])
	self:ThrowComp()
end

function ENT:ThrowComp()
	if not IsValid(self) then return end
	local ent = ents.Create("proj_cw_computer")
	ent:SetPos(self:LocalToWorld(Vector(70, 0, 60)))
	ent:SetAngles(self:GetEnemy():GetAngles() - Angle(0, 180, 0))
	ent:Spawn()
	ent:Activate()
end

function ENT:CustomKilled(dmginfo)
end

function ENT:CustomInjured(dmginfo)
end

function ENT:CustomElementalInjured(dmgtype, attacker)
end

function ENT:CustomOnDrowning(dmginfo)
end

function ENT:CustomOnRemove()
end

function ENT:CustomRunBehaviour()
end

function ENT:CustomOnDissolve()
end

function ENT:CustomOnJump()
end
