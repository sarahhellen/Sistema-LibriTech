package model;

public class Endereco {

    private int id;
    private String logradouro;
    private String bairro;
    private String cidade;
    private String uf;
    private int idUsuarioFk;

    public Endereco() {}

    public Endereco(String logradouro, String bairro, String cidade, String uf, int idUsuarioFk) {
        setLogradouro(logradouro);
        setBairro(bairro);
        setCidade(cidade);
        setUf(uf);
        setIdUsuarioFk(idUsuarioFk);
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getLogradouro() {
        return logradouro;
    }

    public void setLogradouro(String logradouro) {
        this.logradouro = logradouro;
    }

    public String getBairro() {
        return bairro;
    }
    public void setBairro(String bairro) {
        this.bairro = bairro;
    }

    public String getCidade() {
        return cidade;
    }

    public void setCidade(String cidade) {
        this.cidade = cidade;
    }

    public String getUf() {
        return uf;
    }

    public void setUf(String uf) {
        if (uf == null || uf.trim().length() != 2)
            throw new IllegalArgumentException("UF deve ter 2 caracteres.");
        this.uf = uf.trim().toUpperCase();
    }

    public int getIdUsuarioFk() {
        return idUsuarioFk;
    }

    public void setIdUsuarioFk(int idUsuarioFk) {
        this.idUsuarioFk = idUsuarioFk;
    }

    @Override
    public String toString() {
        return String.format("%s, %s, %s - %s", logradouro, bairro, cidade, uf);
    }
}
