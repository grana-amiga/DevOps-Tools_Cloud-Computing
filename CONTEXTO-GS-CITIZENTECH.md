# Global Solution 2026/2 – CitizenTech · Contexto do Projeto

> Documento de contexto para o Claude Code. Reúne tudo o que foi definido no planejamento do grupo: regras da GS, ideia do app, revisão, IoT, modelo de dados, divisão por disciplina, telas, modelo de negócio, cronograma e checklist.
> Última atualização: 10/11/2026.

---

## 0. Como trabalhar neste projeto (instruções para o Claude Code)

- **Idioma:** responder sempre em português. Termos técnicos e código ficam em inglês.
- **Tom:** equilibrado entre direto e didático; explicar o porquê das decisões.
- **Revisões de código:** usar indicadores ✅ (ok) / ⚠️ (atenção) / ❌ (problema).
- **Fluxo:** iterativo — eu faço correções pontuais e volto para revisão.
- **Meu papel no grupo:** sou o **Cassio**, responsável por **DevOps** (e, como todos, por QA/Compliance e IoT).
- **Convenção de nomes do banco:** tabelas e colunas em **português e snake_case**, iguais em todos os bancos (Oracle e PostgreSQL).
- **Segredos:** nunca commitar senhas, chaves ou connection strings reais (penaliza em Java, .NET e IoT). Usar variáveis de ambiente, `.env` no `.gitignore` e arquivos `*.example`.
- **Git:** commits pequenos e incrementais, mensagens claras e **em um único idioma** (o Mobile penaliza histórico confuso em até −50 e commit único em Java em −20).
- **Uso de IA generativa:** precisa ser declarado no README (ferramentas usadas e para quê) — obrigatório em Mobile.

---

## 1. Resumo

O grupo vai entregar um **app de educação e organização financeira para famílias endividadas**, com um **medidor de energia IoT** que mostra em reais o custo da conta de luz. A mesma solução é a base das 7 disciplinas da Global Solution, que vale **60% da nota do semestre**.

- **Nome do app:** **Grana Amiga** (definido em 10/11).
- **Tema da GS:** CitizenTech — "Tecnologia com o cidadão no centro da inovação".
- **Linha do desafio:** Serviços e direitos.
- **Parceiros da GS:** Claro e CIX Brasil.
- **Página oficial:** https://experience.fiap.com.br/global-solution-citizen-tech

### Datas-chave

| Data | Marco |
| --- | --- |
| 04/11 | Kickoff (encontro digital, 19h) |
| **13/11** | Cadastro dos grupos no portal (grupo não cadastrado não aparece para entrega) |
| **19/11, até 23h55** | Entrega no Portal FIAP — **sem prorrogação** (meta interna: 18h) |
| 23 a 27/11 | Apresentações presenciais na aula de cada disciplina (30% da nota de cada uma) |
| até 30/11 | Correção dos professores |

### Equipe

| Integrante | Disciplina principal | Compartilhado |
| --- | --- | --- |
| **Cassio** | DevOps Tools & Cloud Computing | QA (Compliance) e IoT |
| Davi | Mastering Relational and Non-Relational Database (PL/SQL) | QA e IoT |
| Hugo | Mobile Application Development (Flutter) | QA e IoT |
| Matheus | Advanced Business Development with .NET | QA e IoT |
| Pedro | Java Advanced (inclui o vídeo pitch) | QA e IoT |

### Regras gerais da GS

- Grupos de até 5 integrantes (sem exceções); podem misturar turmas e turnos.
- Cada entrega leva um `.txt` com RM, nome completo e turma de cada integrante (formato varia por disciplina — ver seção 11).
- **Premiação:** shape e camisetas exclusivas. Elegível quem tirar **≥ 90 em todas as disciplinas e no vídeo pitch de Java**; a escolha final é de Scrum Masters, professores e coordenação.
- Não há chamada durante a GS; dúvidas com professores nas aulas.
- Critérios de uma boa proposta: quem é o cidadão beneficiado, qual problema, como funciona, quais tecnologias, quem participa do ecossistema, como o impacto será medido e ampliado.
- A solução deve ser **simples, segura, inclusiva e acessível**: proteger dados, respeitar diferenças e continuar útil fora do cenário ideal de infraestrutura e conectividade.

---

## 2. Proposta (texto oficial da ideia)

