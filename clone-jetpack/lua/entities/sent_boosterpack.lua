AddCSLuaFile()

if SERVER then
	resource.AddFile( "materials/entities/sent_boosterpack.png" )
end

DEFINE_BASECLASS( "base_predictedent_boosterpack" )

ENT.Spawnable = true
ENT.PrintName = "Boosterpack (no model)"

if CLIENT then
	ENT.MatHeatWave		= Material( "sprites/heatwave" )
	ENT.MatFire			= Material( "effects/fire_cloud_blue" )
	
	AccessorFunc( ENT , "NextParticle" , "NextParticle" )
	AccessorFunc( ENT , "LastActive" , "LastActive" )
	AccessorFunc( ENT , "LastFlameTrace" , "LastFlameTrace" )
	AccessorFunc( ENT , "NextFlameTrace" , "NextFlameTrace" )
	
	ENT.MaxEffectsSize = 0.25
	ENT.MinEffectsSize = 0.1
	
	ENT.BoosterpackFireBlue = Color( 0 , 0 , 255 , 255 )
	ENT.BoosterpackFireWhite = Color( 0 , 0 , 255 , 255 )
	ENT.BoosterpackFireNone = Color( 255 , 255 , 255 , 0 )
	ENT.BoosterpackFireRed = Color( 0 , 0 , 255 , 255 )
	
else
	
	ENT.StandaloneAngular = vector_origin
	ENT.StandaloneLinear = Vector( 0 , 0 , 0 )
	
	ENT.ShowPickupNotice = true
	ENT.SpawnOnGroundConVar = CreateConVar( 
		"sv_spawnBoosterpackonground" , 
		"1", 
		{ 
			FCVAR_SERVER_CAN_EXECUTE, 
			FCVAR_ARCHIVE 
		}, 
		"When true, it will spawn the Boosterpack on the ground, otherwise it will try equipping it right away, if you already have one equipped it will not do anything" 
	)
end

--use this to calculate the position on the parent because I can't be arsed to deal with source's parenting bullshit with local angles and position
--plus this is also called during that parenting position recompute, so it's perfect

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_Spine2",
	OffsetVec = Vector( 3 , -5.6 , 0 ),
	OffsetAng = Angle( 180 , 90 , -90 ),
}

sound.Add( {
	name = "Boosterpack.thruster_loop",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 75,
	sound = "^thrusters/jet02.wav"
})

local sv_gravity = GetConVar "sv_gravity"

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36

	local ent = ents.Create( ClassName )
	ent:SetSlotName( ClassName )	--this is the best place to set the slot, only modify it ingame when it's not equipped
	ent:SetPos( SpawnPos )
	ent:SetAngles( Angle( 0 , 0 , 180 ) )
	ent:Spawn()
	
	--try equipping it, if we can't we'll just remove it
	if not self.SpawnOnGroundConVar:GetBool() then
		--forced should not be set here, as we still kinda want the equip logic to work as normal
		if not ent:Attach( ply , false ) then
			ent:Remove()
			return
		end
	end
	
	return ent

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	if SERVER then
		self:SetModel( "models/thrusters/Jetpack.mdl" )
		self:InitPhysics()
		
		self:SetMaxHealth( 100 )
		self:SetHealth( self:GetMaxHealth() )
		
		self:SetInfiniteFuel( false )
		self:SetMaxFuel( 100 )
		self:SetFuel( self:GetMaxFuel() )
		self:SetFuelDrain( 1 )	--drain in seconds
		self:SetFuelRecharge( 5 )	--recharge in seconds
		self:SetActive( false )
		self:SetAirResistance( 2.0 )
		self:SetRemoveGravity( false )
		self:SetBoosterpackSpeed( 500 )
		self:SetBoosterpackSpeedStrafeSpeed( 500 )
		self:SetBoosterpackSpeedVelocity( 2000 )
		self:SetBoosterpackSpeedStrafeVelocity( 1000 )
	else
		self:SetLastActive( false )
		self:SetNextParticle( 0 )
		self:SetNextFlameTrace( 0 )
		self:SetLastFlameTrace( nil )
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )

	self:DefineNWVar( "Bool" , "Active" )
	self:DefineNWVar( "Bool" , "RemoveGravity" )
	self:DefineNWVar( "Bool" , "InfiniteFuel" , true , "Infinite Fuel" )
	self:DefineNWVar( "Float" , "Fuel" )
	self:DefineNWVar( "Float" , "MaxFuel" )	--don't modify the max amount, the drain scales anyway, set to -1 to disable the fuel drain
	self:DefineNWVar( "Float" , "FuelDrain" , true , "Seconds to drain fuel" , 1 , 60 ) --how many seconds it's gonna take to drain all the fuel
	self:DefineNWVar( "Float" , "FuelRecharge" , true , "Seconds to recharge the fuel" , 1 , 60 ) --how many seconds it should take to fully recharge this
	self:DefineNWVar( "Float" , "AirResistance" , true , "Air Resistance" , 0 , 10 )
	
	self:DefineNWVar( "Int" , "Key" )	--override it to disallow people from editing the key since it's unused
	self:DefineNWVar( "Int" , "BoosterpackSpeed" , true , "Boosterpack idle upward speed" , 1 , 1000 )
	self:DefineNWVar( "Int" , "BoosterpackSpeedStrafeSpeed" , true , "Boosterpack idle side speed" , 1 , 1000 )
	self:DefineNWVar( "Int" , "BoosterpackSpeedVelocity" , true , "Boosterpack active upward speed" , 1 , 3000 )
	self:DefineNWVar( "Int" , "BoosterpackSpeedStrafeVelocity" , true , "Boosterpack active side speed" , 1 , 3000 )
	
