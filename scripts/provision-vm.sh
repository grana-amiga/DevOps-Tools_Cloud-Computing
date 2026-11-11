#!/bin/bash
# provision-vm.sh - Cria a infraestrutura da Grana Amiga na Azure (Grupo de Recursos, VM e porta da API)
# Uso (Git Bash, WSL ou Azure Cloud Shell, depois do az login):
#   chmod +x scripts/provision-vm.sh
#   ./scripts/provision-vm.sh

# Para o script no primeiro comando que falhar (ex.: se o az vm create der erro,
# não tenta abrir porta numa VM que não existe). Não foi usado em aula, é uma proteção extra.
set -e

# ===== Variáveis =====
RG="rg-granaamiga-gs"
LOCATION="southafricanorth"
VM="vm-granaamiga"
IMAGE="Ubuntu2404"
SIZE="Standard_B2als_v2"   # 2 vCPU e 4 GB de RAM: folga para a API Java + PostgreSQL
ADMIN_USER="rm567295"
PORT=8080                  # Porta da API (o PostgreSQL NÃO é exposto para a internet)

echo "*************************************"
echo "Grana Amiga - Provisionamento da VM na Azure"
echo "*************************************"
echo ""

# -s: a senha não aparece na tela enquanto é digitada (nem no vídeo)
echo "A senha precisa ter de 12 a 72 caracteres, com maiúscula, minúscula, número e símbolo."
read -s -p "Digite a senha do usuário $ADMIN_USER da VM: " ADMIN_PASSWORD
echo ""
echo ""

echo "[1/5] Conferindo a assinatura ativa..."
az account show --query "{Sub:id, Nome:name}" -o jsonc
echo ""

echo "[2/5] Criando o Grupo de Recursos $RG em $LOCATION..."
az group create --name $RG --location $LOCATION -o table
echo ""

echo "[3/5] Criando a VM $VM ($IMAGE, $SIZE)..."
IP=$(az vm create \
  --resource-group $RG \
  --name $VM \
  --location $LOCATION \
  --image $IMAGE \
  --size $SIZE \
  --authentication-type password \
  --admin-username $ADMIN_USER \
  --admin-password "$ADMIN_PASSWORD" \
  --vnet-name vnet-granaamiga \
  --nsg nsg-granaamiga \
  --public-ip-address pip-granaamiga \
  --public-ip-sku Standard \
  --tags "owner=GranaAmiga" "purpose=GlobalSolution" \
  --query publicIpAddress -o tsv)
echo "VM criada. IP público: $IP"
echo ""

echo "[4/5] Liberando a porta $PORT da API no NSG..."
# A porta 22 (SSH) o az vm create já libera sozinho
# -o table: resumo em tabela, em vez do JSON completo do NSG
az vm open-port --resource-group $RG --name $VM --port $PORT --priority 1010 -o table
echo ""

echo "[5/5] Infraestrutura pronta!"
echo "Próximo passo, conectar na VM:"
echo "  ssh $ADMIN_USER@$IP"
echo "Dentro da VM, clonar o repositório e rodar o scripts/setup-docker.sh (ver README)."
echo "Depois dos containers no ar, a API responde em:"
echo "  http://$IP:$PORT"
