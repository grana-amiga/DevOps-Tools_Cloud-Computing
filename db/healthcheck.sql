-- Healthcheck do container db: o banco só é "healthy" quando o script do Davi terminou.
-- A última procedure criada pelo script é PRC_ALERTAS_VENCIMENTO; se ela existe, as tabelas também existem.
WHENEVER SQLERROR EXIT FAILURE
SET HEADING OFF FEEDBACK OFF
SELECT 'PRONTO' FROM user_objects WHERE object_name = 'PRC_ALERTAS_VENCIMENTO';
EXIT
