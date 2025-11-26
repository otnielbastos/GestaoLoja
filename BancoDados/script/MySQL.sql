-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: loja_organizada
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auditoria`
--

DROP TABLE IF EXISTS `auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `acao` varchar(100) NOT NULL,
  `tabela` varchar(50) DEFAULT NULL,
  `registro_id` int(11) DEFAULT NULL,
  `dados_antigos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`dados_antigos`)),
  `dados_novos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`dados_novos`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `data_acao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_usuario_id` (`usuario_id`),
  KEY `idx_data_acao` (`data_acao`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
INSERT INTO `auditoria` VALUES (1,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 18:30:34'),(2,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 18:53:38'),(3,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:03:05'),(4,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:13:45'),(5,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:36:14'),(6,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:43:24'),(7,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:43:28'),(8,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:45:16'),(9,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:45:20'),(10,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:03:51'),(11,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:09:48'),(12,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:12:27'),(13,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:12:32'),(14,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:22:24'),(15,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:22:29'),(16,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:23:08'),(17,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:23:13'),(18,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:25:58'),(19,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:30:12'),(20,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:30:15'),(21,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:31:31'),(22,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:33:26'),(23,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:33:28'),(24,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:34:57'),(25,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:34:59'),(26,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:35:31'),(27,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:35:34'),(28,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:04'),(29,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:08'),(30,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:14'),(31,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:18'),(32,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:23'),(33,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:35'),(34,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:37:54'),(35,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:39:03'),(36,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:39:05'),(37,2,'LOGOUT','usuarios',2,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-09 00:21:21'),(38,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-09 00:21:47'),(39,2,'LOGIN','usuarios',2,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-09 00:26:22'),(40,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-11 02:34:41');
/*!40000 ALTER TABLE `auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backup_produtos_estoque_20241204`
--

DROP TABLE IF EXISTS `backup_produtos_estoque_20241204`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `backup_produtos_estoque_20241204` (
  `id` int(11) NOT NULL DEFAULT 0,
  `nome` varchar(255) NOT NULL,
  `quantidade_atual` int(11) NOT NULL DEFAULT 0,
  `quantidade_pronta_entrega` int(11) NOT NULL DEFAULT 0,
  `quantidade_encomenda` int(11) NOT NULL DEFAULT 0,
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `data_backup` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backup_produtos_estoque_20241204`
--

LOCK TABLES `backup_produtos_estoque_20241204` WRITE;
/*!40000 ALTER TABLE `backup_produtos_estoque_20241204` DISABLE KEYS */;
INSERT INTO `backup_produtos_estoque_20241204` VALUES (14,'Nhoque Tradicional - 500g',5,5,0,'2025-06-06 03:00:14','2025-06-06 00:09:03'),(15,'Nhoque Recheado Mussarela - 500g',0,0,0,'2025-06-06 01:48:26','2025-06-06 00:09:03'),(16,'Nhoque Recheado Mussarela com Catupiry - 500g',0,0,0,'2025-06-05 00:45:19','2025-06-06 00:09:03'),(17,'Nhoque Recheado Presunto com Mussarela - 500g',0,0,0,'2025-06-05 00:45:19','2025-06-06 00:09:03'),(18,'Nhoque Recheado Calabresa com Mussarela - 500g',0,0,0,'2025-06-05 00:45:19','2025-06-06 00:09:03'),(19,'Molho ao Sugo Extrato - 500ml',0,0,0,'2025-06-05 00:45:19','2025-06-06 00:09:03'),(20,'Molho Bolonhesa Extrato - 500ml',0,0,0,'2025-06-05 00:45:19','2025-06-06 00:09:03'),(21,'Refrigerante Coca-Cola - Lata 350ml',0,0,0,'2025-06-05 00:45:19','2025-06-06 00:09:03'),(22,'Refrigerante Coca-Cola Zero - Lata 350ml',0,0,0,'2025-06-05 00:45:19','2025-06-06 00:09:03'),(23,'Refrigerante Guarana Antartica - Lata 269ml',0,0,0,'2025-06-05 00:45:19','2025-06-06 00:09:03'),(25,'Caldo Verde',0,0,0,'2025-06-06 02:57:43','2025-06-06 00:09:03'),(26,'Molho ao Sugo Natural - 500ml',0,0,0,'2025-06-06 01:48:26','2025-06-06 00:09:03');
/*!40000 ALTER TABLE `backup_produtos_estoque_20241204` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `cpf_cnpj` varchar(20) DEFAULT NULL,
  `tipo_pessoa` enum('fisica','juridica') NOT NULL,
  `endereco_rua` varchar(255) DEFAULT NULL,
  `endereco_numero` varchar(20) DEFAULT NULL,
  `endereco_complemento` varchar(100) DEFAULT NULL,
  `endereco_bairro` varchar(100) DEFAULT NULL,
  `endereco_cidade` varchar(100) DEFAULT NULL,
  `endereco_estado` char(2) DEFAULT NULL,
  `endereco_cep` varchar(10) DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  `status` enum('ativo','inativo') DEFAULT 'ativo',
  `data_cadastro` timestamp NOT NULL DEFAULT current_timestamp(),
  `criado_por` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `cpf_cnpj` (`cpf_cnpj`),
  KEY `idx_clientes_criado_por` (`criado_por`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'Silvana Lara Machado','silvanalm01@hotmail.com','1193219184','13070958877','fisica','Rua Jose da Silva','55','Apto 44','Centro','Osasco','SP','061112120','Teste ','ativo','2025-06-08 18:31:28',1),(2,'Cliente do Vendedor Otniel','vendedor@teste.com.br','1193219184',NULL,'fisica','Rua Cravo','82',NULL,'Jardim das Flores','Osasco','SP','0612555',NULL,'ativo','2025-06-08 19:44:30',2);
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracoes_relatorios`
--

DROP TABLE IF EXISTS `configuracoes_relatorios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracoes_relatorios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `filtros` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`filtros`)),
  `periodo_padrao` varchar(50) DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracoes_relatorios`
--

LOCK TABLES `configuracoes_relatorios` WRITE;
/*!40000 ALTER TABLE `configuracoes_relatorios` DISABLE KEYS */;
/*!40000 ALTER TABLE `configuracoes_relatorios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entregas`
--

DROP TABLE IF EXISTS `entregas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entregas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pedido_id` int(11) NOT NULL,
  `status` enum('aguardando','em_rota','entregue','cancelada') NOT NULL,
  `data_agendada` date DEFAULT NULL,
  `periodo_entrega` enum('manha','tarde','noite') DEFAULT NULL,
  `endereco_entrega_rua` varchar(255) NOT NULL,
  `endereco_entrega_numero` varchar(20) DEFAULT NULL,
  `endereco_entrega_complemento` varchar(100) DEFAULT NULL,
  `endereco_entrega_bairro` varchar(100) DEFAULT NULL,
  `endereco_entrega_cidade` varchar(100) DEFAULT NULL,
  `endereco_entrega_estado` char(2) DEFAULT NULL,
  `endereco_entrega_cep` varchar(10) DEFAULT NULL,
  `transportadora` varchar(100) DEFAULT NULL,
  `codigo_rastreamento` varchar(50) DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  CONSTRAINT `entregas_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entregas`
--

LOCK TABLES `entregas` WRITE;
/*!40000 ALTER TABLE `entregas` DISABLE KEYS */;
/*!40000 ALTER TABLE `entregas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estoque`
--

DROP TABLE IF EXISTS `estoque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estoque` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `produto_id` int(11) NOT NULL,
  `quantidade_atual` int(11) NOT NULL DEFAULT 0,
  `quantidade_pronta_entrega` int(11) NOT NULL DEFAULT 0,
  `quantidade_encomenda` int(11) NOT NULL DEFAULT 0,
  `ultima_atualizacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `produto_id` (`produto_id`),
  CONSTRAINT `estoque_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estoque`
--

LOCK TABLES `estoque` WRITE;
/*!40000 ALTER TABLE `estoque` DISABLE KEYS */;
INSERT INTO `estoque` VALUES (1,14,7,7,0,'2025-06-08 19:45:08'),(2,25,0,0,0,'2025-06-08 18:55:49');
/*!40000 ALTER TABLE `estoque` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itens_pedido`
--

DROP TABLE IF EXISTS `itens_pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `itens_pedido` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pedido_id` int(11) NOT NULL,
  `produto_id` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `preco_unitario` decimal(10,2) NOT NULL,
  `desconto_valor` decimal(10,2) DEFAULT 0.00,
  `desconto_percentual` decimal(5,2) DEFAULT 0.00,
  `tipo_desconto` enum('valor','percentual') DEFAULT 'valor',
  `preco_unitario_com_desconto` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  KEY `produto_id` (`produto_id`),
  CONSTRAINT `itens_pedido_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`),
  CONSTRAINT `itens_pedido_ibfk_2` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itens_pedido`
--

LOCK TABLES `itens_pedido` WRITE;
/*!40000 ALTER TABLE `itens_pedido` DISABLE KEYS */;
INSERT INTO `itens_pedido` VALUES (1,1,25,10,25.00,0.00,0.00,'valor',25.00,250.00),(2,2,14,1,25.00,0.00,0.00,'valor',25.00,25.00),(3,3,14,1,25.00,0.00,0.00,'valor',25.00,25.00),(4,4,14,1,25.00,0.00,0.00,'valor',25.00,25.00),(5,5,14,4,25.00,0.00,0.00,'valor',25.00,100.00),(6,6,14,1,25.00,0.00,0.00,'valor',25.00,25.00);
/*!40000 ALTER TABLE `itens_pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `log_operacoes_automaticas`
--

DROP TABLE IF EXISTS `log_operacoes_automaticas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_operacoes_automaticas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pedido_id` int(11) NOT NULL,
  `tipo_operacao` enum('entrada_estoque','saida_estoque') NOT NULL,
  `status_anterior` varchar(50) DEFAULT NULL,
  `status_novo` varchar(50) DEFAULT NULL,
  `produtos_afetados` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`produtos_afetados`)),
  `data_operacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `observacoes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  CONSTRAINT `log_operacoes_automaticas_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_operacoes_automaticas`
--

LOCK TABLES `log_operacoes_automaticas` WRITE;
/*!40000 ALTER TABLE `log_operacoes_automaticas` DISABLE KEYS */;
INSERT INTO `log_operacoes_automaticas` VALUES (1,1,'entrada_estoque','em_preparo','produzido','[{\"produto_id\":25,\"quantidade\":10,\"operacao\":\"entrada\",\"tipo_estoque\":\"encomenda\"}]','2025-06-08 18:55:27','Entrada automática por conclusão da produção - ESTOQUE DE ENCOMENDA'),(2,1,'saida_estoque','pronto','entregue','[{\"produto_id\":25,\"quantidade\":10,\"operacao\":\"saida\",\"tipo_estoque\":\"encomenda\"}]','2025-06-08 18:55:49','Saída automática por entrega - Tipo: encomenda - Estoque: encomenda'),(3,2,'saida_estoque','pronto','entregue','[{\"produto_id\":14,\"quantidade\":1,\"operacao\":\"saida\",\"tipo_estoque\":\"pronta_entrega\"}]','2025-06-08 18:56:06','Saída automática por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),(4,3,'saida_estoque','pronto','entregue','[{\"produto_id\":14,\"quantidade\":1,\"operacao\":\"saida\",\"tipo_estoque\":\"pronta_entrega\"}]','2025-06-08 19:22:25','Saída automática por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),(5,4,'saida_estoque','pronto','entregue','[{\"produto_id\":14,\"quantidade\":1,\"operacao\":\"saida\",\"tipo_estoque\":\"pronta_entrega\"}]','2025-06-08 19:23:06','Saída automática por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),(6,5,'saida_estoque','pronto','entregue','[{\"produto_id\":14,\"quantidade\":4,\"operacao\":\"saida\",\"tipo_estoque\":\"pronta_entrega\"}]','2025-06-08 19:24:06','Saída automática por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega'),(7,6,'saida_estoque','pronto','entregue','[{\"produto_id\":14,\"quantidade\":1,\"operacao\":\"saida\",\"tipo_estoque\":\"pronta_entrega\"}]','2025-06-08 19:45:08','Saída automática por entrega - Tipo: pronta_entrega - Estoque: pronta_entrega');
/*!40000 ALTER TABLE `log_operacoes_automaticas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimentacoes_estoque`
--

DROP TABLE IF EXISTS `movimentacoes_estoque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimentacoes_estoque` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `produto_id` int(11) NOT NULL,
  `tipo_movimento` enum('entrada','saida','ajuste') NOT NULL,
  `quantidade` int(11) NOT NULL,
  `motivo` varchar(100) NOT NULL,
  `valor` decimal(10,2) DEFAULT NULL,
  `documento_referencia` varchar(50) DEFAULT NULL,
  `pedido_id` int(11) DEFAULT NULL,
  `tipo_operacao` enum('manual','automatica') DEFAULT 'manual',
  `tipo_estoque` enum('pronta_entrega','encomenda') DEFAULT 'pronta_entrega',
  `data_movimentacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_fabricacao` date DEFAULT NULL,
  `data_validade` date DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `observacao` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `produto_id` (`produto_id`),
  KEY `fk_movimentacao_pedido` (`pedido_id`),
  CONSTRAINT `fk_movimentacao_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE SET NULL,
  CONSTRAINT `movimentacoes_estoque_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimentacoes_estoque`
--

LOCK TABLES `movimentacoes_estoque` WRITE;
/*!40000 ALTER TABLE `movimentacoes_estoque` DISABLE KEYS */;
INSERT INTO `movimentacoes_estoque` VALUES (1,14,'entrada',15,'Produção',NULL,NULL,NULL,'manual','pronta_entrega','2025-06-08 18:32:45','2025-06-08','2025-09-08',NULL,NULL),(2,25,'entrada',10,'Produção finalizada - Encomenda',NULL,'#1',1,'automatica','encomenda','2025-06-08 18:55:27','2025-06-08',NULL,NULL,'Entrada automática por conclusão de produção - ESTOQUE DE ENCOMENDA'),(3,25,'saida',10,'Entrega - Encomenda',NULL,'#1',1,'automatica','encomenda','2025-06-08 18:55:49',NULL,NULL,NULL,'Saída automática por entrega realizada'),(4,14,'saida',1,'Venda - Pronta Entrega',NULL,'#2',2,'automatica','pronta_entrega','2025-06-08 18:56:06',NULL,NULL,NULL,'Saída automática por entrega realizada'),(5,14,'saida',1,'Venda - Pronta Entrega',NULL,'#3',3,'automatica','pronta_entrega','2025-06-08 19:22:25',NULL,NULL,NULL,'Saída automática por entrega realizada'),(6,14,'saida',1,'Venda - Pronta Entrega',NULL,'#4',4,'automatica','pronta_entrega','2025-06-08 19:23:06',NULL,NULL,NULL,'Saída automática por entrega realizada'),(7,14,'saida',4,'Venda - Pronta Entrega',NULL,'#5',5,'automatica','pronta_entrega','2025-06-08 19:24:06',NULL,NULL,NULL,'Saída automática por entrega realizada'),(8,14,'saida',1,'Venda - Pronta Entrega',NULL,'#6',6,'automatica','pronta_entrega','2025-06-08 19:45:08',NULL,NULL,NULL,'Saída automática por entrega realizada');
/*!40000 ALTER TABLE `movimentacoes_estoque` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cliente_id` int(11) NOT NULL,
  `numero_pedido` varchar(50) NOT NULL,
  `data_pedido` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('pendente','aprovado','aguardando_producao','em_preparo','em_separacao','produzido','pronto','em_entrega','entregue','concluido','cancelado') NOT NULL DEFAULT 'pendente',
  `tipo` enum('pronta_entrega','encomenda') NOT NULL DEFAULT 'pronta_entrega',
  `data_entrega_prevista` date DEFAULT NULL,
  `horario_entrega` time DEFAULT NULL,
  `valor_total` decimal(10,2) NOT NULL,
  `forma_pagamento` varchar(50) NOT NULL,
  `status_pagamento` enum('pendente','pago','parcial') NOT NULL DEFAULT 'pendente',
  `valor_pago` decimal(10,2) DEFAULT 0.00,
  `data_pagamento` timestamp NULL DEFAULT NULL,
  `observacoes_pagamento` text DEFAULT NULL,
  `data_entrega` timestamp NULL DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  `observacoes_producao` text DEFAULT NULL,
  `estoque_processado` tinyint(1) DEFAULT 0,
  `criado_por` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `numero_pedido` (`numero_pedido`),
  KEY `cliente_id` (`cliente_id`),
  KEY `idx_pedidos_tipo` (`tipo`),
  KEY `idx_pedidos_data_entrega` (`data_entrega_prevista`),
  KEY `idx_pedidos_status_tipo` (`status`,`tipo`),
  KEY `idx_pedidos_criado_por` (`criado_por`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (1,1,'#001','2025-06-08 18:32:09','concluido','encomenda','2025-06-09','15:31:00',250.00,'Cartão de Crédito','pago',250.00,'2025-06-08 18:55:54','',NULL,'','',1,1),(2,1,'#002','2025-06-08 18:33:08','concluido','pronta_entrega',NULL,NULL,25.00,'Cartão de Crédito','pago',25.00,'2025-06-08 18:56:14','',NULL,'','',0,1),(3,1,'#003','2025-06-06 19:22:14','concluido','pronta_entrega',NULL,NULL,25.00,'PIX','pago',25.00,'2025-06-08 19:22:29','',NULL,'','',0,1),(4,1,'#004','2025-06-06 19:22:59','concluido','pronta_entrega',NULL,NULL,25.00,'Dinheiro','pago',25.00,'2025-06-08 19:23:10','',NULL,'','',0,1),(5,1,'#005','2025-06-08 19:23:59','concluido','pronta_entrega',NULL,NULL,100.00,'Dinheiro','pago',100.00,'2025-06-08 19:24:10','',NULL,'','',0,1),(6,2,'#006','2025-06-08 19:45:01','concluido','pronta_entrega',NULL,NULL,25.00,'Dinheiro','pago',25.00,'2025-06-08 19:45:12','',NULL,'','',0,2);
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perfis`
--

DROP TABLE IF EXISTS `perfis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfis` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `permissoes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissoes`)),
  `ativo` tinyint(1) DEFAULT 1,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfis`
--

LOCK TABLES `perfis` WRITE;
/*!40000 ALTER TABLE `perfis` DISABLE KEYS */;
INSERT INTO `perfis` VALUES (1,'Administrador','Acesso total ao sistema','{\"usuarios\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"clientes\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"pedidos\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"produtos\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"estoque\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"entregas\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"relatorios\":[\"criar\",\"listar\",\"editar\",\"excluir\"]}',1,'2025-06-04 05:51:21','2025-06-04 06:59:58'),(2,'Gerente','Acesso a todos os módulos exceto usuários','{\"usuarios\":[],\"clientes\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"pedidos\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"produtos\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"estoque\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"entregas\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"relatorios\":[\"criar\",\"listar\",\"editar\",\"excluir\"]}',1,'2025-06-04 05:51:21','2025-06-04 06:59:58'),(3,'Vendedor','Acesso restrito a clientes e pedidos próprios','{\"usuarios\":[],\"clientes\":[\"create\",\"read\",\"update\"],\"pedidos\":[\"create\",\"read\",\"update\"],\"produtos\":[\"read\"],\"financeiro\":[],\"relatorios\":[\"read\"]}',1,'2025-06-04 05:51:21','2025-06-09 00:28:08');
/*!40000 ALTER TABLE `perfis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produtos`
--

DROP TABLE IF EXISTS `produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produtos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco_venda` decimal(10,2) NOT NULL,
  `preco_custo` decimal(10,2) NOT NULL,
  `quantidade_minima` int(11) NOT NULL,
  `categoria` varchar(100) DEFAULT NULL,
  `tipo_produto` enum('producao_propria','revenda','materia_prima') NOT NULL DEFAULT 'producao_propria',
  `unidade_medida` varchar(20) DEFAULT NULL,
  `imagem_url` varchar(255) DEFAULT NULL,
  `status` enum('ativo','inativo') DEFAULT 'ativo',
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtos`
--

LOCK TABLES `produtos` WRITE;
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` VALUES (14,'Nhoque Tradicional - 500g','Nhoque Tradicional de 500g feito de batata,',25.00,6.61,3,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975675797-731946779.jpg','ativo','2025-06-03 18:00:36','2025-06-06 03:00:14'),(15,'Nhoque Recheado Mussarela - 500g','Contem pacote de 500g de nhoque recheado de Mussarela.',40.00,12.72,3,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975772896-582541457.jpg','ativo','2025-06-03 18:03:30','2025-06-06 01:48:26'),(16,'Nhoque Recheado Mussarela com Catupiry - 500g','Pacote de 500g com Nhoque Recheado Mussarela com Catupiry.',40.00,11.18,3,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975798766-619419538.jpg','ativo','2025-06-03 18:04:35','2025-06-05 00:45:19'),(17,'Nhoque Recheado Presunto com Mussarela - 500g','Pacote de 500g de Nhoque Recheado Presunto com Mussarela.',40.00,10.42,3,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975822395-385952879.jpg','ativo','2025-06-03 18:05:33','2025-06-05 00:45:19'),(18,'Nhoque Recheado Calabresa com Mussarela - 500g','Pacote de 500g de Nhoque Recheado Calabresa com Mussarela.',40.00,10.37,3,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975843109-869330303.jpg','ativo','2025-06-03 18:06:19','2025-06-05 00:45:19'),(19,'Molho ao Sugo Extrato - 500ml','Pote de 500ml de molho de extrato de tomate.',20.00,7.74,3,'Molho','producao_propria','Pote','/uploads/produtos/1748975880417-190043038.jpg','ativo','2025-06-03 18:09:17','2025-06-05 00:45:19'),(20,'Molho Bolonhesa Extrato - 500ml','Pote de 500ml de molho de extrato de tomate',20.00,12.64,3,'Molho','producao_propria','Pote','/uploads/produtos/1748975904643-820407538.jpg','ativo','2025-06-03 18:10:18','2025-06-05 00:45:19'),(21,'Refrigerante Coca-Cola - Lata 350ml','Refrigerante Coca-Cola - Lata 350ml',3.00,7.90,5,'Bebidas','revenda','Latas','/uploads/produtos/1748988215446-707073668.png','ativo','2025-06-03 18:12:07','2025-06-05 00:45:19'),(22,'Refrigerante Coca-Cola Zero - Lata 350ml','Refrigerante Coca-Cola Zero - Lata 350ml',3.00,7.90,5,'Bebidas','revenda','Latas','/uploads/produtos/1748988382869-601995256.png','ativo','2025-06-03 18:12:52','2025-06-05 00:45:19'),(23,'Refrigerante Guarana Antartica - Lata 269ml','Refrigerante Guarana Antartica - Lata 269ml',3.00,4.99,5,'Bebidas','revenda','Latas','/uploads/produtos/1748988278894-87367356.png','ativo','2025-06-03 18:13:29','2025-06-05 00:45:19'),(25,'Caldo Verde','',25.00,9.23,2,'Caldo','producao_propria','pote','/uploads/produtos/1749062849455-744863486.jpg','ativo','2025-06-04 18:05:14','2025-06-06 02:57:43'),(26,'Molho ao Sugo Natural - 500ml','Molho ao Sugo Natural - 500ml',15.00,7.02,2,'Molho','producao_propria','Pote','/uploads/produtos/1749062876280-551634345.jpg','ativo','2025-06-04 18:19:52','2025-06-06 01:48:26');
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessoes`
--

DROP TABLE IF EXISTS `sessoes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_expiracao` timestamp NULL DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_usuario_id` (`usuario_id`),
  KEY `idx_token` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessoes`
--

LOCK TABLES `sessoes` WRITE;
/*!40000 ALTER TABLE `sessoes` DISABLE KEYS */;
INSERT INTO `sessoes` VALUES (1,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQwNzQzNCwiZXhwIjoxNzQ5NDM2MjM0fQ.ScNHPgQWwOWXUVprY7vZZpkF4j2eSmnDUpDY4_CYtYg','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 18:30:34','2025-06-09 02:30:34',1),(2,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQwODgxOCwiZXhwIjoxNzQ5NDM3NjE4fQ.i8h50YVpWWW1nMaujes5JBZ5EMW3DKGHt6QY0m49cOU','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 18:53:38','2025-06-09 02:53:38',1),(3,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQwOTM4NSwiZXhwIjoxNzQ5NDM4MTg1fQ.YW5jYv-useq8vsD1kubeV_u-MWP0Ch63mCDgqINiHjI','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:03:05','2025-06-09 03:03:05',1),(4,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQxMDAyNSwiZXhwIjoxNzQ5NDM4ODI1fQ._4GZzJHeAPy9KgOSCpei5JSHUckRkeiulHkmDJmpU5s','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:13:45','2025-06-09 03:13:45',1),(5,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQxMTM3NCwiZXhwIjoxNzQ5NDQwMTc0fQ.JDaqa5-zSE36j152BDfVHfe_yjKzdX_sxMVRwi4Uff0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:36:14','2025-06-09 03:36:14',0),(6,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxMTgwOCwiZXhwIjoxNzQ5NDQwNjA4fQ.JJy1RA9W3qBHjtnaGX3VC4zkXAVqIG8OzDyoevuBPgE','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:43:28','2025-06-09 03:43:28',0),(7,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQxMTkyMCwiZXhwIjoxNzQ5NDQwNzIwfQ.yGtlKaQBwR8J-vgsecJRicwSKWxWhb8EHETboQsnLDk','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:45:20','2025-06-09 03:45:20',1),(8,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQxMzAzMSwiZXhwIjoxNzQ5NDQxODMxfQ.M6kj9oZx9175akMcmhL5At1cBULJ-oTPW3gVR07bJwk','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:03:51','2025-06-09 04:03:51',1),(9,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQxMzM4OCwiZXhwIjoxNzQ5NDQyMTg4fQ.hej6ML4B7tIP7FlhgbnjN5vOvjPX_isXtACofQY9S0M','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:09:48','2025-06-09 04:09:48',0),(10,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxMzU1MSwiZXhwIjoxNzQ5NDQyMzUxfQ._NQ7a1BdWvN4B5tO6Hv_jT13gcwB4EN-BM8BAJJzCTM','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:12:31','2025-06-09 04:12:31',0),(11,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQxNDE0OSwiZXhwIjoxNzQ5NDQyOTQ5fQ.YQLzXE4fsnASW80k5cMluhcsM-_wb0cISFSVbY1VvU4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:22:29','2025-06-09 04:22:29',0),(12,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNDE5MywiZXhwIjoxNzQ5NDQyOTkzfQ.jKDFqvRF3f5JubdHfZg30rHyfcp_MzrXXuAiqnqdCCA','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:23:13','2025-06-09 04:23:13',1),(13,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNDM1OCwiZXhwIjoxNzQ5NDQzMTU4fQ.gHaAo2LjgD3KoyTp_k8R0HLSxEdAbo0TvKfd-1aVnxE','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:25:58','2025-06-09 04:25:58',0),(14,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNDYxNSwiZXhwIjoxNzQ5NDQzNDE1fQ.A9u_h45g6eCX7FEj72owqIfM66mysGLGQXwXWGCX0-8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:30:15','2025-06-09 04:30:15',1),(15,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNDY5MSwiZXhwIjoxNzQ5NDQzNDkxfQ.7SGZhVT3zwNI0A4kL08IDtS1wf1obSaZMXXmc_P27R8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:31:31','2025-06-09 04:31:31',0),(16,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNDgwOCwiZXhwIjoxNzQ5NDQzNjA4fQ.XbkJlNxRpI4FxKFv4aNxBbUGkYYZqvMq0kxb5VaifTA','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:33:28','2025-06-09 04:33:28',0),(17,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNDg5OSwiZXhwIjoxNzQ5NDQzNjk5fQ.A5G2I_OXwJg8HViy7bSTLqnbzCXOMaB-FTf9idWgijQ','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:34:59','2025-06-09 04:34:59',0),(18,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQxNDkzNCwiZXhwIjoxNzQ5NDQzNzM0fQ.rvjNX1x4_sgc8SZz2jQQ6acV3ORSKv-7DScgxM3Ve-M','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:35:34','2025-06-09 04:35:34',0),(19,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNDk2OCwiZXhwIjoxNzQ5NDQzNzY4fQ.3CUupxbIfwJ2hWrjSORqhljNQs_dTyAClePzh4d0gKg','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:08','2025-06-09 04:36:08',0),(20,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTQxNDk3OCwiZXhwIjoxNzQ5NDQzNzc4fQ.5BNJVR9X15Wfhe3JgZ80XWp1oPRfWJXG3Wg7VWa3ZrM','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:18','2025-06-09 04:36:18',0),(21,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNDk5NSwiZXhwIjoxNzQ5NDQzNzk1fQ.xR7yu8lS_lVoLbhdPmb8vOZ2Ve_T19chuMxRJiVA2R0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:35','2025-06-09 04:36:35',1),(22,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNTA3NCwiZXhwIjoxNzQ5NDQzODc0fQ.tA7P_23YeYZvCRYrrCOwyJ_aCzhRHWwHzrA5gPebmsc','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:37:54','2025-06-09 04:37:54',0),(23,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQxNTE0NSwiZXhwIjoxNzQ5NDQzOTQ1fQ.ktELXK70555-CnCQq9QJwO6Mu6zLP0xES7KKPw8zaOc','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:39:05','2025-06-09 04:39:05',0),(24,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQyODUwNywiZXhwIjoxNzQ5NDU3MzA3fQ.WiUS8qmCp8mseYKaZX-TjDA6U1j6OKMrgPMX7zZyiyw','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-09 00:21:47','2025-06-09 08:21:47',1),(25,2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTc0OTQyODc4MiwiZXhwIjoxNzQ5NDU3NTgyfQ.mHXa3gfXfJfVFRhq5_jBNjiIVk6TXoGHajfTyn32MmM','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-09 00:26:22','2025-06-09 08:26:22',1),(26,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTYwOTI4MSwiZXhwIjoxNzQ5NjM4MDgxfQ.bB1VKip-E15zpUdr6iYs9fPIWuJ5ysZ4Mmg-RJQcLvQ','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-11 02:34:41','2025-06-11 10:34:41',1);
/*!40000 ALTER TABLE `sessoes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tentativas_login`
--

DROP TABLE IF EXISTS `tentativas_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tentativas_login` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `sucesso` tinyint(1) DEFAULT NULL,
  `motivo` varchar(100) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `data_tentativa` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_ip_address` (`ip_address`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tentativas_login`
--

LOCK TABLES `tentativas_login` WRITE;
/*!40000 ALTER TABLE `tentativas_login` DISABLE KEYS */;
INSERT INTO `tentativas_login` VALUES (1,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 18:30:34'),(2,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 18:53:38'),(3,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:03:05'),(4,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:13:45'),(5,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:36:14'),(6,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:43:28'),(7,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 19:45:20'),(8,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:03:51'),(9,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:09:48'),(10,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:12:31'),(11,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:22:29'),(12,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:23:13'),(13,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:25:58'),(14,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:30:15'),(15,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:31:31'),(16,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:33:28'),(17,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:34:59'),(18,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:35:34'),(19,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:08'),(20,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:18'),(21,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:36:35'),(22,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:37:54'),(23,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-08 20:39:05'),(24,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-09 00:21:47'),(25,'otnielbastos@hotmail.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-09 00:26:22'),(26,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-11 02:34:34'),(27,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-11 02:34:41');
/*!40000 ALTER TABLE `tentativas_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transferencias_estoque`
--

DROP TABLE IF EXISTS `transferencias_estoque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transferencias_estoque` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `produto_id` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `origem` enum('pronta_entrega','encomenda') NOT NULL,
  `destino` enum('pronta_entrega','encomenda') NOT NULL,
  `motivo` varchar(255) NOT NULL,
  `pedido_id` int(11) DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `observacao` text DEFAULT NULL,
  `data_transferencia` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  KEY `idx_transferencias_produto` (`produto_id`),
  KEY `idx_transferencias_data` (`data_transferencia`),
  CONSTRAINT `transferencias_estoque_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`),
  CONSTRAINT `transferencias_estoque_ibfk_2` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transferencias_estoque`
--

LOCK TABLES `transferencias_estoque` WRITE;
/*!40000 ALTER TABLE `transferencias_estoque` DISABLE KEYS */;
/*!40000 ALTER TABLE `transferencias_estoque` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `cargo` varchar(50) DEFAULT NULL,
  `status` enum('ativo','inativo') DEFAULT 'ativo',
  `ultimo_acesso` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `perfil_id` int(11) DEFAULT NULL,
  `senha_hash` varchar(255) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  `token_reset` varchar(255) DEFAULT NULL,
  `token_reset_expira` timestamp NULL DEFAULT NULL,
  `tentativas_login` int(11) DEFAULT 0,
  `bloqueado_ate` timestamp NULL DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `criado_por` int(11) DEFAULT NULL,
  `atualizado_por` int(11) DEFAULT NULL,
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Administrador','admin@silosystem.com','','','ativo','2025-06-11 02:34:40','2025-06-04 05:53:50',1,'$2b$12$WRm7Q5F4D2Oic62x0yq2xuv5oIeI8Qf5tF1BfIJPCSqqHLCDCP40K',NULL,NULL,NULL,0,NULL,1,NULL,1,'2025-06-11 02:34:40'),(2,'Otniel Bastos Machado','otnielbastos@hotmail.com','',NULL,'ativo','2025-06-09 00:26:22','2025-06-08 16:55:09',3,'$2b$12$/oCkAgLY.oRMNcCfuRdBcu8veEndHl16x6SNEgTmvPfdC2qQ/iU2a',NULL,NULL,NULL,0,NULL,1,1,NULL,'2025-06-09 00:26:22');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_estoque_completo`
--

DROP TABLE IF EXISTS `vw_estoque_completo`;
/*!50001 DROP VIEW IF EXISTS `vw_estoque_completo`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_estoque_completo` AS SELECT 
 1 AS `produto_id`,
 1 AS `produto_nome`,
 1 AS `categoria`,
 1 AS `unidade_medida`,
 1 AS `quantidade_minima`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_estoque_completo`
--

/*!50001 DROP VIEW IF EXISTS `vw_estoque_completo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_estoque_completo` AS select `p`.`id` AS `produto_id`,`p`.`nome` AS `produto_nome`,`p`.`categoria` AS `categoria`,`p`.`unidade_medida` AS `unidade_medida`,`p`.`quantidade_minima` AS `quantidade_minima` from `produtos` `p` where `p`.`status` = 'ativo' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-10 23:36:16
