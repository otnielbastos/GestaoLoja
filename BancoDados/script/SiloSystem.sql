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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'João Silva','joao.silva@email.com','(11) 99999-1234','123.456.789-00','fisica','Rua das Flores','123','Apto 45','Centro','São Paulo','SP','01234-567','Cliente preferencial, sempre pontual nos pagamentos','ativo','2025-06-03 05:05:42'),(2,'Maria Santos','maria.santos@email.com','(11) 99999-5678','987.654.321-00','fisica','Avenida Principal','456','','Jardim','São Paulo','SP','05678-901','Sempre pede entrega, prefere pedidos aos finais de semana','ativo','2025-06-03 05:05:42'),(3,'Restaurante Bella Vista Ltda','pedidos@bellavista.com.br','(11) 3333-4444','12.345.678/0001-90','juridica','Rua do Comércio','789','Loja 2','Vila Nova','São Paulo','SP','09876-543','Cliente corporativo, pedidos grandes mensais','ativo','2025-06-03 05:05:42'),(4,'Restaurante do irmão do Ricardo','Ricardo@teste.com.br','11993219184','','juridica','Apto','44','Apto 44','1234','Osasco','SP','06040-470','Teste','ativo','2025-06-03 05:11:46'),(8,'Silvana Lara Machado','silvanalm01@hotmail.com','1193219184',NULL,'fisica','Rua Jose','55',NULL,'1234',NULL,NULL,NULL,'teste','ativo','2025-06-03 05:35:23');
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estoque`
--

LOCK TABLES `estoque` WRITE;
/*!40000 ALTER TABLE `estoque` DISABLE KEYS */;
INSERT INTO `estoque` VALUES (8,11,10,'2025-06-03 04:45:31'),(9,12,9,'2025-06-03 04:46:36');
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
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itens_pedido`
--

LOCK TABLES `itens_pedido` WRITE;
/*!40000 ALTER TABLE `itens_pedido` DISABLE KEYS */;
INSERT INTO `itens_pedido` VALUES (2,1,11,3,15.00,45.00),(3,2,11,2,15.00,30.00),(4,2,12,3,16.00,48.50),(5,3,11,4,15.00,60.00),(6,3,12,4,16.00,64.00),(27,4,11,1,40.00,40.00),(30,5,11,1,40.00,40.00);
/*!40000 ALTER TABLE `itens_pedido` ENABLE KEYS */;
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
  `data_movimentacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_fabricacao` date DEFAULT NULL,
  `data_validade` date DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `observacao` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `produto_id` (`produto_id`),
  CONSTRAINT `movimentacoes_estoque_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimentacoes_estoque`
--

LOCK TABLES `movimentacoes_estoque` WRITE;
/*!40000 ALTER TABLE `movimentacoes_estoque` DISABLE KEYS */;
INSERT INTO `movimentacoes_estoque` VALUES (1,11,'entrada',10,'Produção',40.00,NULL,'2025-06-03 04:44:52','2025-06-03','2025-09-03',NULL,'Produção de nhoques'),(2,12,'entrada',9,'Produção',40.00,NULL,'2025-06-03 04:46:36','2025-06-03','2025-09-03',NULL,'Produção de nhoques'),(3,11,'saida',1,'Venda - Pedido',40.00,'#004','2025-06-03 05:54:39',NULL,NULL,NULL,NULL),(4,12,'saida',2,'Venda - Pedido',80.00,'#004','2025-06-03 05:54:39',NULL,NULL,NULL,NULL),(5,11,'saida',1,'Pedido',NULL,'#005','2025-06-03 06:52:51',NULL,NULL,NULL,NULL);
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
  `status` enum('pendente','aprovado','em_preparo','em_separacao','pronto','em_entrega','concluido','cancelado') NOT NULL DEFAULT 'pendente',
  `valor_total` decimal(10,2) NOT NULL,
  `forma_pagamento` varchar(50) NOT NULL,
  `status_pagamento` enum('pendente','pago','parcial') NOT NULL DEFAULT 'pendente',
  `valor_pago` decimal(10,2) DEFAULT 0.00,
  `data_pagamento` timestamp NULL DEFAULT NULL,
  `observacoes_pagamento` text DEFAULT NULL,
  `data_entrega` timestamp NULL DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `numero_pedido` (`numero_pedido`),
  KEY `cliente_id` (`cliente_id`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (1,1,'#001','2025-06-03 05:25:08','pendente',45.00,'Cartão de Crédito','pendente',0.00,NULL,NULL,NULL,'Entrega rápida'),(2,2,'#002','2025-06-03 05:25:08','pendente',78.50,'PIX','pendente',0.00,NULL,NULL,NULL,NULL),(3,3,'#003','2025-06-03 05:25:08','pendente',120.00,'Dinheiro','pendente',0.00,NULL,NULL,NULL,'Cliente prefere entrega após 18h'),(4,8,'#004','2025-06-03 05:54:39','concluido',40.00,'Cartão de Crédito','pago',40.00,'2025-06-03 06:51:53','','2025-06-03 06:49:11','- 1'),(5,8,'#005','2025-06-03 06:52:51','concluido',40.00,'Cartão de Crédito','pago',40.00,'2025-06-03 06:53:23','','2025-06-03 06:53:32','');
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtos`
--

LOCK TABLES `produtos` WRITE;
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` VALUES (11,'Nhoque de Simples - 500g','Nhoque Simples Congelado de 500g',40.00,15.00,5,8,'Congelados','producao_propria','g','/uploads/produtos/1748913728802-316161621.jpg','ativo','2025-06-03 01:22:08','2025-06-03 06:53:12'),(12,'Nhoque Recheado Mussarela - 500g','Nhoque Recheado Mussarela - 500g',40.00,15.00,5,9,'Congelados','producao_propria','g','/uploads/produtos/1748924043180-978285663.jpg','ativo','2025-06-03 04:13:51','2025-06-03 06:10:59'),(13,'Sal','Sal de 500g - Sisne',0.00,0.00,2,0,'Ingredientes','materia_prima','g','/uploads/produtos/1748924530465-524313446.jpg','ativo','2025-06-03 04:22:10','2025-06-03 04:22:10');
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
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

-- Dump completed on 2025-06-03  4:39:15
