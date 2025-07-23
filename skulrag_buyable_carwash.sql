USE `<your database name>`;


CREATE TABLE `carwash_list` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`owner` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`isForSale` TINYINT(1) NULL DEFAULT NULL,
	`price` INT(11) NOT NULL,
	`accountMoney` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `name` (`name`) USING BTREE
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=8
;

INSERT INTO `carwash_list` (name, owner, isForSale, price, accountMoney) VALUES
	('PaletoBay', '', true, 25000, 0),
  ('Sandyshore', '', true, 25000, 0),
  ('MiddleWest', '', true, 25000, 0),
  ('LSWest', '', true, 25000, 0),
  ('LSEast', '', true, 25000, 0),
  ('LSNorth', '', true, 25000, 0),
  ('LSSouth', '', true, 25000, 0)
;

