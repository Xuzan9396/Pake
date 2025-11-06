#!/usr/bin/env node

import fs from 'fs';
import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 读取命令行参数
const configName = process.argv[2];
const platform = process.argv[3]; // 'macos' or 'windows'
const arch = process.argv[4]; // 'universal' or 'x64' or 'arm64'

if (!configName || !platform || !arch) {
  console.error('Usage: node build-with-config.js <config-name> <platform> <arch>');
  console.error('Example: node build-with-config.js vinted macos universal');
  process.exit(1);
}

// 读取配置文件
const configPath = path.join(__dirname, '..', 'build-configs', `${configName}.json`);
if (!fs.existsSync(configPath)) {
  console.error(`Config file not found: ${configPath}`);
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
console.log(`Building ${config.name} for ${platform} ${arch}`);

// 构建 CLI 参数
const args = [
  path.join(__dirname, '..', 'dist', 'cli.js'),
  config.url,
  '--name', config.name,
  '--icon', config.icon,
  '--width', config.width.toString(),
  '--height', config.height.toString(),
  '--targets', arch,
];

// 添加可选参数
const options = config.options || {};

if (options.title) {
  args.push('--title', options.title);
}

if (options.resizable === false) {
  args.push('--no-resizable');
}

if (options.fullscreen) {
  args.push('--fullscreen');
}

if (options.maximize) {
  args.push('--maximize');
}

if (options.hideTitleBar) {
  args.push('--hide-title-bar');
}

if (options.alwaysOnTop) {
  args.push('--always-on-top');
}

if (options.darkMode) {
  args.push('--dark-mode');
}

if (options.disabledWebShortcuts) {
  args.push('--disabled-web-shortcuts');
}

if (options.activationShortcut) {
  args.push('--activation-shortcut', options.activationShortcut);
}

if (options.userAgent) {
  args.push('--user-agent', options.userAgent);
}

if (options.showSystemTray) {
  args.push('--show-system-tray');
}

if (options.systemTrayIcon) {
  args.push('--system-tray-icon', options.systemTrayIcon);
}

if (options.useLocalFile) {
  args.push('--use-local-file');
}

if (options.multiArch) {
  args.push('--multi-arch');
}

if (options.debug) {
  args.push('--debug');
}

if (options.inject && options.inject.length > 0) {
  args.push('--inject', options.inject.join(','));
}

if (options.proxyUrl) {
  args.push('--proxy-url', options.proxyUrl);
}

if (options.installerLanguage) {
  args.push('--installer-language', options.installerLanguage);
}

if (options.hideOnClose) {
  args.push('--hide-on-close');
}

if (options.incognito) {
  args.push('--incognito');
}

if (options.wasm) {
  args.push('--wasm');
}

if (options.enableDragDrop) {
  args.push('--enable-drag-drop');
}

if (options.keepBinary) {
  args.push('--keep-binary');
}

if (options.multiInstance) {
  args.push('--multi-instance');
}

if (options.startToTray) {
  args.push('--start-to-tray');
}

if (options.appVersion) {
  args.push('--app-version', options.appVersion);
}

console.log('CLI command:', 'node', args.join(' '));

// 执行构建
const child = spawn('node', args, {
  stdio: 'inherit',
  env: {
    ...process.env,
    PAKE_CREATE_APP: platform === 'macos' ? '1' : undefined,
  },
});

child.on('exit', (code) => {
  process.exit(code);
});
