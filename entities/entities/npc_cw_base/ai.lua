function ENT:RunBehaviour()
	self:SpawnIn()

	while (true) do
		self:CustomRunBehaviour()
		if GetConVar("ai_disabled"):GetInt() == 1 then return end

		if (self:GetEnemy()) then
			self.Idling = false
			self:MovementFunctions(self.AnimSet.run, self.Speed)
			self:ChaseEnemy()
			coroutine.wait(0.25)
		elseif self:FindEnemy() then
			self.Idling = false
			self:MovementFunctions(self.AnimSet.run, self.Speed)
			self:ChaseEnemy()
			coroutine.wait(0.01)
		else
			self.Idling = true
			self:MovementFunctions(self.AnimSet.idle, 0)
			self:BodyMoveXY()
			coroutine.wait(0.1)
		end
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
		if self:FindEnemy() then
			self.Idling = false
			self:MovementFunctions(self.AnimSet.run, self.Speed)
			self:ChaseEnemy()
		else
			self.Idling = true
			self:MovementFunctions(self.AnimSet.idle, 0)
		end
	end

	if (not path:IsValid()) then return "failed" end

	while (path:IsValid() and self:GetEnemy()) do
		if (path:GetAge() > 0.1) then
			if IsValid(self:GetEnemy()) then
				path:Compute(self, self:GetEnemy():GetPos())
			else
				if self:FindEnemy() then
					self.Idling = false
					self:MovementFunctions(self.AnimSet.run, self.Speed)
					self:ChaseEnemy()
				else
					self.Idling = true
					self:MovementFunctions(self.AnimSet.idle, 0)
				end
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

		for k, v in pairs(ents.FindInSphere(self:GetPos(), 60)) do
			local dmgSped = v:GetVelocity():Length()
			if string.find(v:GetClass(), "proj_cw_computer") and dmgSped > 50 and dmgSped > self.Hitpoints * 5 then
					self:TakeDamage(v:GetVelocity():Length() / 10, v:GetOwner(), v)
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
