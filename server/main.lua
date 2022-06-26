local Carwash = {}
local QBCore = nil
QBCore = exports['qb-core']:GetCoreObject()

--
RegisterServerEvent('buyable_carwash:getOwners')
AddEventHandler('buyable_carwash:getOwners', function()
    local _source = source
    local cwListResult = MySQL.Sync.fetchAll('SELECT * FROM `carwash_list`')
    for i = 1, #cwListResult, 1 do
        Carwash[cwListResult[i].name] = {
            name = cwListResult[i].name,
            owner = cwListResult[i].owner,
            price = cwListResult[i].price,
            isForSale = cwListResult[i].isForSale
        }
    end

    local xPlayer = QBCore.Functions.GetPlayer(_source)
    
    if xPlayer ~= nil then
        TriggerClientEvent('buyable_carwash:saveOwners', _source, Carwash, xPlayer.identifier)
    else
        TriggerClientEvent('QBCore:Notify', _source, Lang:t('comeback'))
    end
end)

RegisterServerEvent('buyable_carwash:openMenu')
AddEventHandler('buyable_carwash:openMenu', function(zone)
  TriggerClientEvent('buyable_carwash:menuIsAlreadyOpened', -1, zone, true)
end)

RegisterServerEvent('buyable_carwash:closeMenu')
AddEventHandler('buyable_carwash:closeMenu', function(zone)
  TriggerClientEvent('buyable_carwash:menuIsAlreadyOpened', -1, zone, false)
end)

--
RegisterServerEvent('buyable_carwash:buy_carwash')
AddEventHandler('buyable_carwash:buy_carwash', function(zone)
    local _source = source
    local xPlayer
    local playerMoney
    local xOwner
    local identifier

    xPlayer = QBCore.Functions.GetPlayer(_source)
    identifier = xPlayer.citizenid
    playerMoney = xPlayer.Functions.GetMoney('cash')
    if Carwash[zone].owner ~= nil then
        xOwner = QBcore.Functions.GetPlayerByCitizenId(Carwash[zone].owner)
      end

    local price = MySQL.Sync.fetchScalar('SELECT price from `carwash_list` WHERE name=@zone', {
        ['@zone'] = zone,
    }, function(_)end)

    if playerMoney >= price then
        MySQL.Sync.execute('UPDATE `carwash_list` SET `price`=0, `owner`=@identifier, `isForSale`=@forsale WHERE name = @zone', {
            ['@identifier'] = identifier,
            ['@forsale'] = false,
            ['@zone'] = zone,
        }, function(_)end)

        
        xPlayer.Functions.RemoveMoney('cash', tonumber(price))

        TriggerClientEvent('buyable_carwash:carwashBought', -1, zone, identifier)
        if xOwner ~= nil then
            xOwner.Functions.AddMoney('bank', tonumber(price))
        end
        print(('[Carwash bought] FROM : Owner Identifier: %s /  BY : Identifier: %s'):format(Carwash[zone].owner, identifier))
        TriggerClientEvent('QBCore:Notify', _source, Lang:t('bought', {price}))
    else
        TriggerClientEvent('QBCore:Notify', _source, Lang:t('not_enough_money'))
    end
end)

--
RegisterServerEvent('buyable_carwash:withdrawMoney')
AddEventHandler('buyable_carwash:withdrawMoney', function(zone, amount)
    local _source = source
    local xPlayer  
    local identifier
    xPlayer = QBCore.Functions.GetPlayer(_source)
    identifier = xPlayer.citizenid
    
    amount = ESX.Math.Round(tonumber(amount))
    local accountMoney = MySQL.Sync.fetchScalar('SELECT accountMoney from `carwash_list` WHERE name=@zone AND owner=@owner', {
        ['@owner'] = identifier,
        ['@zone'] = zone,
    }, function(_)end)
    if amount > 0 and accountMoney >= amount then
      local newAmount = accountMoney - amount
      MySQL.Sync.execute('UPDATE `carwash_list` SET `accountMoney`=@newAmount WHERE name = @zone', {
          ['@newAmount'] = newAmount,
          ['@zone'] = zone,
      }, function(_)end)
      xPlayer.Functions.AddMoney('bank', tonumber(amount))
      amount = ESX.Math.GroupDigits(amount)
      print(('[Carwash withdrawMoney] BY : Owner Identifier: %s / Quantity : %d'):format(identifier, amount))
      TriggerClientEvent('QBCore:Notify', _source, Lang:t('have_withdrawn', {amount}))
    else
      TriggerClientEvent('QBCore:Notify', _source, Lang:t('invalid_amount'))
    end
end)

