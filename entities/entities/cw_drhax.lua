if (SERVER) then
  AddCSLuaFile()
end

----------------------------------------------
ENT.Base = "r_base_basic"
ENT.Type = "nextbot"

list.Set("NPC", "cw_drhax", {
  Name = "Doctor Hax",
  Class = "cw_drhax",
  Category = "Cardwar"
})

if CLIENT then
  language.Add("cw_drhax", "Doctor Hax")
end

-- Essentials --
ENT.Model = "models/player/breen.mdl"
ENT.health = 100
ENT.Damage = 10
ENT.AttackRange = 700
ENT.AttackInterval = 1
ENT.Speed = 75
-- Animations --
ENT.WalkAnim = "walk_all"
ENT.RunAnim = "run_all_01"
ENT.IdleAnim = "idle_all_01"
ENT.AttackAnim = "idle_magic"
-- Sounds --
ENT.AttackSounds = {"vo/npc/male01/hacks01.wav", "vo/npc/male01/hacks02.wav"}
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
  if CLIENT then
    local bone = self:LookupBone("ValveBiped.Bip01_Head1")
    self:ManipulateBoneScale(bone,Vector(2.5, 2.5, 2.5))
  end
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

function ENT:CustomIdleSound()
end

function ENT:PrimaryAttack()
  self:MovementFunctions(self.AttackAnim, 0)
  self:EmitSound(self.AttackSounds[math.random(1, #self.AttackSounds)])
  self:ThrowComp()
end

function ENT:ThrowComp()
  self:CheckValid()
  local ent = ents.Create("prop_physics")
  ent:SetModel("models/props_lab/monitor01a.mdl")
  ent:SetPos(self:GetPos() + Vector(0, 0, 50))
  ent:SetAngles(self:GetAngles())
  ent:Spawn()
  ent:Activate()
  local phys = ent:GetPhysicsObject()
  phys:ApplyForceCenter((self:GetEnemy():GetPos() + Vector(0,0,50) - self:GetPos()):GetNormal() + Vector(0,0,50) * 50000)
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
