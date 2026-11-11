FROM nousresearch/hermes-agent:v0.23.1

USER root

# Instalar GitHub CLI (repositório oficial apt)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Instalar pnpm (permitindo que os scripts de instalação sejam executados, contornando o bloqueio padrão do npm 12)
# provisório para o pnpm funcionar no container (na versão v0.23.1 do Hermes, o pnpm não está no PATH por padrão)
RUN npm install -g --allow-scripts=pnpm pnpm

USER root