> **[Nome do app]** é uma CitizenTech de educação e organização financeira para famílias brasileiras de baixa renda. Em julho de 2026, 82% das famílias tinham dívidas, recorde da série histórica da CNC, chegando a 84,9% entre quem ganha até três salários mínimos. O cartão de crédito é o principal vilão.
>
> O app combina **aprender** e **organizar**. Na área aberta, sem cadastro, qualquer pessoa joga simuladores curtos sobre juros, compras e poupança, com áudio, ícones grandes e linguagem simples. Ao criar a conta (telefone e senha no primeiro acesso, biometria do aparelho nos seguintes), a família ganha um painel com o *Termômetro do Dinheiro*. Ele classifica a situação em Verde, Amarelo ou Vermelho conforme o comprometimento da renda e gera um plano visual de quitação de dívidas, com alertas de vencimento.
>
> Os gastos podem ser registrados por ícones, por voz ou pelo WhatsApp. Um **medidor de energia de baixo custo (Arduino/ESP32)** mostra em reais quanto a casa está gastando de luz e avisa antes da conta estourar, transformando consumo invisível em decisão financeira.
>
> A solução é gratuita para as famílias e sustentada por parcerias com prefeituras (CRAS), cooperativas de crédito e ONGs. Ela contribui com os ODS 4, 10 e 13, e o impacto é medido pela quantidade de famílias que saem da faixa Vermelha.

### Dados de apoio (Peic/CNC 2026)

- 82% das famílias com dívidas a vencer em julho/2026 (recorde da série).
- 84,9% entre lares com até 3 salários mínimos; 72% acima de 10 salários mínimos.
- Cartão de crédito presente em 84,9% dos casos de endividamento (2026).
- Comprometimento médio da renda com dívidas: cerca de 30% (base do limite do Termômetro).

Fontes:
- https://soubrasilia.com/endividamento-familias-82-por-cento-julho-2026-peic-cnc-recorde/
- https://paraibabusiness.com.br/endividamento-de-familias-chega-a-82-em-julho-diz-cnc/
- https://www.dieese.org.br/sinteseespecial/2026/sinteseEspecial23.pdf

---

## 3. Revisão da ideia original

O rascunho original se encaixava no tema, mas **não cobria IoT** e tinha **falha de segurança no login**. Ambos já estão corrigidos na proposta acima.

### ✅ O que já estava bom
- Problema real e mensurável (atende o item 06 de Compliance: público-alvo com dados de mercado).
- Foco concreto para os jogos: "Fugindo dos Juros" deve tratar rotativo e parcelamento do cartão.
- Acessibilidade e inclusão (áudio, ícones grandes, WhatsApp).
- Área aberta antes do login: baixa barreira de entrada.
- Termômetro do Dinheiro: regra de negócio pronta para o PL/SQL.

### ❌ Problemas críticos (já resolvidos)
1. **Faltava IoT/Arduino** → decisão: **monitor de consumo de energia** (seção 4).
2. **"Diga seu nome para entrar" não é autenticação** → primeiro acesso com telefone + senha (JWT); biometria do aparelho só destrava o token salvo; voz apenas para navegação.
3. **Login com CPF** (dado pessoal sob LGPD) → usar **telefone** como login.

### ⚠️ Pontos de atenção
- **Escopo para 15 dias:** chatbot de WhatsApp, OCR de comprovantes e IA de voz não são cobrados por nenhuma disciplina. Ficam como **visão de produto** (Archimate e pitch). No app: tela simulada de conversa ou link `wa.me`.
- **Mobile exige ≥ 5 telas** → planejadas 7 (seção 7).
- **Formulário obrigatório** em Mobile: `Form` + `GlobalKey<FormState>` com validação na tela de gasto.
- **Biometria/voz no Flutter** (`local_auth`, `speech_to_text`) podem ser "fora do escopo das aulas" (−60) → confirmar com o professor ou deixar opcional.
- **Duas APIs** (Java e .NET) → divisão na seção 6.
- **Persona:** famílias com renda de até 3 salários mínimos, chefes de família com baixa escolaridade. Crianças = público secundário dos jogos.
- **Conectividade:** registro offline com sincronização; WhatsApp como canal de baixo consumo; medidor IoT funciona sem internet.

### Inconsistências no material da FIAP
- Slide de .NET fala em "Apresentação online", mas o resto diz presencial → confirmar.
- Requisito 07 de Mobile ("Publicação do app") não tem pontuação própria, mas sua falta custa −20.
- Java diz que o app Mobile consome a API, mas Mobile aceita dados mockados → app com mock, estruturado para trocar a fonte pela API se der tempo.

