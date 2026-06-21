-- 1. CRIAÇÃO DO BANCO DE DADOS (DDL)

DROP DATABASE IF EXISTS db_libritech;
CREATE DATABASE db_libritech;
USE db_libritech;

-- 2. CRIAÇÃO DE TABELAS (DDL)

CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    tipo ENUM('ALUNO', 'GERENTE', 'BIBLIOTECARIO', 'ESTAGIARIO') NOT NULL
);

CREATE TABLE Enderecos (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    logradouro VARCHAR(150) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    uf CHAR(2) NOT NULL,
    id_usuario_fk INT NOT NULL,
    FOREIGN KEY (id_usuario_fk) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Livros (
    id_livro INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    preco_custo DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'DISPONIVEL'
);

CREATE TABLE Emprestimos (
    id_emprestimo INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario_fk INT NOT NULL,
    id_livro_fk INT NOT NULL,
    data_saida DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_prevista DATE NOT NULL,
    data_devolucao DATETIME NULL,
    FOREIGN KEY (id_usuario_fk) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_livro_fk) REFERENCES Livros(id_livro)
);

CREATE TABLE Multas (
    id_multa INT PRIMARY KEY AUTO_INCREMENT,
    id_emprestimo_fk INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    pago BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_emprestimo_fk) REFERENCES Emprestimos(id_emprestimo)
);

