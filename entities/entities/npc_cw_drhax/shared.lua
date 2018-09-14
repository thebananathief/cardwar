
ENT.Base = "npc_cw_base"
ENT.Type = "nextbot"

-- Essentials --
ENT.Model = "models/player/breen.mdl"
ENT.health = 200
ENT.Damage = 0
ENT.AttackRange = 500
ENT.AttackInterval = 3
ENT.Speed = 75
-- Animations --
ENT.WalkAnim = "walk_all"
ENT.RunAnim = "run_all_01"
ENT.IdleAnim = "idle_all_01"
ENT.AttackAnim = "idle_magic"
-- Sounds --
ENT.AttackSounds = {"vo/npc/male01/hacks01.wav", "vo/npc/male01/hacks02.wav"}
--[[
ENT.JumpAnim = ""
ENT.InAirAnim = ""
ENT.CrouchAnims = {
CrouchIdle = (""),
CrouchWalk = ("")
}]]
-- Footsteps --
ENT.UseFootSteps = true
ENT.FootStepInterval = 1
-- Immunities --
ENT.ImmuneToCombineBalls = false
ENT.ResistantToCombineBalls = false
ENT.CombineBallDamage = ENT.health / 2
ENT.ImmuneToElectricity = false
ENT.ImmuneToFire = false
ENT.ImmuneToIce = false
ENT.CanDrown = true
ENT.BreathTime = 30
-- Nodes --
ENT.CanDetectNavNodes = true -- Can we detect and use nav-mesh nodes to our advantage? (Experimental, requires decent navmesh!)
ENT.CanDetectRBaseNodes = false -- Can we detect and use R-Base nodes? (Requires the nodes to be placed via toolgun.)
ENT.CanJump = false
ENT.JumpHeight = 58
ENT.CanCrouch = false
ENT.CrouchSpeed = 50
