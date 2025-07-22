local Translations = {
	['press_wash'] = '~INPUT_CONTEXT~ to wash your vehicle for ~g~$%d',
	['press_manage'] = '~INPUT_CONTEXT~ to manage your carwash station.',
	['press_buy'] = '~INPUT_CONTEXT~ to buy the carwash station.',
	['carwash_blip'] = 'Carwash station',
	['withdraw_amount'] = 'Withdraw Amount',
	['no_wash_needed'] = 'Your vehicle is clean.',
	['cleaning_vehicle'] = 'Vehicle currently being cleaned... Please wait',
	['cleaned_vehicle'] = 'Your vehicle was cleaned for ~g~$%d',
	['not_enough_money'] = 'You don\'t have enough cash !',
	['shop_proprio'] = 'Station managment',
	['menu_isAlreadyOpened'] = 'Menu already used',
	['invalid_amount'] = 'Invalid amount',
	['have_withdrawn'] = 'You\'ve just withdrawed ~g~$%d',
	['cancel'] = 'Cancel',
	['buy_carwash'] = 'Buy carwash station for $%d',
	['cancel_selling'] = 'Cancel station selling',
	['stored_money'] = 'Stored money - $',
	['withdraw_money'] = 'Click to withdraw money.',
	['put_forsale'] = 'Put for sale',
	['selling_price'] = 'Selling price',
	['bought'] = 'You just bought this carwash station for $%d',
	['comeback'] = 'Please come back on the marker'
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