---

## 4. Componente IoT: monitor de energia

Medidor de consumo que estima em reais a conta de luz e alerta quando a meta mensal está perto de estourar.

### Componentes

| Componente | Função |
| --- | --- |
| ESP32 (framework Arduino) | Lê o sensor; Wi-Fi embutido |
| Sensor SCT-013 (alicate não invasivo) + resistor de carga | Mede a corrente sem mexer na fiação |
| Display LCD 16x2 I2C | Mostra consumo e R$ estimado, mesmo sem internet |
| LED RGB | Termômetro de energia: verde, amarelo, vermelho |
| Buzzer | Alerta sonoro ao passar da meta |

**Segurança:** não usar ACS712 em série com a rede 127/220V. Se a demo for no **Wokwi**, simular a corrente com potenciômetro e registrar isso na análise de limitações.

### Lógica

```
Irms (EmonLib) × tensão (127 ou 220V)  = potência (W)
potência × tempo                        = kWh acumulado
kWh × tarifa (R$/kWh + bandeira)        = custo estimado em R$
custo / meta mensal → LED: < 70% verde · 70–100% amarelo · > 100% vermelho + buzzer
```

### Fluxo de comunicação em rede

```
Sensor SCT-013 → ESP32 (LCD, LED, buzzer) → Wi-Fi → Roteador da casa → Internet
  → Broker MQTT (HiveMQ, tópico casa/{id}/energia)
  → Node-RED (dashboard + ponte HTTP)
  → API Java (POST /leituras, grava no PostgreSQL)
  → App Flutter (alerta de meta, REST + JWT)
```

Sem internet, o ESP32 guarda as leituras e continua mostrando o custo no LCD; envia quando a conexão volta.

### Pontuação IoT (Disruptive Architectures)

| Item | Pts |
| --- | --- |
| Identificação do problema e proposta CitizenTech | 10 |
| Desenvolvimento do protótipo | 25 |
| Componentes e fluxo de comunicação em rede | 20 |
| Diagrama da arquitetura | 15 |
| Testes, evidências e demonstração | 20 |
| Documentação técnica e justificativas | 10 |

Penalidades: fora do prazo/portal ou sem `.txt` = zero; sem relação com CitizenTech −40; sem código/circuito/evidências −30; sem diagrama −20.

Entrega: **apenas `.txt`** com RM, nome completo e link do GitHub. Repositório com código, dependências, configs de exemplo sem credenciais; README com integrantes, funcionalidade, execução, tecnologias, justificativas e diagrama; evidências (casos de teste, resultados, métricas, limitações).

Apresentação (30%): demo IoT + redes 25 · arquitetura 15 · justificativa de sensores/técnicas 20 · testes 15 · limitações e situações propostas 15 · domínio técnico 10.

---

## 5. Modelo de dados compartilhado

```
USUARIO 1──N TRANSACAO N──1 CATEGORIA
USUARIO 1──N DIVIDA
USUARIO 1──N DISPOSITIVO 1──N LEITURA_ENERGIA

(.NET – separado)  TRILHA 1──N DESAFIO
```

| Entidade | Campos principais | Usada em |
| --- | --- | --- |
| `usuario` | id, nome, telefone (login), senha_hash, papel (USER/ADMIN), renda_mensal, dt_cadastro | Java, PL/SQL, Mobile |
| `categoria` | id, nome, icone, tipo (ENTRADA/SAIDA) | Java, PL/SQL, Mobile |
| `transacao` | id, usuario_id, categoria_id, valor, tipo, descricao, dt_transacao, origem (APP/WHATSAPP/IOT) | Java, PL/SQL, Mobile |
| `divida` | id, usuario_id, credor, tipo (CARTAO/CARNE/PESSOAL/…), saldo_devedor, taxa_juros_mes, valor_parcela, dia_vencimento, status | Java, PL/SQL, Mobile |
| `dispositivo` | id, usuario_id, codigo, tarifa_kwh, meta_mensal_reais | Java, IoT |
| `leitura_energia` | id, dispositivo_id, dt_leitura, potencia_w, kwh, custo_estimado | Java, IoT |
| `trilha` | id, titulo, tema (JUROS/CONSUMO/POUPANCA), nivel | .NET, Mobile |
| `desafio` | id, trilha_id, pergunta, alternativas, resposta_correta, pontos | .NET, Mobile |

