package view;

import connection.Conexao;
import dao.EmprestimoDAO;
import dao.LivroDAO;
import dao.RelatorioDAO;
import dao.UsuarioDAO;
import model.Funcionario;
import model.Livro;

import javax.swing.*;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

public class MenuFuncionario {

    private final Funcionario   funcionario;
    private final Conexao       conexao;
    private final LivroDAO      livroDAO;
    private final EmprestimoDAO emprestimoDAO;
    private final RelatorioDAO  relatorioDAO;

    // Credenciais MySQL guardadas para o backup (mysqldump).
    private final String usuarioBanco;
    private final String senhaBanco;

    public MenuFuncionario(Funcionario funcionario, Conexao conexao,
                           String usuarioBanco, String senhaBanco) {
        this.funcionario   = funcionario;
        this.conexao       = conexao;
        this.usuarioBanco  = usuarioBanco;
        this.senhaBanco    = senhaBanco;
        this.livroDAO      = new LivroDAO(conexao);
        this.emprestimoDAO = new EmprestimoDAO(conexao);
        this.relatorioDAO  = new RelatorioDAO(conexao);
    }

    public void exibir() {
        String[] opcoes = {
                "1. Cadastrar Livro",
                "2. Realizar Empréstimo",
                "3. Renovar Empréstimo",
                "4. Realizar Devolução",
                "5. Excluir Livro",
                "6. Relatórios / Backup",
                "7. Sair"
        };

        int escolha;

        do {
            escolha = JOptionPane.showOptionDialog(
                    null,
                    "Bem-vindo, " + funcionario.getNome()
                            + " [" + funcionario.getTipo() + "]\nEscolha uma opção:",
                    "LibriTech — Menu do Funcionário",
                    JOptionPane.DEFAULT_OPTION,
                    JOptionPane.PLAIN_MESSAGE,
                    null,
                    opcoes,
                    opcoes[0]
            );

            if (escolha == JOptionPane.CLOSED_OPTION) escolha = 6;

            switch (escolha) {
                case 0 -> cadastrarLivro();
                case 1 -> realizarEmprestimo();
                case 2 -> renovarEmprestimo();
                case 3 -> realizarDevolucao();
                case 4 -> excluirLivro();          // "Teste de Fogo"
                case 5 -> relatoriosEBackup();
                case 6 -> JOptionPane.showMessageDialog(null,
                        "Encerrando sessão. Até logo!", "LibriTech",
                        JOptionPane.INFORMATION_MESSAGE);
            }

        } while (escolha != 6);
    }

    private void cadastrarLivro() {
        try {
            String titulo    = pedirTexto("Título do livro:");
            if (titulo == null) return;
            String autor     = pedirTexto("Autor:");
            if (autor == null) return;
            String isbn      = pedirTexto("ISBN:");
            if (isbn == null) return;
            String precoStr  = pedirTexto("Preço de custo (ex: 49.90):");
            if (precoStr == null) return;
            String estqStr   = pedirTexto("Quantidade em estoque:");
            if (estqStr == null) return;

            BigDecimal preco = new BigDecimal(precoStr.replace(",", "."));
            int estoque      = Integer.parseInt(estqStr.trim());

            Livro livro = new Livro();
            livro.setTitulo(titulo);
            livro.setAutor(autor);
            livro.setIsbn(isbn);
            livro.setPrecoCusto(preco);
            livro.setQuantidadeEstoque(estoque);
            livro.setStatus("DISPONIVEL");

            livroDAO.cadastrar(livro);
            JOptionPane.showMessageDialog(null,
                    "Livro cadastrado com sucesso!", "Sucesso",
                    JOptionPane.INFORMATION_MESSAGE);

        } catch (NumberFormatException e) {
            mostrarErro("Valor numérico inválido. Verifique preço e estoque.");
        } catch (IllegalArgumentException e) {
            mostrarErro("Dado inválido: " + e.getMessage());
        } catch (SQLException e) {
            mostrarErroBanco(e);
        }
    }