end

function ENT:HandleFly( predicted , owner , movedata , usercmd )
	self:SetActive( self:CanFly( owner , movedata ) )
	
	--the check below has to be done with prediction on the client!
	
	if CLIENT and not predicted then
		return
	end
end

function ENT:HandleFuel( predicted )

	--like with normal rules of prediction, we don't want to run on the client if we're not in the simulation

	if not predicted and CLIENT then
		return
	end

	--we set the think rate on the entity to the tickrate on the server, we could've done NextThink() - CurTime(), but it's only a setter, not a getter
	local ft = engine.TickInterval()

	--screw that, during prediction we need to recharge with FrameTime()
	if predicted then
		ft = FrameTime()
	end

	local fueltime = self:GetActive() and self:GetFuelDrain() or self:GetFuelRecharge()

	local fuelrate = self:GetMaxFuel() / ( fueltime / ft )

	if self:GetActive() then
		fuelrate = fuelrate * -1

		
		--don't drain any fuel when infinite fuel is on, but still allow recharge
		if self:GetInfiniteFuel() then
			fuelrate = 0
		end
	else
		--recharge in different ways if we have an owner or not, because players might drop and reequip the Boosterpack to exploit the recharging
		if IsValid( self:GetControllingPlayer() ) then
			--can't recharge until our owner is on the ground!
			--prevents the player from tapping the jump button to fly and recharge at the same time
			if not self:GetControllingPlayer():OnGround() then
				fuelrate = 0
			end
		else
			--only recharge if our physobj is sleeping and it's valid ( should never be invalid in the first place )
			local physobj = self:GetPhysicsObject()
			if not IsValid( physobj ) or not physobj:IsAsleep() then
				fuelrate = 0
			end
		end
	end
	
	--holy shit, optimization??
	if fuelrate ~= 0 then	
		self:SetFuel( math.Clamp( self:GetFuel() + fuelrate , 0 , self:GetMaxFuel() ) )
	end
	
	
end

function ENT:HandleLoopingSounds()

	--create the soundpatch if it doesn't exist, it might happen on the client sometimes since it's garbage collected

	if not self.BoosterpackSound then
		self.BoosterpackSound = CreateSound( self, "Boosterpack.thruster_loop" )
	end

	if self:GetActive() then
		local pitch = 125
		
		
		self.BoosterpackSound:PlayEx( 0.35  , pitch )
	else
		self.BoosterpackSound:FadeOut( 0.1 )
	end
end

function ENT:HasFuel()
	return self:GetFuel() > 0
end

function ENT:GetFuelFraction()
	return self:GetFuel() / self:GetMaxFuel()
end

function ENT:CanFly( owner , mv )
	
	
	if IsValid( owner ) then
		
		return ( mv:KeyDown( IN_JUMP ) or mv:KeyDown( IN_DUCK ) or mv:KeyDown( IN_SPEED ) ) and not owner:OnGround() and owner:WaterLevel() == 0 and owner:GetMoveType() == MOVETYPE_WALK and owner:Alive() and self:HasFuel()
	end

	
	return false
end

function ENT:Think()

	--still act if we're not being held by a player
	if not self:IsCarried() then
		self:HandleFly( false )
		self:HandleFuel( false )
	end

	
	return BaseClass.Think( self )
