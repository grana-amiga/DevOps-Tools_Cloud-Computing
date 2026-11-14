# CLAUDE.md – GS CitizenTech · Repositório de DevOps

Contexto completo do projeto (ideia, equipe, modelo de dados, requisitos de todas as disciplinas, cronograma):
@CONTEXTO-GS-CITIZENTECH.md

Leia o arquivo acima antes de qualquer tarefa. Este CLAUDE.md traz só o que é específico deste repositório.

---

## Quem sou e como trabalhar comigo

- Sou o **Cassio**, responsável pela entrega de **DevOps Tools & Cloud Computing** da Global Solution 2026/2 (FIAP, 2º ano ADS).
- Responda **sempre em português**; termos técnicos, comandos e código em **inglês**.
- Tom equilibrado entre direto e didático: **explique o porquê** de cada decisão (vou ter que defender tudo na apresentação e responder perguntas do professor).
- Em revisões, use ✅ (ok) / ⚠️ (atenção) / ❌ (problema).
- Trabalho de forma iterativa: faça uma etapa, me mostre, eu valido e seguimos. Não faça várias etapas grandes de uma vez sem checar comigo.
- Antes de criar algo, confira se segue o padrão ensinado em aula (ver `C:\Users\cassi\Downloads\2 ano\DevOps`). Se o padrão da aula e a "melhor prática" divergirem, siga a aula e me avise da diferença.

## Objetivo deste repositório

Demonstrar a API Java (Spring Boot) da solução rodando em uma **VM Linux no Microsoft Azure provisionada por Azure CLI**, com **Docker + Docker Compose**, em **dois containers integrados**:

1. **app** – API Java (Spring Boot), CRUD completo com ≥ 2 tabelas relacionadas.
2. **db** – Oracle AI Database 26ai Free (`gvenzl/oracle-free`) com o script da disciplina de BD, volume nomeado e persistência.

O professor precisa **reproduzir todo o ambiente seguindo somente o README**. Solução rodando só em localhost = **nota zero**.

## Estrutura esperada

```
/
├── CLAUDE.md
├── CONTEXTO-GS-CITIZENTECH.md
├── README.md                  ← How To completo (entrega principal)
├── app/                       ← código-fonte da API Java (ver "Decisões em aberto")
├── Dockerfile                 ← imagem da API (ou app/Dockerfile)
├── docker-compose.yml
├── .env.example               ← variáveis com valores de exemplo (o .env real NÃO vai pro Git)
├── .gitignore
├── scripts/
│   ├── provision-vm.sh        ← Azure CLI: resource group, VM, abertura de portas
│   ├── setup-docker.sh        ← instala Docker e Compose na VM
│   └── teardown.sh            ← apaga o resource group (evitar custo)
├── docs/
│   ├── arquitetura.png        ← arquitetura macro (específica da solução, não genérica)
│   └── aulas/                 ← material das aulas convertido em .md (no .gitignore se não puder ser público)
```

## Requisitos obrigatórios (checklist técnico)

Cada item abaixo vale ponto ou gera desconto. Não pule nenhum.

**Azure CLI**
- [ ] VM criada **por script** (`az group create`, `az vm create`, `az vm open-port`), versionado em `scripts/`.
- [ ] Comandos documentados no README, na ordem de execução.

**Dockerfile da API**
- [ ] Build multi-stage (Maven/Gradle → JRE enxuto).
- [ ] `WORKDIR` definido.
- [ ] **Usuário não-root** criado e usado (`USER`).
- [ ] Configuração por **variáveis de ambiente** (URL do banco, usuário, senha, porta).
- [ ] `EXPOSE` da porta da API.

**Container do banco (Oracle)**
- [ ] **Volume nomeado** para os dados.
- [ ] Variáveis de ambiente (`ORACLE_PASSWORD`, `APP_USER`, `APP_USER_PASSWORD`).
- [ ] Porta configurada.
- [ ] ≥ 2 tabelas relacionadas, dados persistem após `docker compose down` + `up`.

