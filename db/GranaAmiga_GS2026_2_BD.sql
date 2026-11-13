BEGIN
    FOR obj IN (SELECT object_name, object_type
                  FROM user_objects
                 WHERE object_type IN ('TABLE', 'SEQUENCE', 'PROCEDURE', 'FUNCTION')
                   AND object_name IN ('LEITURA_ENERGIA', 'DISPOSITIVO', 'DIVIDA', 'TRANSACAO',
                                       'CATEGORIA', 'USUARIO',
                                       'SEQ_USUARIO', 'SEQ_CATEGORIA', 'SEQ_TRANSACAO', 'SEQ_DIVIDA',
                                       'SEQ_DISPOSITIVO', 'SEQ_LEITURA_ENERGIA',
                                       'FN_FORMATAR_BRL', 'FN_FORMATAR_PCT',
                                       'PRC_REGISTRAR_TRANSACAO', 'PRC_REGISTRAR_LEITURA_ENERGIA',
                                       'PRC_RESUMO_ENERGIA', 'PRC_ALERTAS_VENCIMENTO'))
    LOOP
        IF obj.object_type = 'TABLE' THEN
            EXECUTE IMMEDIATE 'DROP TABLE ' || obj.object_name || ' CASCADE CONSTRAINTS PURGE';
        ELSE
            EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' ' || obj.object_name;
        END IF;
    END LOOP;
END;
/

CREATE SEQUENCE seq_usuario         START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_categoria       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_transacao       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_divida          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_dispositivo     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_leitura_energia START WITH 1 INCREMENT BY 1;

CREATE TABLE usuario (
    id_usuario    NUMBER(10)    NOT NULL,
    nome          VARCHAR2(120) NOT NULL,
    telefone      VARCHAR2(20)  NOT NULL,
    senha_hash    VARCHAR2(255) NOT NULL,
    papel         VARCHAR2(10)  DEFAULT 'USER' NOT NULL,
    renda_mensal  NUMBER(19,2),
    dt_cadastro   DATE          DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_usuario          PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_telefone UNIQUE (telefone),
    CONSTRAINT ck_usuario_papel    CHECK (papel IN ('USER', 'ADMIN')),
    CONSTRAINT ck_usuario_renda    CHECK (renda_mensal >= 0)
);

CREATE TABLE categoria (
    id_categoria  NUMBER(10)   NOT NULL,
    nome          VARCHAR2(80) NOT NULL,
    icone         VARCHAR2(100),
    tipo          VARCHAR2(10) NOT NULL,
    CONSTRAINT pk_categoria         PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nome    UNIQUE (nome, tipo),
    CONSTRAINT uq_categoria_id_tipo UNIQUE (id_categoria, tipo),
    CONSTRAINT ck_categoria_tipo    CHECK (tipo IN ('ENTRADA', 'SAIDA'))
);

CREATE TABLE transacao (
    id_transacao  NUMBER(10)    NOT NULL,
    id_usuario    NUMBER(10)    NOT NULL,
    id_categoria  NUMBER(10)    NOT NULL,
    tipo          VARCHAR2(10)  NOT NULL,
    valor         NUMBER(19,2)  NOT NULL,
    descricao     VARCHAR2(500),
    dt_transacao  TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    origem        VARCHAR2(10)  DEFAULT 'APP' NOT NULL,
    CONSTRAINT pk_transacao           PRIMARY KEY (id_transacao),
    CONSTRAINT fk_transacao_usuario   FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT fk_transacao_categoria FOREIGN KEY (id_categoria, tipo)
        REFERENCES categoria (id_categoria, tipo),
    CONSTRAINT ck_transacao_tipo      CHECK (tipo IN ('ENTRADA', 'SAIDA')),
    CONSTRAINT ck_transacao_valor     CHECK (valor >= 0.01),
    CONSTRAINT ck_transacao_origem    CHECK (origem IN ('APP', 'WHATSAPP', 'IOT'))
);

CREATE TABLE divida (
    id_divida        NUMBER(10)    NOT NULL,
    id_usuario       NUMBER(10)    NOT NULL,
    credor           VARCHAR2(120) NOT NULL,
    tipo             VARCHAR2(20)  NOT NULL,
    saldo_devedor    NUMBER(19,2)  NOT NULL,
    taxa_juros_mes   NUMBER(10,4)  NOT NULL,
    valor_parcela    NUMBER(19,2)  NOT NULL,
    dia_vencimento   NUMBER(2)     NOT NULL,
    status           VARCHAR2(20)  DEFAULT 'ABERTA' NOT NULL,
    CONSTRAINT pk_divida         PRIMARY KEY (id_divida),
    CONSTRAINT fk_divida_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT ck_divida_tipo    CHECK (tipo IN ('CARTAO', 'CARNE', 'PESSOAL', 'OUTROS')),
    CONSTRAINT ck_divida_status  CHECK (status IN ('ABERTA', 'QUITADA')),
    CONSTRAINT ck_divida_saldo   CHECK (saldo_devedor >= 0),
    CONSTRAINT ck_divida_taxa    CHECK (taxa_juros_mes >= 0),
    CONSTRAINT ck_divida_parcela CHECK (valor_parcela >= 0.01),
    CONSTRAINT ck_divida_dia     CHECK (dia_vencimento BETWEEN 1 AND 31),
    CONSTRAINT ck_divida_status_saldo CHECK (
        (status = 'QUITADA' AND saldo_devedor = 0)
        OR (status = 'ABERTA' AND saldo_devedor > 0))
);

CREATE TABLE dispositivo (
    id_dispositivo     NUMBER(10)   NOT NULL,
    id_usuario         NUMBER(10)   NOT NULL,
    codigo             VARCHAR2(80) NOT NULL,
    tarifa_kwh         NUMBER(12,6) NOT NULL,
    meta_mensal_reais  NUMBER(19,2) NOT NULL,
    CONSTRAINT pk_dispositivo         PRIMARY KEY (id_dispositivo),
    CONSTRAINT uq_dispositivo_codigo  UNIQUE (codigo),
    CONSTRAINT fk_dispositivo_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT ck_dispositivo_tarifa  CHECK (tarifa_kwh > 0),
    CONSTRAINT ck_dispositivo_meta    CHECK (meta_mensal_reais > 0)
);

