# RP HUD System

A modern, customizable HUD system for FiveM roleplay servers featuring real-time player information, server status, and administrative controls.

## Features

- **Player Information**: Display player ID, health, armor, voice status
- **Server Status**: AOP (Area of Play), Peacetime status, Priority information
- **Multiple Styles**: Choose between original and modern HUD styles
- **Customizable**: Accent colors and user preferences
- **Administrative Controls**: Commands for managing server status
- **Export Functions**: Easy integration with other resources

## Installation

1. Place the `rphud` folder in your `resources/[custom]/` directory
2. Add `ensure rphud` to your `server.cfg`
3. Configure permissions (see below)
4. Restart your server

## Permissions Setup

Add these permissions to your `server.cfg` to allow administrators to use HUD commands:

```cfg
# HUD System Permissions
add_ace group.admin rphud.aop allow
add_ace group.admin rphud.peacetime allow
add_ace group.admin rphud.priority allow
```

### Permission Breakdown

- `rphud.aop` - Allows changing Area of Play
- `rphud.peacetime` - Allows toggling peacetime status
- `rphud.priority` - Allows managing priority status

## Commands

### Administrative Commands

- `/aop [text]` - Set the Area of Play
- `/peacetime [on/off]` - Toggle peacetime status
- `/prio [bc/ls] [on/off]` - Set priority status for BC or LS

### User Commands

- `/hudmenu` - Open the HUD menu

## Configuration

Edit `config.lua` to customize:

- Default server data (AOP, peacetime, etc.)
- HUD update intervals
- Voice system integration
- Map settings
- Style preferences

## Exports

### Client-Side Exports

#### Get Player Data
```lua
local playerData = exports['rphud']:getPlayerData()
```
Returns current player data including name, ID, headtag, postal, direction, AOP, and peacetime status.

#### Set Headtag
```lua
exports['rphud']:setHeadtag("LSPD | Officer")
```
Sets the player's headtag display.

#### Toggle HUD
```lua
exports['rphud']:toggleHUD(true)  -- Show HUD
exports['rphud']:toggleHUD(false) -- Hide HUD
```
Controls HUD visibility.

#### Update Postal
```lua
exports['rphud']:updatePostal("252")
```
Manually updates the postal code display.

### Server-Side Exports

#### Get Server Data
```lua
local serverData = exports['rphud']:getServerData()
```
Returns server data with AOP and peacetime status.

#### Set AOP
```lua
exports['rphud']:setAOP("Sandy Shores")
```
Changes the Area of Play for all players.

#### Set Peacetime
```lua
exports['rphud']:setPeacetime(true)  
exports['rphud']:setPeacetime(false) 
```
Controls peacetime status.

## Integration Examples

### ESX Integration
```lua
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    local headtag = string.format("%s | %s", job.label, job.grade_label)
    exports['rphud']:setHeadtag(headtag)
end)
```

### QBCore Integration
```lua
RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    local headtag = string.format("%s | %s", JobInfo.label, JobInfo.grade.name)
    exports['rphud']:setHeadtag(headtag)
end)
```

## Dependencies

- `ox_lib` - Required for notifications and UI components
- `oxmysql` - Required for database operations

## Database

The system automatically creates a `rphud_preferences` table to store user preferences including HUD style and accent color.

## Troubleshooting

### Common Issues

1. **HUD not showing**: Check if the resource is started and permissions are set correctly
2. **Commands not working**: Verify permissions in `server.cfg`
3. **Database errors**: Ensure `oxmysql` is installed and configured
4. **Style not saving**: Check database connection and table creation

### Support

For issues or feature requests, check the resource documentation or contact the development team.

## License

This resource is provided as-is for FiveM roleplay servers. Please respect the original author's work.

---
![Speedometer 1](https://i.postimg.cc/mrLggtJT/image.png)
![Speedometer 2](https://i.postimg.cc/7LKYGqr0/image.png)
![Speedometer 3](https://i.postimg.cc/MHQWFRMm/image.png)


**Version**: 2.0.0  
**Author**: Luckyz  
**Description**: Advanced FiveM HUD System
