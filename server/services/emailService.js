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
  const logoUrl = process.env.EMAIL_LOGO_URL;

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
          body { margin: 0; padding: 24px; background: #f3f4f6; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, 'Helvetica Neue', sans-serif; line-height: 1.6; color: #1f2937; }
          .container { max-width: 640px; margin: 0 auto; }
          .card { background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.04); }
          .header { background-color: #dc2626; color: #ffffff; padding: 20px 24px; text-align: center; }
          .brand-logo { max-height: 48px; width: auto; display: block; margin: 0 auto 8px auto; border-radius: 6px; }
          .title { margin: 8px 0 0 0; font-size: 22px; font-weight: 700; letter-spacing: 0.2px; }
          .content { padding: 24px; background-color: #ffffff; }
          .section { margin-bottom: 20px; }
          .section-title { font-weight: 700; color: #b91c1c; margin-bottom: 12px; font-size: 16px; text-transform: uppercase; letter-spacing: 0.4px; }
          .info-row { display: flex; gap: 8px; margin-bottom: 10px; }
          .info-label { min-width: 120px; font-weight: 600; color: #374151; }
          .info-value { color: #111827; }
          .pedido { background-color: #fafafa; padding: 16px; border-radius: 8px; border: 1px solid #e5e7eb; margin-top: 8px; }
          .pedido pre { white-space: pre-wrap; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace; font-size: 14px; margin: 0; color: #111827; }
          .total { font-size: 18px; font-weight: 800; color: #b91c1c; text-align: right; margin-top: 16px; }
          .divider { height: 1px; background: #f3f4f6; margin: 16px 0; }
          .footer { text-align: center; margin: 0; padding: 16px 24px 20px; color: #6b7280; font-size: 12px; background: #ffffff; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="card">
            <div class="header">
              ${logoUrl ? `<img src="${logoUrl}" alt="Silo Sabores" class="brand-logo" />` : ''}
              <div class="title">Nova Encomenda Recebida</div>
            </div>
            <div class="content">
              <div class="section">
                <div class="section-title">Dados do Cliente</div>
                <div class="info-row">
                  <span class="info-label">Nome:</span>
                  <span class="info-value">${nome}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">Telefone:</span>
                  <span class="info-value">${telefone}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">Endereço:</span>
                  <span class="info-value">${endereco}</span>
                </div>
                ${observacoes ? `
                <div class="info-row">
                  <span class="info-label">Observações:</span>
                  <span class="info-value">${observacoes}</span>
                </div>
                ` : ''}
              </div>

              <div class="divider"></div>

              <div class="section">
                <div class="section-title">Pedido</div>
                <div class="pedido">
                  <pre>${pedido}</pre>
                </div>
                <div class="total">
                  Total: ${total}
                </div>
              </div>
            </div>
            <p class="footer">
              Este e-mail foi enviado automaticamente pelo sistema de encomendas.<br/>
              Data: ${new Date().toLocaleString('pt-BR')}
            </p>
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

