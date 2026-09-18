#!/bin/bash

# Para OS Windows

# reativar todos os profiles
hermes gateway restart
hermes -p gerente-ceo1 gateway run --replace > /tmp/gerente-ceo1-gateway.log 2>&1 &
hermes -p time-performance gateway run --replace > /tmp/time-performance-gateway.log 2>&1 &
hermes -p time-pedagogico gateway run --replace > /tmp/time-pedagogico-gateway.log 2>&1 &
hermes -p time-sac gateway run --replace > /tmp/time-sac-gateway.log 2>&1 &
hermes -p time-comercial gateway run --replace > /tmp/time-comercial-gateway.log 2>&1 &
hermes -p time-conteudo gateway run --replace > /tmp/time-conteudo-gateway.log 2>&1 &
sleep 8
hermes gateway list