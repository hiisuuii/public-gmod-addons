if CLIENT then
local laser = Material("effects/blueblacklargebeam")

	function EFFECT:Init(data)
		self.WeaponEnt = data:GetEntity()
		self.Attachment = data:GetAttachment()
	end	

	function EFFECT:Think()
		if !IsValid(self.WeaponEnt.Owner) or !IsValid(self.WeaponEnt) or not(self.WeaponEnt.Owner:IsPlayer() and self.WeaponEnt.Owner:Alive()) or self.WeaponEnt.Owner:GetActiveWeapon()~=self.WeaponEnt then return false end
			local trace={}
			trace.start=self.WeaponEnt.Owner:GetShootPos()
			trace.endpos=trace.start+self.WeaponEnt.Owner:GetAimVector()*100000000000
			trace.filter=function(ent) if ent:IsWorld() then return true end end 
					 
        	local tr=util.TraceLine(trace)			
			if self.WeaponEnt.Owner:KeyDown(IN_ATTACK) or (self.WeaponEnt.Owner:KeyDown(IN_ATTACK2)) then
				self:SetRenderBoundsWS(self.WeaponEnt.Owner:GetShootPos(),tr.HitPos)
			end
		return true 
	end


	function EFFECT:Render()	
		self.Position = self.WeaponEnt.Owner:GetShootPos()
 		self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)		

		local trace={}
		trace.start=self.WeaponEnt.Owner:GetShootPos()
        trace.endpos=self.WeaponEnt.Owner:GetEyeTrace().HitPos
        trace.filter=function(ent) if ent:IsWorld() then return true end end 
					 
        local tr=util.TraceLine(trace)							  
								 
		if self.WeaponEnt.Owner:KeyDown(IN_ATTACK) or self.WeaponEnt.Owner:KeyDown(IN_ATTACK2) then
			render.SetMaterial(laser)
			for i=1,3 do
				render.DrawBeam(self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment),tr.HitPos, 48, 1, 1, Color(255,0,0, 255))
			end
		end
	end

end