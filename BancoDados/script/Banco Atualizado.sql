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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
INSERT INTO `auditoria` VALUES (1,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT; Windows NT 10.0; pt-BR) WindowsPowerShell/5.1.26100.4061\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; pt-BR) WindowsPowerShell/5.1.26100.4061','2025-06-04 06:27:32'),(2,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:28:44'),(3,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:34:00'),(4,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:34:03'),(5,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:43:22'),(6,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:43:27'),(7,1,'LOGOUT','usuarios',1,'null','null','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:44:38'),(8,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:46:17'),(9,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:55:30'),(10,1,'LOGIN','usuarios',1,'null','{\"ip\":\"::1\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 07:17:38');
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (11,'Cliente teste','silvanalm01@hotmail.com','1193219184',NULL,'fisica','Rua Jose','55',NULL,'1234',NULL,NULL,NULL,NULL,'ativo','2025-06-04 01:42:17');
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estoque`
--

LOCK TABLES `estoque` WRITE;
/*!40000 ALTER TABLE `estoque` DISABLE KEYS */;
INSERT INTO `estoque` VALUES (10,14,49,'2025-06-04 02:18:50'),(11,15,1,'2025-06-04 02:33:38');
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
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itens_pedido`
--

LOCK TABLES `itens_pedido` WRITE;
/*!40000 ALTER TABLE `itens_pedido` DISABLE KEYS */;
INSERT INTO `itens_pedido` VALUES (37,9,14,1,25.00,25.00),(43,10,15,1,40.00,40.00);
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_operacoes_automaticas`
--

LOCK TABLES `log_operacoes_automaticas` WRITE;
/*!40000 ALTER TABLE `log_operacoes_automaticas` DISABLE KEYS */;
INSERT INTO `log_operacoes_automaticas` VALUES (1,9,'saida_estoque','pronto','entregue','[{\"produto_id\":14,\"quantidade\":1,\"operacao\":\"saida\"}]','2025-06-04 02:18:50','Saída automática por entrega - Tipo: pronta_entrega'),(2,10,'entrada_estoque','em_preparo','produzido','[{\"produto_id\":15,\"quantidade\":1,\"operacao\":\"entrada\"}]','2025-06-04 02:33:38','Entrada automática por conclusão da produção');
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimentacoes_estoque`
--

