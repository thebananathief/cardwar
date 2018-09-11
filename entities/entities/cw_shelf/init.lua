
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.AddNetworkString("sendEnt")

function ENT:Initialize()
    self:SetModel("models/props_c17/FurnitureShelf001a.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetUseType(3)
    self:DrawShadow(false)
    self:SetPos(self:GetPos() + Vector(0, 0, 34))
    self:SetSkin(math.random(0, 2))
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:EnableMotion(false) end

    self.storage = {}
    
    self:MakeAttachment("models/props_c17/FurnitureShelf001b.mdl", Vector(0, 0, 14.397), Angle(0, 0, 0))
    self:MakeAttachment("models/props_c17/FurnitureShelf001b.mdl", Vector(0, 0, -14.403), Angle(0, 0, 0))
end

function ENT:MakeAttachment(model, position, angle)
    local id = ents.Create("prop_physics")
    if !id:IsValid() then return end
	id:SetModel( model )
    id:SetCollisionGroup(11)
    id:SetSkin(math.random(0, 2))
    id:Spawn()
	id:SetPos( self:GetPos() + position )
	id:SetAngles( self:GetAngles() + angle)
    id:SetParent( self )
    id:DrawShadow(false)
    local phys = id:GetPhysicsObject()
    phys:EnableMotion(false)
end

function ENT:Use(activator, caller)
    print("storage(shelf)")
    PrintTable(self.storage)
end

function ENT:PhysicsCollide( data )
    local ent = data.HitEntity
    local phy = ent:GetPhysicsObject()

    if (ent:IsValid() and !timey) then
        if (ent:GetClass() == "cw_card" and (#self.storage) < 9 and !table.HasValue(self.storage, ent)) then
            table.insert(self.storage, ent)
            DropEntityIfHeld(ent)
            ent:SetParent(self)
            self:SortCards()
            local phys = ent:GetPhysicsObject()
            if (phys:IsValid()) then phys:EnableMotion(true) end
        end
    end
end

function ENT:SortCards()
    if self.storage[1] then self.storage[1]:SetLocalPos(Vector(0, -12, 30)) end
    if self.storage[2] then self.storage[2]:SetLocalPos(Vector(0, 0, 30)) end
    if self.storage[3] then self.storage[3]:SetLocalPos(Vector(0, 12, 30)) end
    if self.storage[4] then self.storage[4]:SetLocalPos(Vector(0, -12, 0)) end
    if self.storage[5] then self.storage[5]:SetLocalPos(Vector(0, 0, 0)) end
    if self.storage[6] then self.storage[6]:SetLocalPos(Vector(0, 12, 0)) end
    if self.storage[7] then self.storage[7]:SetLocalPos(Vector(0, -12, -30)) end
    if self.storage[8] then self.storage[8]:SetLocalPos(Vector(0, 0, -30)) end
    if self.storage[9] then self.storage[9]:SetLocalPos(Vector(0, 12, -30)) end
end