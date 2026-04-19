#!/bin/bash

echo "=== SCUM Server - Diagnóstico Avançado (Pterodactyl) ==="

STEAMCMD="/home/container/steamcmd/steamcmd.sh"

if [ ! -f "$STEAMCMD" ]; then
    echo "ERRO: SteamCMD não encontrado!"
    exit 1
fi

echo "Atualizando servidor (forçando verificação completa)..."
cd /home/container
"$STEAMCMD" +force_install_dir /home/container +login anonymous +app_update 3792580 validate +quit

echo ""
echo "=== DIAGNÓSTICO DETALHADO ==="

echo "Conteúdo da pasta /home/container:"
ls -la /home/container

echo ""
echo "Conteúdo da pasta SCUM:"
ls -la SCUM

echo ""
echo "Conteúdo da pasta SCUM/Binaries (se existir):"
ls -la SCUM/Binaries 2>/dev/null || echo "Pasta SCUM/Binaries não existe"

echo ""
echo "Conteúdo da pasta SCUM/Binaries/Win64 (se existir):"
ls -la SCUM/Binaries/Win64 2>/dev/null || echo "Pasta SCUM/Binaries/Win64 não existe"

echo ""
echo "Busca completa por SCUMServer.exe:"
find /home/container -name "*SCUMServer.exe*" -o -name "*SCUMServer*" 2>/dev/null || echo "Nenhum SCUMServer encontrado!"

echo ""
echo "Fim do diagnóstico avançado."
exit 0
