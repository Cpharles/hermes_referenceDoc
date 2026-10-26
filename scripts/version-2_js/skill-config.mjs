#!/usr/bin/env node

import { cancel, confirm, isCancel, note, select, spinner } from '@clack/prompts';
import { MultiSelectPrompt } from '@clack/core';
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { load as yamlLoad, dump as yamlDump } from 'js-yaml';
import chalk from 'chalk';

function runHermes(args, { showOutput = false, env = {} } = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn('hermes', args, {
      shell: process.platform === 'win32',
      windowsHide: true,
      env: { ...process.env, ...env },
      stdio: showOutput ? 'inherit' : ['ignore', 'pipe', 'pipe'],
    });
    let stdout = '';
    let stderr = '';
    if (!showOutput) {
      child.stdout.setEncoding('utf8').on('data', chunk => { stdout += chunk; });
      child.stderr.setEncoding('utf8').on('data', chunk => { stderr += chunk; });
    }
    child.on('error', reject);
    child.on('close', code => {
      if (code === 0) resolve({ stdout, stderr });
      else reject(new Error(stderr.trim() || `hermes ${args.join(' ')} terminou com código ${code}.`));
    });
  });
}

const stripAnsi = value => value.replace(/\u001b\[[0-9;]*m/g, '').trim();
async function withSpinner(message, action, successMessage) {
  const taskSpinner = spinner();
  taskSpinner.start(message);
  try {
    const result = await action();
    taskSpinner.stop(chalk.green(`✓ ${successMessage}`));
    return result;
  } catch (error) {
    taskSpinner.stop(chalk.red(`✗ ${message}`));
    throw error;
  }
}

const cancelIfNeeded = value => {
  if (isCancel(value)) {
    cancel('Operação cancelada.');
    process.exit(0);
  }
  return value;
};

function promptForSkills(message, options, initialValues) {
  const visibleCount = 10;
  return new MultiSelectPrompt({
    options,
    initialValues,
    required: false,
    render() {
      const title = `◆ ${message}`;
      // Keep Clack's completed prompt compact; the chosen skills are summarized
      // in the enabled/disabled blocks after the configuration is saved.
      if (this.state === 'submit') return title;
      if (this.state === 'cancel') return `${title}\n│ ${chalk.dim('Cancelado')}`;

      const start = Math.max(0, Math.min(
        this.cursor - Math.floor(visibleCount / 2),
        this.options.length - visibleCount,
      ));
      const visibleOptions = this.options.slice(start, start + visibleCount);
      const rows = visibleOptions.map((option, index) => {
        const optionIndex = start + index;
        const active = optionIndex === this.cursor;
        const checked = (this.value ?? []).includes(option.value);
        const marker = checked ? chalk.green('◼') : chalk.dim('◻');
        const label = active ? chalk.cyan(option.label) : option.label;
        return `│ ${active ? chalk.cyan('›') : ' '} ${marker} ${label}`;
      });
      const range = this.options.length > visibleCount
        ? ` ${start + 1}–${Math.min(start + visibleCount, this.options.length)} de ${this.options.length}`
        : '';
      rows.push(`│ ${chalk.dim(`↑/↓ navegar • Espaço selecionar • Enter confirmar${range}`)}`);
      return [title, ...rows].join('\n');
    },
  }).prompt();
}

function parseProfiles(output) {
  return stripAnsi(output).split(/\r?\n/).map(line => line.trim())
    .filter(line => line && !/^[-─┄\s]+$/.test(line))
    // Hermes can prefix the active profile with a status glyph (for example ◆).
    .map(line => line.split(/[\s│|]+/).filter(Boolean)
      .map(token => token.replace(/^[◆◇●○•*✓✔▶>]+/u, ''))
      .find(Boolean))
    .filter(name => name && !/^(name|profile|profiles|────+)$/i.test(name));
}

function parseSkills(output) {
  const skills = [];
  for (const rawLine of stripAnsi(output).split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || /^[-─┄\s]+$/.test(line)) continue;

    // Rich tables use vertical borders; read the first and fifth cells directly
    // so spacing or multi-word middle columns cannot shift the Status column.
    const cells = line.split('│').map(cell => cell.trim()).filter(Boolean);
    let name;
    let status;
    if (cells.length >= 5) {
      [name] = cells;
      status = cells[4].toLowerCase();
    } else {
      const columns = line.split(/[\s|]+/).filter(Boolean);
      [name] = columns;
      status = columns[4]?.toLowerCase();
    }

    if (!name || /^(name|skill)$/i.test(name)) continue;
    if (status && ['enabled', 'disabled'].includes(status)) skills.push({ name, status });
  }
  return skills;
}

