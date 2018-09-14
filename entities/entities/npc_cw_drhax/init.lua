AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

list.Set("NPC", "npc_cw_drhax", {
  Name = "Doctor Hax",
  Class = "npc_cw_drhax",
  Category = "Cardwar"
})

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

function ENT:CustomIdleSound()
end

function ENT:PrimaryAttack()
  self:MovementFunctions(self.AttackAnim, 0)
  self:EmitSound(self.AttackSounds[math.random(1, #self.AttackSounds)])
  self.loco:FaceTowards(self:GetEnemy():GetPos())
  self:ThrowComp()
end

function ENT:ThrowComp()
  if !IsValid(self) then return end
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
