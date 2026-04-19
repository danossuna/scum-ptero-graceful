#!/bin/bash

echo "=== SCUM Server com graceful shutdown (Pterodactyl) ==="

# Instala SteamCMD se não existir
if ! command -v steamcmd &> /dev/null; then
    echo "SteamCMD não encontrado. Instalando..."
    mkdir -p /home/container/steamcmd
    cd /home/container/steamcmd
    wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xzf steamcmd_linux.tar.gz
    rm steamcmd_linux.tar.gz
    chmod +x steamcmd.sh
    ln -s /home/container/steamcmd/steamcmd.sh /usr/local/bin/steamcmd
    echo "SteamCMD instalado com sucesso."
fi

echo "Atualizando SCUM Dedicated Server..."
cd /home/container

# Atualiza o servidor (AppID do SCUM é 3792580)
steamcmd +force_install_dir /home/container +login anonymous +app_update 3792580 validate +quit

echo "Iniciando SCUMServer.exe..."

# Lança o servidor (use as variáveis do seu egg)
wine ./SCUM/Binaries/Win64/SCUMServer.exe \
  -log \
  -port=${SERVER_PORT:-7777} \
  -queryport=${QUERY_PORT:-7778} \
  -maxplayers=${MAX_PLAYERS:-32} \
  ${ADDITIONALFLAGS} &

SERVER_PID=$!

# Graceful shutdown
shutdown() {
  echo "Recebido sinal de shutdown do Pterodactyl - enviando SIGINT (Ctrl+C) pro SCUMServer.exe..."
  kill -SIGINT $SERVER_PID 2>/dev/null || true
  
  echo "Aguardando salvamento do banco de dados (SQLite) - isso pode demorar..."
  sleep 60   # 60 segundos deve ser suficiente pro SCUM salvar tudo
  
  echo "Servidor encerrado com sucesso."
  exit 0
}

trap shutdown SIGTERM SIGINT SIGQUIT

# Mantém o container vivo
wait $SERVER_PID
