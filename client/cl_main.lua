local QBCore = exports['qb-core']:GetCoreObject()

local washPed = nil
local washing = false

local AlertCops = function()
    TriggerServerEvent('police:server:policeAlert', 'Suspicious Hand-off')
end

local CreatePed = function(coords)
	if washPed ~= nil then return end
	local model = Config.Peds[math.random(#Config.Peds)]
	local hash = GetHashKey(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
	washPed = CreatePed(5, hash, coords.x, coords.y, coords.z-1, coords.w, true, true)
	while not DoesEntityExist(washPed) do Wait(10) end
	ClearPedTasks(washPed)
    ClearPedSecondaryTask(washPed)
    TaskSetBlockingOfNonTemporaryEvents(washPed, true)
    SetPedFleeAttributes(washPed, 0, 0)
    SetPedCombatAttributes(washPed, 17, 1)
    SetPedSeeingRange(washPed, 0.0)
    SetPedHearingRange(washPed, 0.0)
    SetPedAlertness(washPed, 0)
    SetPedKeepTask(washPed, true)
	FreezeEntityPosition(washPed, true)
    SetEntityInvincible(washPed, true)
	exports['qb-target']:AddTargetEntity(washPed, {
		options = {
			{
				type = "client",
				event = "irp-moneywash:client:UseLaunderer",
				icon = 'fa-solid fa-circle',
				label = 'Talk To Stranger',
			}
		},
		distance = 2.0
	})
end

local CreateFenceLocation = function()
	local randomLoc = Config.Locations[math.random(#Config.Locations)]
    CreatePed(randomLoc)
end

CreateThread(function()
    CreateFenceLocation()
end)

RegisterNetEvent('irp-moneywash:client:UseLaunderer', function()
    local player = PlayerPedId()
    local chance = Config.AlertChance
    if washing then return end
    if Config.RequireCops then
        QBCore.Functions.TriggerCallback('irp-moneywash:server:CopCount', function(CurrentCops)
            if CurrentCops >= Config.CopCount then
                TriggerEvent('animations:client:EmoteCommandStart', {'point'})
                Wait(200)
                TriggerServerEvent('irp-moneywash:server:UseLaunderer')
                ClearPedTasks(player)
                washing = true
            else
                QBCore.Functions.Notify("Not enough cops on duty..", 'error')
            end
        end)
    else 
        TriggerEvent('animations:client:EmoteCommandStart', {'point'})
        Wait(200)
        TriggerServerEvent('irp-moneywash:server:UseLaunderer')
        ClearPedTasks(player)
        washing = true
    end
    if (chance >= math.random(1, 100)) then
        AlertCops()
    end
end)

RegisterNetEvent('irp-moneywash:client:PayPlayer', function(takeitem, amount)
    local timer = math.random(8,15) 
    QBCore.Functions.Progressbar('launderer_wait', "Wait for your laundry to finish..", timer*1000, false, true, {
        disableMovement = false, 
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'anim@amb@board_room@supervising@',
        anim = 'think_01_hi_amy_skater_01',
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent('irp-moneywash:server:PayPlayer', amount)
        washing = false
    end, function() -- Cancel
        TriggerServerEvent('irp-moneywash:server:AddItem', takeitem, 1)
        TriggerEvent('inventory:client:busy:status', false)
        QBCore.Functions.Notify("Canceled..", "error")
        washing = false
    end) 
end)