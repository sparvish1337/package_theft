local packageModel = `prop_cs_package_01` 

local function smashWindow(vehicle)
    local playerPed = PlayerPedId()


    SetVehicleDoorsLocked(vehicle, 2) 

    -- Get positions of the rear doors
    local rearRightDoorBone = GetEntityBoneIndexByName(vehicle, "door_pside_r") 
    local rearLeftDoorBone = GetEntityBoneIndexByName(vehicle, "door_dside_r")  

    local rightDoorPos = GetWorldPositionOfEntityBone(vehicle, rearRightDoorBone)
    local leftDoorPos = GetWorldPositionOfEntityBone(vehicle, rearLeftDoorBone)

    local playerPos = GetEntityCoords(playerPed)

    local distToRightDoor = #(playerPos - rightDoorPos)
    local distToLeftDoor = #(playerPos - leftDoorPos)

    local targetDoorPos
    local windowIndex

    if distToLeftDoor < distToRightDoor then
        targetDoorPos = leftDoorPos
        windowIndex = 2 
    else
        targetDoorPos = rightDoorPos
        windowIndex = 3 
    end

    local pos = GetEntityCoords(vehicle)
    local boneIndex = GetEntityBoneIndexByName(vehicle, "seat_dside_r")
    local package = CreateObject(packageModel, pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(package, vehicle, boneIndex, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, true, false, 2, true)


    Citizen.Wait(1000) 

    FreezeEntityPosition(playerPed, true)
    RequestAnimDict("veh@break_in@0h@p_m_one@")
    while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do
        Citizen.Wait(100)
    end


    TaskPlayAnim(playerPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 8.0, -8.0, 2000, 48, 0, false, false, false)


    Citizen.Wait(3000)


    SmashVehicleWindow(vehicle, windowIndex)

    FreezeEntityPosition(playerPed, false)



    Citizen.Wait(1000)
    ClearPedTasksImmediately(playerPed)

    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
    Citizen.Wait(5000)
    ClearPedTasksImmediately(playerPed) 

    DeleteEntity(package)

    TriggerServerEvent('package_theft:givePackage')
end

RegisterNetEvent('package_theft:playSmashAnimation')
AddEventHandler('package_theft:playSmashAnimation', function(vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    smashWindow(vehicle)
end)

exports.ox_target:addGlobalVehicle({
    {
        name = 'smash_window',
        icon = 'fa-solid fa-hand-fist',
        label = 'Smash Window & Steal Package',
        bones = { 'door_dside_r', 'door_pside_r' },
        onSelect = function(data)
            local vehicle = data.entity
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('package_theft:smashWindow', vehicleNetId)
        end
    }
}, {
    distance = 1.5
})