CREATE TABLE leitura_energia (
    id_leitura      NUMBER(10)   NOT NULL,
    id_dispositivo  NUMBER(10)   NOT NULL,
    dt_leitura      TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    potencia_w      NUMBER(15,3) NOT NULL,
    kwh             NUMBER(15,6) NOT NULL,
    custo_estimado  NUMBER(19,2) NOT NULL,
    CONSTRAINT pk_leitura_energia             PRIMARY KEY (id_leitura),
    CONSTRAINT fk_leitura_energia_dispositivo FOREIGN KEY (id_dispositivo)
        REFERENCES dispositivo (id_dispositivo),
    CONSTRAINT ck_leitura_energia_potencia    CHECK (potencia_w >= 0),
    CONSTRAINT ck_leitura_energia_kwh         CHECK (kwh > 0),
    CONSTRAINT ck_leitura_energia_custo       CHECK (custo_estimado >= 0)
);

CREATE INDEX ix_transacao_usuario_data  ON transacao (id_usuario, dt_transacao);
CREATE INDEX ix_transacao_categoria     ON transacao (id_categoria, tipo);
CREATE INDEX ix_divida_usuario          ON divida (id_usuario);
CREATE INDEX ix_dispositivo_usuario     ON dispositivo (id_usuario);
CREATE INDEX ix_leitura_dispositivo_dt  ON leitura_energia (id_dispositivo, dt_leitura);

COMMENT ON TABLE usuario         IS 'Família ou pessoa que usa o app; papel USER ou ADMIN.';
COMMENT ON TABLE categoria       IS 'Categorias de entrada e saída, mostradas em figuras no app.';
COMMENT ON TABLE transacao       IS 'Entrada ou saída de dinheiro registrada pelo app, pelo WhatsApp ou pelo medidor.';
COMMENT ON TABLE divida          IS 'Dívida parcelada da família, usada no plano de quitação.';
COMMENT ON TABLE dispositivo     IS 'Medidor de energia de baixo custo (ESP32) vinculado a um usuário.';
COMMENT ON TABLE leitura_energia IS 'Leitura enviada pelo medidor, com o custo estimado no momento da leitura.';
COMMENT ON COLUMN usuario.renda_mensal       IS 'Renda de referência informada no cadastro; o saldo do mês usa as transações ENTRADA.';
COMMENT ON COLUMN categoria.icone            IS 'Nome do ícone Material usado pelo app Flutter.';
COMMENT ON COLUMN transacao.tipo             IS 'ENTRADA ou SAIDA; deve ser o mesmo tipo da categoria (chave estrangeira composta).';
COMMENT ON COLUMN transacao.origem           IS 'Canal do registro: APP, WHATSAPP ou IOT.';
COMMENT ON COLUMN divida.taxa_juros_mes      IS 'Juros ao mês em porcentagem (12 significa 12% ao mês).';
COMMENT ON COLUMN divida.dia_vencimento      IS 'Dia do mês em que vence a parcela (1 a 31).';
COMMENT ON COLUMN dispositivo.tarifa_kwh     IS 'Preço do kWh em reais.';
COMMENT ON COLUMN dispositivo.meta_mensal_reais IS 'Meta de gasto com luz no mês, em reais.';
COMMENT ON COLUMN leitura_energia.potencia_w IS 'Potência instantânea medida no momento da leitura, em watts.';
COMMENT ON COLUMN leitura_energia.kwh        IS 'Energia consumida desde a leitura anterior, em kWh.';
COMMENT ON COLUMN leitura_energia.custo_estimado IS 'kwh multiplicado pela tarifa do dispositivo, gravado no momento da leitura.';

INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Maria das Dores Silva', '11900000001', 'HASH_DEMO_MARIA', 'USER', 2400.00, DATE '2026-09-01');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'José Carlos Santos', '11900000002', 'HASH_DEMO_JOSE', 'USER', 3200.00, DATE '2026-09-02');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Ana Paula Oliveira', '11900000003', 'HASH_DEMO_ANA', 'USER', 1800.00, DATE '2026-09-03');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Carlos Eduardo Lima', '11900000004', 'HASH_DEMO_CARLOS', 'USER', 2800.00, DATE '2026-09-05');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Beatriz Ferreira Rocha', '11900000005', 'HASH_DEMO_BEATRIZ', 'USER', 2000.00, DATE '2026-09-08');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Paulo Roberto Almeida', '11900000006', 'HASH_DEMO_PAULO', 'USER', 2200.00, DATE '2026-09-10');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Luciana Martins', '11900000007', 'HASH_DEMO_LUCIANA', 'USER', 3500.00, DATE '2026-09-12');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Francisco das Chagas', '11900000008', 'HASH_DEMO_FRANCISCO', 'USER', 1500.00, DATE '2026-09-15');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Rita de Cássia Souza', '11900000009', 'HASH_DEMO_RITA', 'USER', NULL, DATE '2026-09-20');
INSERT INTO usuario (id_usuario, nome, telefone, senha_hash, papel, renda_mensal, dt_cadastro)
VALUES (seq_usuario.NEXTVAL, 'Administrador Grana Amiga', '11900000010', 'HASH_DEMO_ADMINISTRADOR', 'ADMIN', NULL, DATE '2026-08-30');

INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Salário', 'attach_money', 'ENTRADA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Outras entradas', 'add_circle_outline', 'ENTRADA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Alimentação', 'restaurant', 'SAIDA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Mercado', 'shopping_cart', 'SAIDA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Transporte', 'directions_bus', 'SAIDA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Moradia', 'home', 'SAIDA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Energia', 'bolt', 'SAIDA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Saúde', 'medication', 'SAIDA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Lazer', 'sports_esports', 'SAIDA');
INSERT INTO categoria (id_categoria, nome, icone, tipo)
VALUES (seq_categoria.NEXTVAL, 'Outros gastos', 'inventory_2', 'SAIDA');

INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 1, 'ENTRADA', 2400, 'Salário de outubro', TIMESTAMP '2026-10-05 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 6, 'SAIDA', 750, 'Aluguel de outubro', TIMESTAMP '2026-10-06 09:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 1, 'ENTRADA', 2400, 'Salário', TIMESTAMP '2026-11-02 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 6, 'SAIDA', 750, 'Aluguel', TIMESTAMP '2026-11-03 09:10:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 10, 'SAIDA', 120, 'Material escolar', TIMESTAMP '2026-11-04 14:20:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 7, 'SAIDA', 144, 'Conta de luz do medidor', TIMESTAMP '2026-11-05 07:00:00', 'IOT');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 6, 'SAIDA', 62, 'Conta de água', TIMESTAMP '2026-11-06 10:05:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 5, 'SAIDA', 210, 'Passagens do mês', TIMESTAMP '2026-11-07 06:45:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 4, 'SAIDA', 520, 'Compras do mês', TIMESTAMP '2026-11-08 17:30:00', 'WHATSAPP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 8, 'SAIDA', 84, 'Remédio', TIMESTAMP '2026-11-09 12:15:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 1, 3, 'SAIDA', 190, 'Padaria e almoço', TIMESTAMP '2026-11-10 13:00:00', 'WHATSAPP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 2, 1, 'ENTRADA', 3200, 'Salário', TIMESTAMP '2026-11-05 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 2, 6, 'SAIDA', 900, 'Aluguel', TIMESTAMP '2026-11-06 09:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 2, 4, 'SAIDA', 450, 'Compras do mês', TIMESTAMP '2026-11-08 16:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 2, 5, 'SAIDA', 180, 'Passagens do mês', TIMESTAMP '2026-11-04 07:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 2, 7, 'SAIDA', 110.50, 'Conta de luz do medidor', TIMESTAMP '2026-11-08 20:00:00', 'IOT');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 2, 8, 'SAIDA', 60, 'Farmácia', TIMESTAMP '2026-11-09 11:30:00', 'WHATSAPP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 1, 'ENTRADA', 1800, 'Salário', TIMESTAMP '2026-11-05 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 2, 'ENTRADA', 300, 'Bico no fim de semana', TIMESTAMP '2026-11-07 19:00:00', 'WHATSAPP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 6, 'SAIDA', 800, 'Aluguel', TIMESTAMP '2026-11-06 09:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 4, 'SAIDA', 400, 'Compras do mês', TIMESTAMP '2026-11-08 15:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 5, 'SAIDA', 160, 'Passagens do mês', TIMESTAMP '2026-11-04 07:30:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 7, 'SAIDA', 166.50, 'Conta de luz do medidor', TIMESTAMP '2026-11-08 20:00:00', 'IOT');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 3, 'SAIDA', 220, 'Almoço e lanches', TIMESTAMP '2026-11-09 12:40:00', 'WHATSAPP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 8, 'SAIDA', 130, 'Consulta e remédio', TIMESTAMP '2026-11-09 16:10:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 3, 9, 'SAIDA', 60, 'Passeio com as crianças', TIMESTAMP '2026-11-10 15:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 4, 1, 'ENTRADA', 2800, 'Salário', TIMESTAMP '2026-11-05 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 4, 6, 'SAIDA', 1000, 'Aluguel', TIMESTAMP '2026-11-06 09:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 4, 4, 'SAIDA', 480, 'Compras do mês', TIMESTAMP '2026-11-07 18:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 4, 5, 'SAIDA', 200, 'Passagens do mês', TIMESTAMP '2026-11-04 07:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 4, 7, 'SAIDA', 109.20, 'Conta de luz do medidor', TIMESTAMP '2026-11-09 20:00:00', 'IOT');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 4, 9, 'SAIDA', 150, 'Cinema', TIMESTAMP '2026-11-08 20:30:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 5, 1, 'ENTRADA', 2000, 'Salário', TIMESTAMP '2026-11-05 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 5, 6, 'SAIDA', 700, 'Aluguel', TIMESTAMP '2026-11-06 09:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 5, 4, 'SAIDA', 380, 'Compras do mês', TIMESTAMP '2026-11-07 17:00:00', 'WHATSAPP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 5, 5, 'SAIDA', 150, 'Passagens do mês', TIMESTAMP '2026-11-04 07:15:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 5, 7, 'SAIDA', 114.80, 'Conta de luz do medidor', TIMESTAMP '2026-11-07 20:00:00', 'IOT');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 5, 3, 'SAIDA', 100, 'Padaria', TIMESTAMP '2026-11-09 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 6, 1, 'ENTRADA', 2200, 'Salário', TIMESTAMP '2026-11-05 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 6, 6, 'SAIDA', 800, 'Aluguel', TIMESTAMP '2026-11-06 09:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 6, 4, 'SAIDA', 420, 'Compras do mês', TIMESTAMP '2026-11-07 18:30:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 6, 5, 'SAIDA', 190, 'Passagens do mês', TIMESTAMP '2026-11-04 07:20:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 6, 7, 'SAIDA', 190.00, 'Conta de luz do medidor', TIMESTAMP '2026-11-08 20:00:00', 'IOT');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 6, 8, 'SAIDA', 150, 'Remédio', TIMESTAMP '2026-11-09 10:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 6, 3, 'SAIDA', 250, 'Almoço e lanches', TIMESTAMP '2026-11-09 13:30:00', 'WHATSAPP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 7, 1, 'ENTRADA', 3500, 'Salário', TIMESTAMP '2026-11-05 08:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 7, 6, 'SAIDA', 1100, 'Aluguel', TIMESTAMP '2026-11-06 09:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 7, 4, 'SAIDA', 600, 'Compras do mês', TIMESTAMP '2026-11-07 17:45:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 7, 5, 'SAIDA', 220, 'Passagens do mês', TIMESTAMP '2026-11-04 07:10:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 7, 7, 'SAIDA', 136.00, 'Conta de luz do medidor', TIMESTAMP '2026-11-09 20:00:00', 'IOT');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 7, 9, 'SAIDA', 200, 'Festa de aniversário', TIMESTAMP '2026-11-08 21:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 8, 2, 'ENTRADA', 600, 'Bico', TIMESTAMP '2026-11-03 18:00:00', 'WHATSAPP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 8, 6, 'SAIDA', 500, 'Aluguel', TIMESTAMP '2026-11-04 09:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 8, 4, 'SAIDA', 350, 'Compras do mês', TIMESTAMP '2026-11-05 16:30:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 8, 7, 'SAIDA', 105.60, 'Conta de luz do medidor', TIMESTAMP '2026-11-06 20:00:00', 'IOT');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 8, 5, 'SAIDA', 120, 'Passagens do mês', TIMESTAMP '2026-11-04 07:40:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 9, 2, 'ENTRADA', 400, 'Bico', TIMESTAMP '2026-10-12 18:00:00', 'APP');
INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor, descricao, dt_transacao, origem)
VALUES (seq_transacao.NEXTVAL, 9, 4, 'SAIDA', 150, 'Compras da semana', TIMESTAMP '2026-10-20 16:00:00', 'APP');

INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 1, 'Loja Casa Nova (compra parcelada)', 'CARNE', 480.00, 3.5, 120.00, 13, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 1, 'Banco Aurora (cartão de crédito)', 'CARTAO', 1000.00, 12, 250.00, 15, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 1, 'Financeira Horizonte (empréstimo pessoal)', 'PESSOAL', 270.00, 5, 90.00, 22, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 3, 'Banco Aurora (cartão de crédito)', 'CARTAO', 3000.00, 14, 150.00, 8, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 3, 'Loja Casa Nova (carnê)', 'CARNE', 900.00, 4.5, 180.00, 20, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 6, 'Financeira Horizonte (empréstimo pessoal)', 'PESSOAL', 5000.00, 6, 400.00, 5, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 6, 'Banco Aurora (cartão de crédito)', 'CARTAO', 1800.00, 10.5, 300.00, 12, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 8, 'Seu Zé da padaria (dinheiro emprestado)', 'OUTROS', 350.00, 0, 70.00, 31, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 5, 'Loja Casa Nova (carnê)', 'CARNE', 600.00, 3, 100.00, 18, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 2, 'Banco Aurora (cartão de crédito)', 'CARTAO', 0.00, 8, 200.00, 10, 'QUITADA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 4, 'Financeira Horizonte (empréstimo pessoal)', 'PESSOAL', 1500.00, 4, 200.00, 25, 'ABERTA');
INSERT INTO divida (id_divida, id_usuario, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status)
VALUES (seq_divida.NEXTVAL, 7, 'Banco Aurora (cartão de crédito)', 'CARTAO', 2200.00, 11, 260.00, 17, 'ABERTA');

INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 1, 'ESP32-0001', 0.80, 180.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 2, 'ESP32-0002', 0.85, 250.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 3, 'ESP32-0003', 0.90, 150.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 4, 'ESP32-0004', 0.78, 200.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 5, 'ESP32-0005', 0.82, 160.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 6, 'ESP32-0006', 0.95, 220.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 7, 'ESP32-0007', 0.80, 300.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 8, 'ESP32-0008', 0.88, 100.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 9, 'ESP32-0009', 0.80, 180.00);
INSERT INTO dispositivo (id_dispositivo, id_usuario, codigo, tarifa_kwh, meta_mensal_reais)
VALUES (seq_dispositivo.NEXTVAL, 10, 'ESP32-0010', 0.80, 100.00);

INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 1, TIMESTAMP '2026-10-08 08:00:00', 420, 55, 44.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 1, TIMESTAMP '2026-10-18 08:00:00', 510, 60, 48.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 1, TIMESTAMP '2026-10-28 08:00:00', 480, 62, 49.60);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 1, TIMESTAMP '2026-11-03 08:00:00', 380, 40, 32.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 1, TIMESTAMP '2026-11-05 08:00:00', 450, 45, 36.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 1, TIMESTAMP '2026-11-07 08:00:00', 520, 50, 40.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 1, TIMESTAMP '2026-11-09 08:00:00', 410, 45, 36.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 2, TIMESTAMP '2026-11-04 08:00:00', 600, 60, 51.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 2, TIMESTAMP '2026-11-08 08:00:00', 640, 70, 59.50);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 3, TIMESTAMP '2026-11-02 08:00:00', 700, 70, 63.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 3, TIMESTAMP '2026-11-05 08:00:00', 650, 65, 58.50);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 3, TIMESTAMP '2026-11-08 08:00:00', 520, 50, 45.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 4, TIMESTAMP '2026-11-06 08:00:00', 560, 80, 62.40);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 4, TIMESTAMP '2026-11-09 08:00:00', 480, 60, 46.80);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 5, TIMESTAMP '2026-11-03 08:00:00', 610, 70, 57.40);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 5, TIMESTAMP '2026-11-07 08:00:00', 590, 70, 57.40);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 6, TIMESTAMP '2026-11-04 08:00:00', 900, 100, 95.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 6, TIMESTAMP '2026-11-08 08:00:00', 880, 100, 95.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 7, TIMESTAMP '2026-11-05 08:00:00', 500, 90, 72.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 7, TIMESTAMP '2026-11-09 08:00:00', 470, 80, 64.00);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 8, TIMESTAMP '2026-11-02 08:00:00', 640, 60, 52.80);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 8, TIMESTAMP '2026-11-06 08:00:00', 620, 60, 52.80);
INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
VALUES (seq_leitura_energia.NEXTVAL, 9, TIMESTAMP '2026-11-08 08:00:00', 430, 50, 40.00);

COMMIT;

SELECT u.nome                           AS usuario,
       TO_CHAR(t.dt_transacao, 'DD/MM') AS dia,
       c.nome                           AS categoria,
       t.tipo                           AS tipo,
       t.valor                          AS valor,
       t.origem                         AS origem
  FROM transacao t
  JOIN usuario   u ON u.id_usuario   = t.id_usuario
  JOIN categoria c ON c.id_categoria = t.id_categoria
 WHERE u.id_usuario = 1
   AND t.dt_transacao >= TIMESTAMP '2026-11-01 00:00:00'
   AND t.dt_transacao <  TIMESTAMP '2026-12-01 00:00:00'
 ORDER BY t.dt_transacao;

SELECT u.nome                                  AS usuario,
       d.codigo                                AS dispositivo,
       COUNT(l.id_leitura)                     AS qtd_leituras,
       NVL(SUM(l.kwh), 0)                      AS total_kwh,
       NVL(SUM(l.custo_estimado), 0)           AS custo_total,
       d.meta_mensal_reais                     AS meta,
       ROUND(NVL(SUM(l.custo_estimado), 0) * 100 / d.meta_mensal_reais, 2) AS percentual_da_meta
  FROM usuario u
  JOIN dispositivo d ON d.id_usuario = u.id_usuario
  LEFT JOIN leitura_energia l
         ON l.id_dispositivo = d.id_dispositivo
        AND l.dt_leitura >= TIMESTAMP '2026-11-01 00:00:00'
        AND l.dt_leitura <  TIMESTAMP '2026-12-01 00:00:00'
 GROUP BY u.id_usuario, u.nome, d.codigo, d.meta_mensal_reais
 ORDER BY percentual_da_meta DESC, u.nome;

SELECT 'USUARIO' AS tabela, COUNT(*) AS qtd_linhas FROM usuario
UNION ALL SELECT 'CATEGORIA',       COUNT(*) FROM categoria
UNION ALL SELECT 'TRANSACAO',       COUNT(*) FROM transacao
UNION ALL SELECT 'DIVIDA',          COUNT(*) FROM divida
UNION ALL SELECT 'DISPOSITIVO',     COUNT(*) FROM dispositivo
UNION ALL SELECT 'LEITURA_ENERGIA', COUNT(*) FROM leitura_energia;

