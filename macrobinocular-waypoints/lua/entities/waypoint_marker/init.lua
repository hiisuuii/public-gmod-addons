AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:AddEffects(EF_NOSHADOW)
	self:SetSolid(SOLID_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()

	--if phys:IsValid() then
	--	phys:Wake()
	--end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
