--[[-----------------------------------------------------------------------------------------------------------*\
|							 ___________________________________________________ 							  |
|							/                                                   \							  |
|							|  Copyright © 2017 by Roach, All rights reserved.  |							  |
|							\___________________________________________________/ 							  |
|						This base assumes that you know basic lua. It will not teach						  |
|					you how to make Nextbots. With that said, most of the variables have					  |
|							comments on them to explain them a bit more in-depth.							  |
|										Have fun creating Nextbots!											  |
|																											  |
\*-----------------------------------------------------------------------------------------------------------]]
-- Don't touch.
if (SERVER) then
	AddCSLuaFile("shared.lua")
end

ENT.Type = "nextbot"
----------------------------------------------
ENT.Base = "base_nextbot" -- Change "base_nextbot" to "r_base_basic".
ENT.Spawnable = false -- Leave this at false. Nextbots need to be manually shunted over to the NPC category.

-- list.Set("NPC", "replace_this_with_the_filename_of_your_nextbot", {
-- Name = "Basic Nextbot",
-- Class = "replace_this_with_the_filename_of_your_nextbot",
-- Category = "Other"
-- })
if CLIENT then
	language.Add("replace_this_with_the_filename_of_your_nextbot", "Basic Nextbot")
end

-- Essentials --
ENT.Model = "" -- Our model.
ENT.health = 0 -- Our health.
ENT.Damage = 30 -- Our damage output.
ENT.AttackRange = 100
ENT.AttackInterval = 1
ENT.Speed = 100 -- How fast we move.
ENT.IdleNoiseInterval = math.random(5, 30) -- How often do we play idle noises?
ENT.IdleSounds = {}
-- Animations --
ENT.WalkAnim = "" -- The animation we play while walking.
ENT.RunAnim = "" -- The animation we play while running. (The bot only starts "running" when the nav-mesh specifies, if the bot can detect nav-nodes.)
ENT.JumpAnim = "" -- The animation we play before jumping. (Only works if CanJump is enabled.)
ENT.InAirAnim = "" -- The animation we play while in the air.

-- The animation we use for crouching, it's laid out in a table for simplicities sake. (Only works if CanCrouch is enabled.)
ENT.CrouchAnims = {
	CrouchIdle = "",
	CrouchWalk = ""
}

-- Footsteps --
ENT.UseFootSteps = true -- Do we play footstep sounds?
ENT.FootStepInterval = 1 -- How long to wait before playing footstep sound again.
-- Immunities --
ENT.ImmuneToCombineBalls = false -- Do we take damage from Combine Balls?
ENT.ResistantToCombineBalls = false -- Can we survive more than one Combine Ball?
ENT.CombineBallDamage = ENT.health / 2 -- How much damage do we take from Combine Balls? (Can either be a number or a calculation as shown.)
ENT.ImmuneToElectricity = false -- Do we take damage from electrical attacks?
ENT.ImmuneToFire = false -- Do we ignite/take damage from fire?
ENT.ImmuneToIce = false -- Do we freeze/take damage from ice?
ENT.CanDrown = true -- Can we drown?
ENT.BreathTime = 30 -- How long can we hold our breath for while underwater?
-- Possession --
ENT.CanBePossessed = true -- Can we be possessed by using the possessor?
ENT.IsStationary = false -- Can we move? Used for the Possessor since otherwise all movement (or lack thereof) is controlled manually.
-- Nodes --
ENT.CanDetectNavNodes = false -- Can we detect and use nav-mesh nodes to our advantage? (Experimental, requires decent navmesh!)
ENT.CanDetectRBaseNodes = false -- Can we detect and use R-Base nodes? (Requires the nodes to be placed via toolgun.)

ENT.CanJump = false -- Can we jump upon detecting the appropriate node?
ENT.JumpHeight = 58 -- How high do we jump?
ENT.CanCrouch = false -- Can we crouch upon detecting the appropriate node?
ENT.CrouchSpeed = 50 -- How fast do we move when crouch-walking?

function ENT:CustomInit()
end

--hintactivity (internal name for hint type)
function ENT:OnSpawn()
end

function ENT:CustomThink()
end

function ENT:CustomChaseEnemy(target)
end

