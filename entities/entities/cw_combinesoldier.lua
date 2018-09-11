if (SERVER) then
	AddCSLuaFile()
end

----------------------------------------------
ENT.Base = "r_base_basic"
ENT.Type = "nextbot"

list.Set("NPC", "cw_combinesoldier", {
	Name = "Combine Soldier",
	Class = "cw_combinesoldier",
	Category = "Cardwar"
})

if CLIENT then
	language.Add("cw_combinesoldier", "Combine Soldier")
end

-- Essentials --
ENT.Models = {"models/Combine_Soldier.mdl", "models/Combine_Soldier_PrisonGuard.mdl"}
ENT.Model = ENT.Models[math.random(1, #ENT.Models)]
ENT.health = 100
ENT.Damage = 10
ENT.AttackRange = 700
ENT.AttackInterval = 0.1
ENT.Speed = 75
-- Animations --
ENT.WalkAnim = "walk_all"
ENT.RunAnim = "runall"
ENT.IdleAnim = "idle1"
ENT.AttackAnim = "melee_gunhit"
--[[
ENT.JumpAnim = ""
ENT.InAirAnim = ""
ENT.CrouchAnims = {
CrouchIdle = (""),
CrouchWalk = ("")
}]]
-- Footsteps --
ENT.UseFootSteps = true
ENT.FootStepInterval = 1
-- Immunities --
ENT.ImmuneToCombineBalls = false
ENT.ResistantToCombineBalls = false
ENT.CombineBallDamage = ENT.health / 2
ENT.ImmuneToElectricity = false
ENT.ImmuneToFire = false
ENT.ImmuneToIce = false
ENT.CanDrown = true
ENT.BreathTime = 30
-- Possession --
ENT.CanBePossessed = true
ENT.IsStationary = false
-- Nodes --
ENT.CanDetectNavNodes = true -- Can we detect and use nav-mesh nodes to our advantage? (Experimental, requires decent navmesh!)
ENT.CanDetectRBaseNodes = false -- Can we detect and use R-Base nodes? (Requires the nodes to be placed via toolgun.)

ENT.CanJump = false
ENT.JumpHeight = 58
ENT.CanCrouch = false
ENT.CrouchSpeed = 50

function ENT:CustomInit()
end

function ENT:OnSpawn()
	self:GiveWeapon("weapon_smg1")
end

function ENT:CustomThink()
end

function ENT:CustomChaseEnemy(target)
end

function ENT:FootSteps()
end

function ENT:CustomIdle()
	self:MovementFunctions(self.IdleAnim, 0)
end

function ENT:CustomIdleSound()
	self:EmitSound("vo/breencast/br_instinct0" .. math.random(1, 9) .. ".wav")
end

function ENT:PrimaryAttack()
	self.loco:SetDesiredSpeed(0)
	self:FireWeapon()
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