SET SERVEROUTPUT ON SIZE UNLIMITED

CREATE OR REPLACE FUNCTION fn_formatar_brl (p_valor IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
    IF p_valor IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN CASE WHEN p_valor < 0 THEN '-' END
        || 'R$ '
        || TRANSLATE(TO_CHAR(ABS(p_valor), 'FM999,999,999,990.00'), ',.', '.,');
END fn_formatar_brl;
/

CREATE OR REPLACE FUNCTION fn_formatar_pct (p_valor IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
    IF p_valor IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN TRANSLATE(TO_CHAR(p_valor, 'FM99990.00'), '.', ',') || '%';
END fn_formatar_pct;
/

DECLARE
    c_limite_atencao  CONSTANT NUMBER := 70;
    c_limite_urgente  CONSTANT NUMBER := 90;

    v_ano             NUMBER(4)  := 2026;
    v_mes             NUMBER(2)  := 11;
    v_inicio          DATE;
    v_fim             DATE;

    v_total_familias  NUMBER;
    v_entradas        NUMBER(19,2);
    v_saidas          NUMBER(19,2);
    v_saldo           NUMBER(19,2);
    v_comprometido    NUMBER;
    v_nivel           VARCHAR2(30);

    v_qtd_verde       PLS_INTEGER := 0;
    v_qtd_amarelo     PLS_INTEGER := 0;
    v_qtd_vermelho    PLS_INTEGER := 0;
BEGIN
    v_inicio := TO_DATE(v_ano || LPAD(v_mes, 2, '0') || '01', 'YYYYMMDD');
    v_fim    := ADD_MONTHS(v_inicio, 1);

    SELECT COUNT(*)
      INTO v_total_familias
      FROM usuario
     WHERE papel = 'USER';

    DBMS_OUTPUT.PUT_LINE('TERMÔMETRO DO DINHEIRO - ' || TO_CHAR(v_inicio, 'MM/YYYY')
                         || ' - ' || v_total_familias || ' famílias');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));
    DBMS_OUTPUT.PUT_LINE(RPAD('Família', 26) || LPAD('Entradas', 13) || LPAD('Saídas', 13)
                         || LPAD('Saldo', 13) || LPAD('Comprom.', 10) || '  Nível');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));

    FOR fam IN (SELECT id_usuario, nome
                  FROM usuario
                 WHERE papel = 'USER'
                 ORDER BY id_usuario)
    LOOP
        SELECT NVL(SUM(CASE WHEN tipo = 'ENTRADA' THEN valor END), 0),
               NVL(SUM(CASE WHEN tipo = 'SAIDA'   THEN valor END), 0)
          INTO v_entradas, v_saidas
          FROM transacao
         WHERE id_usuario   = fam.id_usuario
           AND dt_transacao >= v_inicio
           AND dt_transacao <  v_fim;

        v_saldo := v_entradas - v_saidas;

        IF v_entradas <= 0 THEN
            IF v_saidas > 0 THEN
                v_comprometido := 100;
            ELSE
                v_comprometido := 0;
            END IF;
        ELSE
            v_comprometido := v_saidas * 100 / v_entradas;
        END IF;

        IF v_comprometido < c_limite_atencao THEN
            v_nivel := 'VERDE    - Tranquilo';
            v_qtd_verde := v_qtd_verde + 1;
        ELSIF v_comprometido < c_limite_urgente THEN
            v_nivel := 'AMARELO  - Atenção';
            v_qtd_amarelo := v_qtd_amarelo + 1;
        ELSE
            v_nivel := 'VERMELHO - Urgente';
            v_qtd_vermelho := v_qtd_vermelho + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(RPAD(fam.nome, 26)
                             || LPAD(fn_formatar_brl(v_entradas), 13)
                             || LPAD(fn_formatar_brl(v_saidas), 13)
                             || LPAD(fn_formatar_brl(v_saldo), 13)
                             || LPAD(fn_formatar_pct(ROUND(v_comprometido, 2)), 10)
                             || '  ' || v_nivel);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));
    DBMS_OUTPUT.PUT_LINE('Resumo: ' || v_qtd_verde || ' tranquilas, '
                         || v_qtd_amarelo || ' em atenção e '
                         || v_qtd_vermelho || ' urgentes.');
END;
/

DECLARE
    c_max_meses       CONSTANT PLS_INTEGER := 600;
    c_meses_exibidos  CONSTANT PLS_INTEGER := 12;

    v_mes             PLS_INTEGER;
    v_limite          PLS_INTEGER;
    v_saldo           NUMBER(19,2);
    v_juros           NUMBER(19,2);
    v_juros_iniciais  NUMBER(19,2);
    v_devido          NUMBER(19,2);
    v_pagamento       NUMBER(19,2);
    v_amortizacao     NUMBER(19,2);
    v_saldo_final     NUMBER(19,2);
    v_total_pago      NUMBER(19,2);
    v_total_juros     NUMBER(19,2);
