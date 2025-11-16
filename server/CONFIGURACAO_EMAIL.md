# Configuração de E-mail

Este documento explica como configurar o envio de e-mails para o sistema de encomendas.

## Variáveis de Ambiente

Crie um arquivo `.env` na pasta `server/` com as seguintes variáveis:

```env
# Configurações do Banco de Dados
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=sua_senha
DB_NAME=loja_organizada

# Configurações de E-mail
EMAIL_USER=silosabores@gmail.com
EMAIL_PASSWORD=sua_senha_de_app_do_gmail

# Configurações do Servidor
PORT=3001
FRONTEND_URL=http://localhost:5173
NODE_ENV=development
```

## Configuração do Gmail

Para usar o Gmail como serviço de envio de e-mails, você precisa criar uma **Senha de App**:

### Passo a Passo:

1. Acesse sua conta Google: https://myaccount.google.com/
2. Vá em **Segurança** (Security)
3. Ative a **Verificação em duas etapas** (se ainda não estiver ativada)
4. Acesse: https://myaccount.google.com/apppasswords
5. Selecione:
   - **App**: E-mail
   - **Device**: Outro (nome personalizado)
   - Digite: "Silo System"
6. Clique em **Gerar**
7. Copie a senha gerada (16 caracteres sem espaços)
8. Use essa senha no campo `EMAIL_PASSWORD` do arquivo `.env`

### Importante:

- **NÃO use sua senha normal do Gmail**
- Use apenas a **Senha de App** gerada
- A senha de app tem 16 caracteres e não contém espaços
- Se você perder a senha, gere uma nova

## Testando o Envio de E-mail

Após configurar as variáveis de ambiente:

1. Inicie o servidor:
   ```bash
   cd server
   npm start
   ```

2. Teste enviando uma encomenda pelo formulário do site

3. Verifique se o e-mail foi recebido em `silosabores@gmail.com`

## Troubleshooting

### Erro: "Invalid login"
- Verifique se está usando a Senha de App, não a senha normal
- Certifique-se de que a verificação em duas etapas está ativada

### Erro: "Connection timeout"
- Verifique sua conexão com a internet
- Verifique se o firewall não está bloqueando a porta SMTP (587)

### E-mail não chega
- Verifique a pasta de spam
- Verifique se o endereço de destino está correto: `silosabores@gmail.com`
- Verifique os logs do servidor para erros

## Alternativas ao Gmail

Se preferir usar outro serviço de e-mail, você pode modificar o arquivo `server/services/emailService.js`:

### Para Outlook/Hotmail:
```javascript
return nodemailer.createTransport({
  service: 'hotmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});
```

### Para SMTP genérico:
```javascript
return nodemailer.createTransport({
  host: 'smtp.seuservidor.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});
```

