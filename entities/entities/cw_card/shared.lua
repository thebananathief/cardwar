
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Card"
ENT.Author = "TheBananaThief"
ENT.Instructions = "Read the card"
ENT.Purpose = "Read the card"
ENT.Category = "Cardwar"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "cwName")
    self:NetworkVar("Int", 0, "cwType")
    self:NetworkVar("String", 1, "cwId")
    self:NetworkVar("Int", 1, "cwHp")
    self:NetworkVar("String", 3, "cwIcon")
    self:NetworkVar("String", 2, "cwDesc")
    self:NetworkVar("Int", 2, "cwQuan")
    self:NetworkVar("Bool", 0, "cwHold")

    if SERVER then
        sCard = cards[math.random(#cards)]
        self:SetcwName(sCard.name)
        self:SetcwType(sCard.type)
        self:SetcwId(sCard.id)
        self:SetcwHp(sCard.hp)
        self:SetcwIcon(sCard.icon)
        self:SetcwDesc(sCard.desc)
        self:SetcwQuan(sCard.quan)
        self:SetcwHold(false)
    end
end