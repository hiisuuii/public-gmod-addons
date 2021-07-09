if SERVER then
    hook.Add("PostPlayerDeath","Deathstick_reset_bools",function(ply)
        ply:SetNWBool("deathstick_hpboost",false)
        ply:SetNWBool("deathstick_speedchange", false)

        if(timer.Exists(ply:SteamID64().."_ds_speeduptimer")) then
            timer.Remove(ply:SteamID64().."_ds_speeduptimer")
        end

        if(timer.Exists(ply:SteamID64().."_ds_slowdowntimer")) then
            timer.Remove(ply:SteamID64().."_ds_slowdowntimer")
        end

        if(timer.Exists(ply:SteamID64().."_ds_hp_small")) then
            timer.Remove(ply:SteamID64().."_ds_hp_small")
        end

        if(timer.Exists(ply:SteamID64().."_ds_hp_big")) then
            timer.Remove(ply:SteamID64().."_ds_hp_big")
        end

    end)
end