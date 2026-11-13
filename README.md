# Grana Amiga – DevOps Tools & Cloud Computing

**Global Solution 2026/2 · FIAP · CitizenTech – Serviços e direitos**

A **Grana Amiga** é uma CitizenTech de educação e organização financeira para famílias brasileiras de baixa renda. Em julho de 2026, 82% das famílias tinham dívidas (recorde da série Peic/CNC), chegando a 84,9% entre quem ganha até três salários mínimos. O app combina jogos educativos, um *Termômetro do Dinheiro* (Verde, Amarelo, Vermelho) e um medidor de energia IoT que mostra em reais o custo da conta de luz.

Nesta disciplina, a **API Java (Spring Boot)** da solução e o **banco Oracle** da disciplina de Banco de Dados rodam em **dois containers integrados** com **Docker Compose**, dentro de uma **VM Linux na Microsoft Azure criada por Azure CLI**.

<!-- TODO: trocar pelo link do vídeo quando publicado -->
**Vídeo da demonstração:** _em breve_

## Integrantes

Turma: **2TDSPR**

| Nome | RM |
|------|----|
| Cassio Ribeiro | 567295 |
| Davi Isac Colin Pereira | 567265 |
| Hugo Souza de Jesus | 568542 |
| Matheus Peres Moraes de Jesus | 567300 |
| Pedro Gonçalves Rodrigues | 567651 |

---

## Arquitetura

![Arquitetura da solução](docs/arquitetura.png)

