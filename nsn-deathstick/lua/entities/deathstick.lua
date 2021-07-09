AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Deathstick"
ENT.Author			= "Ace"
ENT.Contact			= "https://discord.gg/GAd3Hsa"
ENT.Purpose			= "You want to go home and rethink your life."
ENT.Instructions	= "I want to go home and rethink my life."
ENT.Category = "[NSN] Star Wars"
ENT.Spawnable = true
ENT.AdminSpawnable = true

sound.Add({
	name = "deathstick.drink",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 60,
	sound = "deathstick/drink.wav"
})
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/cire992/props/glass01.mdl")
		self:SetSkin(math.Rand(0,4))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:GetPhysicsObject():Wake()

	end

	function ENT:Use(a,c)
		if a:IsPlayer() && a:IsValid() then
			self:Remove()
			sound.Play("deathstick/drink.wav", self:GetPos(), 75, 100, 1.0)
			--a:SetHealth(a:Health()-math.Clamp((math.floor((.25)*a:Health())), 1, 200))
			--a:SetHealth(math.Approach(a:Health(), 0, -math.Clamp(math.floor(a:Health()*0.2), 1, 200)))
			self:HandleEffects(a)
		end
	end

	function ENT:HandleEffects(ply)
	
		
		--print(plyDefaultCWalk)
		--print(plyDefaultWalk)
		--print(plyDefaultRun)
		if self:GetSkin() == 0 then
			if ply:GetNWBool("deathstick_speedchange") then
				self:DealDamage(ply)
				ply:ChatPrint("The deathstick does not seem to have an effect on you..")
				return 
			end
			local plyDefaultRun = ply:GetRunSpeed()
			local plyDefaultWalk = ply:GetWalkSpeed()
			local plyDefaultCWalk = ply:GetCrouchedWalkSpeed()
			local mult = math.Round(math.Rand(1.2,1.9), 1)
			local t = math.floor(math.Rand(10,30))
			ply:ChatPrint("The deathstick makes you feel lighter on your feet.")
			ply:SetCrouchedWalkSpeed((ply:GetCrouchedWalkSpeed()*mult))
			ply:SetWalkSpeed((ply:GetWalkSpeed()*mult))
			ply:SetRunSpeed((ply:GetRunSpeed()*mult))
			ply:SetNWBool("deathstick_speedchange", true)
			timer.Create(ply:SteamID64().."_ds_speeduptimer",t, 1, function()
				ply:SetCrouchedWalkSpeed(plyDefaultCWalk)
				ply:SetWalkSpeed(plyDefaultWalk)
				ply:SetRunSpeed(plyDefaultRun)
				ply:SetNWBool("deathstick_speedchange", false)
				ply:ChatPrint("You feel your speed return to normal.")
			end)
		elseif self:GetSkin() == 1 then
			if ply:GetNWBool("deathstick_hpboost") then
				self:DealDamage(ply)
				ply:ChatPrint("The deathstick does not seem to have an effect on you..")
				return 
			end
			local addHp = math.floor(math.Rand(20, 60))
			local t = math.floor(math.Rand(10,30))
			ply:ChatPrint("The deathstick makes you feel somewhat stronger.")
			ply:SetHealth(ply:Health()+addHp)
			ply:SetNWBool("deathstick_hpboost", true)
			timer.Create(ply:SteamID64().."_ds_hp_small",t, 1, function()
				ply:SetHealth(math.Clamp((ply:Health()-addHp), 1, 2147483646))
				ply:SetNWBool("deathstick_hpboost", false)
				ply:ChatPrint("You feel your strength return to normal.")
			end)
			
		elseif self:GetSkin() == 2 then
			if ply:GetNWBool("deathstick_speedchange") then
				self:DealDamage(ply)
				ply:ChatPrint("The deathstick does not seem to have an effect on you..")
				return 
			end
			local plyDefaultRun = ply:GetRunSpeed()
			local plyDefaultWalk = ply:GetWalkSpeed()
			local plyDefaultCWalk = ply:GetCrouchedWalkSpeed()
			local mult = math.Round(math.Rand(0.4,0.9), 1)
			local t = math.floor(math.Rand(10,30))
			ply:ChatPrint("The deathstick makes you feel heavy and sluggish.")
			ply:SetCrouchedWalkSpeed((ply:GetCrouchedWalkSpeed()*mult))
			ply:SetWalkSpeed((ply:GetWalkSpeed()*mult))
			ply:SetRunSpeed((ply:GetRunSpeed()*mult))
			ply:SetNWBool("deathstick_speedchange", true)
			timer.Create(ply:SteamID64().."_ds_slowdowntimer", t, 1, function()
				ply:SetCrouchedWalkSpeed(plyDefaultCWalk)
				ply:SetWalkSpeed(plyDefaultWalk)
				ply:SetRunSpeed(plyDefaultRun)
				ply:SetNWBool("deathstick_speedchange", false)
				ply:ChatPrint("You no longer feel heavy and sluggish.")
			end)
		elseif self:GetSkin() == 3 then
			if ply:GetNWBool("deathstick_hpboost") then
				self:DealDamage(ply)
				ply:ChatPrint("The deathstick does not seem to have an effect on you..")
				return 
			end
			local addHp = math.floor(math.Rand(60, 150))
			local t = math.floor(math.Rand(10,30))
			ply:ChatPrint("The deathstick makes you feel significantly stronger!")
			ply:SetHealth(ply:Health()+addHp)
			ply:SetNWBool("deathstick_hpboost", true)
			timer.Create(ply:SteamID64().."_ds_hp_big",t, 1, function()
				ply:SetHealth(math.Clamp((ply:Health()-addHp), 1, 2147483646))
				ply:SetNWBool("deathstick_hpboost", false)
				ply:ChatPrint("You feel your strength return to normal.")
			end)
		end
		self:DealDamage(ply)
	end


	function ENT:DealDamage(ply)
		ply:SetHealth( ply:Health() - (math.Clamp(((ply:GetMaxHealth()+1) - ply:Health()), 10, (ply:GetMaxHealth()/3)  )))
		if ply:Health() < 1 then
			ply:Kill()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end