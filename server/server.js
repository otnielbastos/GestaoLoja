// Carregar variáveis de ambiente do arquivo .env localizado na pasta do servidor
require('dotenv').config({ path: require('path').join(__dirname, '.env') });
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');
const pool = require('./config/database');
const fs = require('fs');

// Importar rotas
const produtosRoutes = require('./routes/produtos');
const estoqueRoutes = require('./routes/estoque');
const clientesRoutes = require('./routes/clientes');
const pedidosRoutes = require('./routes/pedidos');
const authRoutes = require('./routes/auth');
const usersRoutes = require('./routes/users');
const encomendasRoutes = require('./routes/encomendas');

const app = express();

// Middlewares de segurança
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: "cross-origin" },
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:", "http://localhost:*"],
    },
  },
}));

// Rate limiting global
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: process.env.NODE_ENV === 'production' ? 100 : 1000, // 1000 em dev, 100 em produção
  message: {
    success: false,
    message: 'Muitas requisições do mesmo IP. Tente novamente em 15 minutos.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

app.use(limiter);

// Middleware CORS
app.use(cors({
  origin: [
    'http://localhost:5173',
    'http://localhost:8080', 
    'http://localhost:8081',
    'http://localhost:3000',
    process.env.FRONTEND_URL
  ].filter(Boolean),
  credentials: true
}));

// Middleware para parsing JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Middleware para capturar IP real
app.use((req, res, next) => {
  req.ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.ip;
  next();
});

// Criar diretório de uploads se não existir
const uploadsDir = path.join(__dirname, 'uploads');
const produtosDir = path.join(uploadsDir, 'produtos');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir);
}
if (!fs.existsSync(produtosDir)) {
    fs.mkdirSync(produtosDir);
}

// Servir arquivos estáticos com headers CORS
app.use('/uploads', (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  res.header('Cross-Origin-Resource-Policy', 'cross-origin');
  next();
});

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Log de todas as requisições
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`${timestamp} - ${req.method} ${req.url} - IP: ${req.ip}`);
    next();
});

// Teste da conexão com o banco (não bloqueia o servidor se falhar)
pool.getConnection()
    .then(connection => {
        console.log('✅ Conexão com o banco de dados MySQL estabelecida com sucesso!');
        connection.release();
    })
    .catch(err => {
        console.warn('⚠️  Aviso: Não foi possível conectar ao banco de dados MySQL.');
        console.warn('   O servidor continuará rodando, mas funcionalidades que dependem do banco não estarão disponíveis.');
        console.warn('   A rota de encomendas (envio de e-mails) funcionará normalmente.');
        // Não encerra o servidor - permite que rotas que não dependem do banco funcionem
    });

// Rotas de autenticação (públicas)
app.use('/api/auth', authRoutes);
app.use('/api/encomendas', encomendasRoutes);

// Rotas protegidas
app.use('/api/users', usersRoutes);
app.use('/api/produtos', produtosRoutes);
app.use('/api/estoque', estoqueRoutes);
app.use('/api/clientes', clientesRoutes);
app.use('/api/pedidos', pedidosRoutes);

// Middleware de tratamento de erros
app.use((err, req, res, next) => {
    console.error('Erro na aplicação:', err);
    
    // Erro de validação do JWT
    if (err.name === 'JsonWebTokenError') {
        return res.status(401).json({ 
            success: false,
            message: 'Token inválido' 
        });
    }
    
    // Erro de token expirado
    if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ 
            success: false,
            message: 'Token expirado' 
        });
    }
    
    // Erro de validação
    if (err.name === 'ValidationError') {
        return res.status(400).json({ 
            success: false,
            message: 'Dados inválidos',
            errors: err.errors
        });
    }
    
    res.status(500).json({ 
        success: false,
        message: 'Erro interno do servidor',
        details: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// Rota de teste (pública)
app.get('/api/test', (req, res) => {
    res.json({ 
        success: true,
        message: 'API funcionando!',
        timestamp: new Date().toISOString()
    });
});

// Rota para verificar status do sistema
app.get('/api/health', (req, res) => {
    res.json({
        success: true,
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// Handler para rotas não encontradas
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: 'Rota não encontrada'
    });
});

// Porta do servidor
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`🚀 Servidor rodando na porta ${PORT}`);
    console.log(`📁 Servindo arquivos estáticos de: ${path.join(__dirname, 'uploads')}`);
    console.log(`🔒 Sistema de segurança ativado`);
    console.log(`🌐 Ambiente: ${process.env.NODE_ENV || 'development'}`);
}); 