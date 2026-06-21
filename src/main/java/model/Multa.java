package model;

import java.math.BigDecimal;

// O valor é calculado pela stored procedure sp_calcular_multa no banco.
public class Multa {

    private int id;
    private int idEmprestimoFk;
    private BigDecimal valor;
    private boolean pago;

    public Multa() {}

    public Multa(int id, int idEmprestimoFk, BigDecimal valor, boolean pago) {
        setId(id);
        setIdEmprestimoFk(idEmprestimoFk);
        setValue(valor);
        setPago(pago);
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdEmprestimoFk() {
        return idEmprestimoFk;
    }

    public void setIdEmprestimoFk(int idEmprestimoFk) {
        this.idEmprestimoFk = idEmprestimoFk;
    }

    public BigDecimal getValor() {
        return valor;
    }

    public void setValue(BigDecimal valor) {
        if (valor != null && valor.compareTo(BigDecimal.ZERO) < 0)
            throw new IllegalArgumentException("Valor da multa não pode ser negativo.");
        this.valor = valor;
    }

    public boolean isPago() {
        return pago;
    }

    public void setPago(boolean pago) {
        this.pago = pago;
    }

    @Override
    public String toString() {
        return String.format("Multa [Empréstimo %d] R$ %.2f | %s",
                idEmprestimoFk, valor, pago ? "PAGA" : "PENDENTE");
    }
}