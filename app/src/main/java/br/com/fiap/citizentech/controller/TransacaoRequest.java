package br.com.fiap.citizentech.controller;

import br.com.fiap.citizentech.model.TipoTransacao;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDateTime;

// Corpo do POST/PUT: recebe só o id do usuário em vez do objeto inteiro
public record TransacaoRequest(
        @NotNull Long usuarioId,
        @NotNull @Positive BigDecimal valor,
        @NotNull TipoTransacao tipo,
        @Size(max = 200) String descricao,
        LocalDateTime dtTransacao
) {
}
