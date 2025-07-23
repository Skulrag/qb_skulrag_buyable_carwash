local Carwash = {}

--
RegisterServerEvent('qbx_skulrag_buyable_carwash:getOwners')
AddEventHandler('qbx_skulrag_buyable_carwash:getOwners', function()
    local _source = source
    local cwListResult = MySQL.query.await('SELECT * FROM `carwash_list`')
    for i = 1, #cwListResult, 1 do
        Carwash[cwListResult[i].name] = {
            name = cwListResult[i].name,
            owner = cwListResult[i].owner,
            price = cwListResult[i].price,
            isForSale = cwListResult[i].isForSale
        }
    end

    local xPlayer = exports.qbx_core:GetPlayer(_source)

    if xPlayer then
        TriggerClientEvent('qbx_skulrag_buyable_carwash:saveOwners', _source, Carwash, xPlayer.PlayerData.citizenid)
    end
end)

RegisterServerEvent('qbx_skulrag_buyable_carwash:openCarwashManagement')
AddEventHandler('qbx_skulrag_buyable_carwash:openCarwashManagement', function(zone)
  TriggerClientEvent('qbx_skulrag_buyable_carwash:menuIsAlreadyOpened', -1, zone, true)
end)

RegisterServerEvent('qbx_skulrag_buyable_carwash:closeMenu')
AddEventHandler('qbx_skulrag_buyable_carwash:closeMenu', function(zone)
  TriggerClientEvent('qbx_skulrag_buyable_carwash:menuIsAlreadyOpened', -1, zone, false)
end)

--
RegisterServerEvent('qbx_skulrag_buyable_carwash:buy_carwash')
AddEventHandler('qbx_skulrag_buyable_carwash:buy_carwash', function(zone)
    local _source = source
    local xPlayer
    local playerMoney
    local xOwner
    local identifier

    xPlayer = exports.qbx_core:GetPlayer(_source)
    identifier = xPlayer.PlayerData.citizenid
    playerMoney = exports.qbx_core:GetMoney(identifier, 'cash')
    if Carwash[zone].owner ~= nil then
        xOwner = exports.qbx_core:GetPlayerByCitizenId(Carwash[zone].owner)
    end

    local price = MySQL.scalar.await('SELECT price from `carwash_list` WHERE name=@zone', {
        ['@zone'] = zone,
    })

    if playerMoney >= price then
        MySQL.update.await('UPDATE `carwash_list` SET `price`=0, `owner`=@identifier, `isForSale`=@forsale WHERE name = @zone', {
            ['@identifier'] = identifier,
            ['@forsale'] = false,
            ['@zone'] = zone,
        })

        exports.qbx_core:RemoveMoney(identifier, 'cash', tonumber(price))

        TriggerClientEvent('qbx_skulrag_buyable_carwash:carwashBought', -1, zone, identifier)
        if xOwner ~= nil then
            exports.qbx_core:AddMoney(identifier, 'bank', tonumber(price))
        end
        print(('[Carwash bought] FROM : Owner Identifier: %s /  BY : Identifier: %s'):format(Carwash[zone].owner, identifier))
        exports.qbx_core:Notify(_source, Lang:t('bought'), 'success')
    else
        exports.qbx_core:Notify(_source, Lang:t('not_enough_money'), 'error')
    end
end)

--
RegisterServerEvent('qbx_skulrag_buyable_carwash:withdrawMoneyFromStation')
AddEventHandler('qbx_skulrag_buyable_carwash:withdrawMoneyFromStation', function(zone, amount)
    local _source = source
    local xPlayer  
    local identifier
    local xPlayer = exports.qbx_core:GetPlayer(_source)
    local identifier = xPlayer.PlayerData.citizenid
    
    amount = math.floor(tonumber(amount)+0.5)
    local accountMoney = MySQL.scalar.await('SELECT accountMoney from `carwash_list` WHERE name=@zone AND owner=@owner', {
        ['@owner'] = identifier,
        ['@zone'] = zone,
    })
    if amount > 0 and accountMoney >= amount then
      local newAmount = accountMoney - amount
      local success = MySQL.update.await('UPDATE `carwash_list` SET `accountMoney`=@newAmount WHERE name = @zone', {
          ['@newAmount'] = newAmount,
          ['@zone'] = zone,
      })
      if success then
        exports.qbx_core:AddMoney(identifier, 'bank', tonumber(price))
        print(('[Carwash withdrawMoney] BY : Owner Identifier: %s / Quantity : %s'):format(identifier, amount))
        exports.qbx_core:Notify(_source, Lang:t('have_withdrawn'), 'success')
      end
    else
      TriggerClientEvent('QBCore:Notify', _source, Lang:t('invalid_amount'))
    end
end)

