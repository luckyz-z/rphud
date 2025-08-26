fx_version 'cerulean'
game 'gta5'

author 'Luckyz'
description 'Advanced FiveM HUD System'
version '2.0.0'

dependencies {
    'ox_lib',
    'oxmysql'
}
lua54 'yes'
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'ui/main.html'

files {
    'ui/main.html',
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/new.html',
    'ui/new.css',
    'ui/new.js',
    'ui/speedometer.html',
    'ui/speedometer.css',
    'ui/speedometer.js',
    'stream/rectmap.ytd',
    'postals.json'
}

data_file 'TEXTURE_FILE' 'stream/rectmap.ytd'