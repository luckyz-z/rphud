Config = {}

Config.UpdateInterval = 100

Config.HUD = {
    enabled = true,
    showPostal = true,
    showDirection = true,
    showPlayerInfo = true,
    showAOP = true,
    showPeacetime = true,
    showHealth = true,
    showArmor = true,
    showVehicle = true,
    showSpeedometer = true,
    disableDefaultHealth = true,
    disableDefaultArmor = true,
    showStamina = true,
    showVoiceStatus = true
}

Config.Map = {
    enabled = true,
    size = 0.15,
    x = 0.0,
    y = 0.0,
    border = true,
    borderColor = {255, 255, 255, 150}
}

Config.DefaultData = {
    aop = "Los Santos",
    peacetime = false,
    discord = "discord.gg/sigmarizz"
}

Config.Permissions = {
    aop = "admin",
    peacetime = "admin"
}

Config.Postals = {}

Config.Exports = {
    enabled = true
}

Config.Voice = {
    enabled = true,
    resource = "pma-voice",
    showMicIcon = true,
    showTalkingIcon = true
}

Config.UI = {
    transparency = 0.8,
    fadeDistance = 100,
    fontFamily = "Inter",
    fontWeight = 900,
    borderStyle = {
        width = 3,
        color = {255, 255, 255, 230},
        radius = 12,
        shadow = true
    }
}

Config.Styles = {
    current = "og", 
    available = {
        ["og"] = {
            name = "Original Style",
            accentColor = {255, 255, 255}, 
            description = "Classic HUD layout with original positioning"
        },
        ["new"] = {
            name = "New Style", 
            accentColor = {0, 255, 255}, 
            description = "Modern HUD layout with updated positioning"
        }
    }
}