if CLIENT then
surface.CreateFont("WaypointMarkerFont", {
	font = "Trebuchet MS",
	outline = true,
	size = 26
	
})
end


hook.Add("HUDPaint", "Sparks_Macrobinoculars_DrawWaypoints", function ()

	local waypoints = ents.FindByClass("waypoint_marker")
	for k,v in ipairs(waypoints) do

		local point = v:GetPos() + v:OBBCenter() //bruh
		
		local opacity = (point:DistToSqr(LocalPlayer():GetPos()))^2 //cancer
		//print(opacity)
		//print(opacity/4)
		local fade = math.Clamp(((opacity/4)/100)*125, 0, 125) //makes shit fade in/out as you get closer/further
		//print(fade)
		local wp_colors = { //this is pretty fucking bad but also i dont care because it works
		[1] = Color(255,0,0,fade),
		[2] = Color(0,255,0,fade),
		[3] = Color(0,0,255,fade),
		[4] = Color(255,255,0,fade),
		[5] = Color(255,0,255,fade),
		["black"] = Color(0,0,0,fade)
		}

		

		//if opacity/4 > 100 then
			local scale = math.Clamp( ( (point:DistToSqr(LocalPlayer():GetPos())) / 500)^2, 15, 20) //dist2sqr is annoying
			local point2D = point:ToScreen()
			point2D.x = math.Clamp(point2D.x, 0, ScrW())
			point2D.y = math.Clamp(point2D.y, 0, ScrH())
			point2D.visible = true
			local diamond = { //fuck you clockwise ordering
				{x = point2D.x + 0*scale, y = point2D.y + 1*scale}, --up
				{x = point2D.x + 1*scale, y = point2D.y + 0*scale}, --right
				{x = point2D.x + 0*scale, y = point2D.y - 1*scale}, --down
				{x = point2D.x - 1*scale, y = point2D.y + 0*scale} --left
			}
			local border = {
				{x = point2D.x + 0*scale, y = point2D.y + 1.2*scale}, --up
				{x = point2D.x + 1.2*scale, y = point2D.y + 0*scale}, --right
				{x = point2D.x + 0*scale, y = point2D.y - 1.2*scale}, --down
				{x = point2D.x - 1.2*scale, y = point2D.y + 0*scale} --left
			}

			surface.SetDrawColor(wp_colors["black"])
			surface.DrawPoly(border) 
			surface.SetDrawColor(wp_colors[v:GetColorType()])
			surface.DrawPoly(diamond) //people having issues with this one specifically not working but i have no fucking clue why so suck my nuts
			draw.SimpleText(v:GetWaypointName(), "WaypointMarkerFont", point2D.x, point2D.y + -16-(1*scale), Color(255,255,255,fade),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		end

	//end


end)