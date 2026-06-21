package dao;

import connection.Conexao;
import model.*;

import java.sql.*;

public class UsuarioDAO {

    private final Conexao conexao;

    public UsuarioDAO(Conexao conexao) {
        this.conexao = conexao;
    }

    public void cadastrarCompleto(Usuario usuario, Endereco endereco) throws SQLException {
        String sql = "{CALL sp_transacao_cadastro_completo(?, ?, ?, ?, ?, ?, ?, ?, ?)}";

        try (CallableStatement cs = conexao.getConexao().prepareCall(sql)) {
            cs.setString(1, usuario.getNome());
            cs.setString(2, usuario.getCpf());
            cs.setString(3, usuario.getEmail());
            cs.setString(4, usuario.getSenha());
            cs.setString(5, usuario.getTipo());
            cs.setString(6, endereco.getLogradouro());
            cs.setString(7, endereco.getBairro());
            cs.setString(8, endereco.getCidade());
            cs.setString(9, endereco.getUf());
            cs.execute();
        }
    }

    public Usuario buscarPorEmailESenha(String email, String senhaHash) throws SQLException {
        String sql = "SELECT id_usuario, nome, cpf, email, senha, tipo "
                + "FROM Usuarios WHERE email = ? AND senha = ?";

        try (PreparedStatement ps = conexao.getConexao().prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, senhaHash);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return construirUsuario(rs);
                }
            }
        }
        return null;
    }

    public Usuario buscarPorId(int id) throws SQLException {
        String sql = "SELECT id_usuario, nome, cpf, email, senha, tipo "
                + "FROM Usuarios WHERE id_usuario = ?";

        try (PreparedStatement ps = conexao.getConexao().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return construirUsuario(rs);
            }
        }
        return null;
    }

    private Usuario construirUsuario(ResultSet rs) throws SQLException {
        int id = rs.getInt("id_usuario");
        String nome = rs.getString("nome");
        String cpf = rs.getString("cpf");
        String email = rs.getString("email");
        String senha = rs.getString("senha");
        String tipo = rs.getString("tipo");

        if ("ALUNO".equalsIgnoreCase(tipo)) {
            return new Aluno(id, nome, cpf, email, senha);
        } else {
            return new Funcionario(id, nome, cpf, email, senha, tipo);
        }
    }
}