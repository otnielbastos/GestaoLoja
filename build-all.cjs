#!/usr/bin/env node

/**
 * Script de Build Unificado para Deploy na Vercel
 * 
 * Compila e organiza os arquivos:
 * - Site Institucional → dist/ (raiz)
 * - Sistema de Gestão → dist/admin/
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Iniciando build unificado para Vercel...\n');

// Função para executar comandos
function exec(command, cwd = process.cwd()) {
  console.log(`📦 ${command}`);
  try {
    execSync(command, { cwd, stdio: 'inherit' });
    return true;
  } catch (error) {
    console.error(`❌ Erro ao executar: ${command}`);
    return false;
  }
}

// Função para copiar diretório recursivamente
function copyDir(src, dest) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }

  const entries = fs.readdirSync(src, { withFileTypes: true });

  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

// Função para mover diretório
function moveDir(src, dest) {
  copyDir(src, dest);
  fs.rmSync(src, { recursive: true, force: true });
}

try {
  // 1. Limpar builds anteriores
  console.log('🧹 Limpando builds anteriores...');
  ['dist', 'dist-admin'].forEach(dir => {
    if (fs.existsSync(dir)) {
      fs.rmSync(dir, { recursive: true, force: true });
    }
  });

  // 2. Instalar dependências do Site (se necessário)
  console.log('\n📦 Instalando dependências do Site...');
  const siteDir = path.join(process.cwd(), 'Site');
  if (!fs.existsSync(path.join(siteDir, 'node_modules'))) {
    console.log('⚠️  node_modules do Site não encontrado, instalando...');
    if (!exec('npm install', siteDir)) {
      throw new Error('Falha ao instalar dependências do Site');
    }
  } else {
    console.log('✓ Dependências do Site já instaladas');
  }

  // 3. Build do Sistema de Gestão (Admin) primeiro
  console.log('\n🔐 BUILD: Sistema de Gestão (Admin)...');
  if (!exec('npm run build:admin')) {
    throw new Error('Falha no build do Admin');
  }

  // 4. Mover build do admin para dist-admin temporário
  console.log('\n📁 Movendo build do Admin para temporário...');
  if (fs.existsSync('dist')) {
    fs.renameSync('dist', 'dist-admin');
  } else {
    throw new Error('Build do Admin não gerou o diretório dist');
  }

  // 5. Build do Site Institucional
  console.log('\n📱 BUILD: Site Institucional...');
  if (!exec('npm run build:site')) {
    throw new Error('Falha no build do Site');
  }

  // 6. Copiar Site/out para dist
  console.log('\n📄 Copiando Site Institucional para dist/...');
  const siteOutDir = path.join(process.cwd(), 'Site', 'out');
  const distDir = path.join(process.cwd(), 'dist');
  
  if (!fs.existsSync(siteOutDir)) {
    throw new Error('Diretório Site/out não encontrado');
  }

  if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir);
  }

  // Copiar arquivos do Site para dist
  const siteEntries = fs.readdirSync(siteOutDir);
  for (const entry of siteEntries) {
    const srcPath = path.join(siteOutDir, entry);
    const destPath = path.join(distDir, entry);
    
    if (fs.statSync(srcPath).isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }

  // 7. Mover build do Admin para dist/admin
  console.log('\n📦 Organizando Admin em dist/admin/...');
  const adminDestDir = path.join(distDir, 'admin');
  moveDir('dist-admin', adminDestDir);

  // 8. Resultado
  console.log('\n✅ Build concluído com sucesso!\n');
  console.log('📊 Estrutura criada:');
  console.log('  dist/');
  console.log('  ├── index.html           ← Site Institucional (/)');
  console.log('  ├── assets/');
  console.log('  └── admin/');
  console.log('      ├── index.html       ← Sistema de Gestão (/admin)');
  console.log('      └── assets/');
  console.log('\n🌐 URLs:');
  console.log('  https://silosaboresgourmet.com.br        → Site');
  console.log('  https://silosaboresgourmet.com.br/admin  → Admin\n');

} catch (error) {
  console.error('\n❌ Erro no build:', error.message);
  process.exit(1);
}

