-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.4.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for toserba
CREATE DATABASE IF NOT EXISTS `toserba` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `toserba`;

-- Dumping structure for table toserba.delivery_orders
DROP TABLE IF EXISTS `delivery_orders`;
CREATE TABLE IF NOT EXISTS `delivery_orders` (
  `delivery_order_id` int(11) NOT NULL AUTO_INCREMENT,
  `warehouse_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `order_timestamp` datetime NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`delivery_order_id`),
  KEY `fk_delivery_orders_warehouse` (`warehouse_id`),
  KEY `fk_delivery_orders_store` (`store_id`),
  CONSTRAINT `fk_delivery_orders_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`),
  CONSTRAINT `fk_delivery_orders_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.delivery_orders: ~0 rows (approximately)

-- Dumping structure for table toserba.delivery_order_details
DROP TABLE IF EXISTS `delivery_order_details`;
CREATE TABLE IF NOT EXISTS `delivery_order_details` (
  `delivery_order_detail_id` int(11) NOT NULL AUTO_INCREMENT,
  `delivery_order_id` int(11) NOT NULL DEFAULT 0,
  `product_detail_id` int(11) NOT NULL DEFAULT 0,
  `product_name` varchar(50) NOT NULL DEFAULT '-',
  `quantity` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`delivery_order_detail_id`),
  KEY `fk_delivery_order_details_order` (`delivery_order_id`),
  KEY `fk_delivery_order_details_product` (`product_detail_id`),
  CONSTRAINT `fk_delivery_order_details_order` FOREIGN KEY (`delivery_order_id`) REFERENCES `delivery_orders` (`delivery_order_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_delivery_order_details_product` FOREIGN KEY (`product_detail_id`) REFERENCES `product_details` (`product_detail_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.delivery_order_details: ~0 rows (approximately)

-- Dumping structure for table toserba.members
DROP TABLE IF EXISTS `members`;
CREATE TABLE IF NOT EXISTS `members` (
  `member_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_name` varchar(225) NOT NULL DEFAULT '-',
  `member_phone_number` varchar(225) NOT NULL DEFAULT '-',
  `member_points` int(11) NOT NULL DEFAULT 0,
  `member_join_date` datetime NOT NULL,
  PRIMARY KEY (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.members: ~0 rows (approximately)

-- Dumping structure for table toserba.payment_method
DROP TABLE IF EXISTS `payment_method`;
CREATE TABLE IF NOT EXISTS `payment_method` (
  `payment_method_id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_method_name` varchar(225) NOT NULL DEFAULT '',
  PRIMARY KEY (`payment_method_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.payment_method: ~1 rows (approximately)
REPLACE INTO `payment_method` (`payment_method_id`, `payment_method_name`) VALUES
	(1, 'Debit');

-- Dumping structure for table toserba.privileges
DROP TABLE IF EXISTS `privileges`;
CREATE TABLE IF NOT EXISTS `privileges` (
  `privileges_id` int(11) NOT NULL AUTO_INCREMENT,
  `privileges_name` varchar(100) NOT NULL,
  `navbar` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`privileges_id`),
  UNIQUE KEY `privileges_name` (`privileges_name`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.privileges: ~26 rows (approximately)
REPLACE INTO `privileges` (`privileges_id`, `privileges_name`, `navbar`) VALUES
	(1, 'session', 1),
	(2, 'transaction history', 1),
	(3, 'input opening cash', 0),
	(4, 'payment', 0),
	(5, 'view all promos', 0),
	(6, 'accept order', 0),
	(7, 'check stock', 0),
	(8, 'session history', 1),
	(9, 'product list', 1),
	(10, 'Add Product', 1),
	(11, 'Subtract product stock', 1),
	(12, 'stock history', 1),
	(13, 'inventory taking', 1),
	(14, 'assign product to store', 1),
	(15, 'stock transfer notes', 1),
	(16, 'notif', 1),
	(17, 'manage cashier', 1),
	(18, 'manage employee admin', 1),
	(19, 'manage inventory', 1),
	(20, 'verify stock change', 0),
	(21, 'verify product assign', 0),
	(22, 'manage employee owner', 1),
	(23, 'sales analytic', 1),
	(24, 'product movement', 0),
	(25, 'manage store & warehouse', 1),
	(26, 'manage promos', 1);

-- Dumping structure for table toserba.products_category
DROP TABLE IF EXISTS `products_category`;
CREATE TABLE IF NOT EXISTS `products_category` (
  `product_category_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_category_name` varchar(255) NOT NULL DEFAULT '-',
  PRIMARY KEY (`product_category_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.products_category: ~3 rows (approximately)
REPLACE INTO `products_category` (`product_category_id`, `product_category_name`) VALUES
	(1, 'Vegetables'),
	(2, 'Meats'),
	(3, 'Fruits');

-- Dumping structure for table toserba.product_details
DROP TABLE IF EXISTS `product_details`;
CREATE TABLE IF NOT EXISTS `product_details` (
  `product_detail_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_code` varchar(225) NOT NULL DEFAULT '-',
  `product_category_id` int(11) NOT NULL DEFAULT 0,
  `product_name` varchar(225) NOT NULL DEFAULT '-',
  `supplier_id` int(11) NOT NULL,
  `product_batch` int(11) NOT NULL DEFAULT 0,
  `buy_price` int(11) NOT NULL DEFAULT 0,
  `sell_price` int(11) NOT NULL DEFAULT 0,
  `expiry_date` date NOT NULL DEFAULT '0000-00-00',
  `min_stock` int(11) NOT NULL DEFAULT 0,
  `product_stock` int(11) NOT NULL DEFAULT 0,
  `product_unit` varchar(50) NOT NULL DEFAULT '-',
  `product_timestamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`product_detail_id`) USING BTREE,
  UNIQUE KEY `product_code` (`product_code`),
  KEY `product_category_id` (`product_category_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `FK_product_details_suppliers` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_product_details_product_category` FOREIGN KEY (`product_category_id`) REFERENCES `products_category` (`product_category_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.product_details: ~2 rows (approximately)
REPLACE INTO `product_details` (`product_detail_id`, `product_code`, `product_category_id`, `product_name`, `supplier_id`, `product_batch`, `buy_price`, `sell_price`, `expiry_date`, `min_stock`, `product_stock`, `product_unit`, `product_timestamp`) VALUES
	(3, 'VEG001', 1, 'Spinach', 1, 1, 20000, 22000, '2024-08-23', 500, 1000, 'gram', '2024-08-13 09:10:00'),
	(4, 'VEG002', 1, 'Pepper', 1, 1, 25000, 28000, '2024-08-23', 500, 1000, 'gram', '2024-08-13 09:10:00');

-- Dumping structure for table toserba.promos
DROP TABLE IF EXISTS `promos`;
CREATE TABLE IF NOT EXISTS `promos` (
  `promo_id` int(11) NOT NULL AUTO_INCREMENT,
  `promo_code` varchar(225) NOT NULL DEFAULT '-',
  `promo_type_id` int(11) NOT NULL DEFAULT 0,
  `promo_start_date` date NOT NULL DEFAULT '0000-00-00',
  `promo_end_date` date NOT NULL DEFAULT '0000-00-00',
  `promo_percentage` int(11) NOT NULL DEFAULT 0,
  `promo_discount` int(11) NOT NULL DEFAULT 0,
  `promo_term_and_cond` varchar(225) NOT NULL DEFAULT '-',
  `x_amount` int(11) NOT NULL DEFAULT 0,
  `y_amount` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`promo_id`),
  UNIQUE KEY `promo_code` (`promo_code`),
  KEY `promo_type_id` (`promo_type_id`),
  CONSTRAINT `FK_promos_promo_type` FOREIGN KEY (`promo_type_id`) REFERENCES `promo_type` (`promo_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.promos: ~1 rows (approximately)
REPLACE INTO `promos` (`promo_id`, `promo_code`, `promo_type_id`, `promo_start_date`, `promo_end_date`, `promo_percentage`, `promo_discount`, `promo_term_and_cond`, `x_amount`, `y_amount`) VALUES
	(2, 'PROMO001', 2, '2024-08-20', '2024-08-29', 15, 0, '-', 0, 0);

-- Dumping structure for table toserba.promo_products
DROP TABLE IF EXISTS `promo_products`;
CREATE TABLE IF NOT EXISTS `promo_products` (
  `promo_product_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_detail_id` int(11) NOT NULL,
  `promo_id` int(11) NOT NULL,
  PRIMARY KEY (`promo_product_id`),
  KEY `fk_promo_products_promo` (`promo_id`),
  KEY `fk_promo_products_product` (`product_detail_id`) USING BTREE,
  CONSTRAINT `FK_promo_products_product_details` FOREIGN KEY (`product_detail_id`) REFERENCES `product_details` (`product_detail_id`),
  CONSTRAINT `fk_promo_products_promo` FOREIGN KEY (`promo_id`) REFERENCES `promos` (`promo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.promo_products: ~2 rows (approximately)
REPLACE INTO `promo_products` (`promo_product_id`, `product_detail_id`, `promo_id`) VALUES
	(1, 3, 2),
	(2, 4, 2);

-- Dumping structure for table toserba.promo_type
DROP TABLE IF EXISTS `promo_type`;
CREATE TABLE IF NOT EXISTS `promo_type` (
  `promo_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `promo_type_name` varchar(225) NOT NULL DEFAULT '-',
  PRIMARY KEY (`promo_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.promo_type: ~3 rows (approximately)
REPLACE INTO `promo_type` (`promo_type_id`, `promo_type_name`) VALUES
	(1, 'BUYXGETY'),
	(2, '%DISCOUNT'),
	(3, 'RPDISCOUNT');

-- Dumping structure for table toserba.roles
DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `roles_id` int(11) NOT NULL AUTO_INCREMENT,
  `roles_name` varchar(100) NOT NULL,
  PRIMARY KEY (`roles_id`),
  UNIQUE KEY `roles_name` (`roles_name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.roles: ~5 rows (approximately)
REPLACE INTO `roles` (`roles_id`, `roles_name`) VALUES
	(5, 'Admin'),
	(1, 'Cashier'),
	(2, 'Inventory Store Employee'),
	(6, 'Owner'),
	(3, 'Warehouse Employee'),
	(4, 'Warehouse Operational Staff');

-- Dumping structure for table toserba.roles_default
DROP TABLE IF EXISTS `roles_default`;
CREATE TABLE IF NOT EXISTS `roles_default` (
  `roles_default_id` int(11) NOT NULL AUTO_INCREMENT,
  `roles_id` int(11) NOT NULL,
  `privileges_id` int(11) NOT NULL,
  PRIMARY KEY (`roles_default_id`),
  KEY `fk_roles_default_privileges` (`privileges_id`),
  KEY `fk_uroles_default_roles` (`roles_id`),
  CONSTRAINT `fk_roles_default_privileges` FOREIGN KEY (`privileges_id`) REFERENCES `privileges` (`privileges_id`),
  CONSTRAINT `fk_uroles_default_roles` FOREIGN KEY (`roles_id`) REFERENCES `roles` (`roles_id`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.roles_default: ~69 rows (approximately)
REPLACE INTO `roles_default` (`roles_default_id`, `roles_id`, `privileges_id`) VALUES
	(1, 1, 1),
	(2, 1, 2),
	(3, 1, 3),
	(4, 1, 4),
	(5, 1, 5),
	(6, 1, 7),
	(7, 1, 8),
	(8, 1, 9),
	(9, 1, 16),
	(10, 2, 1),
	(11, 2, 5),
	(12, 2, 6),
	(13, 2, 7),
	(14, 2, 8),
	(15, 2, 9),
	(16, 2, 16),
	(17, 3, 9),
	(18, 3, 11),
	(19, 3, 12),
	(20, 3, 13),
	(21, 3, 15),
	(22, 3, 16),
	(23, 4, 9),
	(24, 4, 10),
	(25, 4, 11),
	(26, 4, 12),
	(27, 4, 13),
	(28, 4, 14),
	(29, 4, 15),
	(30, 4, 16),
	(31, 5, 2),
	(32, 5, 5),
	(33, 5, 7),
	(34, 5, 8),
	(35, 5, 9),
	(36, 5, 12),
	(37, 5, 16),
	(38, 5, 17),
	(39, 5, 18),
	(40, 5, 19),
	(41, 5, 20),
	(42, 5, 21),
	(43, 5, 26),
	(44, 6, 1),
	(45, 6, 2),
	(46, 6, 3),
	(47, 6, 4),
	(48, 6, 5),
	(49, 6, 6),
	(50, 6, 7),
	(51, 6, 8),
	(52, 6, 9),
	(53, 6, 10),
	(54, 6, 11),
	(55, 6, 12),
	(56, 6, 13),
	(57, 6, 14),
	(58, 6, 15),
	(59, 6, 16),
	(60, 6, 17),
	(61, 6, 18),
	(62, 6, 19),
	(63, 6, 20),
	(64, 6, 21),
	(65, 6, 22),
	(66, 6, 23),
	(67, 6, 24),
	(68, 6, 25),
	(69, 6, 26);

-- Dumping structure for table toserba.sessions
DROP TABLE IF EXISTS `sessions`;
CREATE TABLE IF NOT EXISTS `sessions` (
  `session_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `start_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `end_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `opening_cash` int(11) NOT NULL DEFAULT 0,
  `total_income` int(11) NOT NULL DEFAULT 0,
  `expected_closing_cash` int(11) NOT NULL DEFAULT 0,
  `actual_closing_cash` int(11) NOT NULL DEFAULT 0,
  `actual_difference` int(11) NOT NULL DEFAULT 0,
  `opening_notes` varchar(225) NOT NULL DEFAULT '-',
  `closing_notes` varchar(225) NOT NULL DEFAULT '-',
  `last_update_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deposit_money` int(11) NOT NULL DEFAULT 0,
  `deposit_difference` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`session_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `FK_sessions_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.sessions: ~2 rows (approximately)
REPLACE INTO `sessions` (`session_id`, `user_id`, `start_time`, `end_time`, `opening_cash`, `total_income`, `expected_closing_cash`, `actual_closing_cash`, `actual_difference`, `opening_notes`, `closing_notes`, `last_update_time`, `deposit_money`, `deposit_difference`) VALUES
	(1, 1, '2015-09-02 08:04:00', '0000-00-00 00:00:00', 20000, 100000, 120000, 100000, 20000, '', 'Finished', '0000-00-00 00:00:00', 0, 0),
	(3, 1, '2015-09-02 08:04:00', '2024-01-01 11:11:11', 30000, 100000, 130000, 100000, 30000, '', 'Finished', '2024-01-01 12:11:11', 0, 0);

-- Dumping structure for table toserba.session_transactions
DROP TABLE IF EXISTS `session_transactions`;
CREATE TABLE IF NOT EXISTS `session_transactions` (
  `session_transaction_id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` int(11) NOT NULL DEFAULT 0,
  `transaction_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`session_transaction_id`),
  KEY `session_id` (`session_id`),
  KEY `transaction_id` (`transaction_id`),
  CONSTRAINT `FK_session_transactions_sessions` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_session_transactions_transactions` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.session_transactions: ~0 rows (approximately)

-- Dumping structure for table toserba.stock_cards
DROP TABLE IF EXISTS `stock_cards`;
CREATE TABLE IF NOT EXISTS `stock_cards` (
  `stock_card_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_detail_id` int(11) NOT NULL,
  `stock_date` date NOT NULL DEFAULT '0000-00-00',
  `stock_description` varchar(225) NOT NULL DEFAULT '-',
  `product_name` varchar(225) NOT NULL DEFAULT '-',
  `product_batch` int(11) NOT NULL DEFAULT 0,
  `product_stock` int(11) NOT NULL DEFAULT 0,
  `expired_date` date NOT NULL DEFAULT '0000-00-00',
  `stock_in` int(11) NOT NULL DEFAULT 0,
  `stock_out` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`stock_card_id`),
  KEY `fk_stock_cards_product_detail` (`product_detail_id`),
  CONSTRAINT `fk_stock_cards_product_detail` FOREIGN KEY (`product_detail_id`) REFERENCES `product_details` (`product_detail_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.stock_cards: ~0 rows (approximately)

-- Dumping structure for table toserba.store_warehouses
DROP TABLE IF EXISTS `store_warehouses`;
CREATE TABLE IF NOT EXISTS `store_warehouses` (
  `store_warehouse_id` int(11) NOT NULL AUTO_INCREMENT,
  `store_warehouse_type` varchar(225) NOT NULL DEFAULT '',
  `store_warehouse_name` varchar(225) NOT NULL DEFAULT '',
  `store_warehouse_address` varchar(225) NOT NULL DEFAULT '',
  `store_warehouse_phone_number` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`store_warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.store_warehouses: ~0 rows (approximately)

-- Dumping structure for table toserba.suppliers
DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE IF NOT EXISTS `suppliers` (
  `supplier_id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_name` varchar(225) NOT NULL DEFAULT '-',
  `supplier_phone_number` varchar(225) NOT NULL DEFAULT '-',
  `supplier_address` varchar(225) NOT NULL DEFAULT '-',
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.suppliers: ~1 rows (approximately)
REPLACE INTO `suppliers` (`supplier_id`, `supplier_name`, `supplier_phone_number`, `supplier_address`) VALUES
	(1, 'Rumah Tani', '081237485623', 'Jl. Semangka II No. 3, Surabay');

-- Dumping structure for table toserba.sw_products
DROP TABLE IF EXISTS `sw_products`;
CREATE TABLE IF NOT EXISTS `sw_products` (
  `sw_product_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_detail_id` int(11) NOT NULL,
  `store_warehouse_id` int(11) NOT NULL,
  `section_placement` varchar(225) NOT NULL DEFAULT '',
  PRIMARY KEY (`sw_product_id`),
  KEY `product_detail_id` (`product_detail_id`),
  KEY `store_warehouse_id` (`store_warehouse_id`),
  CONSTRAINT `FK_sw_products_product_details` FOREIGN KEY (`product_detail_id`) REFERENCES `product_details` (`product_detail_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_sw_products_store_warehouses` FOREIGN KEY (`store_warehouse_id`) REFERENCES `store_warehouses` (`store_warehouse_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.sw_products: ~0 rows (approximately)

-- Dumping structure for table toserba.transactions
DROP TABLE IF EXISTS `transactions`;
CREATE TABLE IF NOT EXISTS `transactions` (
  `transaction_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_total_price` int(11) NOT NULL DEFAULT 0,
  `transaction_timestamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `transaction_payment_method_id` int(11) NOT NULL,
  `transaction_payment` int(11) NOT NULL DEFAULT 0,
  `transaction_change` int(11) NOT NULL DEFAULT 0,
  `transaction_total_item` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`transaction_id`) USING BTREE,
  KEY `transaction_payment_method_id` (`transaction_payment_method_id`),
  CONSTRAINT `FK_transactions_payment_method` FOREIGN KEY (`transaction_payment_method_id`) REFERENCES `payment_method` (`payment_method_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.transactions: ~0 rows (approximately)

-- Dumping structure for table toserba.transactions_member
DROP TABLE IF EXISTS `transactions_member`;
CREATE TABLE IF NOT EXISTS `transactions_member` (
  `transaction_member_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` int(11) NOT NULL DEFAULT 0,
  `member_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`transaction_member_id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `member_id` (`member_id`),
  CONSTRAINT `FK__members` FOREIGN KEY (`member_id`) REFERENCES `members` (`member_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK__transactions` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.transactions_member: ~0 rows (approximately)

-- Dumping structure for table toserba.transaction_details
DROP TABLE IF EXISTS `transaction_details`;
CREATE TABLE IF NOT EXISTS `transaction_details` (
  `transaction_detail_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` int(11) NOT NULL,
  `product_detail_id` int(11) NOT NULL,
  `promo_product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `sell_price` int(11) NOT NULL DEFAULT 0,
  `discount_price` int(11) NOT NULL DEFAULT 0,
  `total_price` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`transaction_detail_id`),
  KEY `fk_transaction_details_product_details` (`product_detail_id`),
  KEY `fk_transaction_details_promo_product` (`promo_product_id`),
  KEY `fk_transaction_details_transaction` (`transaction_id`),
  CONSTRAINT `fk_transaction_details_product_details` FOREIGN KEY (`product_detail_id`) REFERENCES `product_details` (`product_detail_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_transaction_details_promo_product` FOREIGN KEY (`promo_product_id`) REFERENCES `promo_products` (`promo_product_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_transaction_details_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.transaction_details: ~0 rows (approximately)

-- Dumping structure for table toserba.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(255) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `user_password` varchar(50) NOT NULL,
  `user_fullname` varchar(50) NOT NULL,
  `user_address` varchar(50) NOT NULL,
  `user_gender` varchar(10) NOT NULL,
  `user_birthdate` date NOT NULL,
  `user_email` varchar(50) NOT NULL,
  `user_phone_number` varchar(15) NOT NULL,
  `user_photo_profile` varchar(225) DEFAULT NULL,
  `user_created_at` datetime DEFAULT NULL,
  `user_deleted_at` datetime DEFAULT NULL,
  `user_updated_at` datetime DEFAULT NULL,
  `user_login_timestamp` datetime DEFAULT NULL,
  `user_otp` varchar(225) NOT NULL DEFAULT '',
  `otp_exp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `user_email` (`user_email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.users: ~3 rows (approximately)
REPLACE INTO `users` (`user_id`, `username`, `user_password`, `user_fullname`, `user_address`, `user_gender`, `user_birthdate`, `user_email`, `user_phone_number`, `user_photo_profile`, `user_created_at`, `user_deleted_at`, `user_updated_at`, `user_login_timestamp`, `user_otp`, `otp_exp`) VALUES
	(1, 'tipani', 'tipaja', 'Tiffany Jacklin', 'Jalan Jeruk', 'P', '2003-03-13', 'c14210056@john.petra.ac.id', '081000888333', 'uploads/users/lena.png', '2024-07-18 13:48:04', NULL, NULL, '2024-08-07 11:19:43', '', '0000-00-00 00:00:00'),
	(2, 'danielll', 'danielaja', 'Daniel Alexander', 'Jalan leci', 'L', '2003-01-01', 'danielaja@gmail.com', '081000888111', NULL, '2023-07-12 14:30:45', NULL, NULL, '2024-07-29 11:15:28', '', '0000-00-00 00:00:00'),
	(3, 'alexlo', 'alexaja', 'Alexander Louis', 'Jalan mangga', 'L', '2003-02-02', 'alexaja@gmail.com', '081000888222', NULL, '2023-08-12 14:30:45', NULL, NULL, '2024-07-29 11:31:45', '', '0000-00-00 00:00:00');

-- Dumping structure for table toserba.user_privileges
DROP TABLE IF EXISTS `user_privileges`;
CREATE TABLE IF NOT EXISTS `user_privileges` (
  `user_privileges_id` int(11) NOT NULL AUTO_INCREMENT,
  `privileges_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  PRIMARY KEY (`user_privileges_id`),
  KEY `fk_user_privileges_roles` (`role_id`),
  KEY `fk_user_privileges_privileges` (`privileges_id`),
  KEY `fk_user_privileges_users` (`user_id`),
  CONSTRAINT `fk_user_privileges_privileges` FOREIGN KEY (`privileges_id`) REFERENCES `privileges` (`privileges_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_privileges_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`roles_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_privileges_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.user_privileges: ~4 rows (approximately)
REPLACE INTO `user_privileges` (`user_privileges_id`, `privileges_id`, `user_id`, `role_id`) VALUES
	(1, 1, 2, 1),
	(2, 7, 2, 1),
	(3, 3, 2, 1),
	(4, 11, 2, 1);

-- Dumping structure for table toserba.user_roles
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE IF NOT EXISTS `user_roles` (
  `user_roles_id` int(11) NOT NULL AUTO_INCREMENT,
  `roles_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `store_id` int(11) DEFAULT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `custom` int(11) NOT NULL,
  PRIMARY KEY (`user_roles_id`),
  KEY `fk_user_roles_stores` (`store_id`),
  KEY `fk_user_roles_warehouse` (`warehouse_id`),
  KEY `fk_user_roles_roles` (`roles_id`),
  KEY `fk_user_roles_users` (`user_id`),
  CONSTRAINT `fk_user_roles_roles` FOREIGN KEY (`roles_id`) REFERENCES `roles` (`roles_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_roles_stores` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_roles_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_roles_warehouses` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.user_roles: ~4 rows (approximately)
REPLACE INTO `user_roles` (`user_roles_id`, `roles_id`, `user_id`, `store_id`, `warehouse_id`, `custom`) VALUES
	(1, 1, 1, NULL, NULL, 0),
	(2, 2, 1, NULL, NULL, 0),
	(3, 6, 3, NULL, NULL, 0),
	(4, 1, 2, NULL, NULL, 1);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