- O campo `origem` em `transacao` amarra o ecossistema (app, WhatsApp ou medidor).
- Bancos: **Oracle** (.NET e PL/SQL) e **PostgreSQL** (Java/DevOps). Só o DDL muda; nomes e tipos lógicos iguais.

### Regra do Termômetro do Dinheiro

```
comprometimento = soma(valor_parcela das dívidas ativas) / renda_mensal
≤ 30%  → VERDE
≤ 50%  → AMARELO
> 50%  → VERMELHO
```

---

## 6. Distribuição pelas disciplinas

| Disciplina | Responsável | Entrega | Peso principal |
| --- | --- | --- | --- |
| Java Advanced | Pedro | API principal + vídeo pitch | Modelagem 20 · Segurança 20 · Consultas 15 |
| .NET | Matheus | API de conteúdo (Trilha 1:N Desafio) | EF Core + Oracle + Migrations 25 |
| **DevOps** | **Cassio** | API Java + PostgreSQL em containers numa VM Azure | Containers 15 + 15 · README/evidências 15 |
| Banco (PL/SQL) | Davi | Termômetro e plano de quitação | Cursor 15 · Procedures 15 |
| Mobile (Flutter) | Hugo | App com 7 telas, dados mockados | Navegação 20 · Visual 20 · Form 20 · Git 20 |
| IoT | Todos | Monitor de energia + diagrama de rede | Protótipo 25 · Rede 20 · Testes 20 |
| Compliance (QA) | Todos | Archimate (4 camadas) + documento descritivo | 20 por camada |

### 6.1 DevOps Tools & Cloud Computing (Cassio) — detalhado

**Objetivo:** demonstrar a solução (API Java ou .NET — escolhido **Java**) rodando em **VM no Azure provisionada por Azure CLI**, com Docker, mínimo de **2 containers integrados** (app + banco), CRUD funcional e dados persistidos no banco em container. Infra reproduzível.

**Decisão:** API Java (Spring Boot) + **PostgreSQL** em container (mais leve que Oracle em container e fácil de reproduzir).

**Requisitos:**
1. **Azure:** VM criada via Azure CLI; comandos documentados no repositório (script versionado).
2. **Docker:** Docker, Dockerfile e Docker Compose instalados e configurados na VM; containers rodando na VM.
3. **Aplicação:** CRUD completo, ≥ 2 tabelas relacionadas, persistência, roda em container, **usuário não privilegiado**, **WORKDIR**, **variável de ambiente**, **porta exposta**.
4. **Banco:** container com **volume nomeado**, variável de ambiente, porta, ≥ 2 tabelas relacionadas, persistência.
5. **docker-compose.yml:** app, banco, network, volume, portas, variáveis de ambiente, dependências entre serviços.
6. **Evidências:** arquitetura macro, containers executando, logs, acesso aos containers (`exec`), usuário utilizado, estrutura de diretórios, CRUD funcionando, persistência, `SELECT` direto no banco.

**Pontuação (70 pts entrega + 30 apresentação):**

| Item | Pts |
| --- | --- |
| Arquitetura macro da solução | 10 |
| VM Azure + provisionamento via CLI | 10 |
| Container da aplicação + Dockerfile | 15 |
| Container do banco + persistência | 15 |
| Docker Compose + integração App + Banco | 5 |
| GitHub, README/How To + evidências | 15 |

**O que tira pontos:**
- Fora do prazo, GitHub/vídeo inacessível ou **solução só em localhost** → nota zero.
- Sem código-fonte, Dockerfile ou `docker-compose.yml` → nota zero.
- Sem relação com CitizenTech → nota zero.
- Sem `SELECT` no banco / CRUD incompleto / só uma tabela → −20.
- Sem variável de ambiente, porta, `WORKDIR`, containers fora de background, sem logs → até −15.
- README/How To incompleto, sem volume, sem usuário não-root, sem logs, exec ou evidências → até −5 por container.
- Vídeo abaixo de 720p, ilegível ou sem explicação por voz/legenda → −20.
- Arquitetura genérica (não condiz com a aplicação) ou fluxograma → zero no quesito.

