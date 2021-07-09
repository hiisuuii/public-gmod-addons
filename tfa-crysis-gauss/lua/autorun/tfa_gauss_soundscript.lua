--this part is for making kill icons
local icol = Color( 255, 255, 255, 255 ) 
if CLIENT then

	killicon.Add(  "test_rifle",		"vgui/hud/test_rifle", icol  )
	--			weapon name			location of weapon's kill icon, I just used the hud icon

end


--Sounds
sound.Add({
	name = 			"gauss_fire",
	channel = 		CHAN_USER_BASE+10, --see how this is a different channel? Gunshots go here
	volume = 		1.0,
	sound = 			"weapons/snipgauss/awp1.wav"
})

sound.Add({
	name = 			"draw",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/snipgauss/draw.wav"
})

sound.Add({
	name = 			"boltback",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/snipgauss/boltback.wav"
})

sound.Add({
	name = 			"clipin",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/snipgauss/clipin.wav"
})

sound.Add({
	name = 			"clipout",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/snipgauss/clipout.wav"
})

sound.Add({
	name = 			"boltforward",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/snipgauss/boltforward.wav"
})