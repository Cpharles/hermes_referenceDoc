#!/usr/bin/env node
/**
 * Hermes Agent - Criar e configurar Profile (Versão 2)
 * Substitui create-profile.sh mantendo 100% da lógica e segurança.
 */

import { select, text, confirm, spinner, note, cancel, isCancel } from '@clack/prompts';
import fs from 'fs';
import path from 'path';
import { load as yamlLoad, dump as yamlDump } from 'js-yaml';
import chalk from 'chalk';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import { spawn } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// ============================================================
// 0. CONFIGURAÇÃO E VALIDAÇÕES INICIAIS
// ============================================================
const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
if (!BOT_TOKEN) {
  const LARGURA = 100; // ajuste conforme o terminal
  const linha = '⎯'.repeat(LARGURA);

  console.error(chalk.red(`\n╭${linha}╮`));
  console.error(chalk.red('\n❌ ERRO: TELEGRAM_BOT_TOKEN não definido.\n\n'));
  console.log('Execute primeiro no terminal o comando:\n' +
    '   - Para terminal Git Bash:\n' +
    chalk.yellow('       export TELEGRAM_BOT_TOKEN="seu_token_aqui"') + '\n' +
    '   - Para terminal PowerShell:\n' +
    chalk.yellow('       $env:TELEGRAM_BOT_TOKEN="SEU_TOKEN_REAL_AQUI"') + '\n' +
    '   - Depois rode novamente o comando:\n' +
    chalk.yellow('       node create-profile.mjs') + '\n');
  console.error(chalk.red(`╰${linha}╯\n`));
  process.exit(1);
}

// Verifica se o comando 'hermes' está disponível
try {
  const { execSync } = await import('child_process');
  execSync('hermes --version', { stdio: 'ignore' });
} catch {
  const LARGURA = 100;
  const linha = '⎯'.repeat(LARGURA);
  console.error(chalk.red(`\n╭${linha}╮`));
  console.error(chalk.red('\n❌ ERRO: Comando "hermes" não encontrado no PATH.\n\n'));
  console.log('Certifique-se de que o Hermes Agent está instalado e disponível no PATH do sistema.\n' +
    '  - Para verificar, execute:\n' +
    chalk.yellow('      hermes --version') + '\n');
  console.error(chalk.red(`╰${linha}╯\n`));
  process.exit(1);
}

// ============================================================
// 1. COLETA DE DADOS VIA UI INTERATIVA
// ============================================================
const LARGURA = 53;
const linha = '⎯'.repeat(LARGURA);
console.log(chalk.cyan(`\n╭${linha}╮`));
console.log(chalk.cyan('│          Hermes Agent - Criação de Profile          │'));
console.log(chalk.cyan(`╰${linha}╯\n`));

// Profile name input
const profileNameRaw = await text({
  message: 'Nome do profile (minúsculas, números, _ e -):',
  placeholder: 'ex: suporte-vendas',
  validate(value) {
    if (!value) return 'O nome é obrigatório.';
    if (!/^[a-z0-9_-]+$/.test(value)) return 'Permitido apenas letras minúsculas, números, "_" e "-".';
  },
});
if (isCancel(profileNameRaw)) { cancel('Operação cancelada.'); process.exit(0); }

// Channel name input
const channelName = await text({
  message: 'Nome amigável do bot (CHANNEL_NAME):',
  placeholder: 'ex: Bot de Suporte',
  validate: v => !v ? 'Campo obrigatório.' : undefined,
});
if (isCancel(channelName)) { cancel('Operação cancelada.'); process.exit(0); }

// User ID input
const userId = await text({
  message: 'User ID do Telegram (DM):',
  placeholder: 'ex: 123456789',
  validate: v => !v ? 'Campo obrigatório.' : undefined,
});
if (isCancel(userId)) { cancel('Operação cancelada.'); process.exit(0); }

