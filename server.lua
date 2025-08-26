roleList = {
    "Trusted_Civ",  -- Trusted Civ (1)
    "Donator",      -- Donator (2)
    "Personal",     -- Personal (3)
    "Staff", 	    -- Staff (4)
    "T-Mod",	    -- T-Mod (5)
    "Mod", 			-- Mod (6)
    "Admin", 		-- Admin (7)
    "Management",   -- Management (8)
    "Owner", 		-- Owner (9)
}

RegisterNetEvent('Print:PrintDebug')
AddEventHandler('Print:PrintDebug', function(msg)
    -- Debugging disabled
    -- Example for future use:
    -- TriggerClientEvent('chatMessage', -1, "^7[^1Dead's Scripts^7] ^1DEBUG ^7" .. msg)
end)

RegisterNetEvent("DiscordWeaponPerms:CheckPerms")
AddEventHandler("DiscordWeaponPerms:CheckPerms", function()
    local src = source
    local identifierDiscord = nil
    for k, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, 8) == "discord:" then
            identifierDiscord = v
            break
        end
    end

    local hasPerms = {} -- Stores allowed role indexes
    if identifierDiscord then
        local roleIDs = exports.Dead_Discord_API:GetDiscordRoles(src)
        if roleIDs and type(roleIDs) == "table" then
            for i = 1, #roleList do
                for j = 1, #roleIDs do
                    if exports.Dead_Discord_API:CheckEqual(roleList[i], roleIDs[j]) then
                        table.insert(hasPerms, i)
                    end
                end
            end
        else
            print(GetPlayerName(src) .. " has not gotten their permissions (roleIDs == false or nil)")
        end
    end

    TriggerClientEvent('DiscordWeaponPerms:CheckPerms:Return', src, hasPerms)
end)
