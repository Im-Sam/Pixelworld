outputLoading = false
playButtonPressSounds = true
printDebugInformation = false

vehicleSyncDistance = 150
envirementLightBrightness = 0.010
lightDelay = 25 -- Time in MS
flashDelay = 30

panelEnabled = true
panelType = "original"
panelOffsetX = 0.045
panelOffsetY = 0.023

-- https://docs.fivem.net/game-references/controls

shared = {
	horn = 86,
}

keyboard = {
	modifyKey = 61,
	stageChange = 167, -- F6
	guiKey = 97, -- NUMPAD +
	takedown = 96, -- NUMPAD -
	siren = {
		tone_one = 108, -- NUMPAD 4
		tone_two = 110, -- NUMPAD 5
		tone_three = 109, -- NUMPAD 6
	},
	pattern = {
		primary = 118, -- NUMPAD 9
		secondary = 111, -- NUMPAD 8
		advisor = 117, -- NUMPAD 7
	},
	warning = 161, -- TOP NUMBER ROW 7
	secondary = 162, -- TOP NUMBER ROW 8
	primary = 163, -- TOP NUMBER ROW 9 
}

controller = {
	modifyKey = 73,
	stageChange = 80,
	takedown = 74,
	siren = {
		tone_one = 173,
		tone_two = 85,
		tone_three = 172,
	},
}