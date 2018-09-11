
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
    self:SetModel("models/props_c17/oildrum001.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetUseType(3)
    self:DrawShadow(false)
    self:SetPos(self:GetPos() + Vector(0, 0, -20))
    self:SetSkin(math.random(0, 5))
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:EnableMotion(false) end

    self.storage = {}

    self:MakeAttachment("models/props_c17/lampShade001a.mdl", Vector(0, 0, 49.197), Angle(0, 0, 0))
    self:MakeAttachment("models/props_wasteland/light_spotlight02_lamp.mdl", Vector(0, 0, 45.325), Angle(-90, 0, 180))
end

function ENT:MakeAttachment(model, position, angle)
    local id = ents.Create("prop_physics")
    if !id:IsValid() then return end
	id:SetModel( model )
    id:SetCollisionGroup(11)
    id:Spawn()
	id:SetPos( self:GetPos() + position )
	id:SetAngles( self:GetAngles() + angle)
    id:SetParent( self )
    id:DrawShadow(false)
    local phys = id:GetPhysicsObject()
    phys:EnableMotion(false)
    
    if (model=="models/props_c17/lampShade001a.mdl") then
        if self:GetcwTeam()==0 then id:SetColor(Color(255, 20, 20, 255)) end
        if self:GetcwTeam()==1 then id:SetColor(Color(20, 20, 255, 255)) end
    end
end

function ENT:Use(activator, caller)
    print("storage(pedestial)")
    PrintTable(self.storage)
end

function ENT:PhysicsCollide( data )
    local ent = data.HitEntity
    local phy = ent:GetPhysicsObject()
    
    if (ent:IsValid() and !timey) then
        if (ent:GetClass() == "cw_card" and #self.storage < 1 and !table.HasValue(self.storage, ent)) then
            table.insert(self.storage, ent)
            DropEntityIfHeld(ent)
            ent:SetParent(self)
            ent:SetLocalPos(Vector(0, 0, 70))
        end
    end
end