BEGIN
    FOR d IN (SELECT id_divida, credor, saldo_devedor, taxa_juros_mes, valor_parcela
                FROM divida
               WHERE id_divida IN (2, 4)
                 AND status = 'ABERTA'
               ORDER BY id_divida)
    LOOP
        v_saldo         := d.saldo_devedor;
        v_mes           := 0;
        v_total_pago    := 0;
        v_total_juros   := 0;
        v_juros_iniciais := ROUND(v_saldo * d.taxa_juros_mes / 100, 2);

        DBMS_OUTPUT.PUT_LINE('PLANO DE QUITAÇÃO - ' || d.credor);
        DBMS_OUTPUT.PUT_LINE('Saldo ' || fn_formatar_brl(v_saldo)
                             || ' | juros ' || fn_formatar_pct(d.taxa_juros_mes) || ' ao mês'
                             || ' | parcela ' || fn_formatar_brl(d.valor_parcela));

        IF d.valor_parcela <= v_juros_iniciais THEN
            v_limite := c_meses_exibidos;
            DBMS_OUTPUT.PUT_LINE('AVISO: a parcela não supera os juros mensais ('
                                 || fn_formatar_brl(v_juros_iniciais) || ').');
        ELSE
            v_limite := c_max_meses;
        END IF;

        DBMS_OUTPUT.PUT_LINE(LPAD('Mês', 3) || LPAD('Saldo inicial', 16) || LPAD('Juros', 13)
                             || LPAD('Pagamento', 13) || LPAD('Amortiz.', 14) || LPAD('Saldo final', 15));

        WHILE v_saldo > 0 AND v_mes < v_limite LOOP
            v_mes         := v_mes + 1;
            v_juros       := ROUND(v_saldo * d.taxa_juros_mes / 100, 2);
            v_devido      := v_saldo + v_juros;
            v_pagamento   := LEAST(d.valor_parcela, v_devido);
            v_amortizacao := v_pagamento - v_juros;
            v_saldo_final := v_devido - v_pagamento;

            IF v_mes <= c_meses_exibidos THEN
                DBMS_OUTPUT.PUT_LINE(LPAD(v_mes, 3)
                                     || LPAD(fn_formatar_brl(v_saldo), 16)
                                     || LPAD(fn_formatar_brl(v_juros), 13)
                                     || LPAD(fn_formatar_brl(v_pagamento), 13)
                                     || LPAD(fn_formatar_brl(v_amortizacao), 14)
                                     || LPAD(fn_formatar_brl(v_saldo_final), 15));
            END IF;

            v_total_pago  := v_total_pago + v_pagamento;
            v_total_juros := v_total_juros + v_juros;
            v_saldo       := v_saldo_final;
        END LOOP;

        IF v_saldo = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Quitação em ' || v_mes || ' meses. Total pago '
                                 || fn_formatar_brl(v_total_pago) || ', dos quais '
                                 || fn_formatar_brl(v_total_juros) || ' são juros.');
        ELSIF d.valor_parcela <= v_juros_iniciais THEN
            DBMS_OUTPUT.PUT_LINE('Sem quitação: após ' || v_mes || ' meses a dívida já está em '
                                 || fn_formatar_brl(v_saldo) || '. Aumente a parcela ou negocie.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('A dívida não quita em até ' || c_max_meses
                                 || ' meses com a parcela informada.');
        END IF;
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));
    END LOOP;
END;
/

DECLARE
    v_id_usuario      usuario.id_usuario%TYPE := 1;
    v_nome            usuario.nome%TYPE;
    v_renda           usuario.renda_mensal%TYPE;

    CURSOR c_dividas (p_id_usuario usuario.id_usuario%TYPE) IS
        SELECT id_divida, credor, tipo, saldo_devedor, taxa_juros_mes, valor_parcela
          FROM divida
         WHERE id_usuario = p_id_usuario
           AND status     = 'ABERTA'
         ORDER BY taxa_juros_mes DESC, saldo_devedor DESC;

    v_divida          c_dividas%ROWTYPE;
    v_posicao         PLS_INTEGER   := 0;
    v_juros_mes       NUMBER(19,2);
    v_total_parcelas  NUMBER(19,2)  := 0;
BEGIN
    SELECT nome, renda_mensal
      INTO v_nome, v_renda
      FROM usuario
     WHERE id_usuario = v_id_usuario;

    DBMS_OUTPUT.PUT_LINE('PRIORIDADE DAS DÍVIDAS - ' || v_nome);
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));

    OPEN c_dividas(v_id_usuario);
    LOOP
        FETCH c_dividas INTO v_divida;
        EXIT WHEN c_dividas%NOTFOUND;

        v_posicao        := v_posicao + 1;
        v_juros_mes      := ROUND(v_divida.saldo_devedor * v_divida.taxa_juros_mes / 100, 2);
        v_total_parcelas := v_total_parcelas + v_divida.valor_parcela;

        DBMS_OUTPUT.PUT_LINE(v_posicao || 'º ' || RPAD(v_divida.credor, 44)
                             || LPAD(fn_formatar_pct(v_divida.taxa_juros_mes), 8)
                             || ' | juros do mês ' || LPAD(fn_formatar_brl(v_juros_mes), 10)
                             || ' | parcela ' || fn_formatar_brl(v_divida.valor_parcela));
        IF v_posicao = 1 THEN
            DBMS_OUTPUT.PUT_LINE('   ^ maiores juros: pague esta primeiro');
        END IF;
    END LOOP;
    CLOSE c_dividas;

    IF v_posicao = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nenhuma dívida aberta.');
    ELSIF v_renda IS NULL OR v_renda = 0 THEN
        DBMS_OUTPUT.PUT_LINE(v_posicao || ' dívida(s) aberta(s); parcelas somam '
                             || fn_formatar_brl(v_total_parcelas) || ' (renda não informada).');
    ELSE
        DBMS_OUTPUT.PUT_LINE(v_posicao || ' dívida(s) aberta(s); parcelas somam '
                             || fn_formatar_brl(v_total_parcelas) || ', ou '
                             || fn_formatar_pct(ROUND(v_total_parcelas * 100 / v_renda, 2))
                             || ' da renda de ' || fn_formatar_brl(v_renda) || '.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Usuário ' || v_id_usuario || ' não encontrado.');
END;
/

CREATE OR REPLACE PROCEDURE prc_registrar_transacao (
    p_id_usuario    IN  usuario.id_usuario%TYPE,
    p_id_categoria  IN  categoria.id_categoria%TYPE,
    p_tipo          IN  transacao.tipo%TYPE,
    p_valor         IN  transacao.valor%TYPE,
    p_id_transacao  OUT transacao.id_transacao%TYPE,
    p_descricao     IN  transacao.descricao%TYPE    DEFAULT NULL,
    p_origem        IN  transacao.origem%TYPE       DEFAULT 'APP',
    p_dt_transacao  IN  transacao.dt_transacao%TYPE DEFAULT NULL
)
IS
    v_qtd_usuario    NUMBER;
    v_nome_categoria categoria.nome%TYPE;
    v_tipo_categoria categoria.tipo%TYPE;
BEGIN
    IF p_valor IS NULL OR p_valor <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'O valor da transação deve ser maior que zero.');
    END IF;

    IF p_origem IS NULL OR p_origem NOT IN ('APP', 'WHATSAPP', 'IOT') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Origem inválida. Use APP, WHATSAPP ou IOT.');
    END IF;

    SELECT COUNT(*)
      INTO v_qtd_usuario
      FROM usuario
     WHERE id_usuario = p_id_usuario;

    IF v_qtd_usuario = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Usuário não encontrado.');
    END IF;

    BEGIN
        SELECT nome, tipo
          INTO v_nome_categoria, v_tipo_categoria
          FROM categoria
         WHERE id_categoria = p_id_categoria;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Categoria não encontrada.');
    END;

    IF v_tipo_categoria <> p_tipo THEN
        RAISE_APPLICATION_ERROR(-20005, 'Tipo da categoria incompatível com a transação.');
    END IF;

    p_id_transacao := seq_transacao.NEXTVAL;

    INSERT INTO transacao (id_transacao, id_usuario, id_categoria, tipo, valor,
                           descricao, dt_transacao, origem)
    VALUES (p_id_transacao, p_id_usuario, p_id_categoria, p_tipo, ROUND(p_valor, 2),
            TRIM(p_descricao), NVL(p_dt_transacao, SYSTIMESTAMP), p_origem);

    DBMS_OUTPUT.PUT_LINE('Transação ' || p_id_transacao || ' registrada: ' || p_tipo
                         || ' de ' || fn_formatar_brl(p_valor) || ' em ' || v_nome_categoria
                         || ' (origem ' || p_origem || ').');
