package view;

import connection.Conexao;
import dao.EmprestimoDAO;
import dao.LivroDAO;
import model.Aluno;
import model.Emprestimo;
import model.Livro;

import javax.swing.*;
import java.sql.SQLException;
import java.util.List;

public class MenuAluno {

    private final Aluno      aluno;
    private final Conexao    conexao;
    private final LivroDAO   livroDAO;
    private final EmprestimoDAO emprestimoDAO;

    public MenuAluno(Aluno aluno, Conexao conexao) {
        this.aluno         = aluno;
        this.conexao       = conexao;
        this.livroDAO      = new LivroDAO(conexao);
        this.emprestimoDAO = new EmprestimoDAO(conexao);
    }

    public void exibir() {
        String[] opcoes = {"1. Consultar Acervo Disponível", "2. Meus Empréstimos", "3. Sair"};
        int escolha;

        do {
            escolha = JOptionPane.showOptionDialog(
                    null,
                    "Bem-vindo, " + aluno.getNome() + "!\nEscolha uma opção:",
                    "LibriTech — Menu do Aluno",
                    JOptionPane.DEFAULT_OPTION,
                    JOptionPane.PLAIN_MESSAGE,
                    null,
                    opcoes,
                    opcoes[0]
            );

            // -1 = janela fechada pelo X -> trata como Sair
            if (escolha == JOptionPane.CLOSED_OPTION) escolha = 2;

            switch (escolha) {
                case 0 -> consultarAcervo();
                case 1 -> meusEmprestimos();
                case 2 -> JOptionPane.showMessageDialog(null,
                        "Até logo, " + aluno.getNome() + "!", "LibriTech", JOptionPane.INFORMATION_MESSAGE);
            }

        } while (escolha != 2);
    }

    private void consultarAcervo() {
        try {
            List<Livro> livros = livroDAO.listarAcervoPublico();

            if (livros.isEmpty()) {
                JOptionPane.showMessageDialog(null,
                        "Nenhum livro disponível no acervo no momento.",
                        "Acervo", JOptionPane.INFORMATION_MESSAGE);
                return;
            }

            StringBuilder sb = new StringBuilder("=== ACERVO DISPONÍVEL ===\n\n");
            for (Livro l : livros) {
                // Exibe apenas Título, Autor, ISBN e Status — preço oculto pela view
                sb.append(String.format("• [%d] %s\n  Autor: %s | ISBN: %s | Status: %s\n\n",
                        l.getId(), l.getTitulo(), l.getAutor(), l.getIsbn(), l.getStatus()));
            }

            JOptionPane.showMessageDialog(null,
                    new JTextArea(sb.toString()),
                    "Acervo Público", JOptionPane.INFORMATION_MESSAGE);

        } catch (SQLException e) {
            mostrarErro("Erro ao consultar acervo: " + e.getMessage());
        }
    }

    private void meusEmprestimos() {
        try {
            List<Emprestimo> lista = emprestimoDAO.listarPorUsuario(aluno.getId());

            if (lista.isEmpty()) {
                JOptionPane.showMessageDialog(null,
                        "Você não possui empréstimos registrados.",
                        "Meus Empréstimos", JOptionPane.INFORMATION_MESSAGE);
                return;
            }

            StringBuilder sb = new StringBuilder("=== MEUS EMPRÉSTIMOS ===\n\n");
            for (Emprestimo emp : lista) {
                sb.append(emp.toString()).append("\n\n");
            }

            JOptionPane.showMessageDialog(null,
                    new JTextArea(sb.toString()),
                    "Meus Empréstimos", JOptionPane.INFORMATION_MESSAGE);

        } catch (SQLException e) {
            mostrarErro("Erro ao buscar empréstimos: " + e.getMessage());
        }
    }

    private void mostrarErro(String mensagem) {
        JOptionPane.showMessageDialog(null, mensagem, "Erro", JOptionPane.ERROR_MESSAGE);
    }
}