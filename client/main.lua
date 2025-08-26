local isHudVisible = Config.HUD.enabled
local playerData = {
    name = "",
    id = 0,
    headtag = "",
    postal = "000",
    street = "Unknown Street",
    direction = "N",
    aop = Config.DefaultData.aop,
    peacetime = Config.DefaultData.peacetime,
    priority = "BC OFF",
    discord = Config.DefaultData.discord,
    health = 100,
    armor = 0,
    stamina = 100,
    voiceStatus = {
        talking = false,
        micEnabled = true,
        range = 1
    },
    vehicle = {
        inVehicle = false,
        speed = 0,
        fuel = 100,
        engine = 1000,
        name = "",
        gear = 1,
        rpm = 0
    }
}

local mapData = {
    x = Config.Map.x,
    y = Config.Map.y,
    width = Config.Map.size,
    height = Config.Map.size
}

local speedometerVisible = true

-- Load postals from JSON file
Citizen.CreateThread(function()
    local postalsFile = LoadResourceFile(GetCurrentResourceName(), 'postals.json')
    if postalsFile then
        local postalsData = json.decode(postalsFile)
        if postalsData then
            Config.Postals = postalsData
            print('[HUD] Loaded ' .. #Config.Postals .. ' postals from postals.json')
        else
            print('[HUD] Error: Failed to decode postals.json')
        end
    else
        print('[HUD] Error: postals.json not found')
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    
    TriggerServerEvent('rphud:loadUserPreferences')
    TriggerServerEvent('hud:requestServerData')
    
    SendNUIMessage({
        action = 'initSpeedometer'
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        HideHudComponentThisFrame(1)
        HideHudComponentThisFrame(2)
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(4)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(13)
        HideHudComponentThisFrame(11)
        HideHudComponentThisFrame(12)
        HideHudComponentThisFrame(15)
        HideHudComponentThisFrame(18)
        HideHudComponentThisFrame(21)
        HideHudComponentThisFrame(22)
        
        if not Config.Map.enabled then
            DisplayRadar(false)
        else
            DisplayRadar(true)
        end
    end
end)

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

function GetMinimapAnchor()
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    Minimap.center_x = Minimap.left_x + (Minimap.width / 2)
    Minimap.center_y = Minimap.top_y + (Minimap.height / 2)
    return Minimap
end

Citizen.CreateThread(function()
    local userSettings = loadUserSettings()
    if userSettings.accentColor and userSettings.hudStyle then
        Config.Styles.current = userSettings.hudStyle
        if Config.Styles.available[userSettings.hudStyle] then
            Config.Styles.available[userSettings.hudStyle].accentColor = userSettings.accentColor
        end
        
        SendNUIMessage({
            action = 'updateStyle',
            style = userSettings.hudStyle,
            accentColor = userSettings.accentColor
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.UpdateInterval)
        
        if Config.HUD.enabled then
            local player = PlayerId()
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            
            playerData.name = GetPlayerName(player)
            playerData.id = GetPlayerServerId(player)
            
            local heading = GetEntityHeading(ped)
            playerData.direction = getCardinalDirection(heading)
            
            if Config.HUD.showPostal then
                playerData.postal, playerData.street = getClosestPostal(coords)
            end
            
            if Config.HUD.showHealth then
                local health = GetEntityHealth(ped)
                local maxHealth = GetEntityMaxHealth(ped)
                playerData.health = math.max(0, math.floor(((health - 100) / (maxHealth - 100)) * 100))
                if playerData.health < 0 then playerData.health = 0 end
            end
            
            if Config.HUD.showArmor then
                playerData.armor = GetPedArmour(ped)
            end
            
            if Config.HUD.showStamina then
                playerData.stamina = math.floor(GetPlayerStamina(player))
            end
            
            if Config.HUD.showVoiceStatus and Config.Voice.enabled then
                if GetResourceState('pma-voice') == 'started' then
                    local success, isTalking = pcall(function()
                        return exports['pma-voice']:getPlayerTalkingState(player)
                    end)
                    
                    local success2, voiceMode = pcall(function()
                        return exports['pma-voice']:getPlayerVoiceMode(player)
                    end)
                    
                    playerData.voiceStatus = {
                        talking = (success and isTalking) or false,
                        micEnabled = true,
                        range = (success2 and voiceMode) or 1
                    }
                else
                    playerData.voiceStatus = {
                        talking = false,
                        micEnabled = true,
                        range = 1
                    }
                end
            end
            
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle and vehicle ~= 0 then
                playerData.vehicle.inVehicle = true
                playerData.vehicle.speed = math.ceil(GetEntitySpeed(vehicle) * 2.237)
                playerData.vehicle.fuel = math.max(0, math.min(100, GetVehicleFuelLevel(vehicle)))
                playerData.vehicle.engine = math.max(0, math.min(100, math.floor(GetVehicleEngineHealth(vehicle) / 10)))
                playerData.vehicle.name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                playerData.vehicle.gear = GetVehicleCurrentGear(vehicle)
                playerData.vehicle.rpm = GetVehicleCurrentRpm(vehicle)
                playerData.vehicle.licensePlate = GetVehicleNumberPlateText(vehicle)
                playerData.vehicle.seatbelt = false
                playerData.vehicle.engineOn = GetIsVehicleEngineRunning(vehicle)
                local lightsState, highBeamsState = GetVehicleLightsState(vehicle)
                playerData.vehicle.lights = lightsState == 1
                playerData.vehicle.needsRepair = GetVehicleEngineHealth(vehicle) < 300
                
                SendNUIMessage({
                    action = 'updateSpeedometer',
                    data = playerData.vehicle
                })
            else
                playerData.vehicle.inVehicle = false
                playerData.vehicle.speed = 0
                playerData.vehicle.fuel = 100
                playerData.vehicle.engine = 100
                
                SendNUIMessage({
                    action = 'updateSpeedometer',
                    data = playerData.vehicle
                })
            end
            
            local screenX, screenY = GetActiveScreenResolution()
            local minimapAnchor = GetMinimapAnchor()
            
            SendNUIMessage({
                action = 'updateHUD',
                data = {
                    player = playerData,
                    vehicle = playerData.vehicle,
                    minimap = minimapAnchor,
                    style = Config.Styles.current,
                    accentColor = Config.Styles.available[Config.Styles.current] and Config.Styles.available[Config.Styles.current].accentColor or '#ffffff'
                }
            })
        end
    end
end)

function getCardinalDirection(heading)
    if heading >= 337.5 or heading < 22.5 then
        return "N"
    elseif heading >= 22.5 and heading < 67.5 then
        return "NE"
    elseif heading >= 67.5 and heading < 112.5 then
        return "E"
    elseif heading >= 112.5 and heading < 157.5 then
        return "SE"
    elseif heading >= 157.5 and heading < 202.5 then
        return "S"
    elseif heading >= 202.5 and heading < 247.5 then
        return "SW"
    elseif heading >= 247.5 and heading < 292.5 then
        return "W"
    elseif heading >= 292.5 and heading < 337.5 then
        return "NW"
    end
    return "N"
end

function getClosestPostal(coords)
    local closest = "000"
    local closestName = "Unknown Street"
    local closestDist = 99999.0
    
    if not coords or type(coords) ~= "vector3" then
        coords = GetEntityCoords(PlayerPedId())
    end
    
    for _, postal in pairs(Config.Postals) do
        local postalCoords = vector3(postal.x, postal.y, 0.0)
        local dist = #(coords - postalCoords)
        if dist < closestDist then
            closestDist = dist
            closest = postal.code
        end
    end
    
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    if streetHash ~= 0 then
        closestName = GetStreetNameFromHashKey(streetHash)
    else
        closestName = "Unknown Street"
    end
    
    return closest, closestName
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if not IsAimCamActive() or not IsFirstPersonAimCamActive() then
            HideHudComponentThisFrame(14)
        end

        if IsHudComponentActive(1) then
            HideHudComponentThisFrame(1)
        end

        if IsHudComponentActive(6) then
            HideHudComponentThisFrame(6)
        end

        if IsHudComponentActive(7) then
            HideHudComponentThisFrame(7)
        end

        if IsHudComponentActive(9) then
            HideHudComponentThisFrame(9)
        end

        if IsHudComponentActive(0) and not IsPedInAnyVehicle(PlayerPedId(), true) then
            HideHudComponentThisFrame(0)
        end

        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        
        if Config.Map.enabled then
            SetRadarBigmapEnabled(false, false)
            SetRadarZoom(1100)
        end
        
        if isHudVisible then
            HideHudComponentThisFrame(2)
            HideHudComponentThisFrame(3)
            HideHudComponentThisFrame(4)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(11)
            HideHudComponentThisFrame(12)
            HideHudComponentThisFrame(13)
            HideHudComponentThisFrame(15)
            HideHudComponentThisFrame(18)
        end
    end
end)


if GetResourceState('pma-voice') == 'started' then
    local voiceRanges = {
        [1] = 'Whisper',
        [2] = 'Normal', 
        [3] = 'Shout'
    }
    
    AddEventHandler('pma-voice:setTalkingMode', function(mode)
        playerData.voiceStatus.range = voiceRanges[mode] or 'Normal'
    end)
    
    AddEventHandler('pma-voice:radioActive', function(talking)
        playerData.voiceStatus.talking = talking
    end)
    
    AddEventHandler('pma-voice:proximityActive', function(talking)
        playerData.voiceStatus.talking = talking
    end)
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(250)
            if exports['pma-voice'] then
                local isTalking = false
                local voiceMode = 2
                

                local success, result = pcall(function()
                    return exports['pma-voice']:getPlayerTalkingState(PlayerId())
                end)
                if success then
                    isTalking = result or false
                end
                

                local success2, result2 = pcall(function()
                    return exports['pma-voice']:getPlayerVoiceMode(PlayerId())
                end)
                if success2 then
                    voiceMode = result2 or 2
                end
                
                playerData.voiceStatus = {
                    talking = isTalking,
                    range = voiceRanges[voiceMode] or 'Normal'
                }
            end
        end
    end)
else
    playerData.voiceStatus = {
        talking = false,
        range = 'Normal'
    }
end



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(800)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

        if vehicle and DoesEntityExist(vehicle) then
            local driverPed = GetPedInVehicleSeat(vehicle, -1)

            if GetVehicleDoorLockStatus(vehicle) == 7 then
                SetVehicleDoorsLocked(vehicle, 2)
            end

            if driverPed and DoesEntityExist(driverPed) then
                SetPedCanBeDraggedOut(driverPed, false)
            end
        end
    end
end)

RegisterCommand("hud", function()
    isHudVisible = not isHudVisible
    SendNUIMessage({
        type = "toggleHUD",
        visible = isHudVisible
    })
    
    if isHudVisible then
        print("^2[HUD] ^7HUD enabled")
    else
        print("^1[HUD] ^7HUD disabled")
    end
end, false)

RegisterCommand("hudsettings", function()
    SendNUIMessage({
        type = "toggleSettings"
    })
    SetNuiFocus(true, true)
end, false)


RegisterNUICallback('closeSettings', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('focusSettings', function(data, cb)
    SetNuiFocus(data.focus, data.focus)
    cb('ok')
end)

TriggerEvent('chat:addSuggestion', '/hud', 'Toggle the HUD on/off')
TriggerEvent('chat:addSuggestion', '/hudstyle', 'Open HUD style selection menu')
TriggerEvent('chat:addSuggestion', '/aop', 'Set the Area of Play', {
    { name="area", help="Area name" }
})
TriggerEvent('chat:addSuggestion', '/peacetime', 'Toggle peacetime on/off', {
    { name="state", help="on/off (optional)" }
})


RegisterCommand('aop', function(source, args)
    local aopText = table.concat(args, ' ')
    if aopText == '' then
        aopText = Config.DefaultData.aop
    end
    
    pendingCommands = pendingCommands or {}
    pendingCommands['aop'] = {type = 'aop', data = aopText}
    
    TriggerServerEvent('rphud:checkPermission', 'aop')
end)

RegisterCommand('pt', function(source, args)
    local status = args[1]
    if not status then
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"[HUD]", "Usage: /pt [on/off/hold]"}
        })
        return
    end
    
    status = string.lower(status)
    if status == 'on' or status == 'off' or status == 'hold' then
        pendingCommands = pendingCommands or {}
        pendingCommands['peacetime'] = {type = 'peacetime', data = string.upper(status)}
        
        TriggerServerEvent('rphud:checkPermission', 'peacetime')
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"[HUD]", "Invalid status. Use: on/off/hold"}
        })
    end
