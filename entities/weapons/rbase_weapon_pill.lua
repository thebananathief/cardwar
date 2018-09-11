
if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.ViewModelFOV		= 70
	SWEP.ViewModelFlip		= false
	SWEP.PrintName = "R-Base Pill Base"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.BounceWeaponIcon     = false
	SWEP.DrawWeaponInfoBox = false
end

SWEP.HoldType = "normal"

SWEP.Author = "Roach" -- The ACTUAL creator :P
SWEP.Category = "R-Base"

SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = ""
SWEP.UseHands = false
SWEP.DrawCrosshair = false
SWEP.Spawnable = false

-- Custom Variables --
	FootstepSound = {"common/null.wav","common/null.wav"}
	
	SWEP.PillModel = ""
	SWEP.PillWalkSpeed = 100
	SWEP.PillRunSpeed = 300
	SWEP.PillJumpHeight = 0
	SWEP.PillHealth = 100
	SWEP.PillCamera = {}
	SWEP.PillCamera.Up = 12
	SWEP.PillCamera.Zoom = 128
	SWEP.PillCamera.Right = 128
	
	
	
	

	
	SWEP.ACTTranslate = { }
	SWEP.ACTTranslate[ACT_MP_STAND_IDLE] 					= ACT_IDLE;
	SWEP.ACTTranslate[ACT_MP_WALK] 						    = ACT_WALK_RIFLE;
	SWEP.ACTTranslate[ACT_MP_RUN] 						    = ACT_RUN_RIFLE;
	SWEP.ACTTranslate[ACT_MP_CROUCH_IDLE] 				    = ACT_CROUCHIDLE;
	SWEP.ACTTranslate[ACT_MP_CROUCHWALK] 					= ACT_WALK_CROUCH_RIFLE;
	SWEP.ACTTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] 	    = ACT_MELEE_ATTACK_SWING;
	SWEP.ACTTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE]	    = ACT_MELEE_ATTACK_SWING;
	SWEP.ACTTranslate[ACT_MP_RELOAD_STAND]		 		    = ACT_COMBINE_THROW_GRENADE;
	SWEP.ACTTranslate[ACT_MP_RELOAD_CROUCH]		 		    = ACT_SPECIAL_ATTACK1;
	SWEP.ACTTranslate[ACT_MP_JUMP] 						    = ACT_JUMP;
	SWEP.ACTTranslate[ACT_MP_SWIM_IDLE] 					= ACT_JUMP;
	SWEP.ACTTranslate[ACT_MP_SWIM] 						    = ACT_JUMP;
	
-- End Custom Vars --
-- Custom Functions --
	function SWEP:CustomPrimaryAttack()
	
	end
	
	function SWEP:CustomReload()
	
	end
	
	function SWEP:CustomSecondaryAttack()
	
	end
	
	function SWEP:CustomDeath()
	
	end
-- End Custom Functions --
function SWEP:GetViewModelPosition(pos, ang)
	return pos, ang
end

function SWEP:SecondaryAttack()self:CustomSecondaryAttack()end
function SWEP:PrimaryAttack()self:CustomPrimaryAttack()end

hook.Add("ShouldDrawLocalPlayer", "DrawLocalPlayerRBasePill", function()
	if (!IsValid(LocalPlayer())) then return false end
	if (!LocalPlayer():Alive()) then return false end
	if (LocalPlayer():InVehicle()) then return false end
	if (LocalPlayer():GetViewEntity() != LocalPlayer()) then return false end
	if !IsValid(LocalPlayer()) or !IsValid(LocalPlayer():GetActiveWeapon()) then return end
	local cls = LocalPlayer():GetActiveWeapon():GetClass()
	local TableOfFuckingGlitchyHL2SwepsM8 = {
		"weapon_crowbar",
		"weapon_pistol",
		"weapon_357",
		"weapon_smg1",
		"weapon_ar2",
		"weapon_shotgun",
		"weapon_crossbow",
		"weapon_rpg",
		"weapon_frag",
		"weapon_physgun",
		"weapon_camera",
		"gmod_tool",
		"weapon_physcannon",
		"weapon_bugbait",
		"weapon_slam",
		"weapon_stunstick"
	}
	if table.HasValue(TableOfFuckingGlitchyHL2SwepsM8,cls) then return false end
	if !LocalPlayer():GetActiveWeapon().Base then return false end
	if string.find(LocalPlayer():GetActiveWeapon().Base, "rbase_weapon_pill") then 
		return true 
	else 
		return false 
	end
end)

function SWEP:CalcView(ply, pos, angle, fov)
	if (!ply:IsValid() or !ply:Alive() or ply:InVehicle() or ply:GetViewEntity() != ply) then return end
	
	local trace = util.TraceLine({
		start = pos,
		endpos = pos - ((angle:Forward() * self.PillCamera.Zoom) + (angle:Up()*self.PillCamera.Up*2)) + (angle:Right()*self.PillCamera.Right),
		filter = { ply:GetActiveWeapon(), ply }
	})

	if (trace.Hit) then
		pos = trace.HitPos - angle:Up()*self.PillCamera.Up + angle:Right()*self.PillCamera.Right
	elseif !self.Owner:Crouching() then
		pos = pos - angle:Forward() * self.PillCamera.Zoom + angle:Up()*self.PillCamera.Up+ angle:Right()*self.PillCamera.Right
	elseif self.Owner:Crouching() then
		pos = pos - angle:Forward() * self.PillCamera.Zoom + angle:Up()*self.PillCamera.Up+ angle:Right()*self.PillCamera.Right
	end

	return pos, angle, fov