// No Linux, desktop normalmente usa $HOME/.hermes. No servidor/container,
// /opt/data é o padrão; HOME=/root também identifica o ambiente atual.
// HERMES_HOME pode sobrescrever o padrão em qualquer sistema operacional.
const isLinuxServer = process.platform === 'linux'
  && (fs.existsSync('/opt/data') || process.env.HOME === '/root');
const defaultHermesDir = process.env.HERMES_HOME || (
  process.platform === 'win32'
    ? path.join(
        process.env.LOCALAPPDATA || path.join(process.env.USERPROFILE || '', 'AppData', 'Local'),
        'hermes',
      )
    : isLinuxServer
      ? '/opt/data'
      : path.join(process.env.HOME || '', '.hermes')
);

// Hermes directory input
const hermesDir = await text({
  message: 'Diretório raiz do Hermes:',
  placeholder: defaultHermesDir,
  initialValue: defaultHermesDir,
});
if (isCancel(hermesDir)) { cancel('Operação cancelada.'); process.exit(0); }

const HERMES_HOME = path.resolve(hermesDir);
let profileListOutput;
const stopProfileListSpinner = startTerminalSpinner('Buscando nomes dos profiles instalados...');
try {
  ({ stdout: profileListOutput } = await runCommand(
    'hermes',
    ['profile', 'list'],
    { cwd: HERMES_HOME, shell: process.platform === 'win32', windowsHide: true },
  ));
} catch (error) {
  stopProfileListSpinner(chalk.red('✗ Falha ao buscar os profiles.'));
  console.error(chalk.red('Não foi possível listar os profiles do Hermes.'));
  console.error(error.stderr?.toString() || error.message);
  process.exit(1);
}

const installedProfiles = parseProfileList(profileListOutput);
if (installedProfiles.length === 0) {
  stopProfileListSpinner(chalk.yellow('⚠ Nenhum profile encontrado.'));
  console.error(chalk.red('Nenhum profile foi encontrado pelo comando "hermes profile list".'));
  process.exit(1);
}
stopProfileListSpinner(chalk.green(`✓ ${installedProfiles.length} profile(s) encontrado(s).`));

const cloneFrom = await select({
  message: 'Profile base para clonar:',
  options: installedProfiles.map(name => ({
    value: name,
    label: name === 'default' ? `${name} (Recomendado)` : name,
  })),
  initialValue: installedProfiles.includes('default') ? 'default' : installedProfiles[0],
});
if (isCancel(cloneFrom)) { cancel('Operação cancelada.'); process.exit(0); }

// Normalização e paths
const PROFILE_NAME = profileNameRaw.toLowerCase();
const PROFILE_DIR = path.join(HERMES_HOME, 'profiles', PROFILE_NAME);
const ENV_FILE = path.join(PROFILE_DIR, '.env');
const CONFIG_FILE = path.join(PROFILE_DIR, 'config.yaml');
const SOUL_FILE = path.join(PROFILE_DIR, 'SOUL.md');

function runCommand(command, args, options = {}) {
  let stdout = '';
  let stderr = '';

  return new Promise((resolve, reject) => {
    let child;
    try {
      child = spawn(command, args, options);
    } catch (error) {
      reject(error);
      return;
    }

    child.stdout?.setEncoding('utf8').on('data', chunk => { stdout += chunk; });
    child.stderr?.setEncoding('utf8').on('data', chunk => { stderr += chunk; });
    child.on('error', error => {
      error.stdout = stdout;
      error.stderr = stderr;
      reject(error);
    });
    child.on('close', (code, signal) => {
      if (code === 0) resolve({ stdout, stderr });
      else {
        const error = new Error(`Command failed${signal ? ` with signal ${signal}` : ` with exit code ${code}`}`);
        error.stdout = stdout;
        error.stderr = stderr;
        reject(error);
      }
    });
  });
}

