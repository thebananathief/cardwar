AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel("models/props_lab/monitor01a.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:DrawShadow(false)
  local phys = self:GetPhysicsObject()

  if phys:IsValid() then
    phys:Wake()
  end

  local velocity = self:GetForward()
  velocity = velocity * 100000
  velocity = velocity + ( VectorRand() * 10 )
  phys:ApplyForceCenter( velocity )

  SafeRemoveEntityDelayed(self,3)
end
