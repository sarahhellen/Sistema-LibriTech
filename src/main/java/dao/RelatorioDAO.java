package dao;

import connection.Conexao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;


public class RelatorioDAO {

    private final Conexao conexao;

    public RelatorioDAO(Conexao conexao) {
        this.conexao = conexao;
    }
    
    public List<String> dashboardFinanceiro() throws SQLException {
        String sql = "SELECT * FROM vw_dashboard_financeiro";
        List<String> linhas = new ArrayList<>();

        try (PreparedStatement ps = conexao.getConexao().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            ResultSetMetaData meta = rs.getMetaData();
            while (rs.next()) {
                StringBuilder sb = new StringBuilder();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    sb.append(meta.getColumnLabel(i))
                            .append(": ").append(rs.getString(i)).append("  ");
                }
                linhas.add(sb.toString());
            }
        }
        return linhas;
    }

    public List<String> rankingLeitura() throws SQLException {
        String sql = "SELECT * FROM vw_ranking_leitura";
        List<String> linhas = new ArrayList<>();

        try (Statement st = conexao.getConexao().createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            ResultSetMetaData meta = rs.getMetaData();
            while (rs.next()) {
                StringBuilder sb = new StringBuilder();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    sb.append(meta.getColumnLabel(i))
                            .append(": ").append(rs.getString(i)).append("  ");
                }
                linhas.add(sb.toString());
            }
        }
        return linhas;
    }

    public String gerarBackup(String usuarioBanco, String senhaBanco) {
        String timestamp   = String.valueOf(System.currentTimeMillis());
        String nomeArquivo = "backup_libritech_" + timestamp + ".sql";

        String[] comando = {
                "mysqldump",
                "-u", usuarioBanco,
                "-p" + senhaBanco,
                "db_libritech",
                "--result-file=" + nomeArquivo
        };

        try {
            Process processo = Runtime.getRuntime().exec(comando);
            int exitCode = processo.waitFor();
            if (exitCode == 0) {
                return "Backup gerado com sucesso: " + nomeArquivo;
            } else {
                return "Falha ao gerar backup. Código de saída: " + exitCode;
            }
        } catch (Exception e) {
            return "Erro ao executar mysqldump: " + e.getMessage();
        }
    }
}