end)

RegisterCommand('prio', function(source, args)
    local action = args[1]
    local type = args[2]
    
    if action and (action == 'bc' or action == 'ls') then
        if type and (type == 'on' or type == 'off' or type == 'hold') then
            pendingCommands = pendingCommands or {}
            pendingCommands['priority'] = {type = 'priority', action = action, data = type}
            
            TriggerServerEvent('rphud:checkPermission', 'priority')
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 0},
                multiline = true,
                args = {"[HUD]", "Usage: /prio [bc/ls] [on/off/hold]"}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"[HUD]", "Usage: /prio [bc/ls] [on/off/hold]"}
        })
    end
end)


local userPreferences = { accentColor = '#00d4ff', hudStyle = 'original' }
local preferencesLoaded = false

function loadUserSettings()
    if not preferencesLoaded then
        TriggerServerEvent('rphud:loadUserPreferences')
        return userPreferences
    end
    return userPreferences
end

function saveUserSettings(settings)
    userPreferences = settings
    TriggerServerEvent('rphud:saveUserPreferences', settings.hudStyle, settings.accentColor)
end


RegisterNetEvent('rphud:userPreferencesLoaded')
AddEventHandler('rphud:userPreferencesLoaded', function(hudStyle, accentColor)
    userPreferences = {
        hudStyle = hudStyle,
        accentColor = accentColor
    }
    preferencesLoaded = true
    

    local uiStyle = hudStyle
    if hudStyle == 'original' then
        uiStyle = 'og'
    end
    

    Config.Styles.current = uiStyle
    if Config.Styles.available[uiStyle] then
        Config.Styles.available[uiStyle].accentColor = accentColor
    end
    
    if uiStyle == 'new' then
        SendNUIMessage({
            action = 'switchHudStyle',
            style = 'new',
            accentColor = accentColor
        })
    else
        SendNUIMessage({
            action = 'updateStyle',
            style = uiStyle,
            accentColor = accentColor
        })
    end
    
    print(string.format('[RPHUD] Loaded user preferences: style=%s, color=%s', hudStyle, accentColor))
end)

