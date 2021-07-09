TOOL.Category = "Ace's Tools"
TOOL.Name = "Hologram Maker"
TOOL.Command = nil
TOOL.ConfigName = ""

if(CLIENT) then
	language.Add("tool.hologramtool.name","Hologram Maker")
	language.Add("tool.hologramtool.desc","Enable/Disable hologram FX on an entity")
	language.Add("tool.hologramtool.0","Left click to enable/disable hologram FX for the entity you're looking at. Right click to enable/disable hologram FX for yourself.")
	
	function TOOL.BuildCPanel(pnl)
		pnl:AddControl("Header",{Text = "Hologram Tool",Description = [[Left-Click to enable/disable hologram FX for the entity you're looking at.
		Right click to enable/disable hologram FX for yourself.
		]]})
	end
end
Hologram = Hologram or {}

Hologram.EntsCache = Hologram.EntsCache or {}

function TOOL:LeftClick(tr)
	--if(CLIENT) then return true end
	local bIsHologram = tr.Entity:GetNWBool("entIsHologram")

	if(tr.Entity:IsValid() && !tr.Entity:IsWorld()) then
		if ( !bIsHologram ) then
			tr.Entity:SetNWBool("entIsHologram", true)
			Hologram.EntsCache[tr.Entity:EntIndex()] = true
		else
			tr.Entity:SetNWBool("entIsHologram", false)
			Hologram.EntsCache[tr.Entity:EntIndex()] = nil

		end
		if SERVER then
			local l = "notification.AddLegacy(\"" .. (bIsHologram && "Disabled " || "Enabled ") .. "hologram FX for \" .. SQLStr(language.GetPhrase(\"#" .. tr.Entity:GetClass() .. "\")) .. \".\",0,5);"
			l = l .. "surface.PlaySound(\"buttons/button14.wav\")"
			self:GetOwner():SendLua(l)
		end
		return true
	end
end

function TOOL:RightClick(tr)
	--if(CLIENT) then return true end
	local owner = self:GetOwner()
	local bIsHologram = owner:GetNWBool("entIsHologram")

	if ( !bIsHologram ) then
		owner:SetNWBool("entIsHologram", true)
		Hologram.EntsCache[owner:EntIndex()] = true

	else
		owner:SetNWBool("entIsHologram", false)
		Hologram.EntsCache[owner:EntIndex()] = nil
	end

	if SERVER then
		local l = "notification.AddLegacy(\"" .. (bIsHologram && "Disabled " || "Enabled ") .. "hologram FX for " .. SQLStr(owner:GetName()) .. ".\",0,5);"
		l = l .. "surface.PlaySound(\"buttons/button14.wav\")"
		owner:SendLua(l)
	end
	return false
end