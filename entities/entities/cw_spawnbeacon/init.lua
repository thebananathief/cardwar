AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:DrawShadow(false)
	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end
function ENT:InitTeam(team)
	self.Team = team
end
function ENT:SpawnTeam()
	function spawnEnt(class)
		local offset = Vector(math.random(-200, 200), math.random(-200, 200), 100)
		local retries = 100

		local tr = util.TraceLine({
			start = self:GetPos() + offset,
			endpos = self:GetPos() + offset + Vector(0, 0, -10000),
			mask = MASK_SOLID,
			filter = self
		})

		while ((not tr.HitWorld) and (retries > 0)) do
			retries = retries - 1
			offset = Vector(math.random(-200, 200), math.random(-200, 200), 100)

			tr = util.TraceLine({
				start = self:GetPos() + offset,
				endpos = self:GetPos() + offset + Vector(0, 0, -10000),
				mask = MASK_SOLID,
				filter = self
			})
		end

		local ent = ents.Create(class)
		ent:SetPos(tr.HitPos + Vector(0, 0, 16))
		ent:SetAngles(self:GetAngles())

		if (self.Team == 0) then
			ent.Team = 0
			table.insert(npcsRed, ent)
		else
			ent.Team = 1
			table.insert(npcsBlue, ent)
		end

		ent:Spawn()
		ent:Activate()
	end

	if self.Team == 0 then
		for k, v in pairs(loadoutRed) do
			if v:GetcwQuan() > 1 then
				for i = 1, v:GetcwQuan() do
					spawnEnt(loadoutRed[k]:GetcwClass(), k)
				end
			else
				spawnEnt(loadoutRed[k]:GetcwClass(), k)
			end
		end
	else
		for k, v in pairs(loadoutBlue) do
			if v:GetcwQuan() > 1 then
				for i = 1, v:GetcwQuan() do
					spawnEnt(loadoutBlue[k]:GetcwClass(), k)
				end
			else
				spawnEnt(loadoutBlue[k]:GetcwClass(), k)
			end
		end
	end
end
