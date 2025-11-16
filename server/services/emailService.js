const nodemailer = require('nodemailer');
const path = require('path');
// Garantir leitura do .env específico da pasta server
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

// Configuração do transporter de e-mail
const createTransporter = () => {
  const emailUser = process.env.EMAIL_USER || 'silosabores@gmail.com';
  const emailPassword = process.env.EMAIL_PASSWORD;

  // Validar se as credenciais estão configuradas
  if (!emailPassword) {
    throw new Error(
      'EMAIL_PASSWORD não configurado. Por favor, crie um arquivo .env na pasta server/ com:\n' +
      'EMAIL_USER=silosabores@gmail.com\n' +
      'EMAIL_PASSWORD=sua_senha_de_app_do_gmail\n\n' +
      'Para criar uma Senha de App do Gmail, acesse: https://myaccount.google.com/apppasswords'
    );
  }

  // Para Gmail, você precisará configurar uma "Senha de App"
  // Acesse: https://myaccount.google.com/apppasswords
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: emailUser,
      pass: emailPassword
    }
  });
};

// Função para enviar e-mail de encomenda
const sendOrderEmail = async (orderData) => {
  const { nome, telefone, endereco, observacoes, pedido, total } = orderData;
  const emailDestino = 'silosabores@gmail.com';

  const transporter = createTransporter();

  const mailOptions = {
    from: process.env.EMAIL_USER || 'silosabores@gmail.com',
    to: emailDestino,
    subject: `Nova Encomenda - ${nome}`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #dc2626; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
          .content { background-color: #f9fafb; padding: 20px; border: 1px solid #e5e7eb; }
          .section { margin-bottom: 20px; }
          .section-title { font-weight: bold; color: #dc2626; margin-bottom: 10px; font-size: 18px; }
          .info-row { margin-bottom: 10px; }
          .info-label { font-weight: bold; display: inline-block; width: 120px; }
          .pedido { background-color: white; padding: 15px; border-radius: 5px; margin-top: 10px; }
          .total { font-size: 20px; font-weight: bold; color: #dc2626; text-align: right; margin-top: 15px; }
          .footer { text-align: center; margin-top: 20px; color: #6b7280; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🍝 Nova Encomenda Recebida</h1>
          </div>
          <div class="content">
            <div class="section">
              <div class="section-title">📋 Dados do Cliente</div>
              <div class="info-row">
                <span class="info-label">Nome:</span>
                <span>${nome}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Telefone:</span>
                <span>${telefone}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Endereço:</span>
                <span>${endereco}</span>
              </div>
              ${observacoes ? `
              <div class="info-row">
                <span class="info-label">Observações:</span>
                <span>${observacoes}</span>
              </div>
              ` : ''}
            </div>

            <div class="section">
              <div class="section-title">🛒 Pedido</div>
              <div class="pedido">
                <pre style="white-space: pre-wrap; font-family: Arial, sans-serif; margin: 0;">${pedido}</pre>
              </div>
              <div class="total">
                Total: ${total}
              </div>
            </div>

            <div class="footer">
              <p>Este e-mail foi enviado automaticamente pelo sistema de encomendas.</p>
              <p>Data: ${new Date().toLocaleString('pt-BR')}</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `,
    text: `
Nova Encomenda Recebida

Dados do Cliente:
- Nome: ${nome}
- Telefone: ${telefone}
- Endereço: ${endereco}
${observacoes ? `- Observações: ${observacoes}` : ''}

Pedido:
${pedido}

Total: ${total}

Data: ${new Date().toLocaleString('pt-BR')}
    `
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('E-mail enviado com sucesso:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Erro ao enviar e-mail:', error);
    throw error;
  }
};

module.exports = {
  sendOrderEmail
};