-- Callbacks
lib.callback.register('qbx_skulrag_buyable_carwash:getAccountMoney', function(source, zone)
    return MySQL.scalar.await('SELECT accountMoney from `carwash_list` WHERE name=@zone', {
        ['@zone'] = zone,
    })
end)

lib.callback.register('qbx_skulrag_buyable_carwash:isforsale', function(source, zone)
    local row =  MySQL.single.await('SELECT price, isForSale from `carwash_list` WHERE name=@zone', {
        ['@zone'] = zone,
    })
    Carwash[zone].isForSale = row.isForSale
    Carwash[zone].price = row.price
    return row.isForSale, row.price
end)

--
RegisterServerEvent('qbx_skulrag_buyable_carwash:cancelselling')
AddEventHandler('qbx_skulrag_buyable_carwash:cancelselling', function(zone)
    print('zone', zone)
    print('Carwash[zone].isForSale', Carwash[zone].isForSale)
    Carwash[zone].isForSale = false
    MySQL.update.await('UPDATE `carwash_list` SET `isForSale`=@forsale WHERE name = @zone', {
        ['@forsale'] = false,
        ['@zone'] = zone,
    })
    TriggerClientEvent('qbx_skulrag_buyable_carwash:cancelSelling', -1, zone)
end)

--
RegisterServerEvent('qbx_skulrag_buyable_carwash:putforsale')
AddEventHandler('qbx_skulrag_buyable_carwash:putforsale', function(zone, price)
    Carwash[zone].isForSale = true
    MySQL.update.await('UPDATE `carwash_list` SET `isForSale`=@forsale, `price`=@price WHERE name = @zone', {
        ['@forsale'] = true,
        ['@zone'] = zone,
        ['@price'] = price
    })
    TriggerClientEvent('qbx_skulrag_buyable_carwash:carwashForSale', -1, zone)
end)

function addMoneyToCarWash(zone, price)
  local accountMoney = MySQL.scalar.await('SELECT accountMoney from `carwash_list` WHERE name=@zone', {
      ['@zone'] = zone
  })
  MySQL.update('UPDATE `carwash_list` SET `accountMoney`=@newAmount WHERE name = @zone', {
      ['@newAmount'] = accountMoney + price,
      ['@zone'] = zone,
  })
end

RegisterServerEvent('qbx_skulrag_buyable_carwash:checkMoneyForWash')
AddEventHandler('qbx_skulrag_buyable_carwash:checkMoneyForWash', function(price, zone)
    local _source = source
    local xPlayer = exports.qbx_core:GetPlayer(_source)
    local identifier = xPlayer.PlayerData.citizenid

    price = tonumber(price)
    if price < exports.qbx_core:GetMoney(identifier, 'cash') then
        TriggerClientEvent('qbx_skulrag_buyable_carwash:clean', _source)
        exports.qbx_core:RemoveMoney(identifier, 'cash', price)
        addMoneyToCarWash(zone, price)
    elseif price < exports.qbx_core:GetMoney(identifier, 'bank') then
        TriggerClientEvent('qbx_skulrag_buyable_carwash:clean', _source)
        exports.qbx_core:RemoveMoney(identifier, 'bank', price)
        addMoneyToCarWash(zone, price)
    else
        exports.qbx_core:Notify(_source, Lang:t('not_enough_money'), 'error')
    end
end)