LOCK TABLES `movimentacoes_estoque` WRITE;
/*!40000 ALTER TABLE `movimentacoes_estoque` DISABLE KEYS */;
INSERT INTO `movimentacoes_estoque` VALUES (6,14,'entrada',50,'Produção',40.00,NULL,NULL,'manual','2025-06-04 01:43:27','2025-06-03','2025-09-03',NULL,'Teste'),(7,14,'saida',1,'Venda - Pronta Entrega',NULL,'#9',9,'automatica','2025-06-04 02:18:50',NULL,NULL,NULL,'Saída automática por entrega realizada'),(8,15,'entrada',1,'Produção finalizada - Encomenda',NULL,'#10',10,'automatica','2025-06-04 02:33:38','2025-06-03',NULL,NULL,'Entrada automática por conclusão de produção');
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (9,11,'#001','2025-06-04 01:43:51','concluido','pronta_entrega',NULL,NULL,25.00,'Cartão de Crédito','pago',25.00,'2025-06-04 01:45:40','',NULL,'teste','',0),(10,11,'#002','2025-06-04 02:31:22','produzido','encomenda','2025-06-04','12:30:00',40.00,'Cartão de Débito','pendente',0.00,NULL,NULL,NULL,'teste','Teste',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtos`
--

LOCK TABLES `produtos` WRITE;
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` VALUES (14,'Nhoque Simples - 500g','Nhoque Simples de 500g feito de batata,',25.00,6.61,3,49,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975675797-731946779.jpg','ativo','2025-06-03 18:00:36','2025-06-04 02:18:50'),(15,'Nhoque Recheado Mussarela - 500g','Contem pacote de 500g de nhoque recheado de Mussarela.',40.00,12.72,3,1,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975772896-582541457.jpg','ativo','2025-06-03 18:03:30','2025-06-04 02:33:38'),(16,'Nhoque Recheado Mussarela com Catupiry - 500g','Pacote de 500g com Nhoque Recheado Mussarela com Catupiry.',40.00,11.18,3,0,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975798766-619419538.jpg','ativo','2025-06-03 18:04:35','2025-06-03 18:36:38'),(17,'Nhoque Recheado Presunto com Mussarela - 500g','Pacote de 500g de Nhoque Recheado Presunto com Mussarela.',40.00,10.42,3,0,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975822395-385952879.jpg','ativo','2025-06-03 18:05:33','2025-06-03 18:37:02'),(18,'Nhoque Recheado Calabresa com Mussarela - 500g','Pacote de 500g de Nhoque Recheado Calabresa com Mussarela.',40.00,10.37,3,0,'Congelados','producao_propria','Pacote','/uploads/produtos/1748975843109-869330303.jpg','ativo','2025-06-03 18:06:19','2025-06-03 18:37:23'),(19,'Molho ao Sugo - 500ml','Pote de 500ml de molho de extrato de tomate.',20.00,7.74,3,0,'Molho','producao_propria','Pote','/uploads/produtos/1748975880417-190043038.jpg','ativo','2025-06-03 18:09:17','2025-06-03 18:38:00'),(20,'Molho Bolonhesa - 500ml','Pote de 500ml de molho de extrato de tomate',20.00,12.64,3,0,'Molho','producao_propria','Pote','/uploads/produtos/1748975904643-820407538.jpg','ativo','2025-06-03 18:10:18','2025-06-03 18:38:24'),(21,'Refrigerante Coca-Cola - Lata 350ml','Refrigerante Coca-Cola - Lata 350ml',3.00,7.90,5,0,'Bebidas','revenda','Latas','/uploads/produtos/1748988215446-707073668.png','ativo','2025-06-03 18:12:07','2025-06-03 22:03:35'),(22,'Refrigerante Coca-Cola Zero - Lata 350ml','Refrigerante Coca-Cola Zero - Lata 350ml',3.00,7.90,5,0,'Bebidas','revenda','Latas','/uploads/produtos/1748988382869-601995256.png','ativo','2025-06-03 18:12:52','2025-06-03 22:06:22'),(23,'Refrigerante Guarana Antartica - Lata 269ml','Refrigerante Guarana Antartica - Lata 269ml',3.00,4.99,5,0,'Bebidas','revenda','Latas','/uploads/produtos/1748988278894-87367356.png','ativo','2025-06-03 18:13:29','2025-06-03 22:04:38');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessoes`
--

LOCK TABLES `sessoes` WRITE;
/*!40000 ALTER TABLE `sessoes` DISABLE KEYS */;
INSERT INTO `sessoes` VALUES (1,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxODQ1MiwiZXhwIjoxNzQ5MDQ3MjUyfQ.9EjBA_K5iCM-MVnxRZDTbzs8YC0WnzBpjuykkUCp3JQ','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; pt-BR) WindowsPowerShell/5.1.26100.4061','2025-06-04 06:27:32','2025-06-04 14:27:32',1),(2,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxODUyNCwiZXhwIjoxNzQ5MDQ3MzI0fQ.j_lxwfR1i1geHnOGpCgid8ItjrtJIkNCnj4zAqOAlQE','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:28:44','2025-06-04 14:28:44',0),(3,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxODg0MywiZXhwIjoxNzQ5MDQ3NjQzfQ.uLsVtXWmw1eOfHBR69ad2x9Z8G6L3TC8B9erWE_N-V8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:34:03','2025-06-04 14:34:03',0),(4,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxOTQwNywiZXhwIjoxNzQ5MDQ4MjA3fQ.l3xBTa_2yym5hfdnLdNHhPc8up3o1RnimBC7SuxWMew','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:43:27','2025-06-04 14:43:27',0),(5,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAxOTU3NywiZXhwIjoxNzQ5MDQ4Mzc3fQ.BqTkREnXADrJDlHUPYF66iadZV7Y2Vj28oHdXZXjjQ4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:46:17','2025-06-04 14:46:17',1),(6,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAyMDEzMCwiZXhwIjoxNzQ5MDQ4OTMwfQ.E18ZSEfVeBA-U7c0EAfKUL_LNMGeYQ13wR-CQDTKV5Y','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:55:30','2025-06-04 14:55:30',1),(7,1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc0OTAyMTQ1OCwiZXhwIjoxNzQ5MDUwMjU4fQ.d_gNfXkpMwVBr8wF9FSt5FKnP6c1VLi0d_jNrS6rySo','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 07:17:38','2025-06-04 15:17:38',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tentativas_login`
--

LOCK TABLES `tentativas_login` WRITE;
/*!40000 ALTER TABLE `tentativas_login` DISABLE KEYS */;
INSERT INTO `tentativas_login` VALUES (1,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:07:53'),(2,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:08:13'),(3,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:08:59'),(4,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:09:03'),(5,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:09:10'),(6,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:11:09'),(7,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:11:21'),(8,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:11:30'),(9,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:12:12'),(10,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:12:25'),(11,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:12:54'),(12,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:38'),(13,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:39'),(14,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:40'),(15,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:41'),(16,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:13:42'),(17,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:15:56'),(18,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:15:58'),(19,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:15:59'),(20,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:00'),(21,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:01'),(22,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:02'),(23,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:03'),(24,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:03'),(25,'admin@silosystem.com','::1',0,'Usuário bloqueado','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:04'),(26,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:18'),(27,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:21'),(28,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:22'),(29,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:24'),(30,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:25'),(31,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:16:58'),(32,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:01'),(33,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:03'),(34,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:12'),(35,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:31'),(36,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:43'),(37,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:17:53'),(38,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:23:10'),(39,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:26:23'),(40,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:26:42'),(41,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:26:54'),(42,'admin@silosystem.com','::1',0,'Senha incorreta','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:26:58'),(43,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT; Windows NT 10.0; pt-BR) WindowsPowerShell/5.1.26100.4061','2025-06-04 06:27:32'),(44,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:28:44'),(45,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:34:03'),(46,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:43:27'),(47,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:46:17'),(48,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 06:55:30'),(49,'admin@silosystem.com','::1',1,'Login bem-sucedido','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','2025-06-04 07:17:38');
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
INSERT INTO `usuarios` VALUES (1,'Administrador','admin@silosystem.com','','','ativo','2025-06-04 07:18:24','2025-06-04 05:53:50',3,'$2b$12$WRm7Q5F4D2Oic62x0yq2xuv5oIeI8Qf5tF1BfIJPCSqqHLCDCP40K',NULL,NULL,NULL,0,NULL,1,NULL,1,'2025-06-04 07:18:24');
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

-- Dump completed on 2025-06-04  4:20:21
