if (SERVER) then AddCSLuaFile() end
----------------------------------------------
ENT.Base     = "r_base_basic"									-- Leave this at false. Nextbots need to be manually shunted over to the NPC category.
ENT.Type = "nextbot"

list.Set("NPC", "cw_combinesoldier", {
	Name = "Combine Soldier",
	Class = "cw_combinesoldier",
	Category = "Cardwar"
})
if CLIENT then
	language.Add("cw_combinesoldier","Combine Soldier")
end


-- Essentials --
ENT.Models = {
    "models/Combine_Soldier.mdl", "models/Combine_Soldier_PrisonGuard.mdl"
}
ENT.Model = ENT.Models[math.random(1, #ENT.Models)]
ENT.health = 100												-- Our health.
ENT.Damage = 10												-- Our damage output.
ENT.AttackRange = 700
ENT.AttackInterval = 0.1
ENT.Speed = 75												-- How fast we move.

-- Animations --
ENT.WalkAnim = ("walk_all")
ENT.RunAnim = ("runall")											-- The animation we play while running. (The bot only starts "running" when the nav-mesh specifies, if the bot can detect nav-nodes.)
ENT.IdleAnim = ("idle1")
ENT.AttackAnim = ("melee_gunhit")
//ENT.JumpAnim = ("")											-- The animation we play before jumping. (Only works if CanJump is enabled.)
ENT.InAirAnim = ("")										-- The animation we play while in the air.
ENT.CrouchAnims = {											-- The animation we use for crouching, it's laid out in a table for simplicities sake. (Only works if CanCrouch is enabled.)
	CrouchIdle = (""),
	CrouchWalk = ("")
}

-- Footsteps --
ENT.UseFootSteps = true										-- Do we play footstep sounds?
ENT.FootStepInterval = 1 									-- How long to wait before playing footstep sound again.

-- Immunities --
ENT.ImmuneToCombineBalls = false							-- Do we take damage from Combine Balls?
ENT.ResistantToCombineBalls = false							-- Can we survive more than one Combine Ball?
ENT.CombineBallDamage = ENT.health/2						-- How much damage do we take from Combine Balls? (Can either be a number or a calculation as shown.)
ENT.ImmuneToElectricity = false 							-- Do we take damage from electrical attacks?
ENT.ImmuneToFire = false									-- Do we ignite/take damage from fire?
ENT.ImmuneToIce = false										-- Do we freeze/take damage from ice?
ENT.CanDrown = true											-- Can we drown?
ENT.BreathTime = 30											-- How long can we hold our breath for while underwater?

-- Possession --
ENT.CanBePossessed = true									-- Can we be possessed by using the possessor?
ENT.IsStationary = false									-- Can we move? Used for the Possessor since otherwise all movement (or lack thereof) is controlled manually.

-- Nodes --
ENT.CanDetectNavNodes = true								-- Can we detect and use nav-mesh nodes to our advantage? (Experimental, requires decent navmesh!)
ENT.CanDetectRBaseNodes = false								-- Can we detect and use R-Base nodes? (Requires the nodes to be placed via toolgun.)	
--
ENT.CanJump = false											-- Can we jump upon detecting the appropriate node?
ENT.JumpHeight = 58											-- How high do we jump?
ENT.CanCrouch = false										-- Can we crouch upon detecting the appropriate node?
ENT.CrouchSpeed = 50										-- How fast do we move when crouch-walking?

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
function ENT:CustomIdleSound() --  Default function, overwrite as you please.
	self:EmitSound("vo/breencast/br_instinct0"..math.random(1, 9)..".wav")
end
function ENT:PrimaryAttack()
	self.loco:SetDesiredSpeed(0)
	self:FireWeapon()
end
function ENT:CustomKilled(dmginfo)
end
function ENT:CustomInjured(dmginfo)
end
function ENT:CustomElementalInjured(dmgtype,attacker)end
function ENT:CustomOnDrowning(dmginfo)end
function ENT:CustomOnRemove()end
function ENT:CustomRunBehaviour()
end
function ENT:CustomOnDissolve() -- Use for gibbing or etc.
end
function ENT:CustomOnJump() -- What do we do when jumping?
end