local PlayerData = {}

local ownerInit = false
local myIdentifier

AddEventHandler('QBCore:Client:OnPlayerLoaded', function() 
  TriggerServerEvent('qbx_skulrag_buyable_carwash:getOwners')
end)

RegisterNetEvent('qbx_skulrag_buyable_carwash:saveOwners')
AddEventHandler('qbx_skulrag_buyable_carwash:saveOwners', function(Owners, me)
    for k, v in pairs(Owners) do
        if (Config.Zones[v.name] ~= nil) then
            Config.Zones[v.name].Owner = v.owner
            Config.Zones[v.name].isForSale = v.isForSale
        end
    end
    myIdentifier = me
    ownerInit = true;
end)

RegisterNetEvent('qbx_skulrag_buyable_carwash:carwashBought')
AddEventHandler('qbx_skulrag_buyable_carwash:carwashBought', function(zone, owner)
    SetBlipColour(Config.Zones[zone].Washer.Blip, 2)
    Config.Zones[zone].Owner = owner
    Config.Zones[zone].isForSale = false
end)

RegisterNetEvent('qbx_skulrag_buyable_carwash:cancelSelling')
AddEventHandler('qbx_skulrag_buyable_carwash:cancelSelling', function(zone, owner)
    SetBlipColour(Config.Zones[zone].Washer.Blip, 2)
end)

RegisterNetEvent('qbx_skulrag_buyable_carwash:carwashForSale')
AddEventHandler('qbx_skulrag_buyable_carwash:carwashForSale', function(zone, price)
    SetBlipColour(Config.Zones[zone].Washer.Blip, 5)
    Config.Zones[zone].isForSale = true
end)

RegisterNetEvent('qbx_skulrag_buyable_carwash:clean')
AddEventHandler('qbx_skulrag_buyable_carwash:clean', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        -- Barre de progression
        lib.progressBar({
            duration = Config.Timer * 1000,
            label = 'Nettoyage du véhicule...',
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
        })
        
        -- Nettoyer le véhicule
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleDirtLevel(vehicle, 0.0)

        lib.notify({ type = 'success', description = 'Véhicule lavé avec succès !' })
    else
        lib.notify({ type = 'error', description = 'Vous devez être conducteur d’un véhicule.' })
    end
end)

function initBlips()
    while not ownerInit do
        Citizen.Wait(10)
    end
    for k, v in pairs(Config.Zones) do
      Config.Zones[k].Washer.Blip = AddBlipForCoord(v.Washer.Pos.x, v.Washer.Pos.y, v.Washer.Pos.z)
      SetBlipSprite(Config.Zones[k].Washer.Blip, 100)
      SetBlipDisplay(Config.Zones[k].Washer.Blip, 4)
      SetBlipScale(Config.Zones[k].Washer.Blip, Config.Blip.Scale)
      if v.isForSale or v.Owner == '' or v.Owner == nil then
        SetBlipColour(Config.Zones[k].Washer.Blip, 5)
      else
        SetBlipColour(Config.Zones[k].Washer.Blip, 2)
      end
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(Lang:t('carwash_blip'))
      EndTextCommandSetBlipName(Config.Zones[k].Washer.Blip)
      SetBlipAsShortRange(Config.Zones[k].Washer.Blip, true)
    end
    Citizen.Wait(500)
    ownerInit = false
end

function OpenBuyMenu(zone)
  local elements = {}
  
  local isForsale, price = lib.callback.await('qbx_skulrag_buyable_carwash:isforsale', false, zone)
  if isForsale then
    table.insert(elements, {
      title = Lang:t('buy_carwash', {price}),
      onSelect = function() TriggerServerEvent('qbx_skulrag_buyable_carwash:buy_carwash', zone) end
    })
  end

  lib.registerContext({
    id = 'qbx_skulrag_carwash_buy_menu',
    title = Lang:t('carwash_blip'),
    options = elements
  })
  lib.showContext('qbx_skulrag_carwash_buy_menu')
end

