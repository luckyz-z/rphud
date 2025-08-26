local serverData = {
    aop = Config.DefaultData.aop,
    peacetime = Config.DefaultData.peacetime,
    priority = {bc = "OFF", ls = "OFF"},
    headtag = ""
}


CreateThread(function()
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS rphud_preferences (
            license VARCHAR(50) PRIMARY KEY,
            hud_style VARCHAR(20) DEFAULT 'original',
            accent_color VARCHAR(7) DEFAULT '#00d4ff',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
end)

RegisterNetEvent("hud:updateAOP")
AddEventHandler("hud:updateAOP", function(aop)
    local source = source
    local playerName = GetPlayerName(source)
    
    if hasPermission(source, Config.Permissions.aop) then
        serverData.aop = aop
        TriggerClientEvent("hud:syncAOP", -1, aop)
        print(string.format("[HUD] %s changed AOP to: %s", playerName, aop))
    else
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"HUD", "You don't have permission to change AOP"}
        })
    end
end)

RegisterNetEvent("hud:updatePeacetime")
AddEventHandler("hud:updatePeacetime", function(peacetime)
    local source = source
    local playerName = GetPlayerName(source)
    
    if hasPermission(source, Config.Permissions.peacetime) then
        serverData.peacetime = peacetime
        TriggerClientEvent("hud:syncPeacetime", -1, peacetime)
        local status = peacetime and "ON" or "OFF"
        print(string.format("[HUD] %s turned Peacetime: %s", playerName, status))
    else
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"HUD", "You don't have permission to change Peacetime"}
        })
    end
end)

RegisterNetEvent("playerConnecting")
AddEventHandler("playerConnecting", function()
    local source = source
    
    Citizen.Wait(5000)
    
    TriggerClientEvent("hud:syncAOP", source, serverData.aop)
    TriggerClientEvent("hud:syncPeacetime", source, serverData.peacetime)
    local priorityString = string.format("BC %s | LS %s", serverData.priority.bc, serverData.priority.ls)
    TriggerClientEvent("rphud:syncPriority", source, priorityString)
    TriggerClientEvent("rphud:syncHeadtag", source, serverData.headtag)
end)

RegisterNetEvent("hud:requestServerData")
AddEventHandler("hud:requestServerData", function()
    local source = source
    TriggerClientEvent("hud:syncAOP", source, serverData.aop)
    TriggerClientEvent("hud:syncPeacetime", source, serverData.peacetime)
    local priorityString = string.format("BC %s | LS %s", serverData.priority.bc, serverData.priority.ls)
    TriggerClientEvent("rphud:syncPriority", source, priorityString)
    TriggerClientEvent("rphud:syncHeadtag", source, serverData.headtag)
end)


RegisterNetEvent('rphud:checkPermission')
AddEventHandler('rphud:checkPermission', function(command)
    local source = source
    local hasPermissionResult = hasPermission(source, command)
    TriggerClientEvent('rphud:permissionResult', source, hasPermissionResult)
end)


RegisterNetEvent('rphud:updateAOP')
AddEventHandler('rphud:updateAOP', function(aopText)
    local source = source
    local playerName = GetPlayerName(source)
    
    if hasPermission(source, 'aop') then
        serverData.aop = aopText
        TriggerClientEvent('rphud:syncAOP', -1, aopText)
        print(string.format('[HUD] %s changed AOP to: %s', playerName, aopText))
        
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'AOP Updated',
            description = 'Area of Play changed to: ' .. aopText,
            type = 'success',
            duration = 3000
        })
    end
end)

RegisterNetEvent('rphud:updatePeacetime')
AddEventHandler('rphud:updatePeacetime', function(peacetimeText)
    local source = source
    local playerName = GetPlayerName(source)
    
    if hasPermission(source, 'peacetime') then
        serverData.peacetime = peacetimeText
        TriggerClientEvent('rphud:syncPeacetime', -1, peacetimeText)
        print(string.format('[HUD] %s changed Peacetime to: %s', playerName, peacetimeText))
        
        local status = peacetimeText and "ON" or "OFF"
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Peacetime Updated',
            description = 'Peacetime is now: ' .. status,
            type = peacetimeText and 'inform' or 'warning',
            duration = 3000
        })
    end
end)