function openHudMenu()
    local userSettings = loadUserSettings()
    
    lib.registerContext({
        id = 'hud_main_menu',
        title = 'HUD Settings',
        options = {
            {
                title = 'HUD Style',
                description = 'Change HUD layout style',
                icon = 'fas fa-desktop',
                onSelect = function()
                    openHudStyleMenu()
                end
            },
            {
                title = 'Accent Color',
                description = 'Change accent color for status text',
                icon = 'fas fa-palette',
                onSelect = function()
                    openAccentColorMenu()
                end
            },
            {
                title = 'Speedometer',
                description = 'Toggle speedometer visibility',
                icon = 'fas fa-tachometer-alt',
                onSelect = function()
                    toggleSpeedometer()
                end
            }
        }
    })
    
    lib.showContext('hud_main_menu')
end

RegisterCommand('hudmenu', function()
    openHudMenu()
end)

RegisterCommand('hudstyle', function()
    openHudMenu()
end)

function openHudStyleMenu()
    local userSettings = loadUserSettings()
    
    lib.registerContext({
        id = 'hud_style_menu',
        title = 'HUD Style Selection',
        menu = 'hud_main_menu',
        options = {
            {
                title = 'Original Style',
                description = 'Classic HUD layout',
                icon = 'fas fa-tv',
                onSelect = function()
                    setHudStyle('og')
                end
            },
            {
                title = 'New Style',
                description = 'Modern box-based layout',
                icon = 'fas fa-th-large',
                onSelect = function()
                    setHudStyle('new')
                end
            }
        }
    })
    
    lib.showContext('hud_style_menu')
