
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Pedestial"
ENT.Author = "TheBananaThief"
ENT.Instructions = "Place a card on this"
ENT.Purpose = "Place a card on this"
ENT.Category = "Cardwar"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "cwTeam")

    if SERVER then
        self:SetcwTeam(0)
    end
end