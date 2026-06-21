package model;

public abstract class Usuario {

    // Atributos (todos private)
    private int id;
    private String nome;
    private String cpf;
    private String email;
    private String senha;
    private String tipo;

    // Construtor
    public Usuario(int id, String nome, String cpf, String email, String senha, String tipo) {
        setId(id);
        setNome(nome);
        setCpf(cpf);
        setEmail(email);
        setSenha(senha);
        setTipo(tipo);
    }

    public Usuario() {}

    public abstract int getDiasPrazoEmprestimo();

    // Getters e Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        if (id < 0) throw new IllegalArgumentException("ID de usuário inválido.");
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        if (nome == null || nome.trim().isEmpty())
            throw new IllegalArgumentException("Nome não pode ser vazio.");
        this.nome = nome.trim();
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        if (cpf == null || cpf.replaceAll("[^0-9]", "").length() != 11)
            throw new IllegalArgumentException("CPF inválido. Informe 11 dígitos numéricos.");
        this.cpf = cpf.replaceAll("[^0-9]", "");
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        if (email == null || !email.contains("@"))
            throw new IllegalArgumentException("E-mail inválido.");
        this.email = email.trim().toLowerCase();
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    @Override
    public String toString() {
        return String.format("Usuario[id=%d, nome='%s', tipo=%s]", id, nome, tipo);
    }
}
