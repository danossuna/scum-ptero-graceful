#!/bin/bash

echo "=== SCUM Server - Modo Diagnóstico (Pterodactyl) ==="

STEAMCMD="/home/container/steamcmd/steamcmd.sh"

if [ ! -f "$STEAMCMD" ]; then
    echo "ERRO: SteamCMD não encontrado!"
    exit 1
fi

echo "Atualizando servidor..."
cd /home/container
"$STEAMCMD" +force_install_dir /home/container +login anonymous +app_update 3792580 validate +quit

echo ""
echo "=== DIAGNÓSTICO DE PASTAS ==="
echo "Conteúdo principal da pasta /home/container:"
ls -la /home/container

echo ""
echo "Procurando pastas que contenham 'SCUM' ou 'SCUMServer':"
find /home/container -maxdepth 3 -type d \( -name "*SCUM*" -o -name "*scum*" \) 2>/dev/null || echo "Nenhuma pasta SCUM encontrada"

echo ""
echo "Procurando o arquivo SCUMServer.exe (pode demorar um pouco):"
find /home/container -name "SCUMServer.exe" 2>/dev/null || echo "SCUMServer.exe NÃO FOI ENCONTRADO!"

echo ""
echo "Fim do diagnóstico. Container vai parar agora."
exit 0