**Entregas:**
- GitHub público: código-fonte, Dockerfile, `docker-compose.yml`, script Azure CLI, arquitetura e README/How To.
- Vídeo no YouTube (não listado, ≥ 720p) mostrando VM Azure, Compose, containers, CRUD, logs e `SELECT`.
- **PDF** com nome da solução, integrantes/RMs/turma, link do GitHub e do vídeo.
- **O professor deve conseguir reproduzir o ambiente seguindo somente o README.**

**Apresentação (30 pts):** solução na VM 5 · Dockerfile/container app 5 · Compose e comunicação 5 · banco, volume e persistência 5 · arquitetura 5 · domínio técnico 5. Perguntas para todos os membros.

**Dependência:** precisa de uma versão da API Java que compile até **15/11** para testar o Compose na VM.

### 6.2 Java Advanced (Pedro)

Spring Boot, API REST consumida pelo app Mobile. Tecnologias obrigatórias: Spring Web, Spring Data JPA, Bean Validation, Spring Security + JWT, Spring Cache, Spring HATEOAS, Actuator, Swagger/OpenAPI.

Plano:
- Entidades: `usuario`, `categoria`, `transacao`, `divida`, `dispositivo`, `leitura_energia`, com DTOs, paginação e ordenação.
- Derived query: `findByUsuarioIdAndDtTransacaoBetween` (extrato do mês).
- `@Query` JPQL: soma de gastos por categoria no mês.
- Specification: filtro dinâmico de transações (categoria, tipo, período, valor mín./máx.).
- Cache: `@Cacheable` em categorias e resumo mensal; `@CacheEvict` do resumo a cada nova transação.
- Segurança: cadastro/login JWT, BCrypt, papéis `USER` (próprios dados) e `ADMIN` (categorias), CORS para o app.
- `@RestControllerAdvice` com erros padronizados; HATEOAS; Actuator (health, info, metrics); Swagger completo.

Pontuação: modelagem 20 · consultas 15 · validação/erros 10 · cache 10 · HATEOAS 10 · Actuator 5 · Swagger/README 10 · segurança 20.
Penalidades: não compila/não sobe pelo README −30; commit único/sem evolução −20; senhas/chaves commitadas −10; sem relação com tema −40.
Entrega: `.txt` só com link do repo público. README: integrantes, link do pitch, como rodar, usuários de teste por papel, diagrama de entidades, justificativa de consultas e cache.

**Vídeo pitch (até 5 min, vale para premiação):** 0:00 problema (com dado real) · 0:45 solução · 1:30 demonstração rodando · 3:00 modelo de negócio · 4:00 impacto, ODS e fechamento.

### 6.3 Advanced Business Development with .NET (Matheus)

- ASP.NET Core 8 Web API com controllers, EF Core, Oracle FIAP (`oracle.fiap.com.br`), Migrations versionadas.
- `trilha` 1:N `desafio`: conteúdo dos jogos.
- CRUD: GET lista, GET por id, POST 201, PUT 204, DELETE 204.
- Inválido → 400 com JSON; id inexistente → 404.
- Não cobrado: Swagger, autenticação, camadas, testes.
- Pontuação: compila e roda pelo README 20 · modelo 1:N e validações 20 · EF Core + Oracle + Migrations 25 · CRUD com status corretos 20 · 400/404 10 · README 5.
- Penalidades: sem relação com tema −40; não compila/Migrations não aplicam −30; senha do Oracle versionada ou tabela criada à mão −15.
- Entrega: repo público (projeto na raiz, `.gitignore` sem bin/obj), README (integrantes, descrição, diagrama, como executar/testar), vídeo até 5 min; `.txt` com RM, nome, turma, GitHub e vídeo.

### 6.4 Banco de Dados – PL/SQL (Davi)

- Tabelas `usuario`, `categoria`, `transacao`, `divida` (≥ 4 relacionadas), **≥ 10 linhas cada**.
- Bloco anônimo com variáveis, `SELECT INTO` e `DBMS_OUTPUT`.
- `PRC_REGISTRAR_TRANSACAO` (operação): valida e insere o gasto.
- `PRC_TERMOMETRO_E_PLANO` (processamento): `IF/ELSIF` do Termômetro; cursor explícito percorre dívidas por maior juros (método avalanche); `LOOP` simula meses até quitar.
- Pontuação (70): modelo/carga 10 · bloco anônimo 10 · decisão 10 · repetição 10 · cursor 15 · 2 procedures 15.
- Penalidades: scripts com erro até −30; sem evidências/dados até −30; sem `.txt` até −10.
- Entrega: scripts `.sql`, README/PDF (problema, regras, execução, resultados), capturas das execuções.

