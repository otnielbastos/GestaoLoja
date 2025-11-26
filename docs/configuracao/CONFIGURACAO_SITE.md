# Configuração do Site

## ⚠️ IMPORTANTE - Deploy na Vercel

Este projeto está configurado para deploy unificado na Vercel:
- **URL Raiz** (`/`): Site Institucional
- **URL Admin** (`/admin`): Sistema de Gestão

Ao fazer deploy, execute `npm run build` que compilará ambos automaticamente.

## Estrutura do Projeto

O projeto GestaoLoja é um sistema de gestão de loja.

### 1. **Site Institucional** (Pasta `Site/`)
- **Porta**: 8080
- **Descrição**: Site comercial/institucional voltado para o público
- **Tecnologias**: React, Vite, React Router, i18next (internacionalização)
- **Acesso**: http://localhost:8080

### 2. **Sistema Administrativo** (Raiz do projeto)
- **Porta**: 8081
- **Descrição**: Sistema de gestão com Supabase, controle de pedidos, clientes, estoque, etc.
- **Tecnologias**: React, Vite, Supabase, React Router
- **Acesso**: http://localhost:8081

## Comandos Disponíveis

### Para executar o Site Institucional (URL principal):
```bash
npm run dev
# ou
npm run dev:site
```
O site estará disponível em: http://localhost:8080

### Para executar o Sistema Administrativo:
```bash
npm run dev:admin
```
O sistema administrativo estará disponível em: http://localhost:8081

### Para executar ambos simultaneamente:
Em um terminal:
```bash
npm run dev:site
```

Em outro terminal:
```bash
npm run dev:admin
```

## Build para Produção

### Build do Site:
```bash
npm run build
# ou
npm run build:site
```
Saída: `Site/out/`

### Build do Sistema Administrativo:
```bash
npm run build:admin
```
Saída: `dist/`

## Preview (Visualizar Build)

### Preview do Site:
```bash
npm run preview
```

### Preview do Sistema Administrativo:
```bash
npm run preview:admin
```

## Instalação das Dependências

### Dependências do projeto raiz:
```bash
npm install
```

### Dependências do Site:
```bash
cd Site
npm install
cd ..
```

## Observações Importantes

1. **URL Principal**: Por padrão, ao executar `npm run dev`, o **Site Institucional** será iniciado na porta 8080
2. **Desenvolvimento Paralelo**: Você pode executar ambas as aplicações simultaneamente em portas diferentes
3. **Dependências Separadas**: Cada projeto tem seu próprio `package.json` e dependências
4. **Configurações Independentes**: Cada projeto tem sua própria configuração do Vite

## Estrutura de Pastas

```
C:\dev\Silo\
├── Site/                          # Site Institucional
│   ├── src/
│   │   ├── components/           # Componentes do site
│   │   ├── pages/                # Páginas do site
│   │   ├── i18n/                 # Internacionalização
│   │   └── router/               # Configuração de rotas
│   ├── package.json
│   └── vite.config.ts
│
├── src/                           # Sistema Administrativo
│   ├── components/               # Componentes do sistema
│   ├── pages/                    # Páginas do sistema
│   ├── services/                 # Serviços (Supabase)
│   └── hooks/                    # Hooks customizados
├── package.json
└── vite.config.ts
```

## Próximos Passos

1. Instale as dependências do Site (se ainda não instalou):
   ```bash
   cd Site
   npm install
   ```

2. Execute o Site:
   ```bash
   cd ..
   npm run dev
   ```

3. Acesse http://localhost:8080 no navegador

## Suporte

Para mais informações sobre:
- **Sistema Administrativo**: Consulte `REGRAS_NEGOCIO_IMPLEMENTADAS.md`, `SISTEMA_PERMISSOES.md`
- **Relatórios**: Consulte `CONFIGURACAO_RELATÓRIOS_SUPABASE.md`
- **Deploy**: Consulte `DEPLOY_VERCEL.md`

