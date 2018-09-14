AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("ai.lua")

-- list.Set("NPC", "replace_this_with_the_filename_of_your_nextbot", {
-- Name = "Basic Nextbot",
-- Class = "replace_this_with_the_filename_of_your_nextbot",
-- Category = "Other"
-- })

function ENT:Initialize()
	--	Config stuff
	self:Configure()
	self:LoadAnimations()
	self:LoadSoundPack()
	self.nextbot = true
	self.Idling = true

	--	Essential ent stuff
	self:SetModel(self.Model)
	self:SetHealth(self.Hitpoints)
	self:SetMaxHealth(self.Hitpoints)
	self:AddFlags(FL_CLIENT) --This lets us pop triggers as a player
	self:AddFlags(FL_OBJECT) --This allows Default AI to see us

	-- 	Animation stuff
	self:MovementFunctions(self.AnimSet.idle, 0)
	self:SetCollisionBounds(Vector(-20, -20, 0), Vector(20, 20, 64))
	self.loco:SetAcceleration(900)
	self.loco:SetDeceleration(900)
	self.loco:SetStepHeight(35)


	/*
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	self:SetSolidMask(MASK_NPCSOLID)
	self:SetSolidMask(MASK_NPCSOLID)*/
end

function ENT:InitTeam(team)
	self.Team = team
end

function ENT:BodyUpdate()
	self:BodyMoveXY()
end
function ENT:GetEnemy()
	return self.Enemy
end

function ENT:SetEnemy(ent)
	self.Enemy = ent
end
/*
function ENT:HaveEnemy()
	if IsValid(self:GetEnemy()) then
		if (self:GetRangeTo(self:GetEnemy():GetPos()) > self.SightRange or 25000) then
			return self:FindEnemy()
		elseif ((self:GetEnemy():IsPlayer() and not self:GetEnemy():Alive()) or (self:GetEnemy():IsNPC())) then
			return self:FindEnemy()
		end

		return true
	else
		return self:FindEnemy()
	end
end*/

function ENT:FindEnemy()
	if GetConVar("ai_disabled"):GetInt() == 1 then return end
	local _ents = ents.FindInSphere(self:GetPos(), self.SightRange or 25000)

	for k, v in pairs(_ents) do
		if (type(v) == "NextBot") and IsValid(v) and v:EntIndex() != self:EntIndex() then
			if self.Team == v.Team then return end
			self:SetEnemy(v)

			return true
		end
	end

	self:SetEnemy(nil)

	return false
end

ENT.NextAttack = false

function ENT:Think()
	if not SERVER then return end

	if IsValid(self) and IsValid(self:GetEnemy()) then
		self.loco:FaceTowards(self:GetEnemy():GetPos())
	end

	if IsValid(self) and IsValid(self:GetEnemy()) then
		if self:GetRangeTo(self:GetEnemy():GetPos()) > self.AttackRange then return end
		if self.NextAttack then return end
		self.NextAttack = true
		self:PrimaryAttack()

		timer.Simple(self.AttackInterval, function()
			if not IsValid(self) then return end
			if not IsValid(self:GetEnemy()) then return end
			self.NextAttack = false

			if self:GetRangeTo(self:GetEnemy():GetPos()) > self.AttackRange then
				self:MovementFunctions(self.AnimSet.run, self.Speed)
			end
		end)
	end

	self:CustomThink()

	if tobool(self.UseFootSteps) then
		if not self.nxtThink then
			self.nxtThink = 0
		end

		if CurTime() < self.nxtThink then return end
		self.nxtThink = CurTime() + 0.025
		self:DoFootstep()
	end

	if tobool(self.CanDrown) and self:WaterLevel() >= 3 then
		timer.Simple(self.BreathTime, function()
			if not IsValid(self) then return end
			if self:WaterLevel() <= 2 then return end
			local d = DamageInfo()
			d:SetAttacker(self)
			d:SetDamage(1)
			d:SetDamageType(DMG_DROWN)
			self:TakeDamageInfo(d)
		end)
	end
end
function ENT:DoFootstep()
	if CurTime() < self.Interval then return end
	if self:GetVelocity() == Vector(0, 0, 0) or self.loco:GetGroundMotionVector() == 0 then return end
	self:FootSteps()
	self.Interval = CurTime() + self.FootStepInterval
end

function ENT:SpawnIn()
	if not SERVER then return end
	local nav = navmesh.GetNearestNavArea(self:GetPos())

	if not self:IsInWorld() or not IsValid(nav) or nav:GetClosestPointOnArea(self:GetPos()):DistToSqr(self:GetPos()) >= 10000 then
		-- ErrorNoHalt("Nextbot ["..self:GetClass().."]["..self:EntIndex().."] spawned too far away from a navmesh!")
		for k, v in pairs(player.GetAll()) do
			if (string.find(v:GetUserGroup(), "admin")) then
				v:PrintMessage(HUD_PRINTTALK, "Nextbot [" .. self:GetClass() .. "][" .. self:EntIndex() .. "] spawned too far away from a navmesh!")
			end
		end

		SafeRemoveEntity(self)
	end

	self:OnSpawn()
end

function ENT:OnRemove()
	self:CustomOnRemove()
end

