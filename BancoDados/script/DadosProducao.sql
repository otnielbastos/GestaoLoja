-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
INSERT INTO `auditoria` VALUES (1,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT; Windows NT 10.0; pt-BR) WindowsPowerShell/5.1.26100.4061\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; pt-BR) WindowsPowerShell/5.1.26100.4061','2025-06-04 06:27:32'),(2,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:28:44'),(3,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:34:00'),(4,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:34:03'),(5,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:43:22'),(6,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:43:27'),(7,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:44:38'),(8,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:46:17'),(9,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:55:30'),(10,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 07:17:38'),(11,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 16:33:25'),(12,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 17:07:12'),(13,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 17:07:14'),(14,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 17:43:13'),(15,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 17:43:15'),(16,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:05:37'),(17,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:05:38'),(18,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:19:54'),(19,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:19:56'),(20,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:42:43'),(21,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:42:45');
/*!40000 ALTER TABLE `auditoria` ENABLE KEYS */;
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `cpf_cnpj` (`cpf_cnpj`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (11,'Cliente teste','silvanalm01@hotmail.com','1193219184',NULL,'fisica','Rua Jose','55',NULL,'1234',NULL,NULL,NULL,NULL,'ativo','2025-06-04 01:42:17'),(12,'Edilene','otnielbastos@hotmail.com','(11) 97676-4214',NULL,'fisica','Apto','44','Apto 44','1234','Osasco','SP','06040-470',NULL,'ativo','2025-06-04 17:10:56'),(13,'Restaurante Alta Dose',NULL,'(11) 99124-8402',NULL,'juridica','Rua Crisantemo',NULL,NULL,'Jardim das Flores','Osasco','SP',NULL,'Representante Jeverson','ativo','2025-06-04 17:33:18'),(14,'Katia - Condominio',NULL,'(11) 97236-3991',NULL,'fisica','Rua Lazaro Suave','283','Apto. 71','City Bussocaba',NULL,NULL,NULL,NULL,'ativo','2025-06-04 18:08:32'),(15,'Nilza Bastos',NULL,'(11) 98186-6587',NULL,'fisica','.',NULL,NULL,'.',NULL,NULL,NULL,NULL,'ativo','2025-06-04 18:12:18'),(16,'Ana Paula (Comanda Sampaio)',NULL,'(11) 95158-6073',NULL,'fisica','.',NULL,NULL,'.',NULL,NULL,NULL,NULL,'ativo','2025-06-04 18:14:03'),(17,'Irma Nina',NULL,'(11) 98374-1056',NULL,'fisica','.',NULL,NULL,'.',NULL,NULL,NULL,NULL,'ativo','2025-06-04 18:17:02'),(18,'Fernanda Lara Machado',NULL,'(15) 98164-7393',NULL,'fisica','Rua La','283','Apto 44','City Bussocaba','Osasco','SP',NULL,NULL,'ativo','2025-06-04 18:23:43');
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
  `ultima_atualizacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `produto_id` (`produto_id`),
  CONSTRAINT `estoque_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estoque`
--

LOCK TABLES `estoque` WRITE;
/*!40000 ALTER TABLE `estoque` DISABLE KEYS */;
INSERT INTO `estoque` VALUES (10,14,48,'2025-06-04 18:10:41'),(11,15,22,'2025-06-04 17:46:17'),(12,15,22,'2025-06-04 17:46:17'),(13,16,5,'2025-06-04 18:10:41'),(14,14,50,'2025-06-04 18:10:41'),(15,15,29,'2025-06-04 17:49:55'),(16,17,7,'2025-06-04 17:50:32'),(17,18,5,'2025-06-04 17:54:19'),(18,15,50,'2025-06-04 17:52:31'),(19,21,10,'2025-06-04 17:57:05'),(20,22,10,'2025-06-04 17:57:18'),(21,23,10,'2025-06-04 17:57:32'),(22,20,2,'2025-06-04 18:02:56'),(23,19,4,'2025-06-04 18:03:27'),(24,25,3,'2025-06-04 18:06:34'),(25,26,4,'2025-06-04 18:20:46'),(26,14,54,'2025-06-04 18:28:59'),(27,15,51,'2025-06-04 18:29:14'),(28,16,6,'2025-06-04 18:29:32'),(29,18,7,'2025-06-04 18:29:44');
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
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  KEY `produto_id` (`produto_id`),
  CONSTRAINT `itens_pedido_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`),
  CONSTRAINT `itens_pedido_ibfk_2` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itens_pedido`
--

LOCK TABLES `itens_pedido` WRITE;
/*!40000 ALTER TABLE `itens_pedido` DISABLE KEYS */;
INSERT INTO `itens_pedido` VALUES (37,9,14,1,25.00,25.00),(43,10,15,1,40.00,40.00),(46,11,15,20,40.00,800.00),(49,12,16,1,40.00,40.00),(50,12,14,1,25.00,25.00),(51,13,14,2,25.00,50.00),(52,14,14,1,25.00,25.00),(53,14,15,1,40.00,40.00),(55,15,26,4,15.00,60.00),(56,15,18,2,40.00,80.00),(57,16,18,3,40.00,120.00),(58,16,16,3,40.00,120.00),(59,16,19,2,20.00,40.00),(60,17,16,3,40.00,120.00),(61,17,18,2,40.00,80.00);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_operacoes_automaticas`
--

LOCK TABLES `log_operacoes_automaticas` WRITE;
/*!40000 ALTER TABLE `log_operacoes_automaticas` DISABLE KEYS */;
INSERT INTO `log_operacoes_automaticas` VALUES (1,9,'saida_estoque','pronto','entregue','[{\"produto_id\":14,\"quantidade\":1,\"operacao\":\"saida\"}]','2025-06-04 02:18:50','Saída automática por entrega - Tipo: pronta_entrega'),(2,10,'entrada_estoque','em_preparo','produzido','[{\"produto_id\":15,\"quantidade\":1,\"operacao\":\"entrada\"}]','2025-06-04 02:33:38','Entrada automática por conclusão da produção'),(3,12,'saida_estoque','pronto','entregue','[{\"produto_id\":14,\"quantidade\":1,\"operacao\":\"saida\"},{\"produto_id\":16,\"quantidade\":1,\"operacao\":\"saida\"}]','2025-06-04 18:10:41','Saída automática por entrega - Tipo: pronta_entrega');
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
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimentacoes_estoque`
--

LOCK TABLES `movimentacoes_estoque` WRITE;
/*!40000 ALTER TABLE `movimentacoes_estoque` DISABLE KEYS */;
INSERT INTO `movimentacoes_estoque` VALUES (6,14,'entrada',50,'Produção',40.00,NULL,NULL,'manual','2025-06-04 01:43:27','2025-06-03','2025-09-03',NULL,'Teste'),(7,14,'saida',1,'Venda - Pronta Entrega',NULL,'#9',9,'automatica','2025-06-04 02:18:50',NULL,NULL,NULL,'Saída automática por entrega realizada'),(8,15,'entrada',1,'Produção finalizada - Encomenda',NULL,'#10',10,'automatica','2025-06-04 02:33:38','2025-06-03',NULL,NULL,'Entrada automática por conclusão de produção'),(9,15,'entrada',21,'Produção',735.00,NULL,NULL,'manual','2025-06-04 17:45:23','2025-06-03','2025-09-03',NULL,'Desconte de R$ 105,00'),(10,16,'entrada',6,'Produção',40.00,NULL,NULL,'manual','2025-06-04 17:48:50','2025-05-27','2025-08-27',NULL,NULL),(11,14,'entrada',2,'Produção',25.00,NULL,NULL,'manual','2025-06-04 17:49:14','2025-05-12','2025-08-12',NULL,NULL),(12,15,'entrada',7,'Produção',40.00,NULL,NULL,'manual','2025-06-04 17:49:55','2025-05-26','2025-08-26',NULL,NULL),(13,17,'entrada',7,'Produção',39.96,NULL,NULL,'manual','2025-06-04 17:50:32','2025-04-02','2025-07-02',NULL,NULL),(14,18,'entrada',5,'Produção',40.00,NULL,NULL,'manual','2025-06-04 17:50:55','2025-05-21','2025-08-21',NULL,NULL),(15,15,'entrada',21,'Produção',NULL,NULL,NULL,'manual','2025-06-04 17:52:31','2025-06-03','2025-09-03',NULL,NULL),(16,21,'entrada',10,'Compra do fornecedor',7.90,NULL,NULL,'manual','2025-06-04 17:57:05',NULL,NULL,NULL,NULL),(17,22,'entrada',10,'Compra do fornecedor',7.90,NULL,NULL,'manual','2025-06-04 17:57:18',NULL,NULL,NULL,NULL),(18,23,'entrada',10,'Compra do fornecedor',4.99,NULL,NULL,'manual','2025-06-04 17:57:32',NULL,NULL,NULL,NULL),(19,20,'entrada',2,'Produção',NULL,NULL,NULL,'manual','2025-06-04 18:02:56','2025-05-19','2025-07-19',NULL,NULL),(20,19,'entrada',4,'Produção',NULL,NULL,NULL,'manual','2025-06-04 18:03:27','2025-05-05','2025-07-05',NULL,NULL),(21,25,'entrada',3,'Produção',NULL,NULL,NULL,'manual','2025-06-04 18:06:34','2025-05-30','2025-08-30',NULL,NULL),(22,14,'saida',1,'Venda - Pronta Entrega',NULL,'#12',12,'automatica','2025-06-04 18:10:41',NULL,NULL,NULL,'Saída automática por entrega realizada'),(23,16,'saida',1,'Venda - Pronta Entrega',NULL,'#12',12,'automatica','2025-06-04 18:10:41',NULL,NULL,NULL,'Saída automática por entrega realizada'),(24,26,'entrada',4,'Produção',NULL,NULL,NULL,'manual','2025-06-04 18:20:46','2025-05-29','2025-08-29',NULL,NULL),(25,14,'entrada',4,'Produção',NULL,NULL,NULL,'manual','2025-06-04 18:28:59','2025-06-02','2025-09-02',NULL,NULL),(26,15,'entrada',1,'Produção',NULL,NULL,NULL,'manual','2025-06-04 18:29:14','2025-06-02','2025-09-02',NULL,NULL),(27,16,'entrada',1,'Produção',NULL,NULL,NULL,'manual','2025-06-04 18:29:32','2025-06-02','2025-09-02',NULL,NULL),(28,18,'entrada',2,'Produção',NULL,NULL,NULL,'manual','2025-06-04 18:29:44','2025-06-02','2025-09-02',NULL,NULL);
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `numero_pedido` (`numero_pedido`),
  KEY `cliente_id` (`cliente_id`),
  KEY `idx_pedidos_tipo` (`tipo`),
  KEY `idx_pedidos_data_entrega` (`data_entrega_prevista`),
  KEY `idx_pedidos_status_tipo` (`status`,`tipo`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (9,11,'#001','2025-06-04 01:43:51','concluido','pronta_entrega',NULL,NULL,25.00,'Cartão de Crédito','pago',25.00,'2025-06-04 01:45:40','',NULL,'teste','',0),(10,11,'#002','2025-06-04 02:31:22','produzido','encomenda','2025-06-04','12:30:00',40.00,'Cartão de Débito','pendente',0.00,NULL,NULL,NULL,'teste','Teste',1),(11,13,'#003','2025-06-04 17:35:41','pronto','encomenda','2025-06-07','14:00:00',800.00,'PIX','pendente',0.00,NULL,NULL,'2025-06-04 17:37:07','','',0),(12,14,'#004','2025-06-04 18:10:15','concluido','pronta_entrega',NULL,NULL,65.00,'PIX','pago',65.00,'2025-06-04 18:10:49','',NULL,'','',0),(13,15,'#005','2025-06-04 18:12:45','concluido','pronta_entrega',NULL,NULL,50.00,'PIX','pago',50.00,'2025-06-04 18:12:52','',NULL,'','',0),(14,16,'#006','2025-06-04 18:16:08','concluido','pronta_entrega',NULL,NULL,65.00,'PIX','pago',65.00,'2025-06-04 18:16:13','',NULL,'','',0),(15,17,'#007','2025-06-04 18:17:59','pendente','pronta_entrega',NULL,NULL,140.00,'Dinheiro','pago',140.00,'2025-06-04 18:22:26','Falta devolver o troco de R$ 10,00',NULL,'Devo troco de R$ 10,00','',0),(16,18,'#008','2025-06-04 18:25:09','pronto','encomenda','2025-06-07','15:24:00',280.00,'PIX','pendente',0.00,NULL,NULL,NULL,'','',0),(17,12,'#009','2025-06-04 18:26:41','concluido','encomenda','2025-06-05','15:26:00',200.00,'PIX','pendente',0.00,NULL,NULL,'2025-06-04 18:32:20','','',0);
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
INSERT INTO `perfis` VALUES (1,'Administrador','Acesso total ao sistema','{\"usuarios\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"clientes\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"pedidos\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"produtos\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"estoque\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"entregas\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"relatorios\":[\"criar\",\"listar\",\"editar\",\"excluir\"]}',1,'2025-06-04 05:51:21','2025-06-04 06:59:58'),(2,'Gerente','Acesso a todos os módulos exceto usuários','{\"usuarios\":[],\"clientes\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"pedidos\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"produtos\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"estoque\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"entregas\":[\"criar\",\"listar\",\"editar\",\"excluir\"],\"relatorios\":[\"criar\",\"listar\",\"editar\",\"excluir\"]}',1,'2025-06-04 05:51:21','2025-06-04 06:59:58'),(3,'Vendedor','Acesso restrito a clientes e pedidos próprios','{\"usuarios\":[],\"clientes\":[\"criar\",\"listar\",\"editar\"],\"pedidos\":[\"criar\",\"listar\",\"editar\"],\"produtos\":[\"listar\"],\"estoque\":[],\"entregas\":[],\"relatorios\":[]}',1,'2025-06-04 05:51:21','2025-06-04 06:59:58');
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
  `quantidade_atual` int(11) NOT NULL DEFAULT 0,
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
INSERT INTO `produtos` VALUES (14,'Nhoque Simples - 500g','Nhoque Simples de 500g feito de batata,',25.00,6.61,3,54,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975675797-731946779.jpg','ativo','2025-06-03 18:00:36','2025-06-04 18:28:59'),(15,'Nhoque Recheado Mussarela - 500g','Contem pacote de 500g de nhoque recheado de Mussarela.',40.00,12.72,3,51,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975772896-582541457.jpg','ativo','2025-06-03 18:03:30','2025-06-04 18:29:14'),(16,'Nhoque Recheado Mussarela com Catupiry - 500g','Pacote de 500g com Nhoque Recheado Mussarela com Catupiry.',40.00,11.18,3,6,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975798766-619419538.jpg','ativo','2025-06-03 18:04:35','2025-06-04 18:29:32'),(17,'Nhoque Recheado Presunto com Mussarela - 500g','Pacote de 500g de Nhoque Recheado Presunto com Mussarela.',40.00,10.42,3,7,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975822395-385952879.jpg','ativo','2025-06-03 18:05:33','2025-06-04 17:50:32'),(18,'Nhoque Recheado Calabresa com Mussarela - 500g','Pacote de 500g de Nhoque Recheado Calabresa com Mussarela.',40.00,10.37,3,7,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975843109-869330303.jpg','ativo','2025-06-03 18:06:19','2025-06-04 18:29:44'),(19,'Molho ao Sugo Extrato - 500ml','Pote de 500ml de molho de extrato de tomate.',20.00,7.74,3,4,'Molho','producao_propria','Pote','/uploads/produtos/1748975880417-190043038.jpg','ativo','2025-06-03 18:09:17','2025-06-04 18:18:21'),(20,'Molho Bolonhesa Extrato - 500ml','Pote de 500ml de molho de extrato de tomate',20.00,12.64,3,2,'Molho','producao_propria','Pote','/uploads/produtos/1748975904643-820407538.jpg','ativo','2025-06-03 18:10:18','2025-06-04 18:18:31'),(21,'Refrigerante Coca-Cola - Lata 350ml','Refrigerante Coca-Cola - Lata 350ml',3.00,7.90,5,10,'Bebidas','revenda','Latas','/uploads/produtos/1748988215446-707073668.png','ativo','2025-06-03 18:12:07','2025-06-04 17:57:05'),(22,'Refrigerante Coca-Cola Zero - Lata 350ml','Refrigerante Coca-Cola Zero - Lata 350ml',3.00,7.90,5,10,'Bebidas','revenda','Latas','/uploads/produtos/1748988382869-601995256.png','ativo','2025-06-03 18:12:52','2025-06-04 17:57:18'),(23,'Refrigerante Guarana Antartica - Lata 269ml','Refrigerante Guarana Antartica - Lata 269ml',3.00,4.99,5,10,'Bebidas','revenda','Latas','/uploads/produtos/1748988278894-87367356.png','ativo','2025-06-03 18:13:29','2025-06-04 17:57:32'),(25,'Caldo Verde','',25.00,9.23,2,3,'Caldo','producao_propria','pote','/uploads/produtos/1749062849455-744863486.jpg','ativo','2025-06-04 18:05:14','2025-06-04 18:47:29'),(26,'Molho ao Sugo Natural - 500ml','Molho ao Sugo Natural - 500ml',15.00,7.02,2,4,'Molho','producao_propria','Pote','/uploads/produtos/1749062876280-551634345.jpg','ativo','2025-06-04 18:19:52','2025-06-04 18:47:56');
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessoes`
--

LOCK TABLES `sessoes` WRITE;
/*!40000 ALTER TABLE `sessoes` DISABLE KEYS */;
INSERT INTO `sessoes` VALUES (1,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxODQ1MiwiZXhwIjoxNzQ5MDQ3MjUyfQ.9EjBA_K5iCM-MVnxRZDTbzs8YC0WnzBpjuykkUCp3JQ','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; pt-BR) WindowsPowerShell/5.1.26100.4061','2025-06-04 06:27:32','2025-06-04 14:27:32',1),(2,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxODUyNCwiZXhwIjoxNzQ5MDQ3MzI0fQ.j_lxwfR1i1geHnOGpCgid8ItjrtJIkNCnj4zAqOAlQE','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:28:44','2025-06-04 14:28:44',0),(3,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxODg0MywiZXhwIjoxNzQ5MDQ3NjQzfQ.uLsVtXWmw1eOfHBR69ad2x9Z8G6L3TC8B9erWE_N-V8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:34:03','2025-06-04 14:34:03',0),(4,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxOTQwNywiZXhwIjoxNzQ5MDQ4MjA3fQ.l3xBTa_2yym5hfdnLdNHhPc8up3o1RnimBC7SuxWMew','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:43:27','2025-06-04 14:43:27',0),(5,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxOTU3NywiZXhwIjoxNzQ5MDQ4Mzc3fQ.BqTkREnXADrJDlHUPYF66iadZV7Y2Vj28oHdXZXjjQ4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:46:17','2025-06-04 14:46:17',1),(6,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAyMDEzMCwiZXhwIjoxNzQ5MDQ4OTMwfQ.E18ZSEfVeBA-U7c0EAfKUL_LNMGeYQ13wR-CQDTKV5Y','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:55:30','2025-06-04 14:55:30',1),(7,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAyMTQ1OCwiZXhwIjoxNzQ5MDUwMjU4fQ.d_gNfXkpMwVBr8wF9FSt5FKnP6c1VLi0d_jNrS6rySo','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 07:17:38','2025-06-04 15:17:38',1),(8,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTA1NDgwNSwiZXhwIjoxNzQ5MDgzNjA1fQ.wvFbH0cwmoaNplbWTYDGisz7DDhDRGOwUOMQQ2FLeoU','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 16:33:25','2025-06-05 00:33:25',0),(9,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTA1NjgzNCwiZXhwIjoxNzQ5MDg1NjM0fQ.UrphCgjhvkbUg_xyKLrRDD3MeCP31xo_8KzXrGF0H2M','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 17:07:14','2025-06-05 01:07:14',0),(10,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTA1ODk5NSwiZXhwIjoxNzQ5MDg3Nzk1fQ.oo-Ig926Yj40RYRBG_DFWVO0yIBFT5mO0ssE3vL70tM','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 17:43:15','2025-06-05 01:43:15',0),(11,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTA2MDMzOCwiZXhwIjoxNzQ5MDg5MTM4fQ.qnuVGdDAQr2B6ILREqosZt6MCGkBm3Eccy5vV38FW9I','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:05:38','2025-06-05 02:05:38',0),(12,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTA2MTE5NiwiZXhwIjoxNzQ5MDg5OTk2fQ.fyiX5DXqQ4E-hJ47isA9uFBOGOjSpBg4nCwrFrnrdA8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:19:56','2025-06-05 02:19:56',0),(13,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTA2MjU2NSwiZXhwIjoxNzQ5MDkxMzY1fQ.D8UK3fDlJUmu1ZFnx8w65FMzjsA0rGd4GxcLpOLt49k','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:42:45','2025-06-05 02:42:45',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tentativas_login`
--

LOCK TABLES `tentativas_login` WRITE;
/*!40000 ALTER TABLE `tentativas_login` DISABLE KEYS */;
INSERT INTO `tentativas_login` VALUES (1,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:07:53'),(2,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:08:13'),(3,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:08:59'),(4,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:09:03'),(5,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:09:10'),(6,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:11:09'),(7,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:11:21'),(8,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:11:30'),(9,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:12:12'),(10,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:12:25'),(11,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:12:54'),(12,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:38'),(13,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:39'),(14,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:40'),(15,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:41'),(16,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:42'),(17,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:15:56'),(18,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:15:58'),(19,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:15:59'),(20,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:00'),(21,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:01'),(22,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:02'),(23,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:03'),(24,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:03'),(25,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:04'),(26,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:18'),(27,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:21'),(28,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:22'),(29,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:24'),(30,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:25'),(31,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:58'),(32,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:01'),(33,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:03'),(34,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:12'),(35,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:31'),(36,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:43'),(37,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:53'),(38,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:23:10'),(39,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:26:23'),(40,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:26:42'),(41,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:26:54'),(42,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:26:58'),(43,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT; Windows NT 10.0; pt-BR) WindowsPowerShell/5.1.26100.4061','2025-06-04 06:27:32'),(44,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:28:44'),(45,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:34:03'),(46,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:43:27'),(47,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:46:17'),(48,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:55:30'),(49,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 07:17:38'),(50,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 16:33:25'),(51,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 17:07:14'),(52,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 17:43:15'),(53,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:05:38'),(54,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:19:56'),(55,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 18:42:45');
/*!40000 ALTER TABLE `tentativas_login` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Administrador','admin@silosystem.com','','','ativo','2025-06-04 18:42:45','2025-06-04 05:53:50',1,'$2b$12$WRm7Q5F4D2Oic62x0yq2xuv5oIeI8Qf5tF1BfIJPCSqqHLCDCP40K',NULL,NULL,NULL,0,NULL,1,NULL,1,'2025-06-04 18:42:45');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-04 15:49:25
