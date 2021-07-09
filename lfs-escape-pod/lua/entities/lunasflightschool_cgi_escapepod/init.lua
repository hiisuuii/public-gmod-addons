AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

local hatch = true

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal * 120 )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:RunOnSpawn()
	local seat_bl = self:AddPassengerSeat( Vector( -1.35, 33.35, -33.35 ), Angle(0,-135,0) ) -- add a passenger seat, store it inside "SpawnedPod" local variable
	local seat_br = self:AddPassengerSeat( Vector( -1.35, -33.35, -33.35 ), Angle(0,-45,0) ) -- add a passenger seat, store it inside "SpawnedPod" local variable
	local seat_fl = self:AddPassengerSeat( Vector( 49.0, 33.35, -33.35 ), Angle(0,180,0) ) -- add a passenger seat, store it inside "SpawnedPod" local variable
	local seat_fr = self:AddPassengerSeat( Vector( 49.0, -33.35, -33.35 ), Angle(0,0,0) ) -- add a passenger seat, store it inside "SpawnedPod" local variable
	
	seat_bl.ExitPos = Vector( -80, 0, -30 )  -- assigns an exit pos for SpawnedPod
	seat_br.ExitPos = Vector( -80, 0, -30 )  -- assigns an exit pos for SpawnedPod
	seat_fl.ExitPos = Vector( -80, 0, -30 )  -- assigns an exit pos for SpawnedPod
	seat_fr.ExitPos = Vector( -80, 0, -30 )  -- assigns an exit pos for SpawnedPod
	self:SetSkin(1)
	self:SetBodygroup(4,1)
	hatch = false
	
end

function ENT:OnTick()
end

function ENT:PrimaryAttack()
	return
end

function ENT:SecondaryAttack()
	return 
end

function ENT:CreateAI() -- called when the ai gets enabled
end

function ENT:RemoveAI() -- called when the ai gets disabled
end

function ENT:OnLandingGearToggled( bOn )
	if self:GetEngineActive() then return end
	print(bOn)
	hatch = bOn
	print(hatch)
	if hatch then
		self:SetBodygroup(4,0)
	else 
		self:SetBodygroup(4,1) 
	end
end

function ENT:OnEngineStarted()
	--self:EmitSound( "alpha-3_nimbus-class_v-wing_starfighter/engine_start.wav" )
	self:SetSkin(0)
	self:SetBodygroup(4,0)
	hatch = true
end

function ENT:OnEngineStopped()
	--self:EmitSound( "alpha-3_nimbus-class_v-wing_starfighter/engine_stop.wav" )
	self:SetSkin(1)
end