function OpenProprioMenu(zone)
  local waiting = true
  local elements = {}

  local isForsale, price = lib.callback.await('qbx_skulrag_buyable_carwash:isforsale', false, zone)

  if isForsale then
    table.insert(elements, { 
      title = Lang:t('cancel_selling'),
      icon = 'fa-solid fa-xmark',
      onSelect = function () TriggerServerEvent('qbx_skulrag_buyable_carwash:cancelselling', zone) end
    })
  elseif not isForsale then
    local accountMoney = lib.callback.await('qbx_skulrag_buyable_carwash:getAccountMoney', zone)
    table.insert(elements, {
      title = (Lang:t('stored_money') .. '<span style="color:green;">%s</span>'):format(accountMoney),
      description = Lang:t('withdraw_money'),
      onSelect = function () TriggerServerEvent('qbx_skulrag_buyable_carwash:withdrawMoneyFromStation', zone) end
    })
    table.insert(elements, {
      title = Lang:t('put_forsale'),
      onSelect = function () TriggerServerEvent('qbx_skulrag_buyable_carwash:putforsale', zone, Config.ForceSellPrice) end
    })
  end

  lib.registerContext({
    id = 'qbx_skulrag_carwash_manage_menu',
    title = Lang:t('shop_proprio'),
    options = elements
  })
  lib.showContext('qbx_skulrag_carwash_manage_menu')
end

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
        -- Optionnel : background rectangle
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
    end
end

-- Create Blips
Citizen.CreateThread(function()
    TriggerServerEvent('qbx_skulrag_buyable_carwash:getOwners')
    initBlips()
end)

CreateThread(function()
    while not ownerInit do
      Citizen.Wait(10)
    end
    for zoneName, data in pairs(Config.Zones) do
        lib.zones.box({
            coords = data.Manage.Pos,
            size = Config.Manage.MarkerSize,
            rotation = 0.0,
            debug = false,
            onEnter = function()
              if Config.Zones[zoneName].Owner == myIdentifier then
                lib.showTextUI('[E] Gérer la station de lavage')
              elseif Config.Zones[zoneName].isForSale then
                lib.showTextUI('[E] Acheter la station de lavage')
              end
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustReleased(0, 38) then -- touche E
                    -- Ouvre ton menu ou déclenche ton action
                    if Config.Zones[zoneName].Owner == myIdentifier then
                      OpenProprioMenu(zoneName)
                    elseif Config.Zones[zoneName].isForSale then
                      OpenBuyMenu(zoneName)
                    end
                end
            end
        })

         -- WASH ZONE 
        lib.zones.box({
            coords = data.Washer.Pos,
            size = Config.Washer.MarkerSize,
            rotation = 1.0,
            debug = false,
            onEnter = function()
                lib.showTextUI('[E] Laver le véhicule')
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustReleased(0, 38) then
                  local playerPed = PlayerPedId()
                  local vehicle = GetVehiclePedIsIn(playerPed, false)

                  if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    local dirt = GetVehicleDirtLevel(vehicle)
                    if dirt == 0 then
                      lib.notify({ type = 'info', description = 'Votre vehicule n\'est pas sale' })
                    else
                      local basePrice = Config.BaseWashPrice
                      local totalPrice = math.floor(basePrice + dirt)
                    
                      TriggerServerEvent('qbx_skulrag_buyable_carwash:checkMoneyForWash', totalPrice, zoneName)
                    end
                  else
                    lib.notify({ type = 'error', description = 'Vous devez être conducteur d’un véhicule.' })
                  end
                end
            end
        })
    end
end)

-- Display markers
Citizen.CreateThread(function()
  while not ownerInit do
    Citizen.Wait(10)
  end
	while true do
		Citizen.Wait(1)
    local coords, letSleep = GetEntityCoords(PlayerPedId()), true

    for k,v in pairs(Config.Zones) do
	     if Config.Washer.MarkerType ~= -1 and #(coords - v.Washer.Pos) < Config.DrawDistance then
         DrawMarker(Config.Washer.MarkerType, v.Washer.Pos.x, v.Washer.Pos.y, v.Washer.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Washer.MarkerSize.x, Config.Washer.MarkerSize.y, Config.Washer.MarkerSize.z, Config.Washer.MarkerColor.r, Config.Washer.MarkerColor.g, Config.Washer.MarkerColor.b, 100, false, false, 2, false, nil, nil, false)
         letSleep = false
	     end
       if (v.isForSale or v.Owner == myIdentifier) and Config.Manage.MarkerType ~= -1 and #(coords - v.Manage.Pos) < Config.DrawDistance then
         DrawMarker(Config.Manage.MarkerType, v.Manage.Pos.x, v.Manage.Pos.y, v.Manage.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Manage.MarkerSize.x, Config.Manage.MarkerSize.y, Config.Manage.MarkerSize.z, Config.Manage.MarkerColor.r, Config.Manage.MarkerColor.g, Config.Manage.MarkerColor.b, 100, false, false, 2, true, nil, nil, false)
         letSleep = false
       end
    end

    if letSleep then
	     Wait(500)
    end
	end
end)