end

function openAccentColorMenu()
    local userSettings = loadUserSettings()
    
    local input = lib.inputDialog('Accent Color Settings', {
        {
            type = 'color',
            label = 'Accent Color',
            description = 'Color for status text (Off, N/A, Discord, etc.)',
            default = userSettings.accentColor or '#00d4ff',
            required = true
        }
    })
    
    if input then
        local selectedAccent = input[1]
        
        local currentSettings = loadUserSettings()
        currentSettings.accentColor = selectedAccent
        
        if Config.Styles.available[Config.Styles.current] then
            Config.Styles.available[Config.Styles.current].accentColor = selectedAccent
        end
        
        saveUserSettings(currentSettings)
        
        SendNUIMessage({
            action = 'updateAccentColor',
            accentColor = selectedAccent
        })
        
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"[HUD]", "Accent color updated and saved to database!"}
        })
    end
end

function setHudStyle(style)
    local userSettings = loadUserSettings()
    

    local dbStyle = style
    if style == 'og' then
        dbStyle = 'original'
    end
    
    userSettings.hudStyle = dbStyle
    
    saveUserSettings(userSettings)
    
    SendNUIMessage({
        action = 'switchHudStyle',
        style = style,
        accentColor = userSettings.accentColor or '#00d4ff'
    })
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"[HUD]", "HUD style changed to: " .. (style == 'og' and 'Original' or 'New') .. " and saved to database!"}
    })
