if (SERVER) then
	AddCSLuaFile()
end

----------------------------------------------
ENT.Base = "r_base_basic"
ENT.Type = "nextbot"

list.Set("NPC", "cw_crowbardude", {
	Name = "Crowbar Dude",
	Class = "cw_crowbardude",
	Category = "Cardwar"
})

if CLIENT then
	language.Add("cw_crowbardude", "Crowbar Dude")
end

-- Essentials --
ENT.Model = "models/player/magnusson.mdl"
ENT.health = 100
ENT.Damage = 10
ENT.AttackRange = 200
ENT.AttackInterval = 1
ENT.Speed = 100
-- Animations --
ENT.WalkAnim = "run_all_01"
ENT.IdleAnim = "idle_all_01"
ENT.AttackAnim = "pose_standing_03"
--[[
ENT.InAirAnim = ""
ENT.RunAnim = ""
ENT.JumpAnim = ""
ENT.CrouchAnims = {
CrouchIdle = "",
CrouchWalk = ""
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
--
ENT.CanJump = false
ENT.JumpHeight = 58
ENT.CanCrouch = false
ENT.CrouchSpeed = 50

function ENT:CustomInit()
end

function ENT:OnSpawn()
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

--  Default function, overwrite as you please.
	function ENT:CustomIdleSound()
		self:EmitSound("vo/breencast/br_instinct0" .. math.random(1, 9) .. ".wav")
	end

	function ENT:PrimaryAttack()
		self.loco:SetDesiredSpeed(0)
		
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
