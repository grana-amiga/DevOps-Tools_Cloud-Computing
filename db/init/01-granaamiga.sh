#!/bin/bash
# Executado UMA vez pela imagem gvenzl/oracle-free, só na primeira subida (volume vazio).
# Roda o script da disciplina de Banco de Dados (Davi) no schema da aplicação, dentro do FREEPDB1.
# APP_USER e APP_USER_PASSWORD vêm do .env; o usuário é criado pela própria imagem antes deste script.

# UTF-8 para os acentos do script (Salário, Alimentação...) não virarem lixo
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8

echo "exit" | sqlplus -s "${APP_USER}/${APP_USER_PASSWORD}@//localhost/FREEPDB1" @/opt/granaamiga/GranaAmiga_GS2026_2_BD.sql
