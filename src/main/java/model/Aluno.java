package model;

public class Aluno extends Usuario {

    public Aluno() {
        super();
        setTipo("ALUNO");
    }

    public Aluno(int id, String nome, String cpf, String email, String senha) {
        super(id, nome, cpf, email, senha, "ALUNO");
    }

    @Override
    public int getDiasPrazoEmprestimo() {
        return 7;
    }
}