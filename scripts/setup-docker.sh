#!/bin/bash
# setup-docker.sh - Cria swap, instala Docker e Docker Compose na VM e sobe os containers app + db
# Uso (DENTRO da VM, depois do git clone e de criar o .env):
#   chmod +x scripts/setup-docker.sh
#   ./scripts/setup-docker.sh

# Para o script no primeiro comando que falhar
set -e

# Roda a partir da raiz do repositório, onde estão o docker-compose.yml e o .env,
# independente da pasta em que o script foi chamado
cd "$(dirname "$0")/.."

# ===== Variáveis =====
PORT=8080

echo "*************************************"
echo "Grana Amiga - Setup do Docker e dos containers na VM"
echo "*************************************"
echo ""

echo "[1/7] Criando 2 GB de swap (folga de memória para o Oracle)..."
# A VM tem 4 GB e o Oracle usa ~2 GB (mais nos picos da primeira subida).
# O swap é uma área do disco usada como memória extra: evita que o Linux mate processos por falta de RAM.
# Não foi usado em aula; é uma proteção extra, mais barata do que pagar por uma VM de 8 GB.
if sudo swapon --show | grep -q /swapfile; then
  echo "Swap já existe, nada a fazer."
else
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile          # só o root lê o arquivo de swap
  sudo mkswap /swapfile
  sudo swapon /swapfile
  # /etc/fstab: o swap volta sozinho se a VM reiniciar
  grep -q "^/swapfile" /etc/fstab || echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
fi
free -h
echo ""

echo "[2/7] Atualizando os pacotes do Ubuntu..."
sudo apt update -y
echo ""

echo "[3/7] Instalando e habilitando o Docker e o Docker Compose..."
# docker.io: Docker Engine do repositório do Ubuntu
# docker-compose-v2: comando "docker compose" (o docker.io não traz o Compose)
# docker-buildx: builder usado pelo "docker compose up --build"
sudo apt install -y docker.io docker-compose-v2 docker-buildx
# enable: o Docker sobe junto com a VM, e com ele os containers com restart: unless-stopped
sudo systemctl enable --now docker
sudo docker --version
sudo docker compose version
echo ""

echo "[4/7] Conferindo o arquivo .env..."
if [ ! -f .env ]; then
  echo "ERRO: arquivo .env não encontrado. Crie com: cp .env.example .env && nano .env"
  exit 1
fi
# Se ainda houver algum valor de exemplo do .env.example (senhas ou segredo JWT), para o script aqui
if grep -q "=troque-" .env; then
  echo "ERRO: o .env ainda tem valores de exemplo (troque-...). Edite com: nano .env"
  grep -o "^[A-Z_]*=troque-" .env | cut -d= -f1
  exit 1
fi
# Mostra só o schema e o telefone do admin (senhas e segredo não aparecem)
grep -E "^(APP_USER|APP_BOOTSTRAP_ADMIN_PHONE)=" .env
echo ""

echo "[5/7] Gerando a imagem da API e subindo os containers em background..."
# -d: background | --build: gera a imagem da API a partir do app/Dockerfile
# Na primeira vez o comando demora (~2 min): o Compose só inicia a app depois que o db fica healthy,
# ou seja, depois que o Oracle criou o banco e rodou o script de BD
sudo docker compose up -d --build
echo ""

echo "[6/7] Containers em execução:"
sudo docker compose ps
echo ""

echo "[7/7] Aguardando a API responder na porta $PORT..."
# /actuator/health responde 200 quando a API subiu e conectou no banco; espera até 3 minutos
for i in $(seq 1 60); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/actuator/health || true)
  if [ "$CODE" = "200" ]; then
    echo "API no ar (HTTP $CODE)."
    break
  fi
  sleep 3
done
if [ "$CODE" != "200" ]; then
  echo "A API ainda não respondeu. Confira os logs com: sudo docker compose logs app"
fi
echo ""

echo "Comandos úteis:"
echo "  sudo docker compose logs -f app"
echo "  sudo docker compose logs db"
echo "Teste pela sua máquina (IP público da VM, nunca localhost):"
echo "  curl http://IP_DA_VM:$PORT/api/v1/categorias"
