function EFFECT:Init(data)

    sound.Play("ambient/fire/ignite.wav", self:GetPos(), 54, math.random(82,112))


    //Create particle emmiter
    local emitter = ParticleEmitter(data:GetOrigin())

    //Amount of particles to create
    for i=0, 16 do

        //Safeguard
        if !FlameEmitter then return end

        //Pool of flame sprites
        local FlameMat = {}
        FlameMat[1] = "effects/muzzleflash2"
        FlameMat[2] = "effects/muzzleflash3"
        FlameMat[3] = "effects/muzzleflash1"

        local FlameParticle = FlameEmitter:Add( FlameMat[math.random(1,3)], data:GetOrigin() )

        if (FlameParticle) then

            FlameParticle:SetVelocity( VectorRand() * 172 )
            
            FlameParticle:SetLifeTime(0)
            FlameParticle:SetDieTime(0.72)
            
            FlameParticle:SetStartAlpha(210)
            FlameParticle:SetEndAlpha(0)
            
            FlameParticle:SetStartSize(0)
            FlameParticle:SetEndSize(64)
            
            FlameParticle:SetRoll(math.Rand(-210, 210))
            FlameParticle:SetRollDelta(math.Rand(-3.2, 3.2))
            
            FlameParticle:SetAirResistance(350)
            
            FlameParticle:SetGravity(Vector(0, 0, 64))

        end
    end

        //We're done with this emmiter
        FlameEmitter:Finish()

end

//Kill effect
function EFFECT:Think()
    return false
end

function EFFECT:Render()
end