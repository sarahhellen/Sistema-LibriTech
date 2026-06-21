# LibriTech — Sistema de Gestão Bibliotecária

Projeto II da disciplina de Banco de Dados — Centro Universitário UNIFACISA.

- Docente: Anna Beatriz Lucena Lira.
- Discentes: Fernanda Travassos, Maria Eduarda de Brito, Samuel Vasconcelos, Sarah Hellen Silva, Vitória Marques.

---

## Sumário

1. [Descrição do projeto](#1-descrição-do-projeto)
2. [Arquitetura geral](#2-arquitetura-geral)
3. [Estrutura de diretórios](#3-estrutura-de-diretórios)
4. [Configuração do banco de dados](#4-configuração-do-banco-de-dados)
5. [Usuários e permissões](#5-usuários-e-permissões)
6. [Objetos do banco de dados](#6-objetos-do-banco-de-dados)
7. [Fluxo de uso](#7-fluxo-de-uso)
8. [Decisões de projeto](#8-decisões-de-projeto)

---

## 1. Descrição do projeto

O LibriTech é um sistema de gerenciamento de biblioteca universitária desenvolvido com Java e MySQL. O Java fornece interface gráfica de interação com o usuário, construída com `javax.swing.JOptionPane`. O MySQL atua como o componente responsável por criar usuários, validar permissões, executar transações e registrar auditorias.

---

## 2. Arquitetura geral

O projeto segue o padrão de camadas DAO (Data Access Object), separando responsabilidades da seguinte forma:

- **Camada de modelo (`model`):** Classes de domínio com encapsulamento completo e hierarquia de herança. A classe abstrata é `Usuario`, estendida por `Aluno` e `Funcionario`, implementando polimorfismo através do método abstrato `getDiasPrazoEmprestimo()`.
- **Camada de acesso a dados (`dao`):** Classes `UsuarioDAO`, `LivroDAO`, `EmprestimoDAO` e `RelatorioDAO`, responsáveis por toda comunicação com o banco via JDBC, Stored Procedures e Views.
- **Camada de conexão (`connection`):** Classe `Conexao`, que gerencia a conexão JDBC com o MySQL utilizando as credenciais fornecidas em tempo de execução pelo usuário.
- **Camada de visão (`view`):** Classes `MenuAluno` e `MenuFuncionario`, que apresentam as interfaces gráficas de acordo com o perfil autenticado.
- **Utilitários (`util`):** Classe `SenhaUtil`, que realiza o hash SHA-256 das senhas antes do tráfego e armazenamento.

---

## 3. Estrutura de biretórios

```
src/
├── Main.java
├── connection/
│   └── Conexao.java
├── dao/
│   ├── EmprestimoDAO.java
│   ├── LivroDAO.java
│   ├── RelatorioDAO.java
│   └── UsuarioDAO.java
├── model/
│   ├── Aluno.java
│   ├── Emprestimo.java
│   ├── Endereco.java
│   ├── Funcionario.java
│   ├── Livro.java
│   ├── Multa.java
│   └── Usuario.java
├── util/
│   └── SenhaUtil.java
├── view/
│   ├── MenuAluno.java
│   └── MenuFuncionario.java
└── Main.java

sql/
├── LibriTech_-_Projeto_2_Universidade.sql   (script em SQL)
```

---

## 4. Configuração do banco de dados

Execute o script SQL fornecido para criar o banco, as tabelas, os usuários, as procedures, as triggers e as views:

```sql
SOURCE /caminho/para/LibriTech_-_Projeto_2_Universidade.sql;
```

O banco `db_libritech` contém com as seguintes tabelas:

- `Usuarios` — entidade central com coluna discriminadora `tipo` (ALUNO, GERENTE, BIBLIOTECARIO, ESTAGIARIO)
- `Enderecos` — separada de `Usuarios` seguindo a Primeira Forma Normal (1FN)
- `Livros` — acervo bibliográfico com controle de estoque e preço em `DECIMAL(10,2)`
- `Emprestimos` — tabela associativa entre usuários e livros
- `Multas` — registros financeiros vinculados a empréstimos
- `Log_Auditoria` — preenchida exclusivamente por trigger; registra deleções e alterações sensíveis

A conexão é configurada para o fuso horário `America/Recife`. Caso o servidor MySQL esteja em outro host ou porta, editar a constante `URL` em `Conexao.java`.

---

## 5. Usuários e permissões

A aplicação implementa o princípio do Privilégio Mínimo. Quatro usuários MySQL devem ser criados pelo script, cada um com permissões distintas:

| Usuário MySQL        | Perfil de negócio | Permissões principais                                                                 |
|----------------------|-------------------|---------------------------------------------------------------------------------------|
| `usr_gerente`        | Gerente           | ALL PRIVILEGES — acesso total ao banco de dados.        |
| `usr_bibliotecario`  | Bibliotecário     | SELECT, INSERT, UPDATE em tabelas operacionais; sem DELETE na tabela de auditoria.     |
| `usr_estagiario`     | Estagiário        | SELECT em acervo; INSERT em empréstimos; DELETE explicitamente revogado em `Livros`.   |
| `usr_aluno`          | Aluno             | SELECT exclusivamente em Views públicas.                                               |

A segurança é imposta pelo banco. Um estagiário que tente excluir um livro receberá um erro do MySQL, capturado pela aplicação Java como `SQLException` e exibido ao usuário com uma mensagem adequada.

---

## 6. Objetos do banco de dados

### Stored Procedures

| Procedure                          | Descrição                                                                                          |
|------------------------------------|----------------------------------------------------------------------------------------------------|
| `sp_transacao_emprestimo`          | Verifica pendências e estoque, insere o empréstimo e decrementa o estoque. Usa ROLLBACK em falha.  |
| `sp_renovar_emprestimo`            | Verifica se o livro está reservado por outro usuário. Se livre, estende a data prevista em 7 dias. |
| `sp_calcular_multa`                | Calcula o valor da multa por atraso (dias * R$ 2,00) e retorna via parâmetro OUT.                 |
| `sp_transacao_cadastro_completo`   | Insere usuário e endereço atomicamente. Em falha no endereço, faz ROLLBACK completo.              |

### Triggers

| Trigger                        | Evento               | Comportamento                                                              |
|--------------------------------|----------------------|----------------------------------------------------------------------------|
| `trg_trava_horario_comercial`  | BEFORE INSERT/UPDATE | Aborta operações fora do horário comercial (08h–18h); foram criados esses triggers especicamente para as tabelas `Emprestimos` e `Livros`. |
| `trg_auditoria_delecao`        | AFTER DELETE em Livros | Registra o dado apagado e o usuário responsável na tabela `Log_Auditoria`. |
| `trg_limite_emprestimos`       | BEFORE INSERT        | Bloqueia empréstimo se o aluno já possuir 3 livros ativos.                  |
| `trg_preventiva_estoque`       | BEFORE UPDATE        | Impede que o campo `quantidade_estoque` assuma valor negativo.              |

### Views

| View                      | Finalidade                                                                              |
|---------------------------|-----------------------------------------------------------------------------------------|
| `vw_acervo_publico`       | Lista livros disponíveis sem expor preço de custo — utilizada pelo perfil Aluno.         |
| `vw_livros_atrasados`     | Lista empréstimos vencidos com dados de contato do usuário responsável.                  |
| `vw_ranking_leitura`      | Top 10 livros mais emprestados, ordenados por contagem.                                  |
| `vw_dashboard_financeiro` | Soma total de multas arrecadadas e indicadores financeiros gerais.                        |
| `vw_meus_emprestimos` | Lista os empréstimos feitos pelo Aluno.                        |

---

## 7. Fluxo de uso

Ao iniciar, a aplicação exibe uma janela solicitando o perfil de acesso (Funcionário, Aluno ou Sair). Em seguida, o usuário informa as credenciais do banco de dados MySQL (usuário e senha), que são usadas para abrir a conexão JDBC. Após isso, o usuário informa seu e-mail e senha de negócio, que são verificados na tabela `Usuarios` com hash SHA-256.

Conforme o perfil autenticado, um menu distinto é apresentado:

**Menu do Aluno:** Consultar acervo disponível (via `vw_acervo_publico`) e visualizar seus empréstimos ativos.

**Menu do Funcionário:** Cadastrar livros, realizar empréstimos, renovar empréstimos, registrar devoluções (com cálculo automático de multa), excluir livros (operação sujeita à permissão do banco) e acessar relatórios e backup.

---

## 8. Decisões de projeto

**Senhas:** As senhas dos usuários de negócio são armazenadas como hash SHA-256 (64 caracteres hexadecimais). Nenhuma senha em texto simples trafega ou é persistida no banco.

**Credenciais sem hardcode:** O código Java não contém usuário ou senha fixos. As credenciais são coletadas em tempo de execução pelo usuário, garantindo que as permissões do MySQL se apliquem corretamente a cada sessão.

**Segurança pela camada de banco:** O menu do Funcionário é idêntico para todos os perfis funcionais. A diferenciação de acesso não é feita por lógica condicional no Java, mas pelas permissões GRANT/REVOKE aplicadas a cada usuário MySQL.

**Tipos de dados monetários:** Todos os valores financeiros utilizam `DECIMAL(10,2)` no banco e `BigDecimal` no Java, evitando imprecisões de ponto flutuante.

**Fuso horário:** A conexão JDBC é configurada com `serverTimezone=America/Recife` para garantir consistência nas operações de data e hora das triggers e procedures.