function ENT:FootSteps()
end

function ENT:CustomIdle()
end

function ENT:CustomIdleSound()
	if #self.IdleSounds > 1 then
		self:EmitSound(self.IdleSounds[math.random(1, #self.IdleSounds)])
	elseif #self.IdleSounds == 1 then
		self:EmitSound(self.IdleSounds[1])
	end
end

function ENT:PrimaryAttack()
end

function ENT:CustomKilled(dmginfo)
end

function ENT:CustomInjured(dmginfo)
end

function ENT:CustomElementalInjured(dmgtype, attacker)
end

function ENT:CustomOnDrowning(dmginfo)
end

function ENT:CustomOnRemove()
end

function ENT:CustomRunBehaviour()
end

-- Use for gibbing or etc.
function ENT:CustomOnDissolve()
end

function ENT:CustomOnJump()
end

--Helper functions - you don't need to use them but it'll probably make your life easier.
--[[---------------------------------------------------------------------------------------
self:MovementFunctions(Sequence seq, Integer speed, Integer cycle, Integer playbackrate)
Ex: self:MovementFunctions("idle",1,0,1)
An easier method of playing a sequence, moving at a speed, and if necessary, setting the cycle and playback rate.

CreateBeamParticle(String pcf, Vector pos1, Vector pos2, Angle ang1, Angle ang2, Entity parent, Boolean candie, Integer dietime)
Ex: CreateBeamParticle("error",self:GetPos(),Vector(0,0,0),self:GetAngles(),Angle(0,0,0),self,false)
Creates a particle beam. Works in a different manner to util.ParticleTracer as (you guessed it) it doesn't use TraceData.
---------------------------------------------------------------------------------------]]

-- Everything below this line is all default stuff that comes with the base. Feel free to delete it in your NPC.
function ENT:Initialize()
	self.IsPossessed = false
	self.Interval = self.FootStepInterval
	self:CustomInit()
	self:SetCollisionBounds(Vector(-6, -6, 0), Vector(6, 6, 64))
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	self:SetHealth(self.health)
	self:SetModel(self.Model)
	self.LoseTargetDist = 5000
	self.SearchRadius = 4000

	if SERVER then
		self.loco:SetStepHeight(35)
		self.loco:SetAcceleration(900)
		self.loco:SetDeceleration(900)
		self:SetSolidMask(MASK_NPCSOLID)
	end

	self.nextbot = true
	self:CreateBullseye()
	self.NextIdle = CurTime() + self.IdleNoiseInterval
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

function ENT:HaveEnemy()
	if self:P_IsPossessed() then return false end

	if (self:GetEnemy() and IsValid(self:GetEnemy())) then
		if (self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist or 99000) then
			return self:FindEnemy()
		elseif ((self:GetEnemy():IsPlayer() and not self:GetEnemy():Alive()) or (self:GetEnemy():IsNPC() and not string.find(self:GetEnemy():GetClass(), "bullseye"))) then
			return self:FindEnemy()
		end

		return true
	else
		return self:FindEnemy()
	end
end

function ENT:FindEnemy()
	if self:P_IsPossessed() then return end
	if GetConVar("ai_disabled"):GetInt() == 1 then return end
	local _ents = ents.FindInSphere(self:GetPos(), self.SearchRadius or 10000)

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

	if self:P_IsPossessed() and (self.IsStationary or self:GetVelocity() == Vector(0, 0, 0)) then
		self.loco:FaceTowards(self:P_GetPossessor():GetPos() + self:P_GetPossessor():GetForward() * 100)
	end

	if self:GetEnemy() and IsValid(self) and IsValid(self:GetEnemy()) then
		if self:GetRangeTo(self:GetEnemy():GetPos()) > self.AttackRange then return end
		if self.NextAttack then return end
		self.NextAttack = true
		self:PrimaryAttack()
		print(self:EntIndex())
		print(self:GetEnemy())

		timer.Simple(self.AttackInterval, function()
			if not IsValid(self) then return end
			self.NextAttack = false
			self:MovementFunctions(self.WalkAnim, self.Speed)
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

	self:CreateRelationShip()
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

function ENT:RunBehaviour()
	self:SpawnIn()

	while (true) do
			self:CustomRunBehaviour()

			if (self:HaveEnemy()) then
				self:MovementFunctions(self.WalkAnim, self.Speed)
				self:ChaseEnemy()
			else
				self:CustomIdle()
				self:FindEnemy()
			end
			coroutine.wait(0.1)
	end
end

function ENT:ChaseEnemy(option)
	local options = option or {}
	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)

	if IsValid(self:GetEnemy()) then
		path:Compute(self, self:GetEnemy():GetPos())
	else
		print("Something removed the ENEMY prematurely so this overly-long message is being printed to your console so that you can be safe in the knowledge the problem was not caused by you and was in-fact caused by the idiotic developer it was probably Roach he's dumb like that LOL XD\n\n")
		SafeRemoveEntity(self)
	end

	if (not path:IsValid()) then return "failed" end

	while (path:IsValid() and self:HaveEnemy()) do
		if (path:GetAge() > 0.1) then
			if IsValid(self:GetEnemy()) then
				path:Compute(self, self:GetEnemy():GetPos())
			else
				print("Something removed the ENEMY prematurely so this overly-long message is being printed to your console so that you can be safe in the knowledge the problem was not caused by you and was in-fact caused by the idiotic developer it was probably Roach he's dumb like that LOL XD\n\n")
				SafeRemoveEntity(self)
			end
		end

		path:Update(self)

		if (options.draw) then
			path:Draw()
		end

		if (self.loco:IsStuck()) then
			self:HandleStuck()

			return "stuck"
		end

		--[[		local nav = navmesh.GetNearestNavArea(self:GetPos())
		if (IsValid(nav) and tobool(self.CanDetectNavNodes)) then
			if (nav:HasAttributes(NAV_MESH_JUMP) and tobool(self.CanJump)) then
				if !self.NextJump or CurTime() > self.NextJump then
					-- self.loco:SetDesiredSpeed(0)
					self.loco:SetJumpHeight(self.JumpHeight)
					self:PlaySequenceAndWait(self.JumpAnim)
					-- self.loco:SetDesiredSpeed(self.Speed)
					coroutine.wait(0.25)
					self.loco:Jump()
					self.NextJump = CurTime() + 10
				end
			end
		end
		]]
		if self.NextIdle < CurTime() then
			self:CustomIdleSound()
			self.NextIdle = CurTime() + self.IdleNoiseInterval
		end

		for k, v in pairs(ents.FindInSphere(self:GetPos(), 50)) do
			local dmgSped = v:GetVelocity():Length()
			if string.find(v:GetClass(), "proj_cw_computer") and dmgSped > 50 and dmgSped > self.health * 5 then
					self:TakeDamage(v:GetVelocity():Length() / 10, v:GetOwner(), v)
					print(v:GetVelocity():Length() / 10)
			end

			if (string.find(v:GetClass(), "prop_combine_ball")) then
				if not self.ImmuneToCombineBalls then
					local d = DamageInfo()
					d:SetAttacker(v:GetOwner())
					d:SetInflictor(v)

					if self.ResistantToCombineBalls then
						d:SetDamage(self.CombineBallDamage)
					else
						d:SetDamage(self:Health())
					end

					d:SetDamageType(DMG_DISSOLVE)
					self:TakeDamageInfo(d)
				end

				v:Fire("explode", "", 0.1)
			end

			if string.find(v:GetClass(), "sim_fphys") or v:IsVehicle() then
				if v:GetVelocity():Length() > 50 and string.find(self:GetClass(), "regzombie") then
					if v:GetVelocity():Length() > self.health * 5 then
						local ent = ents.Create("nzombie_death")
						ent:SetPos(self:GetPos())
						ent:SetAngles(self:GetAngles())
						ent:Spawn()
						ent.Typ = "phys"

						SafeRemoveEntity(self)
					else
						self:TakeDamage(v:GetVelocity():Length() / 10, v:GetOwner(), v)
					end
				else
					self:EmitSound("physics/metal/metal_sheet_impact_hard" .. math.random(6, 8) .. ".wav")

					if v:GetVelocity():Length() > self.health then
						self:Helper_BecomeRagdoll()
					end
				end
			end

			if not string.find(self:GetClass(), "regzombie") then
				if v:GetClass() == "obj_lstaff_lgtball" then
					ParticleEffectAttach("zomb_elec", PATTACH_POINT_FOLLOW, self, 0)
					self:EmitSound("staff/lightning/victim_shocked.mp3")

					timer.Simple(1, function()
						self:TakeDamage(self:Health())
					end)

					SafeRemoveEntity(v)
				else
					if string.find(v:GetClass(), "obj_") and string.find(v:GetClass(), "staff_") then
						v:OnCollide(nil, v:GetPhysicsObject(), true)
						self:TakeDamage(self:Health())
					end
				end
			end
		end

		self:CustomChaseEnemy(self:GetEnemy())
		coroutine.yield()
	end

	return "ok"
end

function ENT:OnRemove()
	if self:P_IsPossessed() and IsValid(self:P_GetPossessor()) then
		local spark = EffectData()
		spark:SetOrigin(self:GetPos() + Vector(0, 0, math.random(0, 20)))
		spark:SetStart(self:GetPos() + Vector(0, 0, math.random(0, 20)))

		for i = 0, math.random(30, 50) do
			util.Effect("cball_explode", spark)
		end

		self:P_GetPossessor():EmitSound("npc/assassin/ball_zap1.wav")
		self:P_GetPossessor():KillSilent()
	end

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

	if (not self:HaveEnemy() and (att:IsNPC() or att:IsPlayer())) then
		self:SetEnemy(att)
	end

	if (dmginfo:IsDamageType(DMG_BURN) and not tobool(self.ImmuneToFire)) then
		self:CustomElementalInjured(DMG_BURN, dmginfo:GetAttacker())
	else
		if (dmginfo:IsDamageType(DMG_SHOCK) and not tobool(self.ImmuneToElectricity)) then
			self:CustomElementalInjured(DMG_SHOCK, dmginfo:GetAttacker())
		end

		if (dmginfo:IsDamageType(DMG_SLOWBURN) and not tobool(self.ImmuneToIce)) then
			self:CustomElementalInjured(DMG_SLOWBURN, dmginfo:GetAttacker())
		end

		if (dmginfo:IsDamageType(DMG_DISSOLVE) and not tobool(self.ImmuneToCombineBalls)) then
			self:CustomElementalInjured(DMG_DISSOLVE, dmginfo:GetAttacker())
		end

		if (dmginfo:IsDamageType(DMG_DROWN) and not tobool(self.CanDrown)) then
			self:CustomOnDrowning(dmginfo)
		end
	end

	self:CustomInjured(dmginfo)
end

--Possession funcs
function ENT:P_MoveToPos(option, possessor, direction)
	local options = option or {}
	direction = direction or "forward"
	local pos --= possessor:GetForward() * 9999

	if direction == "left" then
		pos = possessor:GetRight() * -9999
	else
		if direction == "right" then
			pos = possessor:GetRight() * 9999
		end

		if direction == "backward" then
			pos = possessor:GetForward() * -9999
		end

		if direction == "forward" then
			pos = possessor:GetForward() * 9999
		end
	end

	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self, pos)
	if (not path:IsValid()) then return "failed" end

	while (path:IsValid()) do
		if direction == "left" then
			pos = possessor:GetRight() * -9999
		else
			if direction == "right" then
				pos = possessor:GetRight() * 9999
			end

			if direction == "backward" then
				pos = possessor:GetForward() * -9999
			end

			if direction == "forward" then
				pos = possessor:GetForward() * 9999
			end
		end

		path:Update(self)
		if (not possessor:KeyDown(IN_FORWARD) and not possessor:KeyDown(IN_MOVELEFT)) and (not possessor:KeyDown(IN_MOVERIGHT) and not possessor:KeyDown(IN_BACK)) then return "timeout" end

		if (options.draw) then
			path:Draw()
		end

		if (self.loco:IsStuck()) then
			self:HandleStuck()

			return "stuck"
		end

		if options.maxage and path:GetAge() > options.maxage then
			path:Compute(self, pos)
		end

		coroutine.yield()
	end

	return "ok"
end

function ENT:P_GenericMeleeCode(possessor, delay, sequence, SoundFile)
	delay = delay or 0
	local tra = {}
	tra.start = possessor:GetPos()
	tra.endpos = possessor:GetPos() + possessor:GetAimVector() * 500
	tra.filter = {possessor, self}
	local tr = util.TraceLine(tra)

	timer.Simple(delay, function()
		if not IsValid(self) then return end

		for k, v in pairs(ents.FindInSphere(tr.HitPos, self.Damage * 2)) do
			if v == self then continue end
			if v == possessor then continue end
			v:TakeDamage(self.Damage, self)

			if SoundFile and IsValid(v) then
				self:EmitSound(SoundFile)
			end
		end
	end)

	if sequence then
		self:PlaySequenceAndWait(sequence)
	end
end

-- NPC-Targetting funcs
function ENT:CreateBullseye(height)
	if not SERVER then return end
	local bullseye = ents.Create("npc_bullseye")
	bullseye:SetPos(self:GetPos() + Vector(0, 0, height or 50))
	bullseye:SetAngles(self:GetAngles())
	bullseye:SetParent(self)
	bullseye:SetNotSolid(true)
	bullseye:SetCollisionGroup(COLLISION_GROUP_NONE)
	bullseye:SetOwner(self)
	bullseye:Spawn()
	bullseye:Activate()
	bullseye:SetHealth(9999999)
	self.Bullseye = bullseye
end

function ENT:CreateRelationShip()
	if (self.RelationTimer or 0) < CurTime() then
		local bullseye = self.Bullseye

		if not IsValid(bullseye) then
			SafeRemoveEntity(bullseye)

			return
		end

		self.LastPos = self:GetPos()
		local _ents = ents.GetAll()
		table.Add(ents)

		for _, v in pairs(_ents) do
			if v:GetClass() != self and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_grenade_frag" and v:IsNPC() then
				v:AddEntityRelationship(bullseye, 1, 10)
			end
		end

		self.RelationTimer = CurTime() + 2
	end
end

-- Helper funcs
function ENT:P_IsPossessed()
	if self.IsPossessed then return true end

	return false
end

function ENT:P_GetPossessor()
	if IsValid(self.Possessor) then return self.Possessor end

	return nil
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

function GetCenter(v)
	return v:GetPos() + Vector(0, 0, 50)
end

function P_Possess(play, nextbot, delay)
	if play and nextbot then
		delay = delay or 0

		timer.Simple(delay, function()
			if nextbot:IsNPC() or nextbot:IsPlayer() then
				ErrorNoHalt("[R-Base Developer Error](P_Possess) attempting to possess a non-Nextbot NPC.")
			else
				local v = nextbot

				if string.find(v.Base, "r_base") then
					v:SetEnemy(nil)
					v.Possessor = ply
					v.IsPossessed = true
					local Spectator = ents.Create("prop_dynamic")

					if v:GetClass() == "nbnz_bo2_avo" then
						Spectator:SetPos((v:GetPos() + Vector(0, 0, 100)) + v:GetForward() * -50)
					else
						Spectator:SetPos((v:GetPos() + Vector(0, 0, v:OBBMaxs().z + 20)) + (Vector(0, 0, -20)))
					end

					Spectator:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
					Spectator:SetParent(v)
					Spectator:SetRenderMode(RENDERMODE_TRANSALPHA)
					Spectator:Spawn()
					Spectator:SetColor(Color(0, 0, 0, 0))
					Spectator:SetNoDraw(false)
					Spectator:DrawShadow(false)
					ply:Spectate(OBS_MODE_CHASE)
					ply:SpectateEntity(Spectator)
					ply:SetNoTarget(true)
					ply:DrawShadow(false)
					ply:SetNoDraw(true)
					ply:SetMoveType(MOVETYPE_OBSERVER)
					ply:DrawViewModel(false)
					ply:DrawWorldModel(false)
					ply:StripWeapons()
				else
					ErrorNoHalt("[R-Base Developer Error](P_Possess) attempting to possess a non-RBase nextbot.")
				end
			end
		end)
	else
		ErrorNoHalt("[R-Base Developer Error](P_Possess) function has incomplete arguments.")
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
