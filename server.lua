local QBCore = exports['qb-core']:GetCoreObject()

local brokenInto = {}

RegisterNetEvent('package_theft:smashWindow', function(vehicleNetId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    local plate = GetVehicleNumberPlateText(vehicle)
    
    if not brokenInto[plate] then

        brokenInto[plate] = true

        TriggerClientEvent('package_theft:playSmashAnimation', src, vehicleNetId)

        Citizen.Wait(5000)
        TriggerClientEvent('package_theft:givePackage', src)
    else
        TriggerClientEvent('QBCore:Notify', src, "This vehicle has already been broken into!", 'error')
    end
end)

RegisterNetEvent('package_theft:givePackage', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local randomCash = math.random(500, 1500)
        
        
        Player.Functions.AddMoney('cash', randomCash)
        
        TriggerClientEvent('QBCore:Notify', source, "You stole $" .. randomCash .. " in cash!", 'success')
        
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cash'], "add")
    end
end)
