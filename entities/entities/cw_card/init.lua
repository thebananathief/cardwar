AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel("models/props_lab/jar01a.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetUseType(3)
  self:SetCollisionGroup(11)
  self:DrawShadow(false)
  local phys = self:GetPhysicsObject()

  if (phys:IsValid()) then
    phys:Wake()
  end

  self:SetColor(Color(0, 0, 0, 0))
  self:SetMaterial("Models/effects/vol_light001")
end

function ENT:Use(activator, caller)
  local Ang = self:GetAngles()
  self:SetAngles(Angle(0, Ang.y, 0))
  local par = self:GetParent()

  if (par:IsValid()) then
    if (table.HasValue(par.storage, self)) then
      timey = true

      timer.Simple(0.5, function()
        timey = false
      end)

      table.RemoveByValue(par.storage, self)

      if par:GetClass() == "cw_shelf" then
        par:SortCards()
      end
    end

    if (table.HasValue(loadoutRed, self)) then
      table.RemoveByValue(loadoutRed, self)
    end

    if (table.HasValue(loadoutBlue, self)) then
      table.RemoveByValue(loadoutBlue, self)
    end
  end

  if caller:IsValid() then
    self:SetParent(nil)
    caller:PickupObject(self)
    self:SetcwHold(true)
    local phys = self:GetPhysicsObject()

    if (phys:IsValid()) then
      phys:EnableMotion(true)
    end
  end
end
function ENT:PhysicsCollide(data, phys)
  local ent = data.HitEntity
  self:SetcwHold(false)
  if !self:IsValid() then return end
  if !ent:IsValid() then return end

  if (ent:GetClass() == "cw_pedestial") then
    if table.HasValue(loadoutRed, self) then return end
    if table.HasValue(loadoutBlue, self) then return end

    if (ent:GetcwTeam() == 0) then
      table.insert(loadoutRed, self)
    else
      table.insert(loadoutBlue, self)
    end
    --elseif ent:GetClass() == "cw_shelf" then
  end
end
