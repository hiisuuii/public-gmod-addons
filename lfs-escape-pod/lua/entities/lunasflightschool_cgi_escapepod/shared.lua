
ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Republic Escape Pod"
ENT.Author = "Ace"
ENT.Information = ""
ENT.Category = "[LFS] Star Wars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/ace/sw/rh/escapepod.mdl"
ENT.AITEAM = 2

ENT.Mass = 1000
ENT.Inertia = Vector(70000,70000,70000)
ENT.Drag = 0.3

ENT.SeatPos = Vector( 75, 0, -31 )
ENT.SeatAng = Angle(0,-90,0)

ENT.RotorPos = Vector(0,0,0)
ENT.WingPos = Vector(100,0,0)
ENT.ElevatorPos = Vector(-300,0,0)
ENT.RudderPos = Vector(-300,0,0)

ENT.IdleRPM = 1
ENT.MaxRPM = 2500
ENT.LimitRPM = 3000

ENT.MaxVelocity = 1750
ENT.MaxPerfVelocity = 1250

ENT.MaxThrust = 23400

ENT.MaxTurnPitch = 842
ENT.MaxTurnYaw = 842
ENT.MaxTurnRoll = 400

ENT.MaxHealth = 1200

ENT.Stability = 0.24

ENT.MaxPrimaryAmmo = -1
ENT.MaxSecondaryAmmo = -1