    private void realizarEmprestimo() {
        try {
            String idUsrStr  = pedirTexto("ID do Usuário:");
            if (idUsrStr == null) return;
            String idLivroStr = pedirTexto("ID do Livro:");
            if (idLivroStr == null) return;

            int idUsuario = Integer.parseInt(idUsrStr.trim());
            int idLivro   = Integer.parseInt(idLivroStr.trim());

            dao.UsuarioDAO usuarioDAO = new UsuarioDAO(conexao);
            model.Usuario usuario = usuarioDAO.buscarPorId(idUsuario);

            if (usuario == null) {
                mostrarErro("Usuário com ID " + idUsuario + " não encontrado.");
                return;
            }

            emprestimoDAO.realizarEmprestimo(usuario, idLivro);
            JOptionPane.showMessageDialog(null,
                    "Empréstimo realizado com sucesso!\n"
                            + "Prazo de devolução: " + usuario.getDiasPrazoEmprestimo() + " dias.",
                    "Sucesso", JOptionPane.INFORMATION_MESSAGE);

        } catch (NumberFormatException e) {
            mostrarErro("ID deve ser um número inteiro.");
        } catch (SQLException e) {
            mostrarErroBanco(e);
        }
    }

    private void renovarEmprestimo() {
        try {
            String idStr = pedirTexto("ID do Empréstimo a renovar:");
            if (idStr == null) return;

            int idEmprestimo = Integer.parseInt(idStr.trim());
            emprestimoDAO.renovarEmprestimo(idEmprestimo);

            JOptionPane.showMessageDialog(null,
                    "Empréstimo renovado por mais 7 dias!", "Sucesso",
                    JOptionPane.INFORMATION_MESSAGE);

        } catch (NumberFormatException e) {
            mostrarErro("ID deve ser um número inteiro.");
        } catch (SQLException e) {
            // A procedure retorna erro se o livro estiver reservado por outro usuário
            mostrarErroBanco(e);
        }
    }

    private void realizarDevolucao() {
        try {
            String idStr = pedirTexto("ID do Empréstimo a devolver:");
            if (idStr == null) return;

            int idEmprestimo = Integer.parseInt(idStr.trim());

            // Calcula multa para exibir antes da confirmação
            BigDecimal multa = emprestimoDAO.calcularMulta(idEmprestimo);

            if (multa != null && multa.compareTo(BigDecimal.ZERO) > 0) {
                int confirmar = JOptionPane.showConfirmDialog(null,
                        String.format("Existe uma multa de R$ %.2f por atraso.\nDeseja confirmar a devolução?", multa),
                        "Multa por Atraso", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);
                if (confirmar != JOptionPane.YES_OPTION)
                    return;
            }

            emprestimoDAO.realizarDevolucao(idEmprestimo);

            String mensagem = "Devolução realizada com sucesso!";
            if (multa != null && multa.compareTo(BigDecimal.ZERO) > 0) {
                mensagem += "\nMulta registrada: R$ " + String.format("%.2f", multa);
            }
            JOptionPane.showMessageDialog(null, mensagem, "Sucesso",
                    JOptionPane.INFORMATION_MESSAGE);

        } catch (NumberFormatException e) {
            mostrarErro("ID deve ser um número inteiro.");
        } catch (SQLException e) {
            mostrarErroBanco(e);
        }
    }