function parseProfileList(output) {
  const ansiEscapeCodes = /\u001b\[[0-?]*[ -/]*[@-~]/g;
  const names = [];

  for (const rawLine of output.replace(ansiEscapeCodes, '').split(/\r?\n/)) {
    let line = rawLine.trim().replace(/^[│|]+\s*/u, '');
    if (!line || /^no profiles?\b/i.test(line)) continue;

    // Remove markers such as ◆, *, ✓ and ▶, whether attached to the name or
    // printed as a separate prefix column.
    line = line.replace(/^[◆◇●○•*✓✔▶>]+\s*/u, '');
    const name = line.split(/\s+/u)[0]?.replace(/^[◆◇●○•*✓✔▶>]+/u, '');

    if (!name || /^(profile|profiles|name)$/i.test(name)) continue;
    if (/^[─━—-]+$/u.test(name)) continue;
    if (!names.includes(name)) names.push(name);
  }

  return names;
}

function startTerminalSpinner(message) {
  const frames = ['|', '/', '-', '\\'];
  const startedAt = Date.now();
  const isTTY = Boolean(process.stderr.isTTY);
  let frameIndex = 0;

  const render = () => {
    const elapsedSeconds = Math.floor((Date.now() - startedAt) / 1000);
    const frame = frames[frameIndex++ % frames.length];
    if (isTTY) {
      process.stderr.write(`\r${chalk.cyan(frame)} ${message} (${elapsedSeconds}s)`);
    } else {
      process.stderr.write(`[${elapsedSeconds}s] ${message}\n`);
    }
  };

  render();
  const interval = setInterval(render, isTTY ? 100 : 1000);

  return finalMessage => {
    clearInterval(interval);
    if (isTTY) process.stderr.write('\r\u001b[2K');
    process.stderr.write(`${finalMessage}\n`);
  };
}

// ============================================================
// 2. VERIFICAÇÃO DE EXISTÊNCIA
// ============================================================
if (fs.existsSync(PROFILE_DIR)) {  
  note(
    `O profile '${PROFILE_NAME}' já existe em:\n${PROFILE_DIR}\n\nPara recriá-lo, execute:\nhermes profile delete ${PROFILE_NAME}`,
    chalk.yellow('⚠ Profile já existe'),
  );
  process.exit(1);
}

// ============================================================
// 3. CRIAÇÃO DO PROFILE (Chamada ao CLI Hermes)
// ============================================================
const s = spinner();
const createMessage = `Criando profile '${PROFILE_NAME}' (clone de '${cloneFrom}')...`;
let status = false;

if (!status) {
  const stopCreateSpinner = startTerminalSpinner(createMessage);
  try {
    await runCommand('hermes', ['profile', 'create', PROFILE_NAME, '--clone-from', cloneFrom], {
      cwd: HERMES_HOME,
      shell: process.platform === 'win32',
      windowsHide: true,
    });
    status = true;
    stopCreateSpinner(chalk.green(`✓ Profile '${PROFILE_NAME}' criado com sucesso.`));
  } catch (err) {
    stopCreateSpinner(chalk.red('✗ Falha ao criar o profile.'));
    console.error(err.stderr?.toString() || err.message);
    process.exit(1);
  }
}

// Validação de arquivos essenciais
for (const [file, name] of [[ENV_FILE, '.env'], [CONFIG_FILE, 'config.yaml'], [SOUL_FILE, 'SOUL.md']]) {
  if (!fs.existsSync(file)) {
    cancel(`Arquivo essencial não encontrado: ${name}\n(${file})`);
    process.exit(1);
  }
}

// Backup dos arquivos originais
const stamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
[ENV_FILE, CONFIG_FILE].forEach(f => {
  if (fs.existsSync(f)) {
    fs.copyFileSync(f, `${f}.bak.${stamp}`);
  }
});

// ============================================================
// 4. CONFIGURAÇÃO DO TELEGRAM (.env)
// ============================================================
s.start('Configurando variáveis do Telegram no .env...');
let envContent = fs.readFileSync(ENV_FILE, 'utf8').replace(/\r\n/g, '\n');

// Remove chaves antigas do Telegram se existirem
envContent = envContent
  .split('\n')
  .filter(line => !/^TELEGRAM_(HOME_CHANNEL_NAME|ALLOWED_USERS|HOME_CHANNEL|BOT_TOKEN)=/.test(line.trim()))
  .join('\n')
  .trim() + '\n';

// Adiciona novas chaves
envContent += [
  `TELEGRAM_HOME_CHANNEL_NAME=${channelName}`,
  `TELEGRAM_ALLOWED_USERS=${userId}`,
  `TELEGRAM_HOME_CHANNEL=${userId}`,
  `TELEGRAM_BOT_TOKEN=${BOT_TOKEN}`
].join('\n') + '\n';

fs.writeFileSync(ENV_FILE, envContent);
s.stop(chalk.green('✓ Variáveis do Telegram gravadas no .env.'));

// ============================================================
// 5. CONFIGURAÇÃO DO TELEGRAM (config.yaml)
// ============================================================
s.start('Atualizando config.yaml...');
let config = yamlLoad(fs.readFileSync(CONFIG_FILE, 'utf8')) || {};

if (!config.platforms) config.platforms = {};
config.platforms.telegram = {
  enabled: true,
  extra: {
    allow_admin_from: userId,
    user_allowed_commands: []
  },
  home_channel: {
    platform: 'telegram',
    chat_id: userId
  }
};

// Preserva formatação YAML legível
const yamlStr = yamlDump(config, { indent: 2, lineWidth: -1, noRefs: true });
fs.writeFileSync(CONFIG_FILE, yamlStr);
s.stop(chalk.green('✓ Seção platforms.telegram configurada no config.yaml.'));

// ============================================================
// 6. VALIDAÇÃO FINAL
// ============================================================
s.start('Validando configuração final...');
const finalEnv = fs.readFileSync(ENV_FILE, 'utf8');
const finalConfig = fs.readFileSync(CONFIG_FILE, 'utf8');

const checks = [
  { test: /^TELEGRAM_HOME_CHANNEL_NAME=/m, msg: 'TELEGRAM_HOME_CHANNEL_NAME' },
  { test: /^TELEGRAM_ALLOWED_USERS=/m, msg: 'TELEGRAM_ALLOWED_USERS' },
  { test: /^TELEGRAM_HOME_CHANNEL=/m, msg: 'TELEGRAM_HOME_CHANNEL' },
  { test: /^TELEGRAM_BOT_TOKEN=/m, msg: 'TELEGRAM_BOT_TOKEN' },
  { test: /platforms:/m, msg: 'Seção platforms no YAML' },
  { test: /telegram:/m, msg: 'Subseção telegram no YAML' },
];

for (const check of checks) {
  if (!check.test.test(finalEnv) && !check.test.test(finalConfig)) {
    s.stop(chalk.red(`✗ Validação falhou: ${check.msg}`));
    process.exit(1);
  }
}
s.stop(chalk.green('✓ Todas as configurações validadas.'));

// ============================================================
// 7. RESUMO SEGURO (Token mascarado)
// ============================================================
const maskedToken = BOT_TOKEN.replace(/:[A-Za-z0-9_-]+$/, ':***REDACTED***');
const maskedChatId = userId.length >= 6 
  ? `${userId.slice(0, 3)}***${userId.slice(-2)}` 
  : userId;

note(
  [
    `Profile Name      : ${chalk.bold(PROFILE_NAME)}`,
    `Channel Name      : ${channelName}`,
    `Admin User ID     : ${maskedChatId}`,
    `Bot Token         : ${maskedToken}`,
    `Base Clone        : ${cloneFrom}`,
    `Hermes Home       : ${HERMES_HOME}`,
    '',
    chalk.dim('Para listar todos os profiles:'),
    chalk.cyan('hermes profile list')
  ].join('\n'),
  '✅ PROFILE CRIADO COM SUCESSO!'
);
