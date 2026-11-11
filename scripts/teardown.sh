#!/bin/bash
# teardown.sh - Apaga o Grupo de Recursos da Grana Amiga e comprova a exclusão
# Uso (Git Bash, WSL ou Azure Cloud Shell), depois da demonstração:
#   chmod +x scripts/teardown.sh
#   ./scripts/teardown.sh

RG="rg-granaamiga-gs"

echo "*************************************"
echo "Grana Amiga - Remoção da infraestrutura"
echo "*************************************"
echo ""

echo "[1/2] Apagando o Grupo de Recursos $RG (VM, IP, VNet, NSG e discos)..."
# Sem --no-wait de propósito: o terminal espera a exclusão terminar,
# assim o passo 2 comprova que não sobrou nada gastando crédito
az group delete --name $RG --yes
echo ""

echo "[2/2] Comprovando a exclusão (o esperado é: false):"
az group exists --name $RG