-- Callbacks
QBCore.Functions.CreateCallback('buyable_carwash:getAccountMoney', function(source, cb)
    local accountMoney = MySQL.Sync.fetchScalar('SELECT accountMoney from `carwash_list` WHERE name=@zone', {
        ['@zone'] = zone,
    }, function(_)end)
    cb(accountMoney)
end)
QBCore.Functions.CreateCallback('buyable_carwash:isforsale', function(source, cb)
    local price = MySQL.Sync.fetchScalar('SELECT price from `carwash_list` WHERE name=@zone', {
        ['@zone'] = zone,
    }, function(_)end)
    cb(Carwash[zone].isForSale, price)
end)



--
RegisterServerEvent('buyable_carwash:cancelselling')
AddEventHandler('buyable_carwash:cancelselling', function(zone)
    Carwash[zone].isForSale = false
    MySQL.Sync.execute('UPDATE `carwash_list` SET `isForSale`=@forsale WHERE name = @zone', {
        ['@forsale'] = false,
        ['@zone'] = zone,
    }, function(_)
    end)
    TriggerClientEvent('buyable_carwash:cancelSelling', -1, zone)
end)

--
RegisterServerEvent('buyable_carwash:putforsale')
AddEventHandler('buyable_carwash:putforsale', function(zone, price)
    Carwash[zone].isForSale = true
    MySQL.Sync.execute('UPDATE `carwash_list` SET `isForSale`=@forsale, `price`=@price WHERE name = @zone', {
        ['@forsale'] = true,
        ['@zone'] = zone,
        ['@price'] = price
    }, function(_)
    end)
    TriggerClientEvent('buyable_carwash:carwashForSale', -1, zone)
end)

function addMoneyToCarWash(zone, price)
  local accountMoney = MySQL.Sync.fetchScalar('SELECT accountMoney from `carwash_list` WHERE name=@zone', {
      ['@zone'] = zone
  }, function(_)end)
  MySQL.Sync.execute('UPDATE `carwash_list` SET `accountMoney`=@newAmount WHERE name = @zone', {
      ['@newAmount'] = accountMoney + price,
      ['@zone'] = zone,
  }, function(_)end)
end

RegisterServerEvent('buyable_carwash:checkMoney')
AddEventHandler('buyable_carwash:checkMoney', function(price, zone)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    price = tonumber(price)
    if price < xPlayer.Functions.GetMoney('bank') then
      TriggerClientEvent('buyable_carwash:clean', _source)
      xPlayer.Functions.RemoveMoney('bank', tonumber(price))
      addMoneyToCarWash(zone, price)
    elseif price < xPlayer.Functions.GetMoney('cash') then
        TriggerClientEvent('buyable_carwash:clean', _source)
        xPlayer.Functions.RemoveMoney('cash', tonumber(price))
        addMoneyToCarWash(zone, price)
    elseif price < xPlayer.Functions.GetMoney('bank') + xPlayer.Functions.GetMoney('cash') then
        TriggerClientEvent('buyable_carwash:clean', _source)
        local bankPrice = xPlayer.Functions.GetMoney('bank')
        xPlayer.Functions.RemoveMoney('bank', tonumber(bankPrice))
        local cashPrice = price - bankPrice
        xPlayer.Functions.RemoveMoney('cash', tonumber(cashPrice))
        addMoneyToCarWash(zone, price)
    else
        TriggerClientEvent('buyable_carwash:cancel', _source)
    end
end)
