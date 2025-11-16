const express = require('express');
const router = express.Router();
const { sendOrderEmail } = require('../services/emailService');
const { body, validationResult } = require('express-validator');

// Rota pública para receber encomendas do site
router.post('/', [
  body('nome').notEmpty().withMessage('Nome é obrigatório'),
  body('telefone').notEmpty().withMessage('Telefone é obrigatório'),
  body('endereco').notEmpty().withMessage('Endereço é obrigatório'),
  body('pedido').notEmpty().withMessage('Pedido é obrigatório'),
  body('total').notEmpty().withMessage('Total é obrigatório')
], async (req, res) => {
  try {
    // Verificar erros de validação
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Dados inválidos',
        errors: errors.array()
      });
    }

    const { nome, telefone, endereco, observacoes, pedido, total } = req.body;

    // Enviar e-mail
    await sendOrderEmail({
      nome,
      telefone,
      endereco,
      observacoes: observacoes || '',
      pedido,
      total
    });

    res.json({
      success: true,
      message: 'Encomenda enviada com sucesso!'
    });
  } catch (error) {
    console.error('Erro ao processar encomenda:', error);
    
    // Mensagem mais específica para erros de configuração
    let errorMessage = 'Erro ao enviar encomenda. Tente novamente mais tarde.';
    
    if (error.message && error.message.includes('EMAIL_PASSWORD')) {
      errorMessage = 'Configuração de e-mail não encontrada. Entre em contato com o administrador.';
      console.error('⚠️  CONFIGURAÇÃO NECESSÁRIA:', error.message);
    } else if (error.code === 'EAUTH') {
      errorMessage = 'Erro de autenticação no e-mail. Verifique as credenciais configuradas.';
    }
    
    res.status(500).json({
      success: false,
      message: errorMessage
    });
  }
});

module.exports = router;

