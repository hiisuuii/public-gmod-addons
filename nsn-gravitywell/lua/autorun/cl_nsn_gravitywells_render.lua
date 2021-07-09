if CLIENT then
	local fxmat1 = Material('models/shadertest/shader3')
	local fxmat2 = Material('models/props_combine/stasisshield_sheet')
	local blue_clr = Color(60,60,60,120)
	local radius = 500
	local quality = 32
	local wells_tbl = {}

	local function qc(t,p0,p1,p2)
		return (1-t)^2*p0+2*(1-t)*t*p1+t^2*p2
	end

	hook.Add("Tick","SWShieldGen",function()
		wells_tbl = {}
		for k,v in pairs (ents.FindByClass("nsn_gravity_well")) do
			if v:IsValid() then
				wells_tbl[#wells_tbl+1] = v
			end
		end
        //PrintTable(wells_tbl)
	end)

	hook.Add('PostDrawTranslucentRenderables','NSN_GravityWell_Rendering',function(bDepth,bSkybox)
		if bSkybox then return end
		for k,v in pairs(wells_tbl) do
			if !IsValid(v) then continue end
			local pos = v:GetPos()
			local vec1 = v:GetUp()
            
            local matrix = Matrix()
            matrix:Translate(v:GetPos()+(-v:GetUp()*32))
            matrix:SetAngles(v:GetAngles())
            matrix:Scale(Vector(1,1,0.7))

            cam.PushModelMatrix(matrix)

			render.SetColorMaterial()
			render.DrawSphere(Vector(0,0,0),radius,32,32,blue_clr)

			render.SetMaterial(fxmat1)
			render.OverrideBlend(true,2,1,BLENDFUNC_ADD)
			render.DrawSphere(Vector(0,0,0),radius,32,32)
			render.DrawSphere(Vector(0,0,0),-radius,32,32)
			render.OverrideBlend(false,2,1,BLENDFUNC_ADD)
            cam.PopModelMatrix()
            
		end
	end)
end