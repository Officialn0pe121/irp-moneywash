Config = {}

-- Fence Settings --

Config.Locations = { -- Sets random locations for fence ped to spawn at
    vector4(-1235.21, -232.77, 40.04, 342.15),
    vector4(-861.15, -355.99, 38.68, 24.34),
    vector4(-1601.48, 207.04, 59.26, 115.08),
    vector4(-2192.06, 281.26, 169.61, 295.26),
}
Config.Peds = { -- Sets random ped model for fence ped
	'a_f_y_vinewood_04',
	'a_m_m_golfer_01',
	'a_m_m_soucent_04',
}
Config.RequireCops = false -- Toggle if you want cops required
Config.CopCount = 0 -- Only use this if the above var is set to true
Config.AlertChance = 100 -- Police alert chance
Config.ReturnPercent = 0.8 -- % returned to player from washing money with fence
Config.ReturnType = "cash" -- "cash"/"bank"

-- End Fence Settings --