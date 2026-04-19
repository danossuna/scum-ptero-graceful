#!/bin/bash

echo "=== SCUM Server com graceful shutdown (Pterodactyl) ==="

STEAMCMD="/home/container/steamcmd/steamcmd.sh"

if [ ! -f "$STEAMCMD" ]; then
    echo "ERRO: SteamCMD não encontrado!"
    exit 1
fi

cd /home/container

echo "Forçando download completo com platform windows..."
"$STEAMCMD" +force_install_dir /home/container +login anonymous +@sSteamCmdForcePlatformType windows +app_update 3792580 validate +quit

echo "Iniciando SCUM Dedicated Server..."

# Configurações para Wine rodar melhor sem áudio/placa de som
export WINEDLLOVERRIDES="winemenubuilder.exe=d"
export WINEDEBUG="-all"
export XDG_RUNTIME_DIR=/tmp/runtime-container
mkdir -p /tmp/runtime-container
chmod 700 /tmp/runtime-container

# Inicia o servidor
wine SCUM/Binaries/Win64/SCUMServer.exe \
  -log \
  -Port=${SERVER_PORT:-7777} \
  -QueryPort=${QUERY_PORT:-7778} \
  -MaxPlayers=${MAX_PLAYERS:-32} \
  ${ADDITIONALFLAGS} &

SERVER_PID=$!

echo "SCUMServer.exe iniciado com PID ${SERVER_PID}"

# Graceful Shutdown - isso é o que você mais queria
shutdown() {
  echo "=== RECEBIDO SINAL DE SHUTDOWN DO PTERODACTYL ==="
  echo "Enviando SIGINT (Ctrl+C) para o SCUMServer.exe..."
  kill -SIGINT $SERVER_PID 2>/dev/null || true
  
  echo "Aguardando salvamento do banco de dados (SQLite) - isso pode demorar..."
  sleep 90
  
  echo "Servidor encerrado com sucesso. Salvamento concluído."
  exit 0
}

trap shutdown SIGTERM SIGINT SIGQUIT

wait $SERVER_PID