RegisterNetEvent('rphud:updatePriority')
AddEventHandler('rphud:updatePriority', function(action, type)
    local source = source
    local playerName = GetPlayerName(source)
    
    if hasPermission(source, 'priority') then
        serverData.priority = string.format('%s %s', action:upper(), type:upper())
        TriggerClientEvent('rphud:syncPriority', -1, serverData.priority)
        print(string.format('[HUD] %s changed Priority to: %s', playerName, serverData.priority))
        
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Priority Updated',
            description = 'Priority changed to: ' .. serverData.priority,
            type = 'inform',
            duration = 3000
        })
    end
end)

RegisterNetEvent('rphud:updateHeadtag')
AddEventHandler('rphud:updateHeadtag', function(headtagText)
    local source = source
    local playerName = GetPlayerName(source)
    
    serverData.headtag = headtagText
    TriggerClientEvent('rphud:syncHeadtag', source, headtagText)
    print(string.format('[HUD] %s changed Headtag to: %s', playerName, headtagText))
end)

RegisterCommand("setaop", function(source, args)
    if source == 0 then
        if #args > 0 then
            serverData.aop = table.concat(args, " ")
            TriggerClientEvent("hud:syncAOP", -1, serverData.aop)
            print(string.format("[HUD] Console changed AOP to: %s", serverData.aop))
        end
    end
end, true)

RegisterCommand("setpeacetime", function(source, args)
    if source == 0 then
        if #args > 0 then
            local state = args[1]:lower()
            serverData.peacetime = (state == "on" or state == "true" or state == "1")
            TriggerClientEvent("hud:syncPeacetime", -1, serverData.peacetime)
            local status = serverData.peacetime and "ON" or "OFF"
            print(string.format("[HUD] Console turned Peacetime: %s", status))
        end
    end
end, true)

function hasPermission(source, permission)
    if source == 0 then return true end
    

    if IsPlayerAceAllowed(source, 'rphud.' .. permission) or IsPlayerAceAllowed(source, 'group.admin') then
        return true
    end
    

    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        local playerGroup = QBCore.Functions.GetPermission(source)
        
    
        local permissionGroups = {
            aop = {'admin', 'god'},
            peacetime = {'admin', 'god', 'mod'},
            priority = {'admin', 'god', 'mod'}
        }
        
        if permissionGroups[permission] then
            for _, group in ipairs(permissionGroups[permission]) do
                if playerGroup == group then
                    return true
                end
            end
        end
        
        return false
    end
    

    return IsPlayerAceAllowed(source, 'group.admin')
end

function hasAcePermission(source, permission)
    return IsPlayerAceAllowed(source, permission)
end

RegisterCommand('pt', function(source, args, rawCommand)
    local player = source
    if hasAcePermission(player, "rphud.peacetime") or hasPermission(player) then
        if args[1] then
            local status = string.lower(args[1])
            if status == "on" or status == "off" or status == "hold" then
                serverData.peacetime = string.upper(status)
                TriggerClientEvent('rphud:syncPeacetime', -1, serverData.peacetime)
                
                TriggerClientEvent('ox_lib:notify', player, {
                    title = 'Peacetime Updated',
                    description = 'Peacetime set to: ' .. string.upper(status),
                    type = status == 'on' and 'inform' or (status == 'hold' and 'warning' or 'success'),
                    duration = 3000
                })
            else
                TriggerClientEvent('ox_lib:notify', player, {
                    title = 'Invalid Status',
                    description = 'Invalid status. Use: on/off/hold',
                    type = 'error',
                    duration = 3000
                })
            end
        else
            TriggerClientEvent('ox_lib:notify', player, {
                title = 'Invalid Usage',
                description = 'Usage: /pt [on/off/hold]',
                type = 'error',
                duration = 3000
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', player, {
            title = 'Permission Denied',
            description = 'You do not have permission to use this command.',
            type = 'error',
            duration = 3000
        })
    end
end, false)

RegisterCommand('aop', function(source, args, rawCommand)
    local player = source
    if hasAcePermission(player, "rphud.aop") or hasPermission(player) then
        if args[1] then
            local newAOP = table.concat(args, " ")
            serverData.aop = newAOP
            TriggerClientEvent('rphud:syncAOP', -1, newAOP)
            
            TriggerClientEvent('ox_lib:notify', player, {
                title = 'AOP Updated',
                description = 'Area of Play updated to: ' .. newAOP,
                type = 'success',
                duration = 3000
            })
        else
            TriggerClientEvent('ox_lib:notify', player, {
                title = 'Invalid Usage',
                description = 'Usage: /aop [location]',
                type = 'error',
                duration = 3000
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', player, {
            title = 'Permission Denied',
            description = 'You do not have permission to use this command.',
            type = 'error',
            duration = 3000
        })
    end
end, false)