### 6.5 Mobile – Flutter (Hugo)

- ≥ 5 telas (planejadas 7), navegação com passagem de parâmetros.
- Widgets: Scaffold, AppBar, Column, Row, Container, Padding, SizedBox, Card, Image, Icon, ListView, GridView; identidade visual consistente.
- `StatefulWidget` + `setState()`: saldo ao registrar gasto, pontuação do jogo.
- `Form` + `GlobalKey<FormState>` + `TextFormField` + `SnackBar`/`AlertDialog`.
- Dados mockados em classes Dart com os campos do modelo compartilhado.
- Pontuação: navegação 20 · visual 20 · estado 10 · formulário 20 · Git 20 · vídeo 10.
- Penalidades: fora do escopo das aulas −60; Git incoerente −50; commit após prazo −30; < 5 telas −30; sem professor como colaborador −20; vídeo inválido −20; app não publicado −20; README incompleto −20; repo privado −100.
- README: descrição, cidadão beneficiado, ODS, declaração de IA generativa.
- Vídeo narrado até 5 min em emulador ou celular (navegador não vale), YouTube não listado.
- Entrega: `.txt` com nome do grupo, integrantes, link do vídeo e repo público.

### 6.6 Compliance, Quality Assurance & Tests (todos)

- Arquitetura de Soluções baseada em **TOGAF**, diagrama no **Archi (Archimate)**.
- Camadas: **Motivação** (endividamento das famílias), **Negócio** (famílias, CRAS, parceiros), **Aplicação** (app, APIs, chatbot), **Tecnologia** (Azure, containers, Arduino/ESP32).
- Documento descritivo (70% da nota): 20 por camada + 10 nome/equipe/problema + 10 público-alvo com estatísticas.
- Penalidades: fora do prazo −10; arquivo corrompido/sem identificação/PDF em baixa resolução −10; sem relação com tema ou sem usar a ferramenta da aula → zero.
- Entrega: `.zip` com documento descritivo, arquivo `.archi` e PDF do diagrama em alta definição.

---

## 7. Telas do app

| # | Tela | Conteúdo | Requisito de Mobile |
| --- | --- | --- | --- |
| 1 | Início (aberta) | Logo, botão de acessibilidade, boas-vindas com áudio, carrossel de jogos, "Entrar / Criar minha conta" | Navegação, visual |
| 2 | Jogo / Simulador | "Desafio do Supermercado" e "Fugindo dos Juros"; pontuação muda a cada resposta | Estado, parâmetro (qual jogo) |
| 3 | Login / Cadastro | Telefone + senha; biometria opcional nos acessos seguintes | Formulário com validação |
| 4 | Painel principal | Termômetro, saldo com áudio, feed de gastos com ícones, botões (+) (−) e WhatsApp | Visual, estado |
| 5 | Adicionar gasto | Grade de categorias, teclado numérico grande, câmera (visual) | `Form` + `GlobalKey`, `SnackBar` |
| 6 | Plano de quitação | Dívidas por juros, barra de progresso, próximo vencimento | Navegação, `ListView` |
| 7 | Alertas e energia | Vencimentos e custo de luz do mês (medidor) | Narrativa IoT |

### Fluxo do chatbot (visão de produto)
1. Usuário envia áudio: "Gastei 15 reais com o ônibus hoje."
2. Bot transcreve, identifica valor e categoria, grava transação com `origem = WHATSAPP`.
3. Bot responde: "Entendido! Adicionei R$ 15,00 em Transporte. Seu saldo atualizado é R$ 120,00. Confira no app!"

No Archimate, o chatbot é um serviço da camada de Aplicação ligado à API Java.

---

## 8. Modelo de negócio, ODS e impacto

### Modelo de negócio
- **Gratuito para as famílias.**
- **B2G:** prefeituras e CRAS usam o app em programas sociais, com painel agregado e anonimizado.
- **Parcerias:** cooperativas de crédito e ONGs patrocinam trilhas e oferecem renegociação.
- **Conectividade:** Claro (parceira da GS) com zero-rating.
- **Medidor IoT:** distribuído por programas de eficiência energética ou distribuidoras de energia.

### ODS
| ODS | Contribuição |
| --- | --- |
| 10 – Redução das desigualdades | Foco em famílias com até 3 salários mínimos |
| 4 – Educação de qualidade | Jogos e trilhas de educação financeira gratuitos e acessíveis |
| 13 – Ação contra a mudança do clima | Medidor reduz desperdício de energia |

