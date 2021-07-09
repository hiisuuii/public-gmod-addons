local nextcheck = -1

hook.Add("Think", "NSN_GravityWell_Check", function()
    local ply
    if nextcheck < CurTime() then
        //print("checked gravity wells at "..CurTime()) // do not fucking reenable
        local wells = ents.FindByClass("nsn_gravity_well")
        if not table.IsEmpty(wells) then
            for k, v in pairs(player.GetAll()) do
                plypos = v:GetPos()
                ply = v

                for _, ent in pairs(wells) do
                    entpos = ent:GetPos()
                end
        
                if plypos:DistToSqr(entpos) < (500 * 500) then
                    ply.AffectedByGravityWell = true
                else
                    ply.AffectedByGravityWell = false
                end
            end
        end
        if table.IsEmpty(wells) then
            for k,v in pairs(player.GetAll()) do
                v.AffectedByGravityWell = false
            end
        end
        nextcheck = CurTime() + 0.66
    end
end)

hook.Add( "SetupMove", "NSN_GravityWell_Slowdown", function( ply, mv, cmd )
	if ply.AffectedByGravityWell then
        local speed = mv:GetMaxClientSpeed() / 1.7
		mv:SetMaxSpeed(speed)
        mv:SetMaxClientSpeed(speed)
        mv:SetVelocity(mv:GetVelocity()+Vector(0,0,-10))
    end
end )