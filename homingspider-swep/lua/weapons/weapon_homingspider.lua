
SWEP.Base = "weapon_base"
SWEP.Category = "Star Wars"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel = "models/weapons/v_irifle.mdl" 
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.DrawWorldModel=true
SWEP.Primary.ClipSize = -1
SWEP.Primary.Delay = 0.5
SWEP.Primary.DefaultClip = -1 
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 3
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.UseHands=false
 
SWEP.PrintName = "Homing Spider Droid Laser"       
SWEP.Author = "Ace"
SWEP.Instructions = "brrr"
SWEP.ViewModelFOV = 55
SWEP.Slot = 2
SWEP.DrawCrosshair = true
SWEP.Weight = 500
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
	

function SWEP:Initialize()
	self:SetWeaponHoldType( "ar2" )
	if SERVER then
		self.sound=CreateSound(self.Weapon,"weapons/laser.wav")
	end
end


function SWEP:Deploy()
	local effect = EffectData()
	effect:SetEntity(self.Weapon)
	effect:SetAttachment(1)
	util.Effect("effect_hlaser1", effect)
end

function SWEP:Think()

	if SERVER then
		if self.Owner:KeyPressed(IN_ATTACK) or self.Owner:KeyPressed(IN_ATTACK2) then
			self.Weapon:EmitSound("weapons/laseron.wav")
		end
		if self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) then
			self.sound:Play()
			self.sound:ChangeVolume(0.4,0)
			self.sound:ChangePitch(70, 0)
		end
		if (self.Owner:KeyReleased(IN_ATTACK) or self.Owner:KeyReleased(IN_ATTACK2)) and self.sound then
			self.sound:Stop()
		end
	end
end

function SWEP:DrawWorldModel()
	self:DrawModel()	
end

function SWEP:Reload()
	return
end

function SWEP:FireAnimationEvent(pos,ang,event,options)
	return true
end

	
function SWEP:FireLaser()
	self:SetNextPrimaryFire(CurTime()+0.01)
	local trace={
		start=self.Owner:GetShootPos(),
		endpos=self.Owner:GetEyeTrace().HitPos,
		filter=function(ent) if ent:IsWorld() then return true end end
	}
	
	tr=util.TraceLine(trace)
	local ef= EffectData()
	ef:SetOrigin(tr.HitPos)
	util.Effect("effect_hlaser_impact1",ef)
	for k,v in pairs(ents.FindAlongRay(self.Owner:GetShootPos(),tr.HitPos,Vector(-5,-5,-5),Vector(5,5,5))) do								 								 
		if v~=self.Owner then
			if v:GetMoveType()~=0 then
				if SERVER then
					local dmginfo= DamageInfo()
					dmginfo:SetAttacker(self.Owner)
					dmginfo:SetInflictor(self.Weapon)
					dmginfo:SetDamage(1)
					dmginfo:SetDamageForce(Vector(0,0,0))
					dmginfo:SetDamageType(DMG_ENERGYBEAM)
					v:TakeDamageInfo(dmginfo)
				end						 
			end
		end
	end
end

function SWEP:PrimaryAttack()
	self:FireLaser()
end
 
function SWEP:SecondaryAttack()
	self:FireLaser()
end