### Métricas de impacto
- % de usuários que saem da faixa Vermelha em 3 meses.
- Valor total de dívidas quitadas.
- Jogos e trilhas concluídos.
- Dias seguidos registrando gastos.
- Redução média do consumo de energia nas casas com medidor.

---

## 9. Cronograma

| Período | Foco | O que fica pronto |
| --- | --- | --- |
| 06 a 08/11 | Base | Nome do app, repos públicos, modelo de dados fechado, rascunho Archimate (Motivação e Negócio), circuito IoT montado ou no Wokwi |
| 09 a 12/11 | Desenvolvimento | Java: entidades, CRUD, JWT · .NET: CRUD e Migrations · PL/SQL: tabelas, carga, bloco · Mobile: 7 telas · **DevOps: script Azure CLI e Dockerfile** · IoT: sensor, LED, LCD |
| 13/11 | Prazo FIAP | Grupo cadastrado no portal |
| 13 a 15/11 | Avançado | Java: consultas, cache, HATEOAS, Actuator, Swagger · Mobile: form e estado · PL/SQL: procedures e cursor · IoT: MQTT e Node-RED · **DevOps: Compose na VM com a API real (até 15/11)** |
| 16 a 17/11 | Integração e docs | READMEs, evidências, Archimate final, documento descritivo |
| 18/11 | Vídeos e QA cruzado | Vídeos (pitch, .NET, DevOps, Mobile); cada um segue o README de outro do zero |
| 19/11 | Entrega | Tudo no portal até 23h55 (meta 18h); nenhum commit no Mobile depois |
| 23 a 27/11 | Apresentações | Todos preparados para responder sobre qualquer código |

---

## 10. Checklist de entrega no portal

- [ ] Java Advanced (Pedro): `.txt` só com link do repo público; link do pitch no README
- [ ] .NET (Matheus): `.txt` com RM, nome, turma, link do GitHub e do vídeo
- [ ] **DevOps (Cassio): PDF com nome da solução, integrantes, RMs, turma, link do GitHub e do vídeo**
- [ ] Banco (Davi): `.zip` com scripts `.sql`, README/PDF, capturas e `.txt`
- [ ] Mobile (Hugo): `.txt` com nome do grupo, integrantes, vídeo e repo público; professor como colaborador
- [ ] IoT (todos): apenas `.txt` com RM, nome completo e link do repo
- [ ] Compliance (todos): `.zip` com documento, `.archi` e PDF em alta resolução
- [ ] Todos os links testados em aba anônima

---

## 11. Pendências do grupo

- [x] Definir o nome do app → **Grana Amiga**
- [ ] Confirmar com o professor de .NET se a apresentação é online ou presencial
- [ ] Confirmar com o professor de Mobile se biometria e voz entram no escopo
- [ ] Decidir se o IoT será físico ou simulado no Wokwi
- [ ] Definir quem fica com o circuito e quem fica com o fluxo de rede do IoT

---

## 12. Sugestões de nome para o app

| Grupo | Nomes |
| --- | --- |
| Termômetro do Dinheiro | Termômetro, Sinal Verde, Saldo Verde |
| Tom acolhedor e popular | Cofrinho, Bolso Cheio, **Conta Certa**, Grana Amiga |
| Sair da dívida | Quita, Respira, Virada |
| Cidadania e família | **Lar em Dia**, Família no Azul |

Favoritas: **Conta Certa** e **Lar em Dia** (cobrem educação, organização de gastos e conta de luz; fáceis de falar por voz). Checar Play Store, App Store e Google antes de fechar.

---

## 13. Referências

- Página da GS: https://experience.fiap.com.br/global-solution-citizen-tech
- UN-Habitat – diretrizes de cidades inteligentes centradas nas pessoas: https://unhabitat.org/sites/default/files/2025/03/international_guidelines_on_people_centred_smart_cities_tc_6.3.2025_1.pdf
- FAO – agricultura digital: https://www.fao.org/e-agriculture/resources
- PNUD – estratégia digital inclusiva: https://www.undp.org/digital/Digital-Strategy
- ONU – ODS 11: https://sdgs.un.org/goals/goal11
- Documento de planejamento do grupo (Claude Docs): https://claude.ai/artifact/SaixGQfe97rMN3Wd3ysTD7
