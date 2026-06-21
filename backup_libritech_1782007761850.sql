-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: db_libritech
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `emprestimos`
--

DROP TABLE IF EXISTS `emprestimos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emprestimos` (
  `id_emprestimo` int NOT NULL AUTO_INCREMENT,
  `id_usuario_fk` int NOT NULL,
  `id_livro_fk` int NOT NULL,
  `data_saida` datetime DEFAULT CURRENT_TIMESTAMP,
  `data_prevista` date NOT NULL,
  `data_devolucao` datetime DEFAULT NULL,
  PRIMARY KEY (`id_emprestimo`),
  KEY `id_usuario_fk` (`id_usuario_fk`),
  KEY `id_livro_fk` (`id_livro_fk`),
  CONSTRAINT `emprestimos_ibfk_1` FOREIGN KEY (`id_usuario_fk`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `emprestimos_ibfk_2` FOREIGN KEY (`id_livro_fk`) REFERENCES `livros` (`id_livro`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emprestimos`
--

LOCK TABLES `emprestimos` WRITE;
/*!40000 ALTER TABLE `emprestimos` DISABLE KEYS */;
INSERT INTO `emprestimos` VALUES (1,4,1,'2026-06-15 19:03:35','2026-06-18',NULL),(2,4,2,'2026-06-17 19:03:35','2026-06-24',NULL);
/*!40000 ALTER TABLE `emprestimos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_trava_horario_emprestimos_insert` BEFORE INSERT ON `emprestimos` FOR EACH ROW BEGIN
    DECLARE hora_atual INT;
    SET hora_atual = HOUR(NOW());
    
    IF (hora_atual < 8 OR hora_atual >= 18) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Operação permitida apenas em horário comercial (08h às 18h)';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_limite_emprestimos` BEFORE INSERT ON `emprestimos` FOR EACH ROW BEGIN
    DECLARE qtd_emprestimos INT;
    
    SELECT COUNT(*) INTO qtd_emprestimos
    FROM Emprestimos
    WHERE id_usuario_fk = NEW.id_usuario_fk
      AND data_devolucao IS NULL;
    
    IF qtd_emprestimos >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Aluno já possui 3 livros emprestados. Devolva um para pegar outro.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_trava_horario_emprestimos_update` BEFORE UPDATE ON `emprestimos` FOR EACH ROW BEGIN
    DECLARE hora_atual INT;
    SET hora_atual = HOUR(NOW());
    IF (hora_atual < 8 OR hora_atual >= 18) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Operação permitida apenas em horário comercial (08h às 18h)';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `enderecos`
--

DROP TABLE IF EXISTS `enderecos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enderecos` (
  `id_endereco` int NOT NULL AUTO_INCREMENT,
  `logradouro` varchar(150) NOT NULL,
  `bairro` varchar(100) NOT NULL,
  `cidade` varchar(100) NOT NULL,
  `uf` char(2) NOT NULL,
  `id_usuario_fk` int NOT NULL,
  PRIMARY KEY (`id_endereco`),
  KEY `id_usuario_fk` (`id_usuario_fk`),
  CONSTRAINT `enderecos_ibfk_1` FOREIGN KEY (`id_usuario_fk`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enderecos`
--

LOCK TABLES `enderecos` WRITE;
/*!40000 ALTER TABLE `enderecos` DISABLE KEYS */;
INSERT INTO `enderecos` VALUES (1,'Rua das Bibliotecas, 100','Centro','Recife','PE',1),(2,'Avenida dos Livros, 200','Boa Vista','Recife','PE',2),(3,'Travessa do Saber, 300','Casa Forte','Recife','PE',3),(4,'Rua do Conhecimento, 400','Boa Viagem','Recife','PE',4);
/*!40000 ALTER TABLE `enderecos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `livros`
--

DROP TABLE IF EXISTS `livros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `livros` (
  `id_livro` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) NOT NULL,
  `autor` varchar(100) NOT NULL,
  `isbn` varchar(20) NOT NULL,
  `preco_custo` decimal(10,2) NOT NULL,
  `quantidade_estoque` int NOT NULL DEFAULT '0',
  `status` varchar(20) DEFAULT 'DISPONIVEL',
  PRIMARY KEY (`id_livro`),
  UNIQUE KEY `isbn` (`isbn`),
  KEY `idx_livros_titulo` (`titulo`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livros`
--

LOCK TABLES `livros` WRITE;
/*!40000 ALTER TABLE `livros` DISABLE KEYS */;
INSERT INTO `livros` VALUES (1,'O Senhor dos Anéis','J.R.R. Tolkien','9788544000001',49.90,5,'DISPONIVEL'),(2,'1984','George Orwell','9788544000002',35.90,3,'DISPONIVEL'),(4,'A Revolução dos Bichos','George Orwell','9788544000004',25.90,0,'INDISPONIVEL'),(5,'O Pequeno Príncipe','Antoine de Saint-Exupéry','9788544000005',19.90,4,'DISPONIVEL');
/*!40000 ALTER TABLE `livros` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_trava_horario_livros_insert` BEFORE INSERT ON `livros` FOR EACH ROW BEGIN
    DECLARE hora_atual INT;
    SET hora_atual = HOUR(NOW());
    
    IF (hora_atual < 8 OR hora_atual >= 18) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Operação permitida apenas em horário comercial (08h às 18h)';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_trava_horario_livros_update` BEFORE UPDATE ON `livros` FOR EACH ROW BEGIN
    DECLARE hora_atual INT;
    SET hora_atual = HOUR(NOW());
    IF (hora_atual < 8 OR hora_atual >= 18) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Operação permitida apenas em horário comercial (08h às 18h)';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_preventiva_estoque` BEFORE UPDATE ON `livros` FOR EACH ROW BEGIN
    IF NEW.quantidade_estoque < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Estoque não pode ficar negativo.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_auditoria_delecao` AFTER DELETE ON `livros` FOR EACH ROW BEGIN
    INSERT INTO Log_Auditoria (tabela_afetada, acao, usuario_responsavel, dados_antigos)
    VALUES ('Livros', 'DELETE', USER(), CONCAT('id=', OLD.id_livro, ';titulo=', OLD.titulo, ';isbn=', OLD.isbn));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `log_auditoria`
--

DROP TABLE IF EXISTS `log_auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_auditoria` (
  `id_log` int NOT NULL AUTO_INCREMENT,
  `tabela_afetada` varchar(50) NOT NULL,
  `acao` varchar(50) NOT NULL,
  `usuario_responsavel` varchar(100) NOT NULL,
  `dados_antigos` text,
  `data_hora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_auditoria`
--

LOCK TABLES `log_auditoria` WRITE;
/*!40000 ALTER TABLE `log_auditoria` DISABLE KEYS */;
INSERT INTO `log_auditoria` VALUES (1,'Livros','DELETE','usr_gerente@localhost','id=3;titulo=Dom Casmurro;isbn=9788544000003','2026-06-21 02:04:42');
/*!40000 ALTER TABLE `log_auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `multas`
--

DROP TABLE IF EXISTS `multas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multas` (
  `id_multa` int NOT NULL AUTO_INCREMENT,
  `id_emprestimo_fk` int NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `pago` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id_multa`),
  KEY `id_emprestimo_fk` (`id_emprestimo_fk`),
  CONSTRAINT `multas_ibfk_1` FOREIGN KEY (`id_emprestimo_fk`) REFERENCES `emprestimos` (`id_emprestimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `multas`
--

LOCK TABLES `multas` WRITE;
/*!40000 ALTER TABLE `multas` DISABLE KEYS */;
/*!40000 ALTER TABLE `multas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `cpf` char(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `tipo` enum('ALUNO','GERENTE','BIBLIOTECARIO','ESTAGIARIO') NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `cpf` (`cpf`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Admin Geral','11111111111','gerente@libritech.com','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9','GERENTE'),(2,'Bibliotecário Silva','22222222222','biblio@libritech.com','f967a64bffbe3f3a3e4fc807778dda8e965dc26a9b2db20ab705f6bc5543b9d7','BIBLIOTECARIO'),(3,'Estagiário Junior','33333333333','estag@libritech.com','2af804644c6e54deda00045fe293ba4bc5a3525f8c8012d46d60f206c5baff33','ESTAGIARIO'),(4,'Aluno João','44444444444','aluno@libritech.com','fd5675ae2e933b4070e682938203dcbb978966909cf03f3d9c4f271ad1b3107b','ALUNO');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_acervo_publico`
--

DROP TABLE IF EXISTS `vw_acervo_publico`;
/*!50001 DROP VIEW IF EXISTS `vw_acervo_publico`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_acervo_publico` AS SELECT 
 1 AS `id_livro`,
 1 AS `titulo`,
 1 AS `autor`,
 1 AS `isbn`,
 1 AS `quantidade_estoque`,
 1 AS `status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_dashboard_financeiro`
--

DROP TABLE IF EXISTS `vw_dashboard_financeiro`;
/*!50001 DROP VIEW IF EXISTS `vw_dashboard_financeiro`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_dashboard_financeiro` AS SELECT 
 1 AS `total_multas_arrecadadas`,
 1 AS `total_multas_aplicadas`,
 1 AS `total_pago`,
 1 AS `total_pendente`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_livros_atrasados`
--

DROP TABLE IF EXISTS `vw_livros_atrasados`;
/*!50001 DROP VIEW IF EXISTS `vw_livros_atrasados`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_livros_atrasados` AS SELECT 
 1 AS `id_emprestimo`,
 1 AS `usuario_nome`,
 1 AS `usuario_email`,
 1 AS `cpf`,
 1 AS `livro_titulo`,
 1 AS `data_saida`,
 1 AS `data_prevista`,
 1 AS `dias_atraso`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_meus_emprestimos`
--

DROP TABLE IF EXISTS `vw_meus_emprestimos`;
/*!50001 DROP VIEW IF EXISTS `vw_meus_emprestimos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_meus_emprestimos` AS SELECT 
 1 AS `id_emprestimo`,
 1 AS `id_usuario_fk`,
 1 AS `id_livro_fk`,
 1 AS `data_saida`,
 1 AS `data_prevista`,
 1 AS `data_devolucao`,
 1 AS `titulo_livro`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_ranking_leitura`
--

DROP TABLE IF EXISTS `vw_ranking_leitura`;
/*!50001 DROP VIEW IF EXISTS `vw_ranking_leitura`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_ranking_leitura` AS SELECT 
 1 AS `id_livro`,
 1 AS `titulo`,
 1 AS `autor`,
 1 AS `total_emprestimos`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_acervo_publico`
--

/*!50001 DROP VIEW IF EXISTS `vw_acervo_publico`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_acervo_publico` AS select `livros`.`id_livro` AS `id_livro`,`livros`.`titulo` AS `titulo`,`livros`.`autor` AS `autor`,`livros`.`isbn` AS `isbn`,`livros`.`quantidade_estoque` AS `quantidade_estoque`,`livros`.`status` AS `status` from `livros` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_dashboard_financeiro`
--

/*!50001 DROP VIEW IF EXISTS `vw_dashboard_financeiro`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_dashboard_financeiro` AS select sum(`multas`.`valor`) AS `total_multas_arrecadadas`,count(0) AS `total_multas_aplicadas`,sum((case when (`multas`.`pago` = true) then `multas`.`valor` else 0 end)) AS `total_pago`,sum((case when (`multas`.`pago` = false) then `multas`.`valor` else 0 end)) AS `total_pendente` from `multas` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_livros_atrasados`
--

/*!50001 DROP VIEW IF EXISTS `vw_livros_atrasados`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_livros_atrasados` AS select `e`.`id_emprestimo` AS `id_emprestimo`,`u`.`nome` AS `usuario_nome`,`u`.`email` AS `usuario_email`,`u`.`cpf` AS `cpf`,`l`.`titulo` AS `livro_titulo`,`e`.`data_saida` AS `data_saida`,`e`.`data_prevista` AS `data_prevista`,(to_days(curdate()) - to_days(`e`.`data_prevista`)) AS `dias_atraso` from ((`emprestimos` `e` join `usuarios` `u` on((`e`.`id_usuario_fk` = `u`.`id_usuario`))) join `livros` `l` on((`e`.`id_livro_fk` = `l`.`id_livro`))) where ((`e`.`data_devolucao` is null) and (`e`.`data_prevista` < curdate())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_meus_emprestimos`
--

/*!50001 DROP VIEW IF EXISTS `vw_meus_emprestimos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_meus_emprestimos` AS select `e`.`id_emprestimo` AS `id_emprestimo`,`e`.`id_usuario_fk` AS `id_usuario_fk`,`e`.`id_livro_fk` AS `id_livro_fk`,`e`.`data_saida` AS `data_saida`,`e`.`data_prevista` AS `data_prevista`,`e`.`data_devolucao` AS `data_devolucao`,`l`.`titulo` AS `titulo_livro` from (`emprestimos` `e` join `livros` `l` on((`l`.`id_livro` = `e`.`id_livro_fk`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_ranking_leitura`
--

/*!50001 DROP VIEW IF EXISTS `vw_ranking_leitura`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ranking_leitura` AS select `l`.`id_livro` AS `id_livro`,`l`.`titulo` AS `titulo`,`l`.`autor` AS `autor`,count(`e`.`id_emprestimo`) AS `total_emprestimos` from (`livros` `l` join `emprestimos` `e` on((`l`.`id_livro` = `e`.`id_livro_fk`))) group by `l`.`id_livro`,`l`.`titulo`,`l`.`autor` order by `total_emprestimos` desc limit 10 */;
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

-- Dump completed on 2026-06-20 23:09:22