END prc_registrar_transacao;
/

CREATE OR REPLACE PROCEDURE prc_registrar_leitura_energia (
    p_id_dispositivo IN  dispositivo.id_dispositivo%TYPE,
    p_potencia_w     IN  leitura_energia.potencia_w%TYPE,
    p_kwh            IN  leitura_energia.kwh%TYPE,
    p_id_leitura     OUT leitura_energia.id_leitura%TYPE,
    p_dt_leitura     IN  leitura_energia.dt_leitura%TYPE DEFAULT NULL
)
IS
    v_codigo  dispositivo.codigo%TYPE;
    v_tarifa  dispositivo.tarifa_kwh%TYPE;
    v_custo   leitura_energia.custo_estimado%TYPE;
    v_data    leitura_energia.dt_leitura%TYPE;
BEGIN
    IF p_kwh IS NULL OR p_kwh <= 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'O consumo em kWh deve ser maior que zero.');
    END IF;

    IF p_potencia_w IS NULL OR p_potencia_w < 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'A potência em watts não pode ser negativa.');
    END IF;

    BEGIN
        SELECT codigo, tarifa_kwh
          INTO v_codigo, v_tarifa
          FROM dispositivo
         WHERE id_dispositivo = p_id_dispositivo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20013, 'Dispositivo não encontrado.');
    END;

    v_data := NVL(p_dt_leitura, SYSTIMESTAMP);
    IF v_data > SYSTIMESTAMP THEN
        RAISE_APPLICATION_ERROR(-20014, 'A leitura não pode estar no futuro.');
    END IF;

    v_custo := ROUND(p_kwh * v_tarifa, 2);
    p_id_leitura := seq_leitura_energia.NEXTVAL;

    INSERT INTO leitura_energia (id_leitura, id_dispositivo, dt_leitura, potencia_w, kwh, custo_estimado)
    VALUES (p_id_leitura, p_id_dispositivo, v_data, p_potencia_w, p_kwh, v_custo);

    DBMS_OUTPUT.PUT_LINE('Leitura ' || p_id_leitura || ' do ' || v_codigo || ' registrada: '
                         || TRANSLATE(TO_CHAR(p_kwh, 'FM999990.000'), '.', ',')
                         || ' kWh, custo estimado ' || fn_formatar_brl(v_custo) || '.');
END prc_registrar_leitura_energia;
/

CREATE OR REPLACE PROCEDURE prc_resumo_energia (
    p_id_dispositivo IN dispositivo.id_dispositivo%TYPE,
    p_ano            IN NUMBER,
    p_mes            IN NUMBER
)
IS
    v_codigo     dispositivo.codigo%TYPE;
    v_tarifa     dispositivo.tarifa_kwh%TYPE;
    v_meta       dispositivo.meta_mensal_reais%TYPE;
    v_inicio     DATE;
    v_fim        DATE;
    v_qtd        PLS_INTEGER := 0;
    v_total_kwh  NUMBER      := 0;
    v_custo      NUMBER(19,2) := 0;
    v_percentual NUMBER;
    v_faixa      VARCHAR2(10);
BEGIN
    IF p_ano NOT BETWEEN 2000 AND 2100 OR p_mes NOT BETWEEN 1 AND 12 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Ano ou mês inválido.');
    END IF;

    BEGIN
        SELECT codigo, tarifa_kwh, meta_mensal_reais
          INTO v_codigo, v_tarifa, v_meta
          FROM dispositivo
         WHERE id_dispositivo = p_id_dispositivo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20022, 'Dispositivo não encontrado.');
    END;

    v_inicio := TO_DATE(p_ano || LPAD(p_mes, 2, '0') || '01', 'YYYYMMDD');
    v_fim    := ADD_MONTHS(v_inicio, 1);

    DBMS_OUTPUT.PUT_LINE('RESUMO DE ENERGIA - ' || v_codigo || ' - ' || TO_CHAR(v_inicio, 'MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Tarifa ' || fn_formatar_brl(v_tarifa) || ' por kWh | meta do mês '
                         || fn_formatar_brl(v_meta));

    FOR leitura IN (SELECT dt_leitura, kwh, custo_estimado
                      FROM leitura_energia
                     WHERE id_dispositivo = p_id_dispositivo
                       AND dt_leitura >= v_inicio
                       AND dt_leitura <  v_fim
                     ORDER BY dt_leitura)
    LOOP
        v_qtd       := v_qtd + 1;
        v_total_kwh := v_total_kwh + leitura.kwh;
        v_custo     := v_custo + leitura.custo_estimado;
        DBMS_OUTPUT.PUT_LINE('- ' || TO_CHAR(leitura.dt_leitura, 'DD/MM/YYYY HH24:MI')
                             || LPAD(TRANSLATE(TO_CHAR(leitura.kwh, 'FM999990.000'), '.', ','), 10) || ' kWh'
                             || LPAD(fn_formatar_brl(leitura.custo_estimado), 12));
    END LOOP;

    v_percentual := v_custo * 100 / v_meta;

    IF v_custo < v_meta * 0.70 THEN
        v_faixa := 'VERDE';
    ELSIF v_custo <= v_meta THEN
        v_faixa := 'AMARELO';
    ELSE
        v_faixa := 'VERMELHO';
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_qtd || ' leitura(s) | consumo '
                         || TRANSLATE(TO_CHAR(v_total_kwh, 'FM999990.000'), '.', ',') || ' kWh | custo '
                         || fn_formatar_brl(v_custo) || ' = ' || fn_formatar_pct(ROUND(v_percentual, 2))
                         || ' da meta');

    IF v_faixa = 'VERDE' THEN
        DBMS_OUTPUT.PUT_LINE('Faixa VERDE - Tranquilo: o gasto de luz está abaixo de 70% da meta.');
    ELSIF v_faixa = 'AMARELO' THEN
        DBMS_OUTPUT.PUT_LINE('Faixa AMARELO - Atenção: você já usou ' || fn_formatar_pct(ROUND(v_percentual, 2))
                             || ' da meta de luz. Falta ' || fn_formatar_brl(v_meta - v_custo)
                             || ' para estourar!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Faixa VERMELHO - Urgente: a meta de luz estourou em '
                             || fn_formatar_brl(v_custo - v_meta) || '.');
    END IF;