CREATE TABLE Log_Auditoria (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    tabela_afetada VARCHAR(50) NOT NULL,
    acao VARCHAR(50) NOT NULL,
    usuario_responsavel VARCHAR(100) NOT NULL,
    dados_antigos TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. INSERT PARA TESTES
INSERT INTO Usuarios (nome, cpf, email, senha, tipo) VALUES
('Admin Geral', '11111111111', 'gerente@libritech.com', SHA2('admin123', 256), 'GERENTE'),
('Bibliotecário Silva', '22222222222', 'biblio@libritech.com', SHA2('biblio123', 256), 'BIBLIOTECARIO'),
('Estagiário Junior', '33333333333', 'estag@libritech.com', SHA2('estag123', 256), 'ESTAGIARIO'),
('Aluno João', '44444444444', 'aluno@libritech.com', SHA2('aluno123', 256), 'ALUNO');

INSERT INTO Enderecos (logradouro, bairro, cidade, uf, id_usuario_fk) VALUES
('Rua das Bibliotecas, 100', 'Centro', 'Recife', 'PE', 1),
('Avenida dos Livros, 200', 'Boa Vista', 'Recife', 'PE', 2),
('Travessa do Saber, 300', 'Casa Forte', 'Recife', 'PE', 3),
('Rua do Conhecimento, 400', 'Boa Viagem', 'Recife', 'PE', 4);

INSERT INTO Livros (titulo, autor, isbn, preco_custo, quantidade_estoque, status) VALUES
('O Senhor dos Anéis', 'J.R.R. Tolkien', '9788544000001', 49.90, 5, 'DISPONIVEL'),
('1984', 'George Orwell', '9788544000002', 35.90, 3, 'DISPONIVEL'),
('Dom Casmurro', 'Machado de Assis', '9788544000003', 29.90, 2, 'DISPONIVEL'),
('A Revolução dos Bichos', 'George Orwell', '9788544000004', 25.90, 0, 'INDISPONIVEL'),
('O Pequeno Príncipe', 'Antoine de Saint-Exupéry', '9788544000005', 19.90, 4, 'DISPONIVEL');

INSERT INTO Emprestimos (id_usuario_fk, id_livro_fk, data_saida, data_prevista) VALUES
(4, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
(4, 2, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY));

-- 4. CRIAÇÃO DOS USERS (SEGURANÇA DO BANCO DE DADOS)

-- 4.1. GERENTE
CREATE USER 'usr_gerente'@'localhost' IDENTIFIED BY 'gerente123';
GRANT ALL PRIVILEGES ON db_libritech.* TO 'usr_gerente'@'localhost';

-- 4.2. BIBLIOTECÁRIO
CREATE USER 'usr_bibliotecario'@'localhost' IDENTIFIED BY 'bibliotecario123';
GRANT SELECT, INSERT, UPDATE ON db_libritech.* TO 'usr_bibliotecario'@'localhost';
GRANT EXECUTE ON db_libritech.* TO 'usr_bibliotecario'@'localhost';
REVOKE DELETE ON db_libritech.Log_Auditoria FROM 'usr_bibliotecario'@'localhost'; -- Teste

-- 4.3. ESTAGIÁRIO
CREATE USER 'usr_estagiario'@'localhost' IDENTIFIED BY 'estagiario123';
GRANT SELECT, INSERT ON db_libritech.Livros TO 'usr_estagiario'@'localhost';
GRANT SELECT, INSERT ON db_libritech.Emprestimos TO 'usr_estagiario'@'localhost';
GRANT SELECT ON db_libritech.Usuarios TO 'usr_estagiario'@'localhost';
REVOKE DELETE ON db_libritech.* FROM 'usr_estagiario'@'localhost'; -- Teste

-- 4.4. ALUNO
CREATE USER 'usr_aluno'@'localhost' IDENTIFIED BY 'aluno123';
GRANT SELECT ON db_libritech.vw_acervo_publico TO 'usr_aluno'@'localhost';
GRANT SELECT ON db_libritech.vw_ranking_leitura TO 'usr_aluno'@'localhost';
GRANT SELECT ON db_libritech.vw_meus_emprestimos TO 'usr_aluno'@'localhost';
GRANT SELECT ON db_libritech.Usuarios TO 'usr_aluno'@'localhost';

SHOW GRANTS FOR 'usr_gerente'@'localhost';
SHOW GRANTS FOR 'usr_bibliotecario'@'localhost';
SHOW GRANTS FOR 'usr_estagiario'@'localhost';
SHOW GRANTS FOR 'usr_aluno'@'localhost';

FLUSH PRIVILEGES;

-- 5. OBJETOS ATIVOS

-- 5.1. VIEWS

-- 5.1.1. Acervo público
CREATE VIEW vw_acervo_publico AS
SELECT 
    id_livro,
    titulo,
    autor,
    isbn,
    quantidade_estoque,
    status
FROM Livros;

-- 5.1.2. Livros atrasados
CREATE VIEW vw_livros_atrasados AS
SELECT 
    e.id_emprestimo,
    u.nome AS usuario_nome,
    u.email AS usuario_email,
    u.cpf,
    l.titulo AS livro_titulo,
    e.data_saida,
    e.data_prevista,
    DATEDIFF(CURDATE(), e.data_prevista) AS dias_atraso
FROM Emprestimos e
INNER JOIN Usuarios u ON e.id_usuario_fk = u.id_usuario
INNER JOIN Livros l ON e.id_livro_fk = l.id_livro
WHERE e.data_devolucao IS NULL 
  AND e.data_prevista < CURDATE();
  
-- 5.1.3. Ranking de leitura
  CREATE VIEW vw_ranking_leitura AS
SELECT 
    l.id_livro,
    l.titulo,
    l.autor,
    COUNT(e.id_emprestimo) AS total_emprestimos
FROM Livros l
INNER JOIN Emprestimos e ON l.id_livro = e.id_livro_fk
GROUP BY l.id_livro, l.titulo, l.autor
ORDER BY total_emprestimos DESC
LIMIT 10;

-- 5.1.4. Dashboard financeiro
CREATE VIEW vw_dashboard_financeiro AS
SELECT 
    SUM(valor) AS total_multas_arrecadadas,
    COUNT(*) AS total_multas_aplicadas,
    SUM(CASE WHEN pago = TRUE THEN valor ELSE 0 END) AS total_pago,
    SUM(CASE WHEN pago = FALSE THEN valor ELSE 0 END) AS total_pendente
FROM Multas;

-- 5.1.5. Histórico de empréstimos do aluno
CREATE VIEW vw_meus_emprestimos AS
SELECT
    e.id_emprestimo,
    e.id_usuario_fk,
    e.id_livro_fk,
    e.data_saida,
    e.data_prevista,
    e.data_devolucao,
    l.titulo AS titulo_livro
FROM Emprestimos e
INNER JOIN Livros l ON l.id_livro = e.id_livro_fk;

SELECT * FROM vw_acervo_publico;
SELECT * FROM vw_livros_atrasados;
SELECT * FROM vw_ranking_leitura;
SELECT * FROM vw_dashboard_financeiro;
SELECT * FROM vw_meus_emprestimos;

-- 5.2. TRIGGERS

-- 5.2.1. Horário comercial Empréstimos (INSERT)
DELIMITER //

CREATE TRIGGER trg_trava_horario_emprestimos_insert
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE hora_atual INT;
    SET hora_atual = HOUR(NOW());
    
    IF (hora_atual < 8 OR hora_atual >= 18) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Operação permitida apenas em horário comercial (08h às 18h)';
    END IF;
END //

DELIMITER ;

-- 5.2.2. Horário comercial Empréstimos (UPDATE)
DELIMITER //

CREATE TRIGGER trg_trava_horario_emprestimos_update
BEFORE UPDATE ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE hora_atual INT;
    SET hora_atual = HOUR(NOW());
    IF (hora_atual < 8 OR hora_atual >= 18) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Operação permitida apenas em horário comercial (08h às 18h)';
    END IF;
END //

DELIMITER ;

-- 5.2.3. Horário comercial Livros (INSERT)
DELIMITER //

CREATE TRIGGER trg_trava_horario_livros_insert
BEFORE INSERT ON Livros
FOR EACH ROW
BEGIN
    DECLARE hora_atual INT;
    SET hora_atual = HOUR(NOW());
    
    IF (hora_atual < 8 OR hora_atual >= 18) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Operação permitida apenas em horário comercial (08h às 18h)';
    END IF;
END //

DELIMITER ;

-- 5.2.4. Horário comercial Livros (UPDATE)
DELIMITER //

CREATE TRIGGER trg_trava_horario_livros_update
BEFORE UPDATE ON Livros
FOR EACH ROW
BEGIN
    DECLARE hora_atual INT;
    SET hora_atual = HOUR(NOW());
    IF (hora_atual < 8 OR hora_atual >= 18) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Operação permitida apenas em horário comercial (08h às 18h)';
    END IF;
END //

DELIMITER ;

-- 5.2.5. Auditoria de deleção
DELIMITER //

CREATE TRIGGER trg_auditoria_delecao
AFTER DELETE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Log_Auditoria (tabela_afetada, acao, usuario_responsavel, dados_antigos)
    VALUES ('Livros', 'DELETE', USER(), CONCAT('id=', OLD.id_livro, ';titulo=', OLD.titulo, ';isbn=', OLD.isbn));
END //

DELIMITER ;

-- 5.2.6. Limite de empréstimos
DELIMITER //

CREATE TRIGGER trg_limite_emprestimos
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE qtd_emprestimos INT;
    
    SELECT COUNT(*) INTO qtd_emprestimos
    FROM Emprestimos
    WHERE id_usuario_fk = NEW.id_usuario_fk
      AND data_devolucao IS NULL;
    
    IF qtd_emprestimos >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Aluno já possui 3 livros emprestados. Devolva um para pegar outro.';
    END IF;
END //

DELIMITER ;

-- 5.2.7. Prevenção de estoque negativo
DELIMITER //

CREATE TRIGGER trg_preventiva_estoque
BEFORE UPDATE ON Livros
FOR EACH ROW
BEGIN
    IF NEW.quantidade_estoque < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Estoque não pode ficar negativo.';
    END IF;
END //

DELIMITER ;

-- 5.3. PROCEDURES

-- 5.3.1. Transação de empréstimo
DELIMITER //

CREATE PROCEDURE sp_transacao_emprestimo(
    IN p_id_usuario INT,
    IN p_id_livro INT,
    IN p_dias_emprestimo INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    IF EXISTS (SELECT 1 FROM Multas m
               INNER JOIN Emprestimos e ON m.id_emprestimo_fk = e.id_emprestimo
               WHERE e.id_usuario_fk = p_id_usuario AND m.pago = FALSE) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Usuário possui multas pendentes.';
    END IF;
    
    IF (SELECT quantidade_estoque FROM Livros WHERE id_livro = p_id_livro) <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Livro sem estoque disponível.';
    END IF;
    
    INSERT INTO Emprestimos (id_usuario_fk, id_livro_fk, data_prevista)
    VALUES (p_id_usuario, p_id_livro, DATE_ADD(CURDATE(), INTERVAL p_dias_emprestimo DAY));
    
    UPDATE Livros SET quantidade_estoque = quantidade_estoque - 1
    WHERE id_livro = p_id_livro;
    
    COMMIT;
    
    SELECT 'Empréstimo realizado com sucesso!' AS mensagem;
END //

DELIMITER ;

-- 5.3.2. Renovação de empréstimo
DELIMITER //

CREATE PROCEDURE sp_renovar_emprestimo(
    IN p_id_emprestimo INT
)
BEGIN
    DECLARE v_status_livro VARCHAR(20);
    DECLARE v_id_livro INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT id_livro_fk INTO v_id_livro
    FROM Emprestimos WHERE id_emprestimo = p_id_emprestimo FOR UPDATE;

    SELECT status INTO v_status_livro
    FROM Livros WHERE id_livro = v_id_livro FOR UPDATE;

    IF v_status_livro = 'RESERVADO' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Livro está reservado. Renovação não permitida.';
    ELSE
        UPDATE Emprestimos
        SET data_prevista = DATE_ADD(data_prevista, INTERVAL 7 DAY)
        WHERE id_emprestimo = p_id_emprestimo;

        COMMIT;
        SELECT 'Renovação realizada com sucesso!' AS mensagem;
    END IF;
END //

DELIMITER ;

-- 5.3.3. Cálculo de multa
DELIMITER //

CREATE PROCEDURE sp_calcular_multa(
    IN p_id_emprestimo INT,
    OUT p_valor_multa DECIMAL(10,2)
)
BEGIN
    DECLARE v_data_prevista DATE;
    DECLARE v_data_devolucao DATETIME;
    DECLARE v_dias_atraso INT;
    
    SELECT data_prevista, data_devolucao INTO v_data_prevista, v_data_devolucao
    FROM Emprestimos WHERE id_emprestimo = p_id_emprestimo;
    
    IF v_data_devolucao IS NOT NULL THEN
        SET v_dias_atraso = DATEDIFF(v_data_devolucao, v_data_prevista);
    ELSE
        SET v_dias_atraso = DATEDIFF(CURDATE(), v_data_prevista);
    END IF;
    
    IF v_dias_atraso <= 0 THEN
        SET p_valor_multa = 0;
    ELSE
        SET p_valor_multa = v_dias_atraso * 2.00;
    END IF;
END //

DELIMITER ;

-- 5.3.4. Transação de devolução
DELIMITER //

CREATE PROCEDURE sp_transacao_devolucao(
    IN p_id_emprestimo INT
)
BEGIN
    DECLARE v_id_livro INT;
    DECLARE v_valor_multa DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Busca o livro do empréstimo
    SELECT id_livro_fk INTO v_id_livro
    FROM Emprestimos
    WHERE id_emprestimo = p_id_emprestimo
    AND data_devolucao IS NULL;

    IF v_id_livro IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Empréstimo já foi devolvido ou não existe.';
    END IF;

    -- Registra a devolução
    UPDATE Emprestimos
    SET data_devolucao = NOW()
    WHERE id_emprestimo = p_id_emprestimo;

    -- Incrementa estoque
    UPDATE Livros
    SET quantidade_estoque = quantidade_estoque + 1
    WHERE id_livro = v_id_livro;

    -- Calcula e insere multa se houver atraso
    CALL sp_calcular_multa(p_id_emprestimo, v_valor_multa);

    IF v_valor_multa > 0 THEN
        INSERT INTO Multas (id_emprestimo_fk, valor, pago)
        VALUES (p_id_emprestimo, v_valor_multa, FALSE);
    END IF;

    COMMIT;
    SELECT 'Devolução realizada com sucesso!' AS mensagem;
END //

DELIMITER ;

-- 5.3.5. Cadastro completo
DELIMITER //

CREATE PROCEDURE sp_transacao_cadastro_completo(
    IN p_nome VARCHAR(100),
    IN p_cpf CHAR(11),
    IN p_email VARCHAR(100),
    IN p_senha VARCHAR(255),
    IN p_tipo VARCHAR(20),
    IN p_logradouro VARCHAR(150),
    IN p_bairro VARCHAR(100),
    IN p_cidade VARCHAR(100),
    IN p_uf CHAR(2)
)
BEGIN
    DECLARE v_id_usuario INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO Usuarios (nome, cpf, email, senha, tipo)
    VALUES (p_nome, p_cpf, p_email, p_senha, p_tipo);
    
    SET v_id_usuario = LAST_INSERT_ID();
    
    INSERT INTO Enderecos (logradouro, bairro, cidade, uf, id_usuario_fk)
    VALUES (p_logradouro, p_bairro, p_cidade, p_uf, v_id_usuario);
    
    COMMIT;
    
    SELECT 'Cadastro realizado com sucesso!' AS mensagem, v_id_usuario AS id_usuario_gerado;
END //

DELIMITER ;

-- 6. ÍNDICES E EXPLAIN (OTIMIZAÇÃO)

EXPLAIN SELECT id_livro, titulo, autor, isbn, status
FROM Livros
WHERE titulo = 'Dom Casmurro';

-- 6.1. Índice para buscas por título
CREATE INDEX idx_livros_titulo ON Livros(titulo);

-- --
EXPLAIN SELECT id_usuario, nome, tipo
FROM Usuarios
WHERE email = 'aluno@libritech.com';

-- 6.2. Índice para buscas por email
CREATE INDEX idx_usuarios_email ON Usuarios(email);

-- --
EXPLAIN SELECT e.id_emprestimo, e.data_prevista, e.data_devolucao, l.titulo
FROM Emprestimos e
INNER JOIN Livros l ON l.id_livro = e.id_livro_fk
WHERE e.id_usuario_fk = 4;

-- 6.3. Índice para empréstimos por usuário
CREATE INDEX idx_emprestimos_usuario ON Emprestimos(id_usuario_fk);


-- 7. TESTES
-- 7.1. Teste de horário (trg_trava_horario Emprestimos ou Livros)
INSERT INTO Emprestimos (id_usuario_fk, id_livro_fk, data_prevista)
VALUES (4, 3, DATE_ADD(CURDATE(), INTERVAL 7 DAY));

-- 7.2. Atomicidade da procedure (sp_transacao_cadastro_completo)
SELECT COUNT(*) AS usuarios_antes FROM Usuarios;

CALL sp_transacao_cadastro_completo(
    'Teste Atomicidade',
    '99999999999',
    'atomicidade@libritech.com',
    SHA2('senha123', 256),
    'ALUNO',
    'Rua Teste, 0',
    'Bairro Teste',
    'Cidade Teste',
    'PBX' -- UF inválida (3 chars > CHAR(2))
);

-- 7.8. EXPLAIN antes do Índice em titulo
EXPLAIN SELECT * FROM Livros WHERE titulo = '1984';
