#!/bin/bash
echo "🚀 Subindo ExLink..."
docker compose up -d
echo "⏳ Aguardando PostgreSQL..."
sleep 2
docker compose ps
echo "✔ Pronto! Rode: mix phx.server"