END prc_resumo_energia;
/

CREATE OR REPLACE PROCEDURE prc_alertas_vencimento (
    p_id_usuario IN usuario.id_usuario%TYPE,
    p_data_ref   IN DATE   DEFAULT NULL,
    p_dias       IN NUMBER DEFAULT 15
)
IS
    v_ref       DATE := TRUNC(NVL(p_data_ref, SYSDATE));
    v_nome      usuario.nome%TYPE;
    v_dias      NUMBER;
    v_qtd       PLS_INTEGER  := 0;
    v_semana    PLS_INTEGER  := 0;
    v_total     NUMBER(19,2) := 0;
    v_prazo     VARCHAR2(30);

    CURSOR c_vencimentos (cp_ref DATE, cp_dias NUMBER) IS
        SELECT credor, valor_parcela, dt_vencimento
          FROM (SELECT credor, valor_parcela,
                       CASE WHEN dt_neste_mes >= cp_ref THEN dt_neste_mes
                            ELSE dt_proximo_mes
                       END AS dt_vencimento
                  FROM (SELECT d.credor, d.valor_parcela,
                               TRUNC(cp_ref, 'MM')
                                 + LEAST(d.dia_vencimento, EXTRACT(DAY FROM LAST_DAY(cp_ref))) - 1
                                 AS dt_neste_mes,
                               ADD_MONTHS(TRUNC(cp_ref, 'MM'), 1)
                                 + LEAST(d.dia_vencimento, EXTRACT(DAY FROM LAST_DAY(ADD_MONTHS(cp_ref, 1)))) - 1
                                 AS dt_proximo_mes
                          FROM divida d
                         WHERE d.id_usuario = p_id_usuario
                           AND d.status     = 'ABERTA'))
         WHERE dt_vencimento - cp_ref <= cp_dias
         ORDER BY dt_vencimento, credor;
BEGIN
    BEGIN
        SELECT nome
          INTO v_nome
          FROM usuario
         WHERE id_usuario = p_id_usuario;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20031, 'Usuário não encontrado.');
    END;

    DBMS_OUTPUT.PUT_LINE('ALERTAS DE VENCIMENTO - ' || v_nome || ' - a partir de '
                         || TO_CHAR(v_ref, 'DD/MM/YYYY') || ', próximos ' || p_dias || ' dias');

    FOR conta IN c_vencimentos(v_ref, p_dias) LOOP
        v_dias := conta.dt_vencimento - v_ref;

        IF v_dias = 0 THEN
            v_prazo := 'vence hoje';
        ELSIF v_dias = 1 THEN
            v_prazo := 'vence amanhã';
        ELSE
            v_prazo := 'vence em ' || v_dias || ' dias';
        END IF;

        v_qtd   := v_qtd + 1;
        v_total := v_total + conta.valor_parcela;
        IF v_dias <= 7 THEN
            v_semana := v_semana + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE('- ' || TO_CHAR(conta.dt_vencimento, 'DD/MM') || ' '
                             || RPAD(conta.credor, 44)
                             || LPAD(fn_formatar_brl(conta.valor_parcela), 11) || '  ' || v_prazo);
    END LOOP;

    IF v_qtd = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nenhuma conta vence nos próximos ' || p_dias || ' dias.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(v_qtd || ' parcela(s) somam ' || fn_formatar_brl(v_total) || '.');
        IF v_semana > 0 THEN
            DBMS_OUTPUT.PUT_LINE('ATENÇÃO: ' || v_semana || ' parcela(s) vence(m) em até 7 dias.');
        END IF;
    END IF;
END prc_alertas_vencimento;
/

DECLARE
    v_id_transacao  transacao.id_transacao%TYPE;
BEGIN
    prc_registrar_transacao(1, 4, 'SAIDA', 30, v_id_transacao,
                            p_descricao    => 'Gastei 30 no mercado',
                            p_origem       => 'WHATSAPP',
                            p_dt_transacao => TIMESTAMP '2026-11-10 18:30:00');

    BEGIN
        prc_registrar_transacao(1, 4, 'ENTRADA', 30, v_id_transacao);
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
    END;

    BEGIN
        prc_registrar_transacao(1, 4, 'SAIDA', -5, v_id_transacao);
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
    END;

    BEGIN
        prc_registrar_transacao(99, 4, 'SAIDA', 5, v_id_transacao);
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
    END;
END;
/

BEGIN
    prc_resumo_energia(1, 2026, 11);
END;
/

DECLARE
    v_id_leitura  leitura_energia.id_leitura%TYPE;
BEGIN
    prc_registrar_leitura_energia(1, 900, 50, v_id_leitura,
                                  p_dt_leitura => TIMESTAMP '2026-11-10 08:00:00');

    BEGIN
        prc_registrar_leitura_energia(1, 900, 0, v_id_leitura);
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
    END;

    BEGIN
        prc_registrar_leitura_energia(1, 900, 10, v_id_leitura,
                                      p_dt_leitura => TIMESTAMP '2099-01-01 00:00:00');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
    END;
END;
/

BEGIN
    prc_resumo_energia(1, 2026, 11);
END;
/

BEGIN
    prc_alertas_vencimento(1, DATE '2026-11-10');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));
    prc_alertas_vencimento(2, DATE '2026-11-10');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 82, '-'));
    prc_alertas_vencimento(8, DATE '2026-11-10', 30);
END;
/

COMMIT;

SELECT t.id_transacao, u.nome AS usuario, c.nome AS categoria, t.tipo, t.valor, t.origem
  FROM transacao t
  JOIN usuario   u ON u.id_usuario   = t.id_usuario
  JOIN categoria c ON c.id_categoria = t.id_categoria
 WHERE t.origem = 'WHATSAPP'
   AND t.descricao = 'Gastei 30 no mercado';

SELECT l.id_leitura, d.codigo, l.kwh, l.custo_estimado, l.dt_leitura
  FROM leitura_energia l
  JOIN dispositivo d ON d.id_dispositivo = l.id_dispositivo
 WHERE l.id_dispositivo = 1
 ORDER BY l.dt_leitura DESC;
