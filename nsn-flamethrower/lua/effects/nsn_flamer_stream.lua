//Main function
function EFFECT:Init(data)

    //Muzzle and desired position vectors
    local StartPos = self:GetTracerShootPos(self.Position, data:GetEntity(), data:GetAttachment())
    local HitPos = data:GetOrigin()

    //Check if the weapon is still there
    if data:GetEntity():IsValid() && StartPos && HitPos then

        //Create particle emmiter
        local FlameEmitter = ParticleEmitter(StartPos)

            //Amount of particles to create
            for i=0, 8 do

                //Safeguard
                if !FlameEmitter then return end

                //Pool of flame sprites
                local FlameMat = {}
                FlameMat[1] = "effects/muzzleflash2"
                FlameMat[2] = "effects/muzzleflash3"
                FlameMat[3] = "effects/muzzleflash1"

                local FlameParticle = FlameEmitter:Add( FlameMat[math.random(1,3)], StartPos )

                if (FlameParticle) then

                    FlameParticle:SetVelocity( ((HitPos - StartPos):GetNormal() * math.random(1720,1820)) + (VectorRand() * math.random(40,120)) )

                    FlameParticle:SetLifeTime(0)
                    FlameParticle:SetDieTime(0.52)

                    FlameParticle:SetStartAlpha(math.random(92,132))
                    FlameParticle:SetEndAlpha(0)

                    FlameParticle:SetStartSize(math.random(4,6))
                    FlameParticle:SetEndSize(math.random(32,52))

                    FlameParticle:SetRoll(math.Rand(-360, 360))
                    FlameParticle:SetRollDelta(math.Rand(-7.2, 7.2))

                    FlameParticle:SetAirResistance(math.random(128, 256))

                    FlameParticle:SetCollide(true)

                    FlameParticle:SetGravity( Vector(0, 0, 64) )

                end
            end

        //We're done with this emmiter
        FlameEmitter:Finish()

        //Create particle emmiter
        --[[
        local SmokeEmitter = ParticleEmitter(StartPos)

            //Amount of particles to create
            for i=0, 2 do

                //Safeguard
                if !SmokeEmitter then return end

                SmokeParticle = SmokeEmitter:Add( "particle/smokesprites_000" .. math.random(1,8) .. "", StartPos )

                if (SmokeParticle) then

                    SmokeParticle:SetVelocity( ((HitPos - StartPos):GetNormal() * math.random(1720,1820)) + (VectorRand() * math.random(152,182)) )

                    SmokeParticle:SetLifeTime(0)
                    SmokeParticle:SetDieTime( math.Rand(0.92, 1.72) )

                    SmokeParticle:SetStartAlpha(math.random(52,92))
                    SmokeParticle:SetEndAlpha(0)

                    SmokeParticle:SetStartSize(math.random(8,10))
                    SmokeParticle:SetEndSize(math.random(62,82))

                    SmokeParticle:SetRoll(math.Rand(-360, 360))
                    SmokeParticle:SetRollDelta(math.Rand(-5.2, 5.2))

                    SmokeParticle:SetAirResistance(math.random(132, 262))

                    SmokeParticle:SetCollide(true)

                    SmokeParticle:SetGravity( Vector(0, 0, -92) )

                    SmokeParticle:SetLighting(1)

                end
            end

        //We're done with this emmiter
        SmokeEmitter:Finish()

        ]]--
    end
end

//Kill effect
function EFFECT:Think()
    return false
end

//Unused
function EFFECT:Render()
end