AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Gravity Well Projector"
ENT.Author			= "Ace"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Category = "[NSN] Star Wars"
ENT.Spawnable = true
ENT.AdminOnly = false

local affected_players = {}


if SERVER then
	function ENT:Initialize()
		self:SetModel("models/nsn/ace/gravitywell/gravitywell.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():SetMass(400)
		self:GetPhysicsObject():Wake()
        self:SetWellHealth(1000)

	end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)

        local Damage = dmginfo:GetDamage()
        local CurHealth = self:GetWellHealth()
        local NewHealth = math.Clamp( CurHealth - Damage , 0, 1000 )
        

        self:SetWellHealth( NewHealth )
        //print(self:GetWellHealth())
        
        if NewHealth <= 0 then
                local FinalAttacker = dmginfo:GetAttacker() 
                local FinalInflictor = dmginfo:GetInflictor()
                
                local effectdata = EffectData()
                    effectdata:SetOrigin( self:GetPos() )
                util.Effect( "Explosion", effectdata )

                local blastdmg = DamageInfo()

                blastdmg:SetDamage(100)
                blastdmg:SetBaseDamage(80)
                blastdmg:SetMaxDamage(120)
                blastdmg:SetDamageType(64)
                blastdmg:SetInflictor(FinalInflictor)
                blastdmg:SetAttacker(FinalAttacker)
                blastdmg:SetReportedPosition(self:GetPos())
                local vpos = self:GetPos()

                timer.Simple(0.1, function()
                    util.BlastDamageInfo(blastdmg, vpos, 320)
                end)
                self:Remove()
        end
    end

end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "WellHealth")
end
