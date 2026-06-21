package dao;

import connection.Conexao;
import model.Emprestimo;
import model.Usuario;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmprestimoDAO {

    private final Conexao conexao;

    public EmprestimoDAO(Conexao conexao) {
        this.conexao = conexao;
    }

    public void realizarEmprestimo(Usuario usuario, int idLivro) throws SQLException {

        String sql = "{CALL sp_transacao_emprestimo(?, ?, ?)}";

        try (CallableStatement cs = conexao.getConexao().prepareCall(sql)) {
            cs.setInt(1, usuario.getId());
            cs.setInt(2, idLivro);
            cs.setInt(3, usuario.getDiasPrazoEmprestimo());
            cs.execute();
        }
    }

    public void renovarEmprestimo(int idEmprestimo) throws SQLException {
        String sql = "{CALL sp_renovar_emprestimo(?)}";

        try (CallableStatement cs = conexao.getConexao().prepareCall(sql)) {
            cs.setInt(1, idEmprestimo);
            cs.execute();
        }
    }

    public BigDecimal calcularMulta(int idEmprestimo) throws SQLException {
        String sql = "{CALL sp_calcular_multa(?, ?)}";

        try (CallableStatement cs = conexao.getConexao().prepareCall(sql)) {
            cs.setInt(1, idEmprestimo);
            cs.registerOutParameter(2, Types.DECIMAL);
            cs.execute();
            return cs.getBigDecimal(2);
        }
    }

    public void realizarDevolucao(int idEmprestimo) throws SQLException {
        String sql = "{CALL sp_transacao_devolucao(?)}";

        try (CallableStatement cs = conexao.getConexao().prepareCall(sql)) {
            cs.setInt(1, idEmprestimo);
            cs.execute();
        }
    }

    public List<Emprestimo> listarPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT id_emprestimo, id_usuario_fk, id_livro_fk, "
                + "data_saida, data_prevista, data_devolucao, titulo_livro "
                + "FROM vw_meus_emprestimos "
                + "WHERE id_usuario_fk = ?";

        List<Emprestimo> lista = new ArrayList<>();

        try (PreparedStatement ps = conexao.getConexao().prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapearEmprestimo(rs));
                }
            }
        }
        return lista;
    }

    public List<String> listarAtrasados() throws SQLException {
        String sql = "SELECT * FROM vw_livros_atrasados";
        List<String> resultado = new ArrayList<>();

        try (Statement st = conexao.getConexao().createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            ResultSetMetaData meta = rs.getMetaData();
            while (rs.next()) {
                StringBuilder sb = new StringBuilder();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    sb.append(meta.getColumnLabel(i)).append(": ")
                            .append(rs.getString(i)).append(" | ");
                }
                resultado.add(sb.toString());
            }
        }
        return resultado;
    }

    private Emprestimo mapearEmprestimo(ResultSet rs) throws SQLException {
        Emprestimo e = new Emprestimo();
        e.setId(rs.getInt("id_emprestimo"));
        e.setIdUsuarioFk(rs.getInt("id_usuario_fk"));
        e.setIdLivroFk(rs.getInt("id_livro_fk"));

        Timestamp tsSaida = rs.getTimestamp("data_saida");
        if (tsSaida != null) e.setDataSaida(tsSaida.toLocalDateTime());

        Date dataPrev = rs.getDate("data_prevista");
        if (dataPrev != null) e.setDataPrevista(dataPrev.toLocalDate());

        Timestamp tsDevol = rs.getTimestamp("data_devolucao");
        if (tsDevol != null) e.setDataDevolucao(tsDevol.toLocalDateTime());

        String titulo = rs.getString("titulo_livro");
        if (titulo != null) e.setTituloLivro(titulo);

        return e;
    }
}