end

function toggleSpeedometer()
    SendNUIMessage({
        action = 'toggleSpeedometer'
    })
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"[HUD]", "Speedometer toggled!"}
    })
end



RegisterNetEvent("hud:syncAOP")
AddEventHandler("hud:syncAOP", function(aop)
    playerData.aop = aop
end)

RegisterNetEvent("hud:syncPeacetime")
AddEventHandler("hud:syncPeacetime", function(peacetime)
    playerData.peacetime = peacetime
end)


RegisterNetEvent('rphud:syncAOP')
AddEventHandler('rphud:syncAOP', function(aop)
    playerData.aop = aop
end)

RegisterNetEvent('rphud:syncPeacetime')
AddEventHandler('rphud:syncPeacetime', function(peacetime)
    playerData.peacetime = peacetime
end)

RegisterNetEvent('rphud:syncPriority')
AddEventHandler('rphud:syncPriority', function(priority)
    playerData.priority = priority
end)

RegisterNetEvent('rphud:syncHeadtag')
AddEventHandler('rphud:syncHeadtag', function(headtag)
    playerData.headtag = headtag
end)


RegisterNetEvent('rphud:permissionResult')
AddEventHandler('rphud:permissionResult', function(hasPermission)
    if not pendingCommands then return end
    
    for command, data in pairs(pendingCommands) do
        if hasPermission then
            if data.type == 'aop' then
                TriggerServerEvent('rphud:updateAOP', data.data)
            elseif data.type == 'peacetime' then
                TriggerServerEvent('rphud:updatePeacetime', data.data)
            elseif data.type == 'priority' then
                TriggerServerEvent('rphud:updatePriority', data.action, data.data)
            end
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"[HUD]", "You don't have permission to use this command."}
            })
        end
        break
    end
    
    pendingCommands = {}
end)

if Config.Exports.enabled then
    exports('getPlayerData', function()
        return playerData
    end)
    
    exports('setHeadtag', function(tag)
        playerData.headtag = tag or ""
        TriggerServerEvent('rphud:updateHeadtag', playerData.headtag)
    end)
    
    exports('toggleHUD', function(state)
        isHudVisible = state
        SendNUIMessage({
            type = "toggleHUD",
            visible = isHudVisible
        })
    end)
    
    exports('updatePostal', function(postal)
        playerData.postal = postal
    end)
end