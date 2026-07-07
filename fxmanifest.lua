fx_version "bodacious"
game "gta5"
lua54 "yes"
author 'M-Westy'
description 'Capture os IDs de todas as roupas que seu personagem usa.'

ui_page "web-side/index.html"

client_scripts {
	"client-side/*"
}

server_scripts {
	"server-side/credits.lua",
	"server-side/core.lua"
}

files {
	"web-side/*"
}