function ENT:OnKilled(dmginfo)
	if dmginfo:IsDamageType(DMG_DISSOLVE) then
		self:HandleDissolving(dmginfo)
	else
		self:Helper_BecomeRagdoll(dmginfo, 10)
		self:CustomKilled(dmginfo)
	end

	-- Hopefully should fix conflictions against SLVBase. HOPEFULLY.
	if not file.Exists("autorun/slvbase", "LUA") then
		if file.Exists("autorun/bgo_autorun_sh", "LUA") then return end -- BGO has a bone to pick with R-Base too it seems.
		hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor())
	end
end

function ENT:HandleDissolving(dmginfo)
	self:CustomOnDissolve()

	for i = 1, math.random(2, 10) do
		ParticleEffectAttach("rbase_dissolve", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	end

	SafeRemoveEntityDelayed(self, 0.2)
end

function ENT:OnInjured(dmginfo)
	local att = dmginfo:GetAttacker()

	if (not self:GetEnemy() and (att:IsNPC() or att:IsPlayer())) then
		self:SetEnemy(att)
	end

	self:CustomInjured(dmginfo)
end

function ENT:MovementFunctions(seq, speed, cycle, playbackrate)
	speed = speed or 0
	cycle = cycle or 0
	playbackrate = playbackrate or 1

	if cycle > 1 then
		ErrorNoHalt("Nextbot MovementFunctions error: cycle must be less than 1.")
		cycle = 0
	end

	if self:GetSequence() != seq then
		self:ResetSequence(seq)
		self:SetCycle(cycle)
		self:SetPlaybackRate(playbackrate)
		self.loco:SetDesiredSpeed(speed)
	end
end

function CreateBeamParticle(pcf, pos1, pos2, ang1, ang2, parent, candie, dietime)
	if SERVER then
		local P_End = ents.Create("info_particle_system")
		P_End:SetKeyValue("effect_name", pcf)
		P_End:SetName("info_particle_system_MajikPoint_" .. pcf)
		P_End:SetPos(pos2)
		P_End:SetAngles(ang2 or Angle(0, 0, 0))
		P_End:Spawn()
		P_End:Activate()
		P_End:SetParent(parent or nil)
		local P_Start = ents.Create("info_particle_system")
		P_Start:SetKeyValue("effect_name", pcf)
		P_Start:SetKeyValue("cpoint1", P_End:GetName())
		P_Start:SetKeyValue("start_active", tostring(1))
		P_Start:SetPos(pos1)
		P_Start:SetAngles(ang1 or Angle(0, 0, 0))
		P_Start:Spawn()
		P_Start:Activate()
		P_Start:SetParent(parent or nil)

		if candie then
			P_End:Fire("Kill", nil, dietime)
			P_Start:Fire("Kill", nil, dietime)
		end
	end
end

function ENT:GiveWeapon(class)
	local wep = ents.Create(class)
	local pos = self:GetAttachment(self:LookupAttachment("anim_attachment_RH")).Pos -- location of the hand attachment
	wep:SetOwner(self) -- sets the owner to self
	wep:SetPos(pos) --sets the position of the gun to "pos"
	wep:Spawn() -- spawns the weapon
	wep:SetSolid(SOLID_NONE) --collision stuff
	wep:SetParent(self) -- sets the weapon's parent to self
	wep:Fire("setparentattachment", "anim_attachment_RH") -- binds the weapon to the attachment of its parent
	wep:AddEffects(EF_BONEMERGE) -- merges the weapon with the model's bones to make it look like he's actually holding it
	self.Weapon = wep
end

hook.Add("PlayerCanPickupWeapon", "No_Pickup_NPC_Weapons", function(x, wep)
	if type(wep:GetOwner()) == "NextBot" then return false end
end)

function ENT:FireWeapon()
	local bullet = {}
	bullet.Num = 1
	bullet.Src = self:GetPos()
	bullet.Dir = self:GetForward()
	bullet.Spread = Vector(0.1, 0.1, 0)
	bullet.Tracer = 1
	bullet.TracerName = "Tracer"
	bullet.Force = 500
	bullet.Damage = self.Damage
	bullet.AmmoType = "none"
	self:FireBullets(bullet)
end

function ENT:Melee_Attack(victim, delay, damage)
	local v = victim
	if not IsValid(v) then return end

	timer.Simple(delay, function()
		if not IsValid(v) then return end
		v:TakeDamage(damage, self)
	end)
end

function ENT:Helper_BecomeRagdoll(dmginfo, time)
	time = time or 30

	if SERVER then
		if not util.IsValidRagdoll(self:GetModel()) then
			self:OnKilled(dmginfo)
		else
			local ent = ents.Create("prop_ragdoll")
			ent:SetPos(self:GetPos())
			ent:SetAngles(self:GetAngles())
			ent:SetModel(self.Model)
			ent:Spawn()
			ent:Activate()
			ent:SetColor(self:GetColor())
			ent:SetMaterial(self:GetMaterial())
			ent:DrawShadow(false)
			ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			ent:Fire("FadeAndRemove", "", time)
			local dmgforce = dmginfo:GetDamageForce()

			-- 128 = Bone Limit
			for bonelim = 1, 128 do
				local childphys = ent:GetPhysicsObjectNum(bonelim)

				if IsValid(childphys) then
					local childphys_bonepos, childphys_boneang = self:GetBonePosition(ent:TranslatePhysBoneToBone(bonelim))

					if (childphys_bonepos) then
						childphys:SetPos(childphys_bonepos)
						childphys:SetAngles(childphys_boneang)
						childphys:SetVelocity(dmgforce / 40)
					end
				end
			end

			SafeRemoveEntity(self)

			return ent
		end
	end
end
