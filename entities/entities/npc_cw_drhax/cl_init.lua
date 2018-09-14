include("shared.lua")

language.Add("npc_cw_drhax", "Doctor Hax")

function ENT:Draw()
  self:DrawModel()
end

function ENT:Initialize()
  local bone = self:LookupBone("ValveBiped.Bip01_Head1")
  self:ManipulateBoneScale(bone, Vector(2.5, 2.5, 2.5))
end
