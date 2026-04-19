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

echo ""
echo "=== Verificando arquivos após update ==="
echo "Conteúdo de SCUM/Binaries/Win64:"
ls -la SCUM/Binaries/Win64/ 2>/dev/null || echo "Pasta não existe"

echo ""
echo "Buscando SCUMServer.exe:"
find /home/container -name "SCUMServer.exe" 2>/dev/null || echo "Ainda não encontrado!"

echo "Iniciando SCUMServer.exe..."

# Tentativa com caminho mais comum
wine SCUM/Binaries/Win64/SCUMServer.exe \
  -log \
  -Port=${SERVER_PORT:-7777} \
  -QueryPort=${QUERY_PORT:-7778} \
  -MaxPlayers=${MAX_PLAYERS:-32} \
  ${ADDITIONALFLAGS} &

SERVER_PID=$!

shutdown() {
  echo "Recebido sinal de shutdown - enviando SIGINT (Ctrl+C)..."
  kill -SIGINT $SERVER_PID 2>/dev/null || true
  echo "Aguardando salvamento do banco de dados (90 segundos)..."
  sleep 90
  echo "Servidor encerrado com sucesso."
  exit 0
}

trap shutdown SIGTERM SIGINT SIGQUIT

wait $SERVER_PID
