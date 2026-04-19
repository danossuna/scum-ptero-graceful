#!/bin/bash

echo "=== SCUM Server com graceful shutdown (Pterodactyl) ==="

# Caminho correto do SteamCMD instalado pelo egg do Pterodactyl
STEAMCMD="/home/container/steamcmd/steamcmd.sh"

if [ ! -f "$STEAMCMD" ]; then
    echo "ERRO: SteamCMD não encontrado em $STEAMCMD"
    echo "Verifique se o Installation Script do egg SCUM está rodando."
    exit 1
fi

echo "Atualizando SCUM Dedicated Server..."
cd /home/container

# Atualiza usando o steamcmd.sh completo (não o comando "steamcmd")
"$STEAMCMD" +force_install_dir /home/container +login anonymous +app_update 3792580 validate +quit

echo "Iniciando SCUMServer.exe..."

# Inicia o servidor (ajuste as variáveis conforme seu egg)
wine ./SCUM/Binaries/Win64/SCUMServer.exe \
  -log \
  -port=${SERVER_PORT:-7777} \
  -queryport=${QUERY_PORT:-7778} \
  -maxplayers=${MAX_PLAYERS:-32} \
  ${ADDITIONALFLAGS} &

SERVER_PID=$!

# Graceful Shutdown
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
