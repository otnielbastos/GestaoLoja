// Script para testar a configuração de e-mail
const fs = require('fs');
const path = require('path');
const envPath = path.join(__dirname, '.env');
require('dotenv').config({ path: envPath });

console.log('🔍 Verificando configuração de e-mail...\n');

if (!fs.existsSync(envPath)) {
  console.error('❌ Arquivo .env não encontrado em', envPath);
  process.exit(1);
}

const buf = fs.readFileSync(envPath);
if (buf.length >= 2 && buf[0] === 0xff && buf[1] === 0xfe) {
  console.warn('⚠️  O arquivo .env parece estar em UTF-16 LE. Converta para UTF-8 sem BOM.');
}

const emailUser = process.env.EMAIL_USER;
const emailPassword = process.env.EMAIL_PASSWORD;

console.log('EMAIL_USER:', emailUser ? `${emailUser.substring(0, 5)}...` : '❌ NÃO DEFINIDO');
console.log('EMAIL_PASSWORD:', emailPassword ? `${emailPassword.length} caracteres` : '❌ NÃO DEFINIDO');

if (!emailUser) {
  console.error('\n❌ EMAIL_USER não está definido no arquivo .env');
}

if (!emailPassword) {
  console.error('\n❌ EMAIL_PASSWORD não está definido no arquivo .env');
  console.error('\n📝 Para configurar:');
  console.error('   1. Abra o arquivo server/.env');
  console.error('   2. Adicione: EMAIL_PASSWORD=sua_senha_de_app');
  console.error('   3. Para criar uma Senha de App do Gmail:');
  console.error('      https://myaccount.google.com/apppasswords');
} else if (emailPassword.length < 10) {
  console.warn('\n⚠️  EMAIL_PASSWORD parece muito curto. Uma Senha de App do Gmail tem 16 caracteres.');
} else {
  console.log('\n✅ Configuração parece correta!');
  console.log('   Reinicie o servidor para aplicar as mudanças.');
}