    private void excluirLivro() {
        String idStr = pedirTexto("ID do Livro a excluir:");
        if (idStr == null) return;

        try {
            int idLivro = Integer.parseInt(idStr.trim());

            int confirmar = JOptionPane.showConfirmDialog(null,
                    "ATENÇÃO: Esta ação é irreversível!\n" +
                            "Deseja realmente excluir o livro ID " + idLivro + "?",
                    "Confirmar Exclusão",
                    JOptionPane.YES_NO_OPTION,
                    JOptionPane.WARNING_MESSAGE);

            if (confirmar != JOptionPane.YES_OPTION) return;

            livroDAO.deletar(idLivro);
            JOptionPane.showMessageDialog(null,
                    "Livro excluído com sucesso!",
                    "Sucesso",
                    JOptionPane.INFORMATION_MESSAGE);

        } catch (NumberFormatException e) {
            mostrarErro("ID deve ser um número inteiro.");
        } catch (SQLException e) {
            String mensagem = e.getMessage();

            if (mensagem != null && (mensagem.contains("DELETE command denied")
                    || mensagem.contains("Access denied")
                    || mensagem.contains("permission"))) {
                JOptionPane.showMessageDialog(null,
                        "ERRO: Acesso Negado! Seu perfil de usuário não tem permissão\n" +
                                "para excluir registros do sistema.",
                        "Acesso Negado", JOptionPane.ERROR_MESSAGE);
            } else if (mensagem != null && mensagem.contains("foreign key constraint")) {
                JOptionPane.showMessageDialog(null,
                        "ERRO: Não é possível excluir este livro pois ele está\n" +
                                "vinculado a empréstimos ativos.",
                        "Erro", JOptionPane.ERROR_MESSAGE);
            } else {
                mostrarErroBanco(e);
            }
        }
    }


    private void relatoriosEBackup() {
        String[] subOpcoes = {
                "Dashboard financeiro",
                "Ranking de leitura",
                "Livros atrasados",
                "Gerar Backup (mysqldump)",
                "Voltar"
        };

        int sub = JOptionPane.showOptionDialog(null,
                "Escolha o relatório:", "Relatórios / Backup",
                JOptionPane.DEFAULT_OPTION, JOptionPane.PLAIN_MESSAGE,
                null, subOpcoes, subOpcoes[0]);

        if (sub == JOptionPane.CLOSED_OPTION || sub == 4) return;

        try {
            switch (sub) {
                case 0 -> {
                    List<String> linhas = relatorioDAO.dashboardFinanceiro();
                    exibirLista("Dashboard financeiro", linhas);
                }
                case 1 -> {
                    List<String> linhas = relatorioDAO.rankingLeitura();
                    exibirLista("Ranking de leitura", linhas);
                }
                case 2 -> {
                    List<String> linhas = emprestimoDAO.listarAtrasados();
                    exibirLista("Livros atrasados", linhas);
                }
                case 3 -> {
                    if (!"GERENTE".equalsIgnoreCase(funcionario.getTipo())) {
                        JOptionPane.showMessageDialog(null,
                                "Apenas o Gerente pode realizar backup do sistema.",
                                "Acesso Negado", JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                    String resultado = relatorioDAO.gerarBackup(usuarioBanco, senhaBanco);
                    JOptionPane.showMessageDialog(null, resultado,
                            "Backup", JOptionPane.INFORMATION_MESSAGE);
                }
            }
        } catch (SQLException e) {
            mostrarErroBanco(e);
        }
    }

    private String pedirTexto(String pergunta) {
        return JOptionPane.showInputDialog(null, pergunta, "LibriTech",
                JOptionPane.QUESTION_MESSAGE);
    }

    private void mostrarErro(String mensagem) {
        JOptionPane.showMessageDialog(null, mensagem, "Erro",
                JOptionPane.ERROR_MESSAGE);
    }

    private void mostrarErroBanco(SQLException e) {
        JOptionPane.showMessageDialog(null,
                "Operação não permitida pelo banco de dados:\n" + e.getMessage(),
                "Erro do Sistema", JOptionPane.ERROR_MESSAGE);
    }

    private void exibirLista(String titulo, List<String> linhas) {
        if (linhas.isEmpty()) {
            JOptionPane.showMessageDialog(null, "Nenhum dado encontrado.", titulo,
                    JOptionPane.INFORMATION_MESSAGE);
            return;
        }
        JTextArea area = new JTextArea(String.join("\n", linhas));
        area.setEditable(false);
        JOptionPane.showMessageDialog(null, new JScrollPane(area), titulo,
                JOptionPane.INFORMATION_MESSAGE);
    }
}