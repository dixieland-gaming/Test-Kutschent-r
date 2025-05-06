local RSGCore = exports['rsg-core']:GetCoreObject()

local prisonWagons = {}

RegisterServerEvent("prisonwagon:setWagonNetId")
AddEventHandler("prisonwagon:setWagonNetId", function(netId)
    local src = source
    if netId then
        prisonWagons[src] = netId
    end
end)

RegisterServerEvent("prisonwagon:openDoors")
AddEventHandler("prisonwagon:openDoors", function(netId)
    if netId then
        TriggerClientEvent("prisonwagon:openDoorsClient", -1, netId)
    end
end)

RegisterServerEvent("prisonwagon:closeAndLockDoors")
AddEventHandler("prisonwagon:closeAndLockDoors", function(netId)
    if netId then
        TriggerClientEvent("prisonwagon:closeAndLockDoorsClient", -1, netId)
    end
end)

AddEventHandler("playerDropped", function(reason)
    local src = source
    if prisonWagons[src] then
        prisonWagons[src] = nil
    end
end)
