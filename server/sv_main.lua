local QBCore = exports['qb-core']:GetCoreObject()

local washing = false
local CurrentCops = 0

QBCore.Functions.CreateCallback('irp-moneywash:server:CopCount', function(source, cb)
    for k, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == "police"  then
            CurrentCops = CurrentCops+1
        end
    end
    cb(CurrentCops)
end)

RegisterServerEvent('irp-moneywash:server:RemoveItem', function(item, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item, tonumber(amount)) then
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove', amount)
    end
end)

RegisterServerEvent('irp-moneywash:server:AddItem', function(item, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.AddItem(item, tonumber(amount)) then
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add', amount)
    end
end)

RegisterServerEvent('irp-moneywash:server:UseLaunderer', function()
    local pData = QBCore.Functions.GetPlayer(source)
    local takeitem = "markedbills"
    if pData.Functions.GetItemByName(takeitem) ~= nil then
        for k, v in pairs(pData.PlayerData.items) do
            if v.name == takeitem then
                if type(v.info) ~= 'string' and tonumber(v.info.worth) then
                    local amount = tonumber(v.info.worth)
                    pData.Functions.RemoveItem(takeitem, 1)
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[takeitem], 'remove')
                    TriggerClientEvent('QBCore:Notify', source, 'You handed over $'..tostring(amount)..' in marked bills!', "success", 2500)
                    TriggerClientEvent('irp-moneywash:client:PayPlayer', source, takeitem, amount)
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'You dont have any marked bills with you..', 'error', 2500)
    end
end)

RegisterServerEvent('irp-moneywash:server:PayPlayer', function(amount)
    local pData = QBCore.Functions.GetPlayer(source)
    if CurrentCops ~= nil then
        percent = Config.ReturnPercent
    elseif CurrentCops >= 1 and CurrentCops <= 3 then
         percent = Config.ReturnPercent+0.15         -- Use if you want to scale payment based on cop count, caution when using this
    elseif CurrentCops <= 3 and CurrentCops >= 5 then
         percent = Config.ReturnPercent+0.30
    elseif CurrentCops >= 7 then
         percent = Config.ReturnPercent+0.45
    end
    local pay = math.floor(amount*percent)
    local moneytype = Config.ReturnType
    pData.Functions.AddMoney(moneytype, pay, 'money-fence')
    TriggerClientEvent('QBCore:Notify', source, 'You received $'..tostring(pay)..'!', 'success', 'success', 2500)
    return
end)