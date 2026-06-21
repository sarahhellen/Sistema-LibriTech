import connection.Conexao;
import dao.UsuarioDAO;
import model.Aluno;
import model.Funcionario;
import model.Usuario;
import view.MenuAluno;
import view.MenuFuncionario;
import util.SenhaUtil;

import javax.swing.*;
import java.sql.SQLException;

public class Main {

    public static void main(String[] args) {
        SwingUtilities.invokeLater(Main::iniciar);
    }

    private static void iniciar() {
        boolean continuar = true;

        while (continuar) {
            String[] perfis = {"Funcionário", "Aluno", "Sair"};
            int perfilEscolhido = JOptionPane.showOptionDialog(
                    null,
                    "Bem-vindo ao LibriTech!\nQual é o seu perfil de acesso?",
                    "LibriTech — Sistema de Gestão Bibliotecária",
                    JOptionPane.DEFAULT_OPTION,
                    JOptionPane.QUESTION_MESSAGE,
                    null,
                    perfis,
                    perfis[0]
            );

            // Usuário fechou a janela ou escolheu Sair
            if (perfilEscolhido == JOptionPane.CLOSED_OPTION || perfilEscolhido == 2) {
                JOptionPane.showMessageDialog(null,
                        "Sistema encerrado. Até logo!", "LibriTech",
                        JOptionPane.INFORMATION_MESSAGE);
                continuar = false;
                continue;
            }

            boolean ehAluno = (perfilEscolhido == 1);


            String usuarioBanco = JOptionPane.showInputDialog(null,
                    "Usuário do Banco de Dados MySQL:\n(ex: usr_aluno, usr_bibliotecario, usr_estagiario, usr_gerente)",
                    "Login — LibriTech", JOptionPane.QUESTION_MESSAGE);

            if (usuarioBanco == null || usuarioBanco.isBlank()) continue;

            JPasswordField campoSenhaBanco = new JPasswordField(20);
            int okSenha = JOptionPane.showConfirmDialog(null,
                    new Object[]{"Senha do Banco de Dados:", campoSenhaBanco},
                    "Login — LibriTech", JOptionPane.OK_CANCEL_OPTION);

            if (okSenha != JOptionPane.OK_OPTION) continue;

            String senhaBanco = new String(campoSenhaBanco.getPassword());

            Conexao conexao = new Conexao(usuarioBanco.trim(), senhaBanco);

            try {
                conexao.getConexao();
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null,
                        "Não foi possível conectar ao banco de dados.\n"
                                + "Verifique usuário e senha.\n\nDetalhe: " + e.getMessage(),
                        "Erro de Conexão", JOptionPane.ERROR_MESSAGE);
                conexao.fechar();
                continue;
            }

            String emailNegocio = JOptionPane.showInputDialog(null,
                    "E-mail cadastrado no sistema:",
                    "Identificação — LibriTech", JOptionPane.QUESTION_MESSAGE);

            if (emailNegocio == null || emailNegocio.isBlank()) {
                conexao.fechar();
                continue;
            }

            JPasswordField campoSenhaNeg = new JPasswordField(20);
            int okSenhaNeg = JOptionPane.showConfirmDialog(null,
                    new Object[]{"Senha do sistema:", campoSenhaNeg},
                    "Identificação — LibriTech", JOptionPane.OK_CANCEL_OPTION);

            if (okSenhaNeg != JOptionPane.OK_OPTION) {
                conexao.fechar();
                continue;
            }

            String senhaHashNegocio = SenhaUtil.gerarHash(
                    new String(campoSenhaNeg.getPassword()));

            Usuario usuarioLogado;
            try {
                UsuarioDAO usuarioDAO = new UsuarioDAO(conexao);
                usuarioLogado = usuarioDAO.buscarPorEmailESenha(emailNegocio, senhaHashNegocio);
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null,
                        "Erro ao verificar credenciais de negócio:\n" + e.getMessage(),
                        "Erro", JOptionPane.ERROR_MESSAGE);
                conexao.fechar();
                continue;
            }

            if (usuarioLogado == null) {
                JOptionPane.showMessageDialog(null,
                        "E-mail ou senha incorretos.",
                        "Acesso Negado", JOptionPane.ERROR_MESSAGE);
                conexao.fechar();
                continue;
            }

            if (ehAluno) {
                if (!(usuarioLogado instanceof Aluno)) {
                    JOptionPane.showMessageDialog(null,
                            "Acesso Negado!\n" +
                                    "Você selecionou 'Aluno', mas seu usuário é do tipo '" +
                                    usuarioLogado.getTipo() + "'.",
                            "Perfil Incompatível",
                            JOptionPane.ERROR_MESSAGE);
                    conexao.fechar();
                    continue;
                }

                new MenuAluno((Aluno) usuarioLogado, conexao).exibir();

            } else {
                if (!(usuarioLogado instanceof Funcionario)) {
                    JOptionPane.showMessageDialog(null,
                            "Acesso Negado!\n" +
                                    "Você selecionou 'Funcionário', mas seu usuário é do tipo '" +
                                    usuarioLogado.getTipo() + "'.",
                            "Perfil Incompatível",
                            JOptionPane.ERROR_MESSAGE);
                    conexao.fechar();
                    continue;
                }

                Funcionario funcionario = (Funcionario) usuarioLogado;
                new MenuFuncionario(funcionario, conexao, usuarioBanco, senhaBanco).exibir();
            }

            conexao.fechar();
        }

        System.exit(0);
    }
}