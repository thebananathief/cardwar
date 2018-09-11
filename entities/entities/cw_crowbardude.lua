if (SERVER) then AddCSLuaFile() end
----------------------------------------------
ENT.Base     = "r_base_basic"									-- Leave this at false. Nextbots need to be manually shunted over to the NPC category.
ENT.Type = "nextbot"

list.Set("NPC", "cw_crowbardude", {
	Name = "Crowbar Dude",
	Class = "cw_crowbardude",
	Category = "Cardwar"
})
if CLIENT then
	language.Add("cw_crowbardude","Crowbar Dude")
end


-- Essentials --
ENT.Model = ("models/player/magnusson.mdl")
ENT.health = 100												-- Our health.
ENT.Damage = 10												-- Our damage output.
ENT.AttackRange = 200
ENT.AttackInterval = 1
ENT.Speed = 100												-- How fast we move.

-- Animations --
ENT.WalkAnim = ("run_all_01")
//ENT.RunAnim = ("")											-- The animation we play while running. (The bot only starts "running" when the nav-mesh specifies, if the bot can detect nav-nodes.)
ENT.IdleAnim = ("idle_all_01")
ENT.AttackAnim = ("pose_standing_03")
//ENT.JumpAnim = ("")											-- The animation we play before jumping. (Only works if CanJump is enabled.)
ENT.InAirAnim = ("run_all_01")										-- The animation we play while in the air.
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
end
function ENT:CustomThink()
end
function ENT:CustomChaseEnemy(target)
end
function ENT:FootSteps()
end
function ENT:CustomIdle()
	print("wow")
	self:MovementFunctions(self.IdleAnim, 0)
end
function ENT:CustomIdleSound() --  Default function, overwrite as you please.
	self:EmitSound("vo/breencast/br_instinct0"..math.random(1, 9)..".wav")
end
function ENT:PrimaryAttack()
	self.loco:SetDesiredSpeed(0)
	self:attackMelee(self:GetEnemy(),1,self.AttackAnim,true,self.Damage,"weapons/iceaxe/iceaxe_swing1.wav")
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