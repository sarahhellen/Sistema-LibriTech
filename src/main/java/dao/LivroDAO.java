package dao;

import connection.Conexao;
import model.Livro;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;


public class LivroDAO {

    private final Conexao conexao;

    public LivroDAO(Conexao conexao) {
        this.conexao = conexao;
    }

    public List<Livro> listarAcervoPublico() throws SQLException {
        String sql = "SELECT * FROM vw_acervo_publico";
        List<Livro> lista = new ArrayList<>();

        try (Statement st = conexao.getConexao().createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                Livro l = new Livro();
                l.setId(rs.getInt("id_livro"));
                l.setTitulo(rs.getString("titulo"));
                l.setAutor(rs.getString("autor"));
                l.setIsbn(rs.getString("isbn"));
                l.setQuantidadeEstoque(rs.getInt("quantidade_estoque"));
                l.setStatus(rs.getString("status"));
                lista.add(l);
            }
        }
        return lista;
    }

    public List<Livro> listarTodos() throws SQLException {
        String sql = "SELECT id_livro, titulo, autor, isbn, preco_custo, "
                + "quantidade_estoque, status FROM Livros";
        List<Livro> lista = new ArrayList<>();

        try (Statement st = conexao.getConexao().createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                lista.add(mapearLivro(rs));
            }
        }
        return lista;
    }

    public void cadastrar(Livro livro) throws SQLException {
        Connection conn = conexao.getConexao();
        String sql = "INSERT INTO Livros (titulo, autor, isbn, preco_custo, "
                + "quantidade_estoque, status) VALUES (?, ?, ?, ?, ?, ?)";

        boolean autoCommitOriginal = conn.getAutoCommit();
        conn.setAutoCommit(false);

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, livro.getTitulo());
            ps.setString(2, livro.getAutor());
            ps.setString(3, livro.getIsbn());
            ps.setBigDecimal(4, livro.getPrecoCusto());
            ps.setInt(5, livro.getQuantidadeEstoque());
            ps.setString(6, livro.getStatus() != null ? livro.getStatus() : "DISPONIVEL");
            ps.executeUpdate();
            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(autoCommitOriginal);
        }
    }

    public void deletar(int idLivro) throws SQLException {
        String sql = "DELETE FROM Livros WHERE id_livro = ?";

        try (PreparedStatement ps = conexao.getConexao().prepareStatement(sql)) {
            ps.setInt(1, idLivro);
            int linhasAfetadas = ps.executeUpdate();
            if (linhasAfetadas == 0) {
                throw new SQLException("Nenhum livro encontrado com o ID informado.");
            }
        }
    }

    private Livro mapearLivro(ResultSet rs) throws SQLException {
        Livro l = new Livro();
        l.setId(rs.getInt("id_livro"));
        l.setTitulo(rs.getString("titulo"));
        l.setAutor(rs.getString("autor"));
        l.setIsbn(rs.getString("isbn"));
        BigDecimal preco = rs.getBigDecimal("preco_custo");
        if (preco != null) l.setPrecoCusto(preco);
        l.setQuantidadeEstoque(rs.getInt("quantidade_estoque"));
        l.setStatus(rs.getString("status"));
        return l;
    }
}