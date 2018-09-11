
/*-------------------------------------------------*\
|  Copyright © 2017 by Roach, All rights reserved.  |
\*-------------------------------------------------*/
AddCSLuaFile()

SWEP.PrintName				= "Grenade SWEP Base"
SWEP.Author					= "Roach"
SWEP.Purpose				= "To serve as a base for SWEP creators."

SWEP.Slot					= 1
SWEP.SlotPos				= 1

SWEP.Spawnable				= false
SWEP.Category				= "Sample Category"

SWEP.ViewModel				= "models/weapons/c_grenade.mdl"
SWEP.WorldModel				= "models/weapons/w_grenade.mdl"
SWEP.UseHands				= true
SWEP.DrawAmmo				= true

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

-- Custom Vars --
SWEP.NadeEntity = "npc_grenade_frag"			-- The entity to create when we throw the grenade. HL2 Grenade by default.
SWEP.ThrowSound = "common/null.wav"				-- The sound that plays when we throw a grenade.
SWEP.ThrowDelay = 0.5							-- The delay before we throw (Increase if your ThrowAnimation cuts off too early.)
SWEP.PrepAnimation = (ACT_VM_DRAW)				-- The animation that our viewmodel plays when we equip the grenade.
SWEP.ThrowAnimation = (ACT_VM_PRIMARYATTACK)	-- The animation that our viewmodel plays when we throw the grenade.
-- Custom Vars --

function SWEP:OnThrow(nade,player)	-- OnThrow(entity nade, player player)

end

function SWEP:Initialize()self.Weapon:SetHoldType("grenade")end
function SWEP:Reload()return end
function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then self:Reload() return end

	self:SetNextPrimaryFire(CurTime() + 999)
	
	timer.Simple(self.ThrowDelay,function()
		local pos = self.Owner:GetShootPos() + Vector(0,0,-5)
		pos = pos + (self.Owner:GetForward() * 20)
		local ang = self.Owner:GetAngles()	
		if SERVER then
			orb1 = ents.Create(self.NadeEntity)
			orb1:SetPos(pos)
			orb1:SetAngles(ang)
			orb1:Spawn()
			
			local phys = orb1:GetPhysicsObject()
			if IsValid(phys) then
				-- phys:SetVelocity(self.Owner:GetForward() * 150)
				if SERVER then phys:ApplyForceCenter((self.Owner:EyeAngles():Forward()+Vector(0,0,.4))*50)end
			end
		end	
		self:OnThrow(orb1,self.Owner)
		self.Weapon:SendWeaponAnim(self.ThrowAnimation)
		timer.Simple(self.Owner:GetViewModel():SequenceDuration(), function()
			if SERVER then if IsValid(self.Owner) and IsValid(self.Weapon) then self.Owner:StripWeapon(self:GetClass())end end
		end)
	end)

	self:SendWeaponAnim(self.PrepAnimation)
	self.Weapon:EmitSound(self.ThrowSound)
end
function SWEP:SecondaryAttack()end
function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime() + 1)
end
function SWEP:Holster()return true end