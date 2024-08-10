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

-- Dumping structure for table toserba.customers
CREATE TABLE IF NOT EXISTS `customers` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  PRIMARY KEY (`customer_id`),
  KEY `fk_customers_member` (`member_id`),
  CONSTRAINT `fk_customers_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.customers: ~0 rows (approximately)

-- Dumping structure for table toserba.delivery_orders
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
CREATE TABLE IF NOT EXISTS `members` (
  `member_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_name` varchar(225) NOT NULL,
  `member_phone_number` varchar(225) NOT NULL,
  `member_points` int(11) DEFAULT NULL,
  `member_join_date` datetime NOT NULL,
  PRIMARY KEY (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.members: ~0 rows (approximately)

-- Dumping structure for table toserba.privileges
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
CREATE TABLE IF NOT EXISTS `products_category` (
  `product_category_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_cetagory_name` varchar(255) NOT NULL,
  PRIMARY KEY (`product_category_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.products_category: ~0 rows (approximately)

-- Dumping structure for table toserba.product_details
CREATE TABLE IF NOT EXISTS `product_details` (
  `product_detail_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_category_id` int(11) NOT NULL DEFAULT 0,
  `product_name` varchar(225) NOT NULL,
  `product_brand` varchar(50) NOT NULL DEFAULT '-',
  `product_batch` int(11) unsigned zerofill NOT NULL,
  `buy_price` int(11) NOT NULL,
  `sell_price` int(11) NOT NULL,
  `expiry_date` date NOT NULL,
  `min_stock` int(11) DEFAULT NULL,
  `product_stock` int(11) NOT NULL,
  `product_timestamp` datetime NOT NULL,
  PRIMARY KEY (`product_detail_id`),
  KEY `product_category_id` (`product_category_id`),
  CONSTRAINT `fk_product_details_product_category` FOREIGN KEY (`product_category_id`) REFERENCES `products_category` (`product_category_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.product_details: ~0 rows (approximately)

-- Dumping structure for table toserba.promos
CREATE TABLE IF NOT EXISTS `promos` (
  `promo_id` int(11) NOT NULL AUTO_INCREMENT,
  `promo_type` varchar(225) NOT NULL,
  `promo_start_date` date NOT NULL,
  `promo_end_date` date NOT NULL,
  `promo_discount` int(11) DEFAULT NULL,
  `promo_term_and_cond` varchar(225) NOT NULL,
  `x_amount` int(11) DEFAULT NULL,
  `y_amount` int(11) DEFAULT NULL,
  PRIMARY KEY (`promo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.promos: ~0 rows (approximately)

-- Dumping structure for table toserba.promo_products
CREATE TABLE IF NOT EXISTS `promo_products` (
  `promo_product_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_detail_id` int(11) NOT NULL,
  `promo_id` int(11) NOT NULL,
  PRIMARY KEY (`promo_product_id`),
  KEY `fk_promo_products_promo` (`promo_id`),
  KEY `fk_promo_products_product` (`product_detail_id`) USING BTREE,
  CONSTRAINT `FK_promo_products_product_details` FOREIGN KEY (`product_detail_id`) REFERENCES `product_details` (`product_detail_id`),
  CONSTRAINT `fk_promo_products_promo` FOREIGN KEY (`promo_id`) REFERENCES `promos` (`promo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.promo_products: ~0 rows (approximately)

-- Dumping structure for table toserba.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `roles_id` int(11) NOT NULL AUTO_INCREMENT,
  `roles_name` varchar(100) NOT NULL,
  PRIMARY KEY (`roles_id`),
  UNIQUE KEY `roles_name` (`roles_name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.roles: ~6 rows (approximately)
REPLACE INTO `roles` (`roles_id`, `roles_name`) VALUES
	(5, 'Admin'),
	(1, 'Cashier'),
	(2, 'Inventory Store Employee'),
	(6, 'Owner'),
	(3, 'Warehouse Employee'),
	(4, 'Warehouse Operational Staff');

-- Dumping structure for table toserba.roles_default
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
CREATE TABLE IF NOT EXISTS `sessions` (
  `session_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `start_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `end_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `opening_cash` int(11) NOT NULL DEFAULT 0,
  `total_transactions` int(11) NOT NULL DEFAULT 0,
  `expected_closing_cash` int(11) NOT NULL DEFAULT 0,
  `actual_closing_cash` int(11) NOT NULL DEFAULT 0,
  `difference_cash` int(11) NOT NULL DEFAULT 0,
  `opening_notes` varchar(225) NOT NULL DEFAULT '-',
  `closing_notes` varchar(225) NOT NULL DEFAULT '-',
  `last_update_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`session_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `FK_sessions_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.sessions: ~2 rows (approximately)
REPLACE INTO `sessions` (`session_id`, `user_id`, `start_time`, `end_time`, `opening_cash`, `total_transactions`, `expected_closing_cash`, `actual_closing_cash`, `difference_cash`, `opening_notes`, `closing_notes`, `last_update_time`) VALUES
	(1, 1, '2015-09-02 08:04:00', '0000-00-00 00:00:00', 20000, 100000, 120000, 100000, 20000, '', 'Finished', '0000-00-00 00:00:00'),
	(3, 1, '2015-09-02 08:04:00', '2024-01-01 11:11:11', 30000, 100000, 130000, 100000, 30000, '', 'Finished', '2024-01-01 12:11:11');

-- Dumping structure for table toserba.session_transactions
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
CREATE TABLE IF NOT EXISTS `stock_cards` (
  `stock_card_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_detail_id` int(11) NOT NULL,
  `stock_date` date NOT NULL,
  `stock_description` varchar(225) DEFAULT NULL,
  `product_name` varchar(225) NOT NULL,
  `product_batch` int(11) DEFAULT NULL,
  `product_stock` int(11) NOT NULL,
  `expired_date` date NOT NULL,
  `stock_in` int(11) DEFAULT NULL,
  `stock_out` int(11) DEFAULT NULL,
  PRIMARY KEY (`stock_card_id`),
  KEY `fk_stock_cards_product_detail` (`product_detail_id`),
  CONSTRAINT `fk_stock_cards_product_detail` FOREIGN KEY (`product_detail_id`) REFERENCES `product_details` (`product_detail_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.stock_cards: ~0 rows (approximately)

-- Dumping structure for table toserba.stores
CREATE TABLE IF NOT EXISTS `stores` (
  `store_id` int(11) NOT NULL AUTO_INCREMENT,
  `store_name` varchar(255) NOT NULL,
  `store_address` varchar(255) NOT NULL,
  `store_phone_number` varchar(255) NOT NULL,
  PRIMARY KEY (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.stores: ~0 rows (approximately)

-- Dumping structure for table toserba.transactions
CREATE TABLE IF NOT EXISTS `transactions` (
  `transaction_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `store_employee_id` int(11) NOT NULL,
  `transaction_total_price` int(11) NOT NULL,
  `transaction_timestamp` datetime NOT NULL,
  `transaction_payment_method` varchar(225) NOT NULL,
  PRIMARY KEY (`transaction_id`) USING BTREE,
  KEY `fk_transactions_customer` (`customer_id`),
  CONSTRAINT `fk_transactions_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.transactions: ~0 rows (approximately)

-- Dumping structure for table toserba.transaction_details
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
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `user_email` (`user_email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.users: ~3 rows (approximately)
REPLACE INTO `users` (`user_id`, `username`, `user_password`, `user_fullname`, `user_address`, `user_gender`, `user_birthdate`, `user_email`, `user_phone_number`, `user_photo_profile`, `user_created_at`, `user_deleted_at`, `user_updated_at`, `user_login_timestamp`) VALUES
	(1, 'tipani', 'tipaja', 'Tiffany Jacklin', 'Jalan Jeruk', 'P', '2003-03-13', 'tipaja@gmail.com', '081000888333', 'uploads/users/lena.png', '2024-07-18 13:48:04', NULL, NULL, '2024-08-07 11:19:43'),
	(2, 'danielll', 'danielaja', 'Daniel Alexander', 'Jalan leci', 'L', '2003-01-01', 'danielaja@gmail.com', '081000888111', NULL, '2023-07-12 14:30:45', NULL, NULL, '2024-07-29 11:15:28'),
	(3, 'alexlo', 'alexaja', 'Alexander Louis', 'Jalan mangga', 'L', '2003-02-02', 'alexaja@gmail.com', '081000888222', NULL, '2023-08-12 14:30:45', NULL, NULL, '2024-07-29 11:31:45');

-- Dumping structure for table toserba.user_privileges
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

-- Dumping structure for table toserba.warehouses
CREATE TABLE IF NOT EXISTS `warehouses` (
  `warehouse_id` int(11) NOT NULL AUTO_INCREMENT,
  `warehouse_name` varchar(255) NOT NULL,
  `warehouse_address` varchar(255) NOT NULL,
  `warehouse_phone_number` varchar(255) NOT NULL,
  PRIMARY KEY (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table toserba.warehouses: ~0 rows (approximately)

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
