if SERVER then
	local validLevelsStr = "[1-5]$"
	local alertlevel = 1
	local setBy = "High Command"
	util.AddNetworkString("alertlevel_svtocl_senddata")
	//util.AddNetworkString("alertlevel_svtocl_broadcastlevel")

	local function BroadcastAlertLevelData()
		net.Start("alertlevel_svtocl_senddata")
		net.WriteInt(alertlevel, 4)
		net.WriteString(""..setBy)
		net.Broadcast()
	end

	hook.Add("PlayerInitialSpawn","Alertlevel_SendAlertData_OnSpawn", function(ply)
		timer.Simple(2, function()
			if ( !IsValid( ply ) ) then return end
			net.Start("alertlevel_svtocl_senddata")
			net.WriteInt(alertlevel, 4)
			net.WriteString(""..setBy)
			net.Send(ply)
		end)
	end)

	hook.Add("PlayerSay","Alertlevel_ChatCmd", function(ply,text)
		if(string.find(string.lower(text), "setalert")) != nil then
			if ply:IsAdmin() then
				if(string.StartWith(string.lower(text), "/setalert ")) then
					local matchedLevel = string.match(text, validLevelsStr)
					if(	matchedLevel != nil ) then
						alertlevel = tonumber(matchedLevel)
						setBy = ply:Nick()
						BroadcastAlertLevelData()
						PrintMessage(HUD_PRINTTALK, "Alert Level set to "..alertlevel.." by "..ply:Nick())
						return ""
					else return end
				end
			end
		end
	end)
end

if CLIENT then

	local function AlertFilledCircle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) -- This is needed for non absolute segment counts
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end

	local scrw = ScrW()
	local scrh = ScrH()
	surface.CreateFont("LevelFontBig", {
		font = "Trebuchet MS Bold",
		size = 72,
		antialias = true
	})
	surface.CreateFont("LevelFontMedium", {
		font = "Trebuchet MS Bold",
		size = 48,
		antialias = true
	})
	surface.CreateFont("LevelFontSmall", {
		font = "Trebuchet MS Bold",
		size = 24,
		antialias = true
	})


	local function RingRender(dx,dy,cr,cg,cb)
		-- Reset everything to known good
		render.SetStencilWriteMask( 0xFF )
		render.SetStencilTestMask( 0xFF )
		render.SetStencilReferenceValue( 0 )
		-- render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilPassOperation( STENCIL_KEEP )
		-- render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.ClearStencil()
		-- Enable stencils
		render.SetStencilEnable( true )
		-- Set everything up everything draws to the stencil buffer instead of the screen
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_NEVER )
		render.SetStencilFailOperation( STENCIL_REPLACE )
		-- Draw a weird shape to the stencil buffer
		draw.NoTexture()
		surface.SetDrawColor( color_white )
		AlertFilledCircle(scrw*(dx/1920),scrh*(dy/1080),scrw*(55/1920),64)
		render.SetStencilReferenceValue( 2 )
		render.SetStencilCompareFunction( STENCIL_NEVER )
		render.SetStencilFailOperation( STENCIL_REPLACE )
		draw.NoTexture()
		surface.SetDrawColor( color_white )
		AlertFilledCircle(scrw*(dx/1920),scrh*(dy/1080),scrw*(45/1920),64)
		-- Only draw things that are in the stencil buffer
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_EQUAL )
		render.SetStencilFailOperation( STENCIL_KEEP )
		-- Draw our clipped text
		draw.NoTexture()
		surface.SetDrawColor(cr,cg,cb,150)
		surface.DrawRect(0,0,scrw,scrh)
		-- Let everything render normally again
		render.SetStencilEnable( false )
	end

	local huetbl = {
	[0] = 359,
	[1] = 200,
	[2] = 120,
	[3] = 60,
	[4] = 30,
	[5] = 0,
	}

	local receivedLevel = 1
	local receivedSender = "High Command"
	local targetHue = huetbl[receivedLevel]
	local hue = huetbl[receivedLevel]
	local value = 1



	net.Receive("alertlevel_svtocl_senddata", function()
		receivedLevel = net.ReadInt(4)
		receivedSender = net.ReadString()
		targetHue = huetbl[receivedLevel]
	end)

	hook.Add("HUDPaint", "HUDPaint_Alertlevel_drawhud", function()

		surface.SetDrawColor(0,0,0,128)
		AlertFilledCircle(scrw*(75/1920),scrh*(75/1080),scrw*(60/1920),64)

		if hue != targetHue then
			hue = math.Approach(hue,targetHue,1)
		end
		//uncomment this block if you want to make level 5 be black instead of red
		/*if targetHue == 0 then
			if hue < 30 then
				value = math.Approach(value, 0, 0.01)
			end
		elseif value < 1 then
			value = math.Approach(value,1,0.01)
		end*/

		local clr = HSVToColor(hue,1,value)
		RingRender(scrw*(75/1920),scrh*(75/1080),clr.r,clr.g,clr.b)

		surface.SetFont("Trebuchet24")
		surface.SetTextColor(255,255,255)
		surface.SetTextPos(scrw*(75/1920),scrh*(75/1080))
		draw.SimpleTextOutlined(receivedLevel, "LevelFontBig", scrw*(75/1920),scrh*(75/1080),color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,color_black)
		draw.SimpleTextOutlined("Alert Level: "..receivedLevel, "LevelFontMedium", scrw*(150/1920),scrh*(75/1080),color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined("Set by: "..receivedSender, "LevelFontSmall", scrw*(150/1920),scrh*(75/1080),color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP, 1, color_black)
	end)
end