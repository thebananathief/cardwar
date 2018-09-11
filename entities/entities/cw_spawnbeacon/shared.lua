
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Spawn Beacon"
ENT.Author = "TheBananaThief"
ENT.Instructions = "Represents the spawn positions of npcs"
ENT.Purpose = "Represents the spawn positions of npcs"
ENT.Category = "Cardwar"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "cwTeam")

    if SERVER then
        self:SetcwTeam(0)
    end
end