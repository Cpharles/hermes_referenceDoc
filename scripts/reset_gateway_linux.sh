#!/usr/bin/env bash

# ============================================================
# Hermes Agent - Resetar Gateways
# Ambiente: Linux + Git Bash
# ============================================================

set -u

# ============================================================
# 1. RESETAR GATEWAYS
# ============================================================
setsid hermes -p default gateway run --replace > /tmp/default-gateway.log 2>&1 &
setsid hermes -p time-perfomance gateway run --replace > /tmp/time-perfomance-gateway.log 2>&1 &
setsid hermes -p time-pedagogico gateway run --replace > /tmp/time-pedagogico-gateway.log 2>&1 &
setsid hermes -p time-cs gateway run --replace > /tmp/time-cs-gateway.log 2>&1 &
setsid hermes -p time-comercial gateway run --replace > /tmp/time-comercial-gateway.log 2>&1 &
setsid hermes -p time-conteudo gateway run --replace > /tmp/time-conteudo-gateway.log 2>&1 &
sleep 8
hermes gateway list