end

function ENT:PredictedSetupMove( owner , mv , usercmd )
	
	self:HandleFly( true , owner , mv , usercmd )
	self:HandleFuel( true )
	
	if self:GetActive() then
		
		local vel = mv:GetVelocity()
		
		if mv:KeyDown( IN_JUMP ) and vel.z < self:GetBoosterpackSpeed() then

			-- Apply constant Boosterpack_velocity
			
			vel.z = vel.z + self:GetBoosterpackSpeedVelocity() * FrameTime()
		
		elseif mv:KeyDown( IN_SPEED ) and vel.z < 0 then

			-- Apply just the right amount of thrust
			
			vel.z = math.Approach( vel.z , 0 , self:GetBoosterpackSpeedVelocity() * FrameTime() )

		end
		


		--
		-- Remove gravity when velocity is supposed to be zero for hover mode
		--

		if vel.z == 0 then

			self:SetRemoveGravity( true )

			vel.z = vel.z + sv_gravity:GetFloat() * 0.5 * FrameTime()

		end

		--
		-- Apply movement velocity
		--
		
		local move_vel = Vector( 0, 0, 0 )

		local ang = mv:GetMoveAngles()
		ang.p = 0

		move_vel:Add( ang:Right() * mv:GetSideSpeed() )
		move_vel:Add( ang:Forward() * mv:GetForwardSpeed() )

		move_vel:Normalize()
		move_vel:Mul( self:GetBoosterpackSpeedStrafeVelocity() * FrameTime() )

		if vel:Length2D() < self:GetBoosterpackSpeedStrafeSpeed() then

			vel:Add( move_vel )

		end
		
		
		
		--
		-- Apply air resistance
		--
		vel.x = math.Approach( vel.x, 0, FrameTime() * self:GetAirResistance() * vel.x )
		vel.y = math.Approach( vel.y, 0, FrameTime() * self:GetAirResistance() * vel.y )
	
		--
		-- Write our calculated velocity back to the CMoveData structure
		--
		mv:SetVelocity( vel )

		mv:SetForwardSpeed( 0 )
		mv:SetSideSpeed( 0 )
		mv:SetUpSpeed( 0 )
		
		-- Removes the crouch button from the movedata, effectively disabling the crouching behaviour
		
		mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_DUCK ) ) )
	
	end
end

function ENT:PredictedThink( owner , movedata )
end

function ENT:PredictedMove( owner , data )
end

function ENT:PredictedFinishMove( owner , movedata )
	if self:GetActive() then
		
		--
		-- Remove gravity when velocity is supposed to be zero for hover mode
		--
		if self:GetRemoveGravity() then
			local vel = movedata:GetVelocity()

			vel.z = vel.z + sv_gravity:GetFloat() * 0.5 * FrameTime()

			movedata:SetVelocity( vel )

			self:SetRemoveGravity( false )
		end
		
	end
end

local	SF_PHYSEXPLOSION_NODAMAGE			=	0x0001
local	SF_PHYSEXPLOSION_PUSH_PLAYER		=	0x0002
local	SF_PHYSEXPLOSION_RADIAL				=	0x0004
local	SF_PHYSEXPLOSION_TEST_LOS			=	0x0008
local	SF_PHYSEXPLOSION_DISORIENT_PLAYER	=	0x0010

