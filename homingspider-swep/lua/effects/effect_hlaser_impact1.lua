		local mat = Material( "trails/laser" )
local mat2 = Material( "sprites/light_glow02_add" )
local mat4 = Material( "trails/plasma" )

function EFFECT:Init(data)		
	local Startpos = data:GetOrigin()
	
	self.Emitter = ParticleEmitter(Startpos)
	
	for i = 1, 20 do
		local p = self.Emitter:Add("sprites/light_glow02_add", Startpos)
			
		p:SetDieTime(0.1)
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(7)
		p:SetEndSize(1)
		p:SetColor(255, 0, 0)
		//p:SetRoll(math.random(-60, 60))
		//p:SetRollDelta(math.random(-60, 60))	
		p:SetVelocity(VectorRand():GetNormal()*50)
		p:SetCollide(true)
	end
	
	self.Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end