end

function SWEP:TranslateActivity(act)
	if (self.ACTTranslate[act] != nil) then
		return self.ACTTranslate[act]
	end
	return -1
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
	self:CustomReload()
end

function SWEP:Think()
end

function SWEP:OnRemove()
	self:Holster()
	return true
end

function SWEP:Deploy()
	if CLIENT then return end
	
	self.NextReload = CurTime()
	
	self.PlyModel = self.Owner:GetModel()
	self.Skin = self.Owner:GetSkin()
	self.WalkSpeed = self.Owner:GetWalkSpeed()
	self.RunSpeed = self.Owner:GetRunSpeed()
	self.BGroups = {}
	self.CrouchSpeed = self.Owner:GetCrouchedWalkSpeed()
	self.JumpHeight = self.Owner:GetJumpPower()
	local BGroups = self.Owner:GetBodyGroups()
	for num,data in pairs(BGroups) do
		self.BGroups[data.id] = self.Owner:GetBodygroup(data.id)
	end
	self.Owner:SetWalkSpeed(self.PillWalkSpeed)
	self.Owner:SetRunSpeed(self.PillRunSpeed)
	self.Owner:SetCanWalk(false)
	self.Owner:SetSkin(0)
	self.Owner:SetCrouchedWalkSpeed(0.6)
	self.Owner:SetModel(self.PillModel)
	self.Owner:SetBodygroup(0, 0)
	self.Owner:SetJumpPower(self.PillJumpHeight)
	self.Owner:SetMaxHealth(self.PillHealth)
	self.Owner:SetHealth(self.PillHealth)
	return true
end

function SWEP:Holster()
	if self.Owner == NULL or !IsValid(self.Owner) then return true end
	
	if self.Owner:Health() <= 0 then
		self:CustomDeath()
	end
	
	if self.PlyModel and self.PlyModel != "" then
		self.Owner:SetModel(self.PlyModel)
		self.PlyModel = nil
	end
	if self.BGroups then
		for num,data in pairs(self.BGroups) do
			self.Owner:SetBodygroup(num, data)
		end
		self.BGroups = nil
	end
	if self.WalkSpeed then self.Owner:SetWalkSpeed(self.WalkSpeed) end
	if self.RunSpeed then self.Owner:SetRunSpeed(self.RunSpeed) end
	if self.CrouchSpeed then self.Owner:SetCrouchedWalkSpeed(self.CrouchSpeed) end
	if self.JumpHeight then self.Owner:SetJumpPower(self.JumpHeight) end
	
	self.Owner:SetHealth(100)
	if SERVER then self.Owner:SetMaxHealth(100)end
	
	self.Owner:SetCanWalk(true)
	
	return true
end

function SWEP:DrawHUD()
	local pos = self.Owner:GetEyeTrace().HitPos:ToScreen()
	local movement = LocalPlayer():GetVelocity():Length()/10
	if movement > 80 then movement = 80 end
	
	draw.RoundedBox(0, pos.x - 26-movement, pos.y - 2, 15 , 3, Color(0,0,0,200))
	draw.RoundedBox(0, pos.x + 10+movement, pos.y - 2, 15 , 3, Color(0,0,0,200))
	draw.RoundedBox(0, pos.x - 2, pos.y - 26-movement, 3 , 15, Color(0,0,0,200))
	draw.RoundedBox(0, pos.x - 2, pos.y + 10+movement, 3 , 15, Color(0,0,0,200))
	
	draw.RoundedBox(0, pos.x - 25-movement, pos.y - 1, 15 , 1, Color(255,255,255,255))
	draw.RoundedBox(0, pos.x + 9+movement, pos.y - 1, 15 , 1, Color(255,255,255,255))
	draw.RoundedBox(0, pos.x - 1, pos.y - 25-movement, 1 , 15, Color(255,255,255,255))
	draw.RoundedBox(0, pos.x - 1, pos.y + 9+movement, 1 , 15, Color(255,255,255,255))
end

hook.Add("PlayerFootstep","RoachIsStillThyBae",function(ply,pos,foot,sound,volume,rf)
	if (IsValid(ply:GetActiveWeapon()) and string.find(ply:GetActiveWeapon():GetClass(), "weapon_roach_")) then
		ply:EmitSound(FootstepSound[math.random(1,#FootstepSound)])
		return true
	end
	return false
end)

function SWEP:GenericMeleeCode(dmg,delay, SoundFile)
	delay = delay or 0
	
	local tr = self.Owner:GetEyeTrace()
	
	timer.Simple(delay, function()
		if !IsValid(self) or !IsValid(self.Owner) or !self.Owner:Alive() then return end
		for k,v in pairs(ents.FindInSphere(tr.HitPos, dmg * 2)) do
			if v == self.Owner then continue end
			
			v:TakeDamage(dmg, self.Owner,self)
			if SoundFile and IsValid(v) then v:EmitSound(SoundFile) end
		end
	end)
end