if SERVER then
	
	function ENT:OnTakeDamage( dmginfo )
		--we're already dead , might happen if multiple Boosterpacks explode at the same time
		if self:Health() <= 0 then
			return
		end
		
		self:TakePhysicsDamage( dmginfo )
		
		local oldhealth = self:Health()
		
		local newhealth = math.Clamp( self:Health() - dmginfo:GetDamage() , 0 , self:GetMaxHealth() )
		self:SetHealth( newhealth )
		
		if self:Health() <= 0 then
			--maybe something is relaying damage to the Boosterpack instead, an explosion maybe?
			if IsValid( self:GetControllingPlayer() ) then
				self:Remove()
			end
			self:Detonate( dmginfo:GetAttacker() )
			return
		end
		

	end
	
	function ENT:OnAttach( ply )
		//self:SetDoGroundSlam( false )
		--self:SetSolid( SOLID_BBOX )	--we can still be hit when on the player's back
	end
	
	function ENT:CanAttach( ply )
		
	end

	function ENT:OnDrop( ply , forced )
		if IsValid( ply ) and not ply:Alive() then
			--when the player dies while still using us, keep us active and let us fly with physics until
			--our fuel runs out
			if self:GetActive() then
				//self:SetGoneApeshit( true )
				self:SetActive( false )
			end
		else
			self:SetActive( false )
		end
		
	end

	function ENT:OnInitPhysics( physobj )
		if IsValid( physobj ) then
			physobj:SetMass( 75 )
			self:StartMotionController()
		end
		self:SetCollisionGroup( COLLISION_GROUP_NONE )
		--self:SetCollisionGroup( COLLISION_GROUP_WEAPON )	--set to COLLISION_GROUP_NONE to reenable collisions against players and npcs
	end
	
	function ENT:OnRemovePhysics( physobj )
		self:StopMotionController()
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		--self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	end
	
	function ENT:PhysicsSimulate( physobj , delta )
		
		--no point in applying forces and stuff if something is holding our physobj
		
		if self:GetActive() and not self:GetBeingHeld() then
			physobj:Wake()
			local force = self.StandaloneLinear
			local angular = self.StandaloneAngular
			
			
			--yes I know we're technically modifying the variable stored in ENT.StandaloneApeShitLinear and that it might fuck up other Boosterpacks
			--but it won't because we're simply using it as a cached vector_origin and overriding the z anyway
			force.z = -self:GetBoosterpackSpeedVelocity()
			
			return angular * physobj:GetMass() , force * physobj:GetMass() , SIM_LOCAL_FORCE
		end
	end
	
	function ENT:PhysicsCollide( data , physobj )
		--taken straight from valve's code, it's needed since garry overwrote VPhysicsCollision, friction sound is still there though
		--because he didn't override the VPhysicsFriction
		if data.DeltaTime >= 0.05 and data.Speed >= 70 then
			local volume = data.Speed * data.Speed * ( 1 / ( 320 * 320 ) )
			if volume > 1 then
				volume = 1
			end
			
			--TODO: find a better impact sound for this model
			self:EmitSound( "SolidMetal.ImpactHard" , nil , nil , volume , CHAN_BODY )
		end
		
		if self:CheckDetonate( data , physobj ) then
			self:Detonate()
		end
	end
	
	--can't explode on impact if we're not active
	function ENT:CheckDetonate( data , physobj )
		return self:GetActive() and data.Speed > 500 and not self:GetBeingHeld()
	end
	
	function ENT:Detonate( attacker )
		--you never know!
		if self:IsEFlagSet( EFL_KILLME ) then 
			return 
		end
		
		self:Remove()
		
		local fuel = self:GetFuel()
		local atk = IsValid( attacker ) and attacker or self
		
		--check how much fuel was left when we impacted
		local dmg = 1.5 * fuel
		local radius = 2.5 * fuel
		
		util.BlastDamage( self , atk , self:GetPos() , radius , dmg )
		util.ScreenShake( self:GetPos() , 1.5 , dmg , 0.25 , radius * 2 )
		
		local effect = EffectData()
		effect:SetOrigin( self:GetPos() )
		effect:SetMagnitude( dmg )	--this is actually the force of the explosion
		effect:SetFlags( bit.bor( 0x80 , 0x20 ) ) --NOFIREBALLSMOKE, ROTATE
		util.Effect( "Explosion" , effect )
	end
	
	
	function ENT:CanPlayerEditVariable( ply , key , val , editor )
		--don't modify values if we're active, dropped or not
		if self:GetActive() and key ~= "Key" then
			return false
		end
		
		
	end
	