> Fonte editável: [`docs/arquitetura.drawio`](docs/arquitetura.drawio) (abrir no [draw.io](https://app.diagrams.net/)).

**Fluxo:** o usuário (app, navegador ou cURL) acessa o **IP público da VM** na porta **8080**. O **NSG** da Azure libera só as portas 22 (SSH) e 8080 (API). O Docker encaminha a requisição para o container **`app`** (API Spring Boot), que valida o token JWT e grava e lê os dados no container **`db`** (Oracle Database 23ai Free) pela rede interna **`granaamiga-network`**, usando o nome do serviço `db` como host. Os dados do banco ficam no volume nomeado **`granaamiga_oracle-data`**, então sobrevivem à recriação dos containers. A porta 1521 do banco **não** é exposta para a internet.

| Componente | Tecnologia |
|------------|------------|
| Nuvem | Microsoft Azure (Grupo de Recursos, VM, VNet, NSG, IP público) |
| Provisionamento | Azure CLI (`scripts/provision-vm.sh`) |
| Sistema da VM | Ubuntu Server 24.04 LTS · `Standard_B2als_v2` (2 vCPU, 4 GB) + 2 GB de swap |
| Containers | Docker Engine + Docker Compose v2 |
| Aplicação (`app`) | Java 25 + Spring Boot 4.1 (Spring Security + JWT, JPA, HATEOAS, Actuator, Swagger) · imagem multi-stage, usuário não-root |
| Banco (`db`) | Oracle Database 23ai Free (`gvenzl/oracle-free:23.26.3-slim`) · volume nomeado · 6 tabelas relacionadas |

### Origem do código (ferramenta única do grupo)

Este repositório junta as entregas de outras disciplinas da GS, sem alterá-las, para rodar tudo na nuvem:

| Pasta | Origem | Versão usada |
|-------|--------|--------------|
| `app/` | API da disciplina de Java Advanced – [grana-amiga/Java-Advanced](https://github.com/grana-amiga/Java-Advanced) | commit `b8ea138` |
| `db/GranaAmiga_GS2026_2_BD.sql` | Script da disciplina de Banco de Dados – [grana-amiga/Mastering-Relational-and-Non-Relational-Database](https://github.com/grana-amiga/Mastering-Relational-and-Non-Relational-Database) | commit `d63a3db` |

Os arquivos de DevOps são `app/Dockerfile`, `docker-compose.yml`, `db/init/`, `db/healthcheck.sql`, `.env.example` e `scripts/`.

**Modelo de dados** (criado pelo script de BD):

```
USUARIO 1──N TRANSACAO N──1 CATEGORIA
USUARIO 1──N DIVIDA
USUARIO 1──N DISPOSITIVO 1──N LEITURA_ENERGIA
```

---

## Estrutura do repositório

```
.
├── app/                        # API Java (Spring Boot) – código da disciplina de Java Advanced
│   ├── Dockerfile              # Imagem da API (multi-stage, usuário não-root)
│   ├── .dockerignore
│   ├── pom.xml
│   └── src/                    # Controllers, entidades, segurança JWT, serviços
├── db/
│   ├── GranaAmiga_GS2026_2_BD.sql  # Script Oracle da disciplina de BD (tabelas, dados, procedures)
│   ├── init/01-granaamiga.sh   # Executa o script acima na primeira subida do banco
│   └── healthcheck.sql         # Consulta usada pelo healthcheck do container db
├── scripts/
│   ├── provision-vm.sh         # Azure CLI: grupo de recursos, VM e porta 8080
│   ├── setup-docker.sh         # Na VM: swap, Docker + Compose e sobe os containers
│   └── teardown.sh             # Azure CLI: apaga o grupo de recursos
├── docs/
│   ├── arquitetura.png         # Arquitetura macro da solução
│   └── arquitetura.drawio      # Fonte editável do diagrama
├── docker-compose.yml          # Serviços app + db, rede e volume
├── .env.example                # Modelo das variáveis (o .env real não vai para o Git)
├── .gitattributes              # Força quebra de linha LF nos scripts
└── .gitignore
```

---

## Como executar (How To)

> Todos os comandos `bash` abaixo rodam no **Azure Cloud Shell (Bash)**, no **Git Bash** ou no **WSL**.
> No **PowerShell** do Windows, use `curl.exe` em vez de `curl` (no PowerShell 5.1, `curl` é outro comando).
> Os JSONs de exemplo não têm acentos de propósito: o terminal do Windows pode enviá-los em outra codificação e a API responde 400.

### Pré-requisitos

- Conta na Microsoft Azure com créditos (ex.: Azure for Students).
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) instalado **ou** o Azure Cloud Shell (já vem com Azure CLI e Git).
- Git e cliente SSH (já vêm no Git Bash, no WSL e no Cloud Shell).

### 1. Clonar o repositório e entrar na Azure

```bash
git clone https://github.com/grana-amiga/DevOps-Tools_Cloud-Computing.git
cd DevOps-Tools_Cloud-Computing
az login
```

> No Cloud Shell o `az login` não é necessário.

### 2. Criar a infraestrutura na Azure (Azure CLI)

```bash
chmod +x scripts/*.sh
./scripts/provision-vm.sh
```

O script pede a senha do usuário da VM (12 a 72 caracteres, com maiúscula, minúscula, número e símbolo; a digitação não aparece na tela) e, no fim, mostra o **IP público** e o comando `ssh` pronto.

Comandos executados pelo script, na ordem:

```bash
az account show --query "{Sub:id, Nome:name}" -o jsonc
az group create --name rg-granaamiga-gs --location southafricanorth
az vm create --resource-group rg-granaamiga-gs --name vm-granaamiga --location southafricanorth \
  --image Ubuntu2404 --size Standard_B2als_v2 --authentication-type password \
  --admin-username rm567295 --admin-password <SENHA> \
  --vnet-name vnet-granaamiga --nsg nsg-granaamiga --public-ip-address pip-granaamiga \
  --public-ip-sku Standard --tags "owner=GranaAmiga" "purpose=GlobalSolution"
az vm open-port --resource-group rg-granaamiga-gs --name vm-granaamiga --port 8080 --priority 1010
```

> Para usar outro usuário, região ou tamanho de VM, edite as variáveis no topo de `scripts/provision-vm.sh` e de `scripts/teardown.sh`.

### 3. Conectar na VM

```bash
ssh rm567295@<IP_PUBLICO_DA_VM>
```

### 4. Clonar o repositório na VM e configurar o `.env`

```bash
git clone https://github.com/grana-amiga/DevOps-Tools_Cloud-Computing.git
cd DevOps-Tools_Cloud-Computing
cp .env.example .env
nano .env
```

No `nano`, troque **todos** os valores que começam com `troque-` (salvar: `Ctrl+O`, Enter; sair: `Ctrl+X`). O script do próximo passo não continua enquanto houver valor de exemplo.

> Dica: gere um segredo JWT aleatório com `openssl rand -base64 48` e cole em `APP_JWT_SECRET`.
> Use só letras e números nas senhas do Oracle (alguns símbolos, como `@` e `/`, quebram a conexão do `sqlplus`).

| Variável | Uso | Exemplo |
|----------|-----|---------|
| `ORACLE_PASSWORD` | Senha dos usuários administrativos do Oracle (`SYS`/`SYSTEM`) | _defina uma senha forte_ |
| `APP_USER` | Schema da aplicação (dono das tabelas; também usado pela API) | `granaamiga` |
| `APP_USER_PASSWORD` | Senha do schema da aplicação | _defina uma senha forte_ |
| `APP_JWT_SECRET` | Segredo que assina os tokens JWT (mínimo 32 caracteres) | _saída do `openssl rand`_ |
| `APP_BOOTSTRAP_ADMIN_PHONE` | Telefone do administrador criado pelo script de BD | `11900000010` |
| `APP_BOOTSTRAP_ADMIN_PASSWORD` | Senha do administrador (a API grava o hash BCrypt na subida) | _defina uma senha_ |
| `APP_PORT` | Porta publicada da API na VM | `8080` |

### 5. Instalar Docker + Compose e subir os containers

```bash
chmod +x scripts/*.sh
./scripts/setup-docker.sh
```

O script cria 2 GB de **swap** (folga de memória para o Oracle na VM de 4 GB), instala `docker.io`, `docker-compose-v2` e `docker-buildx`, habilita o Docker no boot, confere o `.env` e executa:

```bash
sudo docker compose up -d --build
sudo docker compose ps
```

Na **primeira** subida o Oracle cria o banco e roda o script da disciplina de BD (tabelas, dados de exemplo e procedures), o que leva cerca de **2 minutos**. O `healthcheck` só marca o `db` como `healthy` quando o script termina, e só então o Compose inicia a `app`. Ao final, o script espera a API responder em `/actuator/health`.

### 6. Testar o CRUD (pela sua máquina, usando o IP público)

A API usa **JWT**: primeiro você cria uma conta e faz login; o token retornado vai no cabeçalho `Authorization` das demais chamadas. Swagger (documentação interativa): `http://<IP_PUBLICO_DA_VM>:8080/swagger-ui.html`.

Defina o IP uma vez para copiar os comandos sem editar:

```bash
IP=<IP_PUBLICO_DA_VM>
```

**Saúde da API e categorias (públicas)**

```bash
curl http://$IP:8080/actuator/health
curl http://$IP:8080/api/v1/categorias
```

**Cadastro e login (tabela `usuario`)**

```bash
# CREATE usuário (201)
curl -X POST http://$IP:8080/api/v1/auth/cadastro \
  -H "Content-Type: application/json" \
  -d '{"nome":"Ana Souza","telefone":"11988887777","senha":"senha-demo-123","rendaMensal":2500.00}'

# Login: guarda o token na variável TOKEN
TOKEN=$(curl -s -X POST http://$IP:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"telefone":"11988887777","senha":"senha-demo-123"}' | sed -E 's/.*"token":"([^"]+)".*/\1/')
echo $TOKEN

# READ perfil do usuário logado
curl http://$IP:8080/api/v1/usuarios/me -H "Authorization: Bearer $TOKEN"
```

**Transação (tabela `transacao`, ligada a `usuario` e `categoria`)**

```bash
# CREATE (201) – categoria 4 = Mercado (SAIDA)
curl -X POST http://$IP:8080/api/v1/transacoes \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"categoriaId":4,"valor":150.75,"tipo":"SAIDA","descricao":"Supermercado"}'

# READ (lista paginada e por id) – troque <ID> pelo "id" retornado no POST
curl http://$IP:8080/api/v1/transacoes -H "Authorization: Bearer $TOKEN"
curl http://$IP:8080/api/v1/transacoes/<ID> -H "Authorization: Bearer $TOKEN"

# UPDATE (200)
curl -X PUT http://$IP:8080/api/v1/transacoes/<ID> \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"categoriaId":4,"valor":160.00,"tipo":"SAIDA","descricao":"Supermercado - ALTERADO"}'

# DELETE (204)
curl -X DELETE http://$IP:8080/api/v1/transacoes/<ID> -H "Authorization: Bearer $TOKEN"
```

**Dívida (tabela `divida`) e Termômetro do Dinheiro**

```bash
# CREATE (201)
curl -X POST http://$IP:8080/api/v1/dividas \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"credor":"Cartao Loja X","tipo":"CARTAO","saldoDevedor":1200.00,"taxaJurosMes":12.5,"valorParcela":300.00,"diaVencimento":10}'

# Termômetro: comprometimento da renda (VERDE / AMARELO / VERMELHO)
curl http://$IP:8080/api/v1/dividas/termometro -H "Authorization: Bearer $TOKEN"
```

**Validação (400):** lançar uma `ENTRADA` numa categoria de `SAIDA` é recusado, regra que também existe no banco (FK composta `transacao(id_categoria, tipo)`):

```bash
curl -X POST http://$IP:8080/api/v1/transacoes \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"categoriaId":4,"valor":10.00,"tipo":"ENTRADA"}'
```

Principais rotas:

| Método | Caminho | Função | Acesso |
|--------|---------|--------|--------|
| POST | `/api/v1/auth/cadastro` · `/api/v1/auth/login` | Criar conta · obter token | Público |
| GET | `/api/v1/categorias` · `/{id}` | Listar · consultar categorias | Público |
| POST/PUT/DELETE | `/api/v1/categorias` · `/{id}` | Manter categorias | ADMIN |
| GET · DELETE | `/api/v1/usuarios/me` | Perfil · excluir a própria conta | USER |
| POST · GET · PUT · DELETE | `/api/v1/transacoes` · `/{id}` | CRUD de transações (+ `/extrato`, `/resumo`) | USER |
| POST · GET · PUT · DELETE | `/api/v1/dividas` · `/{id}` | CRUD de dívidas (+ `/termometro`, `/alertas`, `/{id}/plano`) | USER |
| POST · GET · PUT · DELETE | `/api/v1/dispositivos` · `/{id}` | Medidores de energia (+ `/{id}/leituras`, `/{id}/resumo`) | USER |
| GET | `/actuator/health` | Saúde da API | Público |

> **Usuários de exemplo do script de BD:** as senhas deles são marcadores (`HASH_DEMO_...`), então não fazem login; eles servem para os `SELECT` e as procedures. Para testar a API, cadastre um usuário (como acima) ou use o **administrador**: telefone `APP_BOOTSTRAP_ADMIN_PHONE` e senha `APP_BOOTSTRAP_ADMIN_PASSWORD` do seu `.env`.

### 7. Verificar containers, logs, usuário e banco (dentro da VM)

```bash
# Containers em execução
sudo docker ps
sudo docker compose ps

# Logs
sudo docker compose logs app
sudo docker compose logs db

# Acesso a cada container e usuário utilizado
sudo docker exec app whoami          # appuser (não-root)
sudo docker exec -it app bash        # dentro: pwd -> /app (WORKDIR) ; exit
sudo docker exec db whoami           # oracle (a imagem do banco também não roda como root)
sudo docker exec -it db bash         # dentro: ls /opt/oracle/oradata ; exit

# Rede e volume
sudo docker network ls
sudo docker volume ls
sudo docker volume inspect granaamiga_oracle-data
```

**SELECT direto no banco:** abre o `sqlplus` dentro do container `db`, com o usuário e a senha que já estão nas variáveis de ambiente do container (a senha não aparece na tela):

```bash
sudo docker exec -it db bash -c 'sqlplus "$APP_USER/$APP_USER_PASSWORD@//localhost/FREEPDB1"'
```

No prompt `SQL>`:

```sql
SET LINESIZE 150 PAGESIZE 50
COLUMN table_name FORMAT A20
COLUMN nome FORMAT A25
COLUMN telefone FORMAT A12
COLUMN categoria FORMAT A15
SELECT table_name FROM user_tables;
SELECT id_usuario, nome, telefone, papel FROM usuario;
SELECT u.nome, c.nome AS categoria, t.tipo, t.valor, t.origem
  FROM transacao t
  JOIN usuario u   ON u.id_usuario = t.id_usuario
  JOIN categoria c ON c.id_categoria = t.id_categoria
 WHERE ROWNUM <= 10;
EXIT
```

### 8. Comprovar a persistência

```bash
sudo docker compose down             # remove os containers e a rede (o volume continua)
sudo docker compose up -d            # aguarda o db ficar healthy (cerca de 1 a 2 minutos)
sudo docker compose ps
sudo docker exec -it db bash -c 'sqlplus "$APP_USER/$APP_USER_PASSWORD@//localhost/FREEPDB1"'
```

No `SQL>`, rode `SELECT id_usuario, nome, telefone FROM usuario;`: o usuário cadastrado no passo 6 continua no banco. Na segunda subida o script de BD **não** roda de novo (o volume já tem o banco criado). Também é possível reiniciar a VM (`sudo reboot`): por causa do `restart: unless-stopped` e do Docker habilitado no boot, os containers voltam sozinhos.

> `sudo docker compose down -v` apagaria também o volume e, com ele, os dados. Na próxima subida o banco seria recriado do zero pelo script.

### 9. Apagar os recursos da Azure (evita gastar créditos)

Na sua máquina ou no Cloud Shell (fora da VM):

```bash
./scripts/teardown.sh
```

O script apaga o grupo de recursos `rg-granaamiga-gs` (VM, IP, VNet, NSG e discos) e confirma com `az group exists`, que deve responder `false`.

---

## Decisões técnicas

- **Oracle em container (ferramenta única):** o banco da disciplina de Banco de Dados é o mesmo da API, com as mesmas tabelas, regras (`CHECK`, FKs) e procedures. Em aula os exemplos usaram MySQL e PostgreSQL; escolhemos o Oracle para a solução ser uma só em todas as disciplinas. A imagem `gvenzl/oracle-free` é a forma mais usada de rodar o Oracle Database Free em container, e a variante `slim` é a menor.
- **Script de BD na primeira subida:** a imagem executa os arquivos de `/container-entrypoint-initdb.d` apenas quando o volume está vazio. Assim, o banco nasce com tabelas e dados de exemplo sem nenhum passo manual, e as subidas seguintes reaproveitam os dados do volume.
- **`healthcheck` + `depends_on: service_healthy`:** o healthcheck do `db` só passa quando a última procedure do script existe. A API valida o esquema na inicialização (`ddl-auto: validate`); sem essa espera, ela subiria antes das tabelas e cairia.
- **Dockerfile multi-stage:** o Maven e o JDK ficam só no estágio de build; a imagem final tem apenas o JRE e o `.jar`, ficando menor e com menos superfície de ataque.
- **Usuário não-root (`appuser`):** se a API for comprometida, o invasor não tem privilégios de root dentro do container.
- **Segredos fora da imagem e do Git:** senhas do banco, segredo JWT e senha do administrador ficam no `.env` (no `.gitignore`) e entram nos containers pelo `environment` do Compose. O Dockerfile só tem valores não sensíveis.
- **Banco sem porta publicada (`expose`):** a API acessa o banco pela rede interna do Docker; a porta 1521 não fica aberta para a internet.
- **Volume nomeado:** os dados ficam fora do ciclo de vida do container e sobrevivem a `docker compose down` + `up`.
- **Versões fixas:** `gvenzl/oracle-free:23.26.3-slim`, `maven:3.9.16-eclipse-temurin-25` e `eclipse-temurin:25-jre`, para o ambiente ser reproduzível (nada de `latest`).
- **Swap na VM:** o Oracle usa cerca de 2 GB de memória e a API cerca de 0,4 GB; os 2 GB de swap evitam que a VM de 4 GB trave nos picos da primeira subida, sem pagar por uma VM maior.
- **Infraestrutura como código:** VM, rede e firewall criados por script com Azure CLI; o ambiente pode ser recriado ou apagado a qualquer momento.

---

## Evidências

As evidências da execução na VM Azure estão no **[vídeo da demonstração](#grana-amiga--devops-tools--cloud-computing)**. A tabela abaixo indica em que momento cada uma aparece.

<!-- TODO: preencher os minutos depois de publicar o vídeo -->

| Evidência | Comando / o que mostra | Minuto no vídeo |
|-----------|------------------------|-----------------|
| VM criada pela Azure CLI | `./scripts/provision-vm.sh` + recursos no portal Azure | _a definir_ |
| Containers em execução na VM | `docker ps` / `docker compose ps` | _a definir_ |
| Logs dos containers | `docker compose logs` | _a definir_ |
| Acesso aos containers e usuário não-root | `docker exec` + `whoami` | _a definir_ |
| Estrutura de diretórios | `tree` / `ls` no repositório da VM | _a definir_ |
| CRUD (POST, GET, PUT, DELETE) pelo IP público | `curl http://<IP>:8080/api/v1/...` com JWT | _a definir_ |
| `SELECT` direto no banco | `docker exec -it db ... sqlplus` | _a definir_ |
| Persistência após recriar os containers | `docker compose down` + `up -d` + `SELECT` | _a definir_ |
| Remoção dos recursos | `./scripts/teardown.sh` (`az group exists` = false) | _a definir_ |

---

## Uso de IA generativa

Este repositório foi desenvolvido com apoio do **Claude Code (Anthropic)**, usado para: revisar o Dockerfile e o `docker-compose.yml` contra os requisitos da disciplina, adaptar os scripts de Azure CLI, testar a integração da API e do script de BD em containers e redigir este README. Todo o conteúdo foi revisado, executado e validado pelo grupo.
