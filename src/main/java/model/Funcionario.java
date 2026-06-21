package model;

public class Funcionario extends Usuario {

    public Funcionario() {
        super();
    }

    public Funcionario(int id, String nome, String cpf, String email, String senha, String tipo) {
        super(id, nome, cpf, email, senha, tipo);
    }

    @Override
    public int getDiasPrazoEmprestimo() {
        return 14;
    }
}