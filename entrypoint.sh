#!/bin/bash

echo "=== SCUM Server com graceful shutdown (Pterodactyl) ==="

# Caminho do SteamCMD instalado pelo egg
STEAMCMD="/home/container/steamcmd/steamcmd.sh"

if [ ! -f "$STEAMCMD" ]; then
    echo "ERRO: SteamCMD não encontrado!"
    exit 1
fi

echo "Atualizando SCUM Dedicated Server..."
cd /home/container

# Atualiza o servidor
"$STEAMCMD" +force_install_dir /home/container +login anonymous +app_update 3792580 validate +quit

echo "Iniciando SCUMServer.exe..."

# Caminho CORRETO do executável (sem o ./ no início)
wine SCUM/Binaries/Win64/SCUMServer.exe \
  -log \
  -Port=${SERVER_PORT:-7777} \
  -QueryPort=${QUERY_PORT:-7778} \
  -MaxPlayers=${MAX_PLAYERS:-32} \
  ${ADDITIONALFLAGS} &

SERVER_PID=$!

# Graceful Shutdown - essencial pro salvamento do banco
shutdown() {
  echo "Recebido sinal de shutdown do Pterodactyl - enviando SIGINT (Ctrl+C) pro SCUMServer.exe..."
  kill -SIGINT $SERVER_PID 2>/dev/null || true
  
  echo "Aguardando salvamento do banco de dados (SQLite) - pode demorar até 60 segundos..."
  sleep 60
  
  echo "Servidor encerrado com sucesso."
  exit 0
}

trap shutdown SIGTERM SIGINT SIGQUIT

wait $SERVER_PID
