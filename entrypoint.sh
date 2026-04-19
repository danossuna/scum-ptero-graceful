#!/bin/bash

echo "=== SCUM Server com graceful shutdown (Pterodactyl) ==="

# Atualiza o servidor via SteamCMD (mesmo comportamento da imagem oficial)
echo "Atualizando SCUM Dedicated Server..."
steamcmd +force_install_dir /home/container +login anonymous +app_update 3792580 validate +quit

echo "Iniciando SCUMServer.exe..."

# Lança o servidor (ajuste as variáveis se o seu egg usar nomes diferentes)
wine ./SCUM/Binaries/Win64/SCUMServer.exe \
  -log \
  -port=${SERVER_PORT} \
  -queryport=${QUERY_PORT} \
  -RCONPort=7795 \
  -maxplayers=${MAX_PLAYERS} \
  ${ADDITIONALFLAGS} &

SERVER_PID=$!

# Trap: quando o Pterodactyl mandar Stop (SIGTERM), envia Ctrl+C pro servidor
shutdown() {
  echo "Recebido sinal de shutdown do Pterodactyl - enviando SIGINT (Ctrl+C) pro SCUMServer.exe..."
  kill -SIGINT $SERVER_PID 2>/dev/null || true
  echo "Aguardando salvamento do banco de dados (SQLite)..."
  sleep 45   # tempo suficiente pro SCUM salvar o SCUM.db
  echo "Servidor encerrado com sucesso."
  exit 0
}

trap shutdown SIGTERM SIGINT SIGQUIT

# Mantém o container rodando
wait $SERVER_PID