else

	function ENT:Draw( flags )
		local pos , ang = self:GetCustomParentOrigin()
		
		--even though the calcabsoluteposition hook should already prevent this, it doesn't on other players
		--might as well not give it the benefit of the doubt in the first place
		if pos and ang then
			self:SetPos( pos )
			self:SetAngles( ang )
			self:SetupBones()
		end

		if not IsValid( self:GetControllingPlayer() ) then
			self:DrawModel( flags )
		end
		
		
		local atchposN , atchpos1 , atchpos2 , atchang , angrt, angfw = self:GetEffectsOffset()
		
	//	local effectsscale = self:GetEffectsScale()
		
		--technically we shouldn't draw the fire from here, it should be done in drawtranslucent
		--but since we draw from the player and he's not translucent this won't get called despite us being translucent
		--might as well just set us to opaque
		
		if self:GetActive() then	-- and bit.band( flags , STUDIO_TRANSPARENCY ) ~= 0 then
			self:DrawBoosterpackFire( atchposN , atchpos1 , atchpos2 , atchang , angrt , angfw , .1 )
		end
		
	end
	
	
	
	function ENT:GetEffectsOffset()
		local angup = self:GetAngles():Up()
		local angrt = self:GetAngles():Right()
		local angfw = self:GetAngles():Forward()
		return self:GetPos() + angup * 10 , self:GetPos() + (angup * 4) + (angrt * 6) + (angfw * -1), self:GetPos() + (angup * 4) + (angrt * -6) + (angfw * -1), angup / 10 , angrt , angfw
	end
	
	

	--copied straight from the thruster code
	function ENT:DrawBoosterpackFire( posN , pos1 , pos2 , normal , angrt , angfw , scale )
		local scroll = 1000 + UnPredictedCurTime() * -12
		
		--the trace makes sure that the light or the flame don't end up inside walls
		--although it should be cached somehow, and only do the trace every tick
		
		local tracelength = 148 * scale
		
		
		if self:GetNextFlameTrace() < UnPredictedCurTime() or not self:GetLastFlameTrace() then
			local tr = {
				start = posN,
				endpos = posN + normal * tracelength,
				mask = MASK_OPAQUE,
				filter = {
					self:GetControllingPlayer(),
					self
				},
			}
			
			self:SetLastFlameTrace( util.TraceLine( tr ) )
			self:SetNextFlameTrace( UnPredictedCurTime() +  engine.TickInterval() )
		end
		
		local traceresult = self:GetLastFlameTrace()
		
		--what
		if not traceresult then
			return
		end
		
		-- traceresult.Fraction * ( 60 * scale ) / tracelength
		
		
		--TODO: fix the middle segment not being proportional to the tracelength ( and Fraction )
		
		--does the flame

		render.SetMaterial( self.MatFire )
		render.StartBeam( 3 )
			render.AddBeam( pos2, 8 * scale , scroll , self.BoosterpackFireBlue )
			render.AddBeam( pos2 + normal * 60 * scale , 32 * scale , scroll + 1, self.BoosterpackFireWhite )
			render.AddBeam( traceresult.HitPos + (angrt * -8) , 32 * scale , scroll + 3, self.BoosterpackFireNone )
		render.EndBeam()

		render.SetMaterial( self.MatFire )
		render.StartBeam( 3 )
			render.AddBeam( pos1, 8 * scale , scroll , self.BoosterpackFireBlue )
			render.AddBeam( pos1 + normal * 60 * scale , 32 * scale , scroll + 1, self.BoosterpackFireWhite )
			render.AddBeam( traceresult.HitPos + (angrt * 8) , 32 * scale , scroll + 3, self.BoosterpackFireNone )
		render.EndBeam()

	
		
		local light = DynamicLight( self:EntIndex() )
		
		if not light then
			return
		end
		
		light.Pos = traceresult.HitPos
		light.r = 0
		light.g = 25
		light.b = 255
		light.Brightness = 3
		light.Dir = normal
		light.InnerAngle = -45 --light entities in a cone
		light.OuterAngle = 45 --
		light.Size = 1000 * scale -- 125 when the scale is 0.25
		light.Style = 1	--this should do the flicker for us
		light.Decay = 1000
		light.DieTime = UnPredictedCurTime() + 1
	end


end

function ENT:HandleMainActivityOverride( ply , velocity )
	if self:GetActive() then
		local vel2d = velocity:Length2D()
		local idealact = ACT_INVALID
		
		if IsValid( ply:GetActiveWeapon() ) then
			idealact = ACT_MP_SWIM	--vel2d >= 10 and ACT_MP_SWIM or ACT_MP_SWIM_IDLE
		else
			idealact = ACT_HL2MP_IDLE + 9
		end
		
	
		
		return idealact , ACT_INVALID
	end
end

function ENT:HandleUpdateAnimationOverride( ply , velocity , maxseqgroundspeed )
	if self:GetActive() then
		ply:SetPlaybackRate( 0 )	--don't do the full swimming animation
		return true
	end
end

function ENT:OnRemove()

	if CLIENT then
		
		--if stopping the soundpatch doesn't work, stop the sound manually
		if self.BoosterpackSound then
			self.BoosterpackSound:Stop()
			self.BoosterpackSound = nil
		else
			self:StopSound( "Boosterpack.thruster_loop" )
		end
	
	//	self:RemoveWings()
		if self.BoosterpackParticleEmitter then
			self.BoosterpackParticleEmitter:Finish()
			self.BoosterpackParticleEmitter = nil
		end
	end
	
	BaseClass.OnRemove( self )
end