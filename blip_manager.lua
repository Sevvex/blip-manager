local blips = {}
local menuOpen = false
local menu

function createBlip(coords, name)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    table.insert(blips, {blip = blip, name = name})
end

function deleteBlip(index)
    RemoveBlip(blips[index].blip)
    table.remove(blips, index)
end

function openMenu()
    menuOpen = true
    menu:Visible(true)
end

function closeMenu()
    menuOpen = false
    menu:Visible(false)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 56) then -- "B" key to toggle menu
            if not menuOpen then
                openMenu()
            else
                closeMenu()
            end
        end
    end
end)

Citizen.CreateThread(function()
    menu = NativeUI.CreateMenu("Blip Manager", "Verwalte deine Blips")
    _menuPool:Add(menu)

    menu.OnItemSelect = function(_, item, index)
        if item.Text == "Blip erstellen" then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            createBlip(coords, "Custom Blip " .. #blips + 1)
            Notify('Blip erstellt!')
        elseif item.Text == "Alle Blips löschen" then
            for i, blipData in ipairs(blips) do
                deleteBlip(i)
            end
            Notify('Alle Blips gelöscht!')
        end
    end

    local createBlipItem = NativeUI.CreateItem("Blip erstellen", "Erstelle einen neuen Blip an deiner Position.")
    menu:AddItem(createBlipItem)

    local deleteAllBlipsItem = NativeUI.CreateItem("Alle Blips löschen", "Lösche alle erstellten Blips.")
    menu:AddItem(deleteAllBlipsItem)

    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
    end
end)

function Notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end
