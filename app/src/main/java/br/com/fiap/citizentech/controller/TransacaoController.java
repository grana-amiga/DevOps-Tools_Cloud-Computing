package br.com.fiap.citizentech.controller;

import br.com.fiap.citizentech.model.Transacao;
import br.com.fiap.citizentech.model.Usuario;
import br.com.fiap.citizentech.repository.TransacaoRepository;
import br.com.fiap.citizentech.repository.UsuarioRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/transacoes")
public class TransacaoController {

    private final TransacaoRepository repository;
    private final UsuarioRepository usuarioRepository;

    public TransacaoController(TransacaoRepository repository, UsuarioRepository usuarioRepository) {
        this.repository = repository;
        this.usuarioRepository = usuarioRepository;
    }

    // GET /api/transacoes ou /api/transacoes?usuarioId=1
    @GetMapping
    public List<Transacao> listar(@RequestParam(required = false) Long usuarioId) {
        return usuarioId == null ? repository.findAll() : repository.findByUsuarioId(usuarioId);
    }

    @GetMapping("/{id}")
    public Transacao buscar(@PathVariable Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transação não encontrada"));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Transacao criar(@RequestBody @Valid TransacaoRequest dados) {
        Transacao transacao = new Transacao();
        preencher(transacao, dados);
        return repository.save(transacao);
    }

    @PutMapping("/{id}")
    public Transacao atualizar(@PathVariable Long id, @RequestBody @Valid TransacaoRequest dados) {
        Transacao transacao = buscar(id);
        preencher(transacao, dados);
        return repository.save(transacao);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(@PathVariable Long id) {
        repository.delete(buscar(id));
    }

    private void preencher(Transacao transacao, TransacaoRequest dados) {
        Usuario usuario = usuarioRepository.findById(dados.usuarioId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "usuarioId inexistente"));
        transacao.setUsuario(usuario);
        transacao.setValor(dados.valor());
        transacao.setTipo(dados.tipo());
        transacao.setDescricao(dados.descricao());
        transacao.setDtTransacao(dados.dtTransacao() != null ? dados.dtTransacao() : LocalDateTime.now());
    }
}
