#!/bin/bash
# setup-docker.sh - Instala Docker e Docker Compose na VM e sobe os containers app + db
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

echo "[1/6] Atualizando os pacotes do Ubuntu..."
sudo apt update -y
echo ""

echo "[2/6] Instalando e habilitando o Docker e o Docker Compose..."
# docker.io: Docker Engine do repositório do Ubuntu
# docker-compose-v2: comando "docker compose" (o docker.io não traz o Compose)
# docker-buildx: builder usado pelo "docker compose up --build"
sudo apt install -y docker.io docker-compose-v2 docker-buildx
# enable: o Docker sobe junto com a VM, e com ele os containers com restart: unless-stopped
sudo systemctl enable --now docker
sudo docker --version
sudo docker compose version
echo ""

echo "[3/6] Conferindo o arquivo .env..."
if [ ! -f .env ]; then
  echo "ERRO: arquivo .env não encontrado. Crie com: cp .env.example .env && nano .env"
  exit 1
fi
# Se ainda estiver com a senha do .env.example, para o script aqui
if grep -q "troque-esta-senha" .env; then
  echo "ERRO: o .env ainda está com a senha de exemplo. Edite com: nano .env"
  exit 1
fi
# Mostra só o banco e o usuário (a senha não aparece)
grep -E "^(POSTGRES_DB|POSTGRES_USER)=" .env
echo ""

echo "[4/6] Gerando a imagem da API e subindo os containers em background..."
# -d: background | --build: gera a imagem da API a partir do app/Dockerfile
sudo docker compose up -d --build
echo ""

echo "[5/6] Containers em execução:"
sudo docker compose ps
echo ""

echo "[6/6] Aguardando a API responder na porta $PORT..."
# Qualquer resposta HTTP serve (000 = ainda sem conexão); espera até 90 segundos
for i in $(seq 1 45); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/ || true)
  if [ "$CODE" != "000" ]; then
    echo "API no ar (HTTP $CODE)."
    break
  fi
  sleep 2
done
if [ "$CODE" = "000" ]; then
  echo "A API ainda não respondeu. Confira os logs com: sudo docker compose logs app"
fi
echo ""

echo "Comandos úteis:"
echo "  sudo docker compose logs -f app"
echo "  sudo docker compose logs db"
echo "Teste pela sua máquina (IP público da VM, nunca localhost):"
echo "  curl http://IP_DA_VM:$PORT/api/usuarios"