**docker-compose.yml**
- [ ] Serviços `app` e `db`.
- [ ] Network definida explicitamente.
- [ ] Volume nomeado declarado.
- [ ] Portas, variáveis de ambiente (via `.env`).
- [ ] `depends_on` com `condition: service_healthy` + `healthcheck` no banco.
- [ ] Containers rodando em **background** (`docker compose up -d`).

**Evidências (no vídeo; o professor confirmou em 11/11 que não precisa de prints)**
- [ ] Arquitetura macro da solução.
- [ ] `docker ps` com os containers rodando na VM.
- [ ] `docker compose logs`.
- [ ] `docker exec` em cada container + `whoami` mostrando usuário não-root na API.
- [ ] Estrutura de diretórios.
- [ ] CRUD completo funcionando (POST, GET, PUT, DELETE).
- [ ] Persistência (dado continua após recriar containers).
- [ ] `SELECT` direto no banco (`docker exec -it db psql ...`).

## Regras que nunca podem ser quebradas

- ❌ **Nunca commitar segredos**: senhas, connection strings reais, chaves. Use `.env` (no `.gitignore`) e `.env.example`.
- ❌ Nada de `latest` sem versão nas imagens base; fixe versões (ex.: `gvenzl/oracle-free:23.26.3-slim`, `eclipse-temurin:25-jre`).
- ❌ Nada que dependa de configuração manual que não esteja no README.
- ⚠️ Commits pequenos e frequentes, mensagens claras, **sempre em um único idioma** (padrão: português, formato `tipo: descrição`, ex.: `feat: adiciona docker-compose com app e db`).
- ⚠️ Lembrar de rodar `scripts/teardown.sh` quando não estiver usando a VM, para não gastar créditos do Azure.

## Modelo de dados (recorte usado aqui)

Mesmo modelo do grupo, nomes em português e snake_case. A API Java usa:
`usuario`, `categoria`, `transacao`, `divida`, `dispositivo`, `leitura_energia`.
Detalhes dos campos: seção 5 do `CONTEXTO-GS-CITIZENTECH.md`.

## Meu ambiente

- Desenvolvo em **Windows**. Scripts de provisionamento em **bash** (a VM é Linux); para rodá-los localmente use **Git Bash, WSL ou Azure Cloud Shell**. Quando um comando for diferente no PowerShell, me avise.
- Azure CLI autenticado com `az login`.

## Decisões tomadas

- [x] **Origem do código (13/11):** cópia em `app/` da API do Pedro (Java-Advanced, commit `6771d19`, atualizado em 13/11; o `Dockerfile` do repo do Pedro é para o Render e NÃO é copiado) e em `db/` do script do Davi (BD, commit `d63a3db`), sem alterá-los. Para atualizar, copiar de novo e citar o novo commit no README.
- [x] **Banco (13/11):** Oracle em container no lugar do PostgreSQL, para ser a mesma ferramenta das disciplinas de Java e BD. Diverge da aula (MySQL/PostgreSQL); a justificativa está no README.
- [x] **VM:** `Standard_B2als_v2` (4 GB, ~US$ 0,05/h) em `southafricanorth` + 2 GB de swap no `setup-docker.sh`. Se travar, trocar para `Standard_B2as_v2` (8 GB, ~US$ 0,10/h). Crédito de estudante: US$ 100/ano, então sempre rodar o teardown.

## Entregas desta disciplina (prazo: 19/11, 23h55)

1. GitHub **público** com código-fonte, Dockerfile, `docker-compose.yml`, script Azure CLI, arquitetura e README/How To.
2. Vídeo no YouTube (**não listado, mínimo 720p, com narração**) mostrando VM Azure, Compose, containers, CRUD, logs e SELECT.
3. **PDF** com nome da solução, integrantes/RMs/turma, link do GitHub e do vídeo.

Apresentação (23 a 27/11): solução na VM, Dockerfile, Compose e comunicação entre containers, banco/volume/persistência, arquitetura e perguntas para todos.
