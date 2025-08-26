--------------------------
--- DiscordWeaponPerms ---
--------------------------

-- Restricted weapons by role:
-- Index = role ID, array = restricted weapons/components
restrictedWeapons = {
    {}, -- Trusted Civ (1)
    {}, -- Donator (2)
    {}, -- Personal (3)
    {}, -- Staff (4)
    {}, -- T-Mod (5)
    {}, -- Mod (6)
    {"WEAPON_RPG"}, -- Admin (7)
    {}, -- Management (8)
    {
        "WEAPON_GRENADELAUNCHER", "WEAPON_STICKYBOMB", "WEAPON_GRENADE",
        "WEAPON_HOMINGLAUNCHER", "WEAPON_PROXMINE", "WEAPON_PIPEBOMB",
        "WEAPON_COMPACTLAUNCHER", "WEAPON_RAILGUN",
        "COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY",
        "COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY",
        "COMPONENT_PISTOL_MK2_CLIP_INCENDIARY",
        "COMPONENT_SMG_MK2_CLIP_INCENDIARY",
        "COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY",
        "COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE",
        "COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY",
        "COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY",
        "COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY",
        "COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY",
        "COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY",
        "COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY",
        "COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY",
        "COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE",
    } -- Owner (9)
}

-- Stores allowed role IDs for the player
isAllowed = {}

-- Prevent spam notifications
local lastNotify = 0
local notifyCooldown = 2000 -- milliseconds

-- Event: Server returns player permissions
RegisterNetEvent('DiscordWeaponPerms:CheckPerms:Return')
AddEventHandler('DiscordWeaponPerms:CheckPerms:Return', function(hasPerms)
    isAllowed = hasPerms
end)

-- Utility: check if value exists in table
function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

-- Utility: display notification
function DisplayNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Main check loop
Citizen.CreateThread(function()
    -- Trigger once at start to get permissions
    TriggerServerEvent("DiscordWeaponPerms:CheckPerms")

    while true do
        Citizen.Wait(500) -- check every 0.5s

        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)

        local restrictedStr, requiredPerm = nil, nil

        -- Check all restricted weapons and components
        for roleId, weaponList in ipairs(restrictedWeapons) do
            for _, wName in ipairs(weaponList) do
                local wHash = GetHashKey(wName)
                if wHash ~= 0 then
                    if weapon == wHash or HasPedGotWeaponComponent(ped, weapon, wHash) then
                        restrictedStr = wName
                        requiredPerm = roleId
                        break
                    end
                end
            end
            if requiredPerm then break end -- exit outer loop early
        end

        -- Remove restricted weapon if not allowed
        if requiredPerm and not has_value(isAllowed, requiredPerm) then
            local now = GetGameTimer()
            if now - lastNotify >= notifyCooldown then
                RemoveWeaponFromPed(ped, weapon)
                DisplayNotification("~r~Restricted: ~w~" .. restrictedStr)
                lastNotify = now
            end
        end
    end
end)
