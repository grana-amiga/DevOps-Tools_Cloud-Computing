package br.com.fiap.citizentech.repository;

import br.com.fiap.citizentech.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
}
