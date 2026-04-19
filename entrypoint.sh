#!/bin/bash

echo "=== SCUM Server com graceful shutdown (Pterodactyl) ==="

STEAMCMD="/home/container/steamcmd/steamcmd.sh"

if [ ! -f "$STEAMCMD" ]; then
    echo "ERRO: SteamCMD não encontrado!"
    exit 1
fi

echo "Forçando download completo do SCUM Dedicated Server..."
cd /home/container

# Força verificação + download completo (mais agressivo)
"$STEAMCMD" +force_install_dir /home/container +login anonymous +app_update 3792580 validate +quit

echo ""
echo "=== Verificando arquivos do servidor ==="
ls -la SCUM/Binaries/Win64/

echo "Iniciando SCUMServer.exe..."

# Caminho correto baseado no seu diagnóstico
wine SCUM/Binaries/Win64/SCUMServer.exe \
  -log \
  -Port=${SERVER_PORT:-7777} \
  -QueryPort=${QUERY_PORT:-7778} \
  -MaxPlayers=${MAX_PLAYERS:-32} \
  ${ADDITIONALFLAGS} &

SERVER_PID=$!

# Graceful Shutdown (essencial para salvar o SCUM.db)
shutdown() {
  echo "Recebido sinal de shutdown do Pterodactyl - enviando SIGINT (Ctrl+C) pro SCUMServer.exe..."
  kill -SIGINT $SERVER_PID 2>/dev/null || true
  
  echo "Aguardando salvamento do banco de dados (SQLite) - pode demorar até 90 segundos..."
  sleep 90
  
  echo "Servidor encerrado com sucesso."
  exit 0
}

trap shutdown SIGTERM SIGINT SIGQUIT

wait $SERVER_PID