function parseProfilePath(output) {
  const text = stripAnsi(output);
  try {
    const value = JSON.parse(text);
    if (typeof value.Path === 'string') return value.Path;
  } catch { /* Hermes may print the profile details as text instead of JSON. */ }
  const match = text.match(/"?Path"?\s*[:=]\s*["']?([^\r\n"']+)/i);
  if (match) return match[1].trim();
  throw new Error('Não foi possível localizar o campo Path na saída de `hermes profile show`.');
}

// Main execution flow
try {
  // Carregando profiles disponíveis
  const { stdout: profileOutput } = await withSpinner(
    'Carregando profiles...',
    () => runHermes(['profile', 'list']),
    'Profiles carregados.',
  );
  const profiles = [...new Set(parseProfiles(profileOutput))];
  if (!profiles.length) throw new Error('Nenhum profile encontrado em `hermes profile list`.');

  // Solicitando ao usuário que selecione um profile
  const profileName = cancelIfNeeded(await select({
    message: 'Selecione o Profile para configurar as Skills:',
    options: profiles.map(name => ({ value: name, label: name })),
  }));

  // Carregando skills do profile selecionado
  const { stdout: skillsOutput } = await withSpinner(
    `Carregando as Skills de '${profileName}'...`,
    () => runHermes(['skills', 'list', '--profile', profileName], { env: { COLUMNS: '240' } }),
    'Skills carregadas.',
  );
  const skills = parseSkills(skillsOutput);
  if (!skills.length) throw new Error(`Nenhuma Skill com status enabled/disabled encontrada para '${profileName}'.`);
  
  // Solicitando ao usuário que selecione quais skills devem ficar enabled
  const enabledNames = new Set(skills.filter(skill => skill.status === 'enabled').map(skill => skill.name));
  const selectedNames = cancelIfNeeded(await promptForSkills(
    'Selecione as skills que devem ficar enabled (desmarcadas ficarão disabled):',
    skills.map(skill => ({ value: skill.name, label: `${skill.name}  [${skill.status}]` })),
    [...enabledNames],
  ));

  // Confirmando a aplicação da configuração
  const confirmed = cancelIfNeeded(await confirm({
    message: `Aplicar esta configuração ao profile '${profileName}'?`,
    initialValue: true,
  }));
  if (!confirmed) {
    cancel('Configuração interrompida.Nenhuma alteração foi aplicada.');
    process.exit(0);
  }

  // Localizando o arquivo config.yaml do profile e atualizando a lista de skills disabled
  const { stdout: profileDetails } = await withSpinner(
    `Localizando o arquivo config.yaml do profile '${profileName}'...`,
    () => runHermes(['profile', 'show', profileName]),
    'Arquivo config.yaml localizado.',
  );
  const profilePath = parseProfilePath(profileDetails);
  const configPath = path.join(profilePath, 'config.yaml');
  if (!fs.existsSync(configPath)) throw new Error(`Arquivo config.yaml não encontrado em: ${configPath}`);

  // Carregando o arquivo config.yaml e atualizando a lista de skills disabled
  const config = yamlLoad(fs.readFileSync(configPath, 'utf8')) ?? {};
  if (!config.skills || typeof config.skills !== 'object') config.skills = {};
  config.skills.disabled = skills.map(skill => skill.name).filter(name => !selectedNames.includes(name));
  await withSpinner('Gravando configuração...', async () => {
    fs.writeFileSync(configPath, yamlDump(config, { indent: 2, lineWidth: -1, noRefs: true }), 'utf8');
  }, 'Configuração salva.');

  // Exibindo a lista de skills habilitadas e desabilitadas após a atualização
  // Read the post-save CLI output as the source of truth for the reported counts.
  const finalList = await runHermes(['skills', 'list', '--profile', profileName], {
    env: { COLUMNS: '240' },
  });
  const finalSkills = parseSkills(finalList.stdout);
  const enabledCount = finalSkills.filter(skill => skill.status === 'enabled').length;
  const disabledCount = finalSkills.filter(skill => skill.status === 'disabled').length;
  const expectedEnabledCount = selectedNames.length;
  const expectedDisabledCount = skills.length - expectedEnabledCount;
  note(chalk.green(`Total de Skills habilitadas (${enabledCount})`));
  note(chalk.red(`Total de Skills desabilitadas (${disabledCount})`));
  if (enabledCount !== expectedEnabledCount || disabledCount !== expectedDisabledCount) {
    note(
      `Seleção: ${expectedEnabledCount} enabled / ${expectedDisabledCount} disabled\n` +
      `Hermes: ${enabledCount} enabled / ${disabledCount} disabled`,
      chalk.yellow('Atenção: contagem divergente'),
    );
  }

  // Finalizando o processo.
  note(`Profile: ${chalk.bold(profileName)}\n${chalk.dim(configPath)}\n\nAguarde a lista das Skills atualizada será exibida a seguir.`, chalk.cyan('Configuração concluída'));
  
  // Exibindo a lista de skills atualizada
  process.stdout.write(finalList.stdout);
  if (finalList.stderr) process.stderr.write(finalList.stderr);
} catch (error) {
  console.error(chalk.red(`\nErro: ${error.message}`));
  process.exitCode = 1;
}