RegisterCommand('prio', function(source, args, rawCommand)
    local player = source
    if hasAcePermission(player, "rphud.priority") or hasPermission(player) then
        if args[1] and args[2] then
            local department = string.lower(args[1])
            local status = string.lower(args[2])
            
            if department == "bc" or department == "ls" then
                if status == "on" or status == "off" or status == "hold" then
                    if not serverData.priority then
                        serverData.priority = {bc = "OFF", ls = "OFF"}
                    end
                    
                    if department == "bc" then
                        serverData.priority.bc = string.upper(status)
                    else
                        serverData.priority.ls = string.upper(status)
                    end
                    
                    local priorityString = string.format("BC %s | LS %s", serverData.priority.bc, serverData.priority.ls)
                    TriggerClientEvent('rphud:syncPriority', -1, priorityString)
                    
                    TriggerClientEvent('ox_lib:notify', player, {
                        title = 'Priority Updated',
                        description = string.upper(department) .. ' priority set to: ' .. string.upper(status),
                        type = 'inform',
                        duration = 3000
                    })
                else
                    TriggerClientEvent('ox_lib:notify', player, {
                        title = 'Invalid Status',
                        description = 'Invalid status. Use: on/off/hold',
                        type = 'error',
                        duration = 3000
                    })
                end
            else
                TriggerClientEvent('ox_lib:notify', player, {
                    title = 'Invalid Department',
                    description = 'Invalid department. Use: bc/ls',
                    type = 'error',
                    duration = 3000
                })
            end
        else
            TriggerClientEvent('ox_lib:notify', player, {
                title = 'Invalid Usage',
                description = 'Usage: /prio [bc/ls] [on/off/hold]',
                type = 'error',
                duration = 3000
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', player, {
            title = 'Permission Denied',
            description = 'You do not have permission to use this command.',
            type = 'error',
            duration = 3000
        })
    end
end, false)


RegisterNetEvent('rphud:saveUserPreferences')
AddEventHandler('rphud:saveUserPreferences', function(style, accentColor)
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then
        print('[RPHUD] Could not get license for player ' .. source)
        return
    end
    
    
    license = license:gsub('license:', '')
    
    exports.oxmysql:execute('INSERT INTO rphud_preferences (license, hud_style, accent_color) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE hud_style = VALUES(hud_style), accent_color = VALUES(accent_color), updated_at = CURRENT_TIMESTAMP', {
        license, style, accentColor
    }, function(affectedRows)
        if affectedRows then
            print(string.format('[RPHUD] Saved preferences for %s: style=%s, color=%s', license, style, accentColor))
        end
    end)
end)

RegisterNetEvent('rphud:loadUserPreferences')
AddEventHandler('rphud:loadUserPreferences', function()
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then
        print('[RPHUD] Could not get license for player ' .. source)
        TriggerClientEvent('rphud:userPreferencesLoaded', source, 'original', '#00d4ff')
        return
    end
    
    
    license = license:gsub('license:', '')
    
    exports.oxmysql:execute('SELECT hud_style, accent_color FROM rphud_preferences WHERE license = ?', {
        license
    }, function(result)
        if result and #result > 0 then
            local preferences = result[1]
            TriggerClientEvent('rphud:userPreferencesLoaded', source, preferences.hud_style, preferences.accent_color)
            print(string.format('[RPHUD] Loaded preferences for %s: style=%s, color=%s', license, preferences.hud_style, preferences.accent_color))
        else
    
            TriggerClientEvent('rphud:userPreferencesLoaded', source, 'original', '#00d4ff')
            print(string.format('[RPHUD] No preferences found for %s, using defaults', license))
        end
    end)
end)

if Config.Exports.enabled then
    exports('getServerData', function()
        return serverData
    end)
    
    exports('setAOP', function(aop)
        serverData.aop = aop
        TriggerClientEvent("hud:syncAOP", -1, aop)
    end)
    
    exports('setPeacetime', function(state)
        serverData.peacetime = state
        TriggerClientEvent("hud:syncPeacetime", -1, state)
    end)
end