package model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Emprestimo {

    private int id;
    private int idUsuarioFk;
    private int idLivroFk;
    private LocalDateTime dataSaida;
    private LocalDate dataPrevista;
    private LocalDateTime dataDevolucao;  // null enquanto não devolvido

    // Campos extras para exibição (JOIN com outras tabelas no DAO)
    private String nomeUsuario;
    private String tituloLivro;

    // Construtores
    public Emprestimo() {}

    public Emprestimo(int id, int idUsuarioFk, int idLivroFk, LocalDateTime dataSaida, LocalDate dataPrevista, LocalDateTime dataDevolucao) {
        setId(id);
        setIdUsuarioFk(idUsuarioFk);
        setIdLivroFk(idLivroFk);
        setDataSaida(dataSaida);
        setDataPrevista(dataPrevista);
        setDataDevolucao(dataDevolucao);
    }


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdUsuarioFk() {
        return idUsuarioFk;
    }

    public void setIdUsuarioFk(int idUsuarioFk) {
        this.idUsuarioFk = idUsuarioFk;
    }

    public int getIdLivroFk() {
        return idLivroFk;
    }

    public void setIdLivroFk(int idLivroFk) {
        this.idLivroFk = idLivroFk;
    }

    public LocalDateTime getDataSaida() {
        return dataSaida;
    }

    public void setDataSaida(LocalDateTime dataSaida) {
        this.dataSaida = dataSaida;
    }

    public LocalDate getDataPrevista() {
        return dataPrevista;
    }

    public void setDataPrevista(LocalDate dataPrevista) {
        this.dataPrevista = dataPrevista;
    }

    public LocalDateTime getDataDevolucao() {
        return dataDevolucao;
    }

    public void setDataDevolucao(LocalDateTime dataDevolucao) {
        this.dataDevolucao = dataDevolucao;
    }

    public String getNomeUsuario() {
        return nomeUsuario;
    }
    public void setNomeUsuario(String nomeUsuario) {
        this.nomeUsuario = nomeUsuario;
    }

    public String getTituloLivro() {
        return tituloLivro;
    }

    public void setTituloLivro(String tituloLivro) {
        this.tituloLivro = tituloLivro;
    }

    @Override
    public String toString() {
        return String.format("[%d] Livro: %s | Usuário: %s | Prevista: %s | Devolvido: %s",
                id,
                tituloLivro != null ? tituloLivro : String.valueOf(idLivroFk),
                nomeUsuario != null ? nomeUsuario : String.valueOf(idUsuarioFk),
                dataPrevista,
                dataDevolucao != null ? dataDevolucao.toString() : "Não devolvido");
    }
}