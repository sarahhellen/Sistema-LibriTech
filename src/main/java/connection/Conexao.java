package connection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexao {

    private static final String URL = "jdbc:mysql://localhost:3306/db_libritech"
            + "?useSSL=false"
            + "&serverTimezone=America/Recife"
            + "&allowPublicKeyRetrieval=true";

    private String usuarioBanco;
    private String senhaBanco;
    private Connection conexaoAtiva;

    public Conexao(String usuarioBanco, String senhaBanco) {
        this.usuarioBanco = usuarioBanco;
        this.senhaBanco = senhaBanco;
    }

    public Connection getConexao() throws SQLException {
        if (conexaoAtiva == null || conexaoAtiva.isClosed()) {
            conexaoAtiva = DriverManager.getConnection(URL, usuarioBanco, senhaBanco);
        }
        return conexaoAtiva;
    }

    public void fechar() {
        try {
            if (conexaoAtiva != null && !conexaoAtiva.isClosed()) {
                conexaoAtiva.close();
            }
        } catch (SQLException e) {
            System.err.println("Erro ao fechar conexão: " + e.getMessage());
        }
    }
}