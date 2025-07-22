local Translations = {
	['press_wash'] = '~INPUT_CONTEXT~ pour nettoyer votre véhicule pour ~g~$%d',
	['press_manage'] = '~INPUT_CONTEXT~ pour gérer votre station de lavage.',
	['press_buy'] = '~INPUT_CONTEXT~ pour acheter la station de lavage.',
	['carwash_blip'] = 'Station de lavage',
	['withdraw_amount'] = 'Montant du retrait',
	['no_wash_needed'] = 'Votre véhicule est propre.',
	['cleaning_vehicle'] = 'Véhicule en cours de nettoyage... Veuillez patienter',
	['cleaned_vehicle'] = 'Votre véhicule a été nettoyé pour un montant de ~g~$%d',
	['not_enough_money'] = 'Vous n\' avez pas le cash nécessaire !',
	['shop_proprio'] = 'Gestion de la station',
	['menu_isAlreadyOpened'] = 'Le menu est déjà en cours d\'utilisation',
	['invalid_amount'] = 'Montant non valide',
	['have_withdrawn'] = 'Vous avez retiré ~g~$%d',
	['cancel'] = 'Cancel',
	['buy_carwash'] = 'Acheter la station pour %d$',
	['cancel_selling'] = 'Retirer le magasin de la vente',
	['stored_money'] = 'Argent stocké - $',
	['withdraw_money'] = 'Cliquer pour retirer l\'argent.',
	['put_forsale'] = 'Vendre le magasin',
	['selling_price'] = 'Prix de la vente',
	['bought'] = 'Vous venez d\'acheter cette station de lavage au prix de %d$',
	['comeback'] = 'Veuillez revenir sur le point'
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
