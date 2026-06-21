package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class SenhaUtil {

    private SenhaUtil() {} // classe utilitária — sem instância

    public static String gerarHash(String senhaTexto) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(senhaTexto.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Algoritmo SHA-256 não disponível.", e);
        }
    }

    public static boolean verificar(String senhaTexto, String hashArmazenado) {
        return gerarHash(senhaTexto).equals(hashArmazenado);
    }
}
