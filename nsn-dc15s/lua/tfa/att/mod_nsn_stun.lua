if not ATTACHMENT then
	ATTACHMENT = {}
end


ATTACHMENT.Name = "Set to Stun"
ATTACHMENT.ShortName = "STN" --Abbreviation, 5 chars or less please
--ATTACHMENT.ID = "base" -- normally this is just your filename
ATTACHMENT.Description = { 
	TFA.AttachmentColors["+"],"Stun players for 60 seconds",
	TFA.AttachmentColors["-"],"10 shots",
	TFA.AttachmentColors["-"],"75 RPM",
}
ATTACHMENT.Icon = "entities/icon/mod_nsn_stun.png" --Refers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"
ATTACHMENT.Damage = 5

ATTACHMENT.WeaponTable = {
	["Primary"] = {
		["AmmoConsumption"] = 5,
        ["Sound"] = Sound("weapons/nsn/blaster_stun.mp3"),
        ["RPM"] = 75,
        ["RPM_Semi"] = 75
	},
	["TracerName"] = "effect_sw_stun_ring",
}

function ATTACHMENT:HidePlayer(ply,bool)
    ply:SetNoDraw(bool)
    ply:SetNotSolid(bool)
    ply:DrawWorldModel(!bool)
    ply:DrawViewModel(!bool)
    if(bool)then
        ply:GodEnable()
    else
        ply:GodDisable()
    end
end

function ATTACHMENT:Ragdoll(ply)
    ply.stunned_weapons = {}

    for k,v in pairs(ply:GetWeapons()) do
        if IsValid(v) then
            table.insert(ply.stunned_weapons, v:GetClass())
        end
    end

    ply.stunRagdoll = ents.Create("prop_ragdoll")
    ply.stunRagdoll:SetPos(ply:GetPos())
    ply.stunRagdoll:SetAngles(ply:GetAngles())
    ply.stunRagdoll:SetModel(ply:GetModel())
    ply.stunRagdoll:SetSkin(ply:GetSkin())
    ply.stunRagdoll:SetColor(ply:GetColor())
    ply.stunRagdoll:SetMaterial(ply:GetMaterial())
    ply.stunRagdoll:Spawn()

    ply.stunRagdoll:CallOnRemove("ply_stun_unragdoll", function(rag)
        if IsValid(ply) then
            self:HidePlayer(ply,false)
            local p = rag:GetPos()
            ply:SetParent(NULL)
            ply:Spawn()
            timer.Simple(0.1,function()
                ply:SetPos(p+Vector(0,0,8))
            end)
            if(ply.stunned_weapons) then
                for k,v in pairs(ply.stunned_weapons) do
                    ply:Give(v)
                end
            end
            ply.stunned_weapons = nil
        end  
    end)

    ply.stunRagdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    //local vel = ply:GetVelocity()
    local pObj = ply.stunRagdoll:GetPhysicsObjectCount()-1
    
    for i = 0, pObj do
        local bone = ply.stunRagdoll:GetPhysicsObjectNum(i)

        if IsValid(bone) then
            local pos,ang = ply:GetBonePosition(ply.stunRagdoll:TranslatePhysBoneToBone(i))
            if (pos and ang) then
                bone:SetPos(pos)
                bone:SetAngles(ang)
            end
            //bone:AddVelocity(vel)
        end
    end
    ply:StripWeapons()
    ply:SetMoveType(MOVETYPE_OBSERVER)
    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(ply.stunRagdoll)
    ply:SetParent(ply.stunRagdoll)
    timer.Simple(60, function()
        if IsValid(self) and IsValid(ply) then
            self:UnRagdoll(ply)
        end
    end)
    self:HidePlayer(ply, true)
end

function ATTACHMENT:UnRagdoll(ply)

    self:HidePlayer(ply,false)
    local pos = ply.stunRagdoll:GetPos()
    ply:UnSpectate()
    ply.stunRagdoll:Remove()

    ply:SetParent(NULL)
    ply:Spawn()
    timer.Simple(0.1, function()
        ply:SetPos(pos+Vector(0,0,5))
    end)
    for k,v in pairs(ply.stunned_weapons) do
        ply:Give(v)
    end
    ply.stunned_weapons = nil
end

function ATTACHMENT:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if not IsFirstTimePredicted() and not game.SinglePlayer() then return end
	num_bullets = 1
	aimcone = aimcone or 0

    local TracerName = "effect_sw_stun_ring"
    local bp = self.Owner:GetShootPos()
	local tr = self.Owner:GetEyeTrace()
	if SERVER then
		if tr.Entity and tr.Entity:IsPlayer() and IsValid(tr.Entity) then
			if IsValid(tr.Entity.stunRagdoll) then
				self:UnRagdoll(tr.Entity)
			else
				self:Ragdoll(tr.Entity)
			end
		end
	end

    data = EffectData()
    data:SetEntity(self)
    data:SetStart(bp)
    data:SetOrigin(self:GetOwner():GetEyeTrace().HitPos)
    util.Effect(TracerName, data)
    data = nil
end

function ATTACHMENT:Attach(w)
	w.ShootBullet = self.ShootBullet
	w.HidePlayer = self.HidePlayer
	w.Ragdoll = self.Ragdoll
	w.UnRagdoll = self.UnRagdoll
end
function ATTACHMENT:Detach(w)
	w.ShootBullet = baseclass.Get(w.Base).ShootBullet
	//w.UnRagdoll = baseclass.Get(w.Base).UnRagdoll
	//w.Ragdoll = baseclass.Get(w.Base).Ragdoll
end
if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end