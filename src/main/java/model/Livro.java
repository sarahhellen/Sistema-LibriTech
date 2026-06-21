package model;

import java.math.BigDecimal;

public class Livro {

    // Atributos (todos private)
    private int id;
    private String titulo;
    private String autor;
    private String isbn;
    private BigDecimal precoCusto;
    private int quantidadeEstoque;
    private String status;   // 'DISPONIVEL' | 'INDISPONIVEL'

    // Construtor
    public Livro() {}

    public Livro(int id, String titulo, String autor, String isbn,
                 BigDecimal precoCusto, int quantidadeEstoque, String status) {
        setId(id);
        setTitulo(titulo);
        setAutor(autor);
        setIsbn(isbn);
        setPrecoCusto(precoCusto);
        setQuantidadeEstoque(quantidadeEstoque);
        setStatus(status);
    }

    // Getters e Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        if (titulo == null || titulo.isBlank())
            throw new IllegalArgumentException("Título não pode ser vazio.");
        this.titulo = titulo.trim();
    }

    public String getAutor() {
        return autor;
    }

    public void setAutor(String autor) {
        if (autor == null || autor.isBlank())
            throw new IllegalArgumentException("Autor não pode ser vazio.");
        this.autor = autor.trim();
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public BigDecimal getPrecoCusto() {
        return precoCusto;
    }

    // Validação: preço não pode ser negativo (requisito explícito do documento).
    public void setPrecoCusto(BigDecimal precoCusto) {
        if (precoCusto != null && precoCusto.compareTo(BigDecimal.ZERO) < 0)
            throw new IllegalArgumentException("Preço de custo não pode ser negativo.");
        this.precoCusto = precoCusto;
    }

    public int getQuantidadeEstoque() {
        return quantidadeEstoque;
    }

    public void setQuantidadeEstoque(int quantidadeEstoque) {
        if (quantidadeEstoque < 0)
            throw new IllegalArgumentException("Estoque não pode ser negativo.");
        this.quantidadeEstoque = quantidadeEstoque;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return String.format("[%d] %s — %s | Estoque: %d | Status: %s",
                id, titulo, autor, quantidadeEstoque, status);
    }
}