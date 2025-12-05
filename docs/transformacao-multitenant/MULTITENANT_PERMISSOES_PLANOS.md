# Sistema de Permissões Hierárquico e Planos - Multi-Tenant

## 📋 ÍNDICE

1. [Sistema de Permissões Hierárquico](#sistema-de-permissões-hierárquico)
2. [Planos e Limites (Billing)](#planos-e-limites-billing)
3. [Controle de Uso e Quotas](#controle-de-uso-e-quotas)
4. [Gestão de Usuários Multi-Tenant](#gestão-de-usuários-multi-tenant)

---

## 👥 SISTEMA DE PERMISSÕES HIERÁRQUICO

### Conceito

No modelo multi-tenant, as permissões precisam considerar **4 níveis**:

```
1. PAPEL (papel na empresa)
   ↓
2. PERFIL (conjunto de permissões)
   ↓
3. FILIAL (a qual filial tem acesso)
   ↓
4. AÇÃO (o que pode fazer em cada página)
```

### Papéis (Roles) na Empresa

```typescript
enum PapelEmpresa {
  PROPRIETARIO = 'proprietario',  // Dono da conta, acesso total
  ADMIN = 'admin',                 // Administrador, acesso quase total
  GERENTE = 'gerente',             // Gerente, pode gerenciar filiais específicas
  USUARIO = 'usuario'              // Usuário comum, operador
}
```

#### Hierarquia de Papéis

```
PROPRIETARIO
├─ Pode tudo
├─ Gerenciar planos e pagamentos
├─ Excluir empresa
├─ Transferir propriedade
└─ Acessar todas as filiais

ADMIN
├─ Acesso total aos dados
├─ Criar/editar usuários
├─ Criar/editar filiais
├─ NÃO pode gerenciar planos
└─ NÃO pode excluir empresa

GERENTE
├─ Acesso às filiais atribuídas
├─ Pode criar usuários (apenas para suas filiais)
├─ Pode ver relatórios das suas filiais
└─ NÃO pode criar filiais

USUARIO
├─ Acesso operacional
├─ Limitado às filiais atribuídas
├─ Executar operações do dia-a-dia
└─ NÃO pode gerenciar usuários ou filiais
```

### Modelo de Dados de Permissões

#### Estrutura JSONB de Permissões

```json
{
  "pages": [
    "dashboard",
    "produtos",
    "pedidos",
    "clientes",
    "estoque",
    "entregas",
    "relatorios"
  ],
  "actions": {
    "produtos": ["visualizar", "criar", "editar", "excluir", "exportar"],
    "pedidos": ["visualizar", "criar", "editar", "aprovar", "cancelar", "exportar"],
    "clientes": ["visualizar", "criar", "editar", "excluir", "exportar"],
    "estoque": ["visualizar", "editar", "exportar"],
    "entregas": ["visualizar", "editar"],
    "relatorios": ["visualizar", "exportar", "imprimir"]
  },
  "restrictions": {
    "produtos": {
      "can_edit_preco": false,
      "can_see_custo": false
    },
    "pedidos": {
      "max_desconto_percentual": 10,
      "requer_aprovacao_acima": 1000.00
    }
  },
  "filiais_acesso": {
    "mode": "especificas",  // "todas" ou "especificas"
    "filiais": ["filial-uuid-1", "filial-uuid-2"]
  }
}
```

### Perfis Pré-Definidos por Tipo de Empresa

#### Para Pequenos Negócios (1 filial)

```sql
-- Perfil: Proprietário
INSERT INTO perfis (nome, descricao, eh_global, permissoes) VALUES
('Proprietário', 'Acesso total - Dono do negócio', true, 
'{
  "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios", "usuarios", "configuracoes"],
  "actions": {
    "produtos": ["visualizar", "criar", "editar", "excluir", "exportar"],
    "pedidos": ["visualizar", "criar", "editar", "aprovar", "cancelar", "exportar", "imprimir"],
    "clientes": ["visualizar", "criar", "editar", "excluir", "exportar"],
    "estoque": ["visualizar", "editar", "exportar"],
    "entregas": ["visualizar", "editar", "exportar"],
    "relatorios": ["visualizar", "exportar", "imprimir"],
    "usuarios": ["visualizar", "criar", "editar", "excluir"],
    "configuracoes": ["visualizar", "editar"]
  }
}'::jsonb);

-- Perfil: Gerente de Loja
INSERT INTO perfis (nome, descricao, eh_global, permissoes) VALUES
('Gerente de Loja', 'Gerencia operações da loja', true, 
'{
  "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios"],
  "actions": {
    "produtos": ["visualizar", "criar", "editar"],
    "pedidos": ["visualizar", "criar", "editar", "aprovar", "cancelar"],
    "clientes": ["visualizar", "criar", "editar"],
    "estoque": ["visualizar", "editar"],
    "entregas": ["visualizar", "editar"],
    "relatorios": ["visualizar", "exportar"]
  }
}'::jsonb);

-- Perfil: Vendedor
INSERT INTO perfis (nome, descricao, eh_global, permissoes) VALUES
('Vendedor', 'Vendas e atendimento ao cliente', true, 
'{
  "pages": ["dashboard", "pedidos", "clientes", "produtos"],
  "actions": {
    "produtos": ["visualizar"],
    "pedidos": ["visualizar", "criar", "editar"],
    "clientes": ["visualizar", "criar", "editar"],
    "dashboard": ["visualizar"]
  },
  "restrictions": {
    "pedidos": {
      "max_desconto_percentual": 5,
      "requer_aprovacao_acima": 500.00
    }
  }
}'::jsonb);

-- Perfil: Estoquista
INSERT INTO perfis (nome, descricao, eh_global, permissoes) VALUES
('Estoquista', 'Controle de estoque e movimentações', true, 
'{
  "pages": ["dashboard", "estoque", "produtos", "entregas"],
  "actions": {
    "produtos": ["visualizar"],
    "estoque": ["visualizar", "editar"],
    "entregas": ["visualizar", "editar"]
  }
}'::jsonb);
```

#### Para Redes (Múltiplas Filiais)

```sql
-- Perfil: Gerente Regional
INSERT INTO perfis (nome, descricao, eh_global, permissoes) VALUES
('Gerente Regional', 'Gerencia múltiplas filiais de uma região', true, 
'{
  "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios", "usuarios"],
  "actions": {
    "produtos": ["visualizar", "criar", "editar"],
    "pedidos": ["visualizar", "criar", "editar", "aprovar", "cancelar"],
    "clientes": ["visualizar", "criar", "editar"],
    "estoque": ["visualizar", "editar"],
    "entregas": ["visualizar", "editar"],
    "relatorios": ["visualizar", "exportar"],
    "usuarios": ["visualizar", "criar", "editar"]
  },
  "filiais_acesso": {
    "mode": "especificas"
  }
}'::jsonb);

-- Perfil: Gerente de Filial
INSERT INTO perfis (nome, descricao, eh_global, permissoes) VALUES
('Gerente de Filial', 'Gerencia uma filial específica', true, 
'{
  "pages": ["dashboard", "produtos", "pedidos", "clientes", "estoque", "entregas", "relatorios"],
  "actions": {
    "produtos": ["visualizar"],
    "pedidos": ["visualizar", "criar", "editar", "aprovar", "cancelar"],
    "clientes": ["visualizar", "criar", "editar"],
    "estoque": ["visualizar", "editar"],
    "entregas": ["visualizar", "editar"],
    "relatorios": ["visualizar", "exportar"]
  },
  "filiais_acesso": {
    "mode": "especificas"
  }
}'::jsonb);
```

### Hooks de Permissões (Frontend)

```typescript
// src/hooks/usePermissoesTenant.ts

import { useMemo } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { useEmpresa } from '@/contexts/EmpresaContext';

export const usePermissoesTenant = () => {
  const { user } = useAuth();
  const { empresaAtual, filialAtual } = useEmpresa();

  // Buscar relacionamento do usuário com a empresa
  const usuarioEmpresa = useMemo(() => {
    if (!user || !empresaAtual) return null;
    
    return getUserEmpresaRelation(user.id, empresaAtual.id);
  }, [user, empresaAtual]);

  // Verificar se tem acesso à filial atual
  const hasFilialAccess = useMemo(() => {
    if (!usuarioEmpresa || !filialAtual) return false;
    
    // Se tem acesso a todas as filiais
    if (usuarioEmpresa.acesso_todas_filiais) return true;
    
    // Se tem acesso específico à filial
    return usuarioEmpresa.filiais_acesso?.includes(filialAtual.id);
  }, [usuarioEmpresa, filialAtual]);

  // Verificar papel
  const hasRole = (papel: string) => {
    return usuarioEmpresa?.papel === papel;
  };

  // Verificar se é proprietário
  const isProprietario = hasRole('proprietario');
  
  // Verificar se é admin
  const isAdmin = hasRole('admin') || isProprietario;
  
  // Verificar se é gerente
  const isGerente = hasRole('gerente') || isAdmin;

  // Verificar permissão de página
  const hasPageAccess = (page: string): boolean => {
    if (isProprietario) return true;
    
    const permissoes = user?.permissoes;
    if (!permissoes) return false;
    
    return permissoes.pages?.includes(page) || false;
  };

  // Verificar permissão de ação
  const hasActionAccess = (page: string, action: string): boolean => {
    if (isProprietario) return true;
    
    if (!hasPageAccess(page)) return false;
    
    const permissoes = user?.permissoes;
    const pageActions = permissoes?.actions?.[page] || [];
    
    return pageActions.includes(action);
  };

  // Verificar restrições
  const getRestrictions = (page: string) => {
    const permissoes = user?.permissoes;
    return permissoes?.restrictions?.[page] || {};
  };

  // Verificar se pode ver custo de produtos
  const canSeeProductCost = (): boolean => {
    if (isAdmin) return true;
    
    const restrictions = getRestrictions('produtos');
    return restrictions.can_see_custo !== false;
  };

  // Verificar limite de desconto
  const getMaxDiscountPercent = (): number => {
    if (isAdmin) return 100;
    
    const restrictions = getRestrictions('pedidos');
    return restrictions.max_desconto_percentual || 0;
  };

  // Verificar se pedido precisa aprovação
  const needsOrderApproval = (orderValue: number): boolean => {
    if (isAdmin) return false;
    
    const restrictions = getRestrictions('pedidos');
    const threshold = restrictions.requer_aprovacao_acima;
    
    return threshold && orderValue > threshold;
  };

  return {
    usuarioEmpresa,
    hasFilialAccess,
    hasRole,
    isProprietario,
    isAdmin,
    isGerente,
    hasPageAccess,
    hasActionAccess,
    getRestrictions,
    canSeeProductCost,
    getMaxDiscountPercent,
    needsOrderApproval
  };
};
```

### Componente de Verificação de Acesso

```typescript
// src/components/auth/RequireRole.tsx

interface RequireRoleProps {
  papel: string | string[];
  fallback?: React.ReactNode;
  children: React.ReactNode;
}

export const RequireRole: React.FC<RequireRoleProps> = ({ 
  papel, 
  fallback = null, 
  children 
}) => {
  const { hasRole } = usePermissoesTenant();
  
  const papeis = Array.isArray(papel) ? papel : [papel];
  const hasRequiredRole = papeis.some(p => hasRole(p));
  
  if (!hasRequiredRole) {
    return <>{fallback}</>;
  }
  
  return <>{children}</>;
};

// Uso:
<RequireRole papel="proprietario">
  <Button onClick={excluirEmpresa}>Excluir Empresa</Button>
</RequireRole>

<RequireRole papel={['proprietario', 'admin']}>
  <NavItem href="/usuarios">Usuários</NavItem>
</RequireRole>
```

---

## 💰 PLANOS E LIMITES (BILLING)

### Estrutura de Planos

#### Estratégia de Preços

```
┌─────────────────────────────────────────────────────────┐
│                  PLANOS DO GESTÃOLOJA                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🆓 TRIAL (14 dias grátis)                             │
│  ├─ 2 usuários                                         │
│  ├─ 1 filial                                           │
│  ├─ 50 produtos                                        │
│  ├─ 50 pedidos/mês                                     │
│  └─ 500 MB storage                                     │
│                                                         │
│  💼 STARTER - R$ 97/mês (R$ 970/ano - 17% off)        │
│  ├─ 5 usuários                                         │
│  ├─ 1 filial                                           │
│  ├─ 500 produtos                                       │
│  ├─ Pedidos ilimitados                                │
│  ├─ 2 GB storage                                       │
│  ├─ Backup diário                                      │
│  └─ Suporte por email                                  │
│                                                         │
│  🚀 PROFESSIONAL - R$ 197/mês (R$ 1.970/ano - 17% off)│
│  ├─ 15 usuários                                        │
│  ├─ 5 filiais                                          │
│  ├─ 2.000 produtos                                     │
│  ├─ Pedidos ilimitados                                │
│  ├─ 10 GB storage                                      │
│  ├─ Backup diário                                      │
│  ├─ Relatórios avançados                              │
│  ├─ API de integração                                 │
│  └─ Suporte prioritário                               │
│                                                         │
│  🏢 ENTERPRISE - R$ 497/mês (R$ 4.970/ano - 17% off)  │
│  ├─ Usuários ilimitados                               │
│  ├─ Filiais ilimitadas                                │
│  ├─ Produtos ilimitados                               │
│  ├─ Pedidos ilimitados                                │
│  ├─ 50 GB storage                                      │
│  ├─ Backup horário                                     │
│  ├─ Relatórios customizados                           │
│  ├─ API ilimitada                                      │
│  ├─ White label                                        │
│  ├─ SLA garantido                                      │
│  └─ Suporte dedicado                                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Controle de Limites (Backend)

```typescript
// src/services/limitesService.ts

interface LimitesPlano {
  max_usuarios?: number;
  max_filiais?: number;
  max_produtos?: number;
  max_clientes?: number;
  max_pedidos_mes?: number;
  storage_gb?: number;
  max_chamadas_api_dia?: number;
}

class LimitesService {
  
  // Verificar se empresa atingiu limite de usuários
  async podeAdicionarUsuario(empresaId: string): Promise<boolean> {
    const empresa = await getEmpresa(empresaId);
    const limites = empresa.limites as LimitesPlano;
    
    // Se não tem limite definido, permite
    if (!limites.max_usuarios) return true;
    
    // Contar usuários ativos
    const { count } = await supabase
      .from('usuarios_empresas')
      .select('*', { count: 'exact', head: true })
      .eq('empresa_id', empresaId)
      .eq('ativo', true);
    
    return count! < limites.max_usuarios;
  }

  // Verificar se pode adicionar filial
  async podeAdicionarFilial(empresaId: string): Promise<boolean> {
    const empresa = await getEmpresa(empresaId);
    const limites = empresa.limites as LimitesPlano;
    
    if (!limites.max_filiais) return true;
    
    const { count } = await supabase
      .from('filiais')
      .select('*', { count: 'exact', head: true })
      .eq('empresa_id', empresaId)
      .eq('ativo', true);
    
    return count! < limites.max_filiais;
  }

  // Verificar se pode adicionar produto
  async podeAdicionarProduto(empresaId: string): Promise<boolean> {
    const empresa = await getEmpresa(empresaId);
    const limites = empresa.limites as LimitesPlano;
    
    if (!limites.max_produtos) return true;
    
    const { count } = await supabase
      .from('produtos')
      .select('*', { count: 'exact', head: true })
      .eq('empresa_id', empresaId)
      .eq('status', 'ativo');
    
    return count! < limites.max_produtos;
  }

  // Verificar se atingiu limite de pedidos no mês
  async podeAdicionarPedido(empresaId: string): Promise<boolean> {
    const empresa = await getEmpresa(empresaId);
    const limites = empresa.limites as LimitesPlano;
    
    // Se não tem limite, permite
    if (!limites.max_pedidos_mes) return true;
    
    // Primeiro dia do mês atual
    const inicioMes = new Date();
    inicioMes.setDate(1);
    inicioMes.setHours(0, 0, 0, 0);
    
    const { count } = await supabase
      .from('pedidos')
      .select('*', { count: 'exact', head: true })
      .eq('empresa_id', empresaId)
      .gte('data_pedido', inicioMes.toISOString());
    
    return count! < limites.max_pedidos_mes;
  }

  // Calcular storage usado
  async getStorageUsado(empresaId: string): Promise<number> {
    // Buscar total de arquivos no storage desta empresa
    const { data, error } = await supabase
      .storage
      .from('uploads')
      .list(`${empresaId}/`, {
        limit: 10000,
        sortBy: { column: 'name', order: 'asc' }
      });
    
    if (error) throw error;
    
    // Somar tamanhos
    const totalBytes = data.reduce((sum, file) => sum + (file.metadata?.size || 0), 0);
    const totalGB = totalBytes / (1024 * 1024 * 1024);
    
    return parseFloat(totalGB.toFixed(2));
  }

  // Verificar se pode fazer upload
  async podeFazerUpload(empresaId: string, fileSizeBytes: number): Promise<boolean> {
    const empresa = await getEmpresa(empresaId);
    const limites = empresa.limites as LimitesPlano;
    
    const storageUsado = await this.getStorageUsado(empresaId);
    const fileGb = fileSizeBytes / (1024 * 1024 * 1024);
    
    return (storageUsado + fileGb) <= limites.storage_gb!;
  }

  // Atualizar contadores de uso do mês
  async atualizarContadoresMes(empresaId: string) {
    const mesAtual = new Date();
    mesAtual.setDate(1);
    mesAtual.setHours(0, 0, 0, 0);
    
    // Contar recursos
    const [usuarios, filiais, produtos, clientes, pedidos] = await Promise.all([
      this.contarUsuarios(empresaId),
      this.contarFiliais(empresaId),
      this.contarProdutos(empresaId),
      this.contarClientes(empresaId),
      this.contarPedidosMes(empresaId, mesAtual)
    ]);
    
    const storageUsado = await this.getStorageUsado(empresaId);
    
    // Upsert na tabela de limites_uso
    await supabase
      .from('limites_uso')
      .upsert({
        empresa_id: empresaId,
        mes_referencia: mesAtual.toISOString().split('T')[0],
        total_usuarios: usuarios,
        total_filiais: filiais,
        total_produtos: produtos,
        total_clientes: clientes,
        total_pedidos_mes: pedidos,
        storage_usado_gb: storageUsado,
        data_atualizacao: new Date().toISOString()
      }, {
        onConflict: 'empresa_id,mes_referencia'
      });
  }

  // Obter uso atual vs limites
  async getUsoAtual(empresaId: string) {
    const empresa = await getEmpresa(empresaId);
    const limites = empresa.limites as LimitesPlano;
    
    const mesAtual = new Date();
    mesAtual.setDate(1);
    mesAtual.setHours(0, 0, 0, 0);
    
    const { data: uso } = await supabase
      .from('limites_uso')
      .select('*')
      .eq('empresa_id', empresaId)
      .eq('mes_referencia', mesAtual.toISOString().split('T')[0])
      .single();
    
    return {
      uso: uso || {},
      limites: limites,
      percentuais: {
        usuarios: limites.max_usuarios 
          ? ((uso?.total_usuarios || 0) / limites.max_usuarios) * 100 
          : 0,
        filiais: limites.max_filiais 
          ? ((uso?.total_filiais || 0) / limites.max_filiais) * 100 
          : 0,
        produtos: limites.max_produtos 
          ? ((uso?.total_produtos || 0) / limites.max_produtos) * 100 
          : 0,
        pedidos: limites.max_pedidos_mes 
          ? ((uso?.total_pedidos_mes || 0) / limites.max_pedidos_mes) * 100 
          : 0,
        storage: limites.storage_gb 
          ? ((uso?.storage_usado_gb || 0) / limites.storage_gb) * 100 
          : 0
      }
    };
  }
}

export const limitesService = new LimitesService();
```

### Middleware de Verificação de Limites

```typescript
// src/middleware/checkLimits.ts

export const checkLimitMiddleware = (recurso: 'usuario' | 'filial' | 'produto' | 'pedido') => {
  return async (req, res, next) => {
    const empresaId = req.empresa_id;  // Vem do contexto
    
    let podeAdicionar = false;
    
    switch (recurso) {
      case 'usuario':
        podeAdicionar = await limitesService.podeAdicionarUsuario(empresaId);
        break;
      case 'filial':
        podeAdicionar = await limitesService.podeAdicionarFilial(empresaId);
        break;
      case 'produto':
        podeAdicionar = await limitesService.podeAdicionarProduto(empresaId);
        break;
      case 'pedido':
        podeAdicionar = await limitesService.podeAdicionarPedido(empresaId);
        break;
    }
    
    if (!podeAdicionar) {
      return res.status(403).json({
        error: 'Limite do plano atingido',
        message: `Você atingiu o limite de ${recurso}s do seu plano. Faça upgrade para continuar.`,
        upgrade_url: '/configuracoes/planos'
      });
    }
    
    next();
  };
};

// Uso nas rotas:
// app.post('/api/produtos', checkLimitMiddleware('produto'), criarProduto);
```

### Componente de Alerta de Limites (Frontend)

```typescript
// src/components/billing/LimitsAlert.tsx

export const LimitsAlert = () => {
  const { empresaAtual } = useEmpresa();
  const [usoAtual, setUsoAtual] = useState(null);
  
  useEffect(() => {
    if (empresaAtual) {
      carregarUsoAtual();
    }
  }, [empresaAtual]);
  
  const carregarUsoAtual = async () => {
    const uso = await limitesService.getUsoAtual(empresaAtual.id);
    setUsoAtual(uso);
  };
  
  // Verificar se algum limite está acima de 80%
  const limitesAltos = Object.entries(usoAtual?.percentuais || {})
    .filter(([_, percentual]) => percentual > 80);
  
  if (limitesAltos.length === 0) return null;
  
  return (
    <Alert variant="warning" className="mb-4">
      <AlertCircle className="h-4 w-4" />
      <AlertTitle>Atenção: Limite do Plano</AlertTitle>
      <AlertDescription>
        <div className="space-y-2">
          {limitesAltos.map(([recurso, percentual]) => (
            <div key={recurso} className="flex items-center justify-between">
              <span className="capitalize">{recurso}</span>
              <div className="flex items-center gap-2">
                <Progress value={percentual} className="w-32" />
                <span className="text-sm font-medium">{percentual.toFixed(0)}%</span>
              </div>
            </div>
          ))}
          <Button size="sm" variant="outline" asChild className="mt-2">
            <Link href="/configuracoes/planos">
              Fazer Upgrade do Plano
            </Link>
          </Button>
        </div>
      </AlertDescription>
    </Alert>
  );
};
```

### Tela de Gerenciamento de Planos

```typescript
// src/pages/configuracoes/Planos.tsx

const PlanosPage = () => {
  const { empresaAtual } = useEmpresa();
  const { isProprietario } = usePermissoesTenant();
  const [planos, setPlanos] = useState([]);
  const [usoAtual, setUsoAtual] = useState(null);
  
  if (!isProprietario) {
    return <AccessDenied message="Apenas o proprietário pode gerenciar planos" />;
  }
  
  return (
    <div className="space-y-6">
      <PageHeader
        title="Planos e Assinatura"
        description="Gerencie seu plano e visualize o uso dos recursos"
      />

      {/* Card de Uso Atual */}
      <Card>
        <CardHeader>
          <CardTitle>Uso Atual do Plano</CardTitle>
          <CardDescription>
            Plano: <Badge>{empresaAtual.plano?.nome}</Badge>
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {Object.entries(usoAtual?.uso || {}).map(([recurso, valor]) => {
              const limite = usoAtual.limites[recurso];
              const percentual = limite ? (valor / limite) * 100 : 0;
              
              return (
                <div key={recurso} className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="capitalize">{recurso.replace('_', ' ')}</span>
                    <span className="text-muted-foreground">
                      {valor} / {limite || '∞'}
                    </span>
                  </div>
                  <Progress 
                    value={percentual} 
                    className={percentual > 80 ? 'bg-red-100' : ''}
                  />
                </div>
              );
            })}
          </div>
        </CardContent>
        <CardFooter>
          <p className="text-xs text-muted-foreground">
            Atualizado em: {new Date(usoAtual?.data_atualizacao).toLocaleString()}
          </p>
        </CardFooter>
      </Card>

      {/* Grid de Planos Disponíveis */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {planos.map(plano => (
          <Card key={plano.id} className={
            plano.id === empresaAtual.plano_id 
              ? 'border-primary shadow-lg' 
              : ''
          }>
            <CardHeader>
              <CardTitle className="flex items-center justify-between">
                {plano.nome}
                {plano.id === empresaAtual.plano_id && (
                  <Badge variant="default">Atual</Badge>
                )}
              </CardTitle>
              <CardDescription>
                <div className="text-3xl font-bold">
                  R$ {plano.preco_mensal}
                  <span className="text-sm font-normal text-muted-foreground">/mês</span>
                </div>
                {plano.preco_anual && (
                  <p className="text-xs mt-1">
                    ou R$ {plano.preco_anual}/ano (economize {plano.desconto_anual}%)
                  </p>
                )}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2 text-sm">
                <li className="flex items-center">
                  <Check className="mr-2 h-4 w-4 text-green-500" />
                  {plano.max_usuarios || '∞'} usuários
                </li>
                <li className="flex items-center">
                  <Check className="mr-2 h-4 w-4 text-green-500" />
                  {plano.max_filiais || '∞'} filiais
                </li>
                <li className="flex items-center">
                  <Check className="mr-2 h-4 w-4 text-green-500" />
                  {plano.max_produtos || '∞'} produtos
                </li>
                <li className="flex items-center">
                  <Check className="mr-2 h-4 w-4 text-green-500" />
                  {plano.storage_gb} GB storage
                </li>
                {plano.features?.map(feature => (
                  <li key={feature} className="flex items-center">
                    <Check className="mr-2 h-4 w-4 text-green-500" />
                    {formatFeatureName(feature)}
                  </li>
                ))}
              </ul>
            </CardContent>
            <CardFooter>
              {plano.id === empresaAtual.plano_id ? (
                <Button variant="outline" disabled className="w-full">
                  Plano Atual
                </Button>
              ) : (
                <Button 
                  onClick={() => handleUpgrade(plano.id)}
                  className="w-full"
                >
                  {plano.preco_mensal > empresaAtual.plano.preco_mensal 
                    ? 'Fazer Upgrade' 
                    : 'Fazer Downgrade'}
                </Button>
              )}
            </CardFooter>
          </Card>
        ))}
      </div>

      {/* Histórico de Assinaturas */}
      <Card>
        <CardHeader>
          <CardTitle>Histórico de Assinaturas</CardTitle>
        </CardHeader>
        <CardContent>
          {/* Timeline de mudanças de plano */}
        </CardContent>
      </Card>
    </div>
  );
};
```

---

## 🔄 GESTÃO DE USUÁRIOS MULTI-TENANT

### Fluxo de Convite de Usuários

```typescript
// src/services/convitesService.ts

class ConvitesService {
  // Enviar convite
  async enviarConvite(dados: {
    empresaId: string;
    email: string;
    perfilId: number;
    papel: string;
    filiaisAcesso?: string[];
    mensagem?: string;
  }) {
    // 1. Verificar limite de usuários
    const podeAdicionar = await limitesService.podeAdicionarUsuario(dados.empresaId);
    if (!podeAdicionar) {
      throw new Error('Limite de usuários atingido');
    }
    
    // 2. Gerar token único
    const token = generateSecureToken();
    const dataExpiracao = new Date();
    dataExpiracao.setDate(dataExpiracao.getDate() + 7);  // Expira em 7 dias
    
    // 3. Criar convite
    const { data: convite, error } = await supabase
      .from('convites_pendentes')
      .insert({
        empresa_id: dados.empresaId,
        email: dados.email,
        perfil_id: dados.perfilId,
        papel: dados.papel,
        filiais_acesso: dados.filiaisAcesso || [],
        token,
        data_expiracao: dataExpiracao.toISOString(),
        status: 'pendente',
        criado_por: getCurrentUser().id,
        mensagem_personalizada: dados.mensagem
      })
      .select()
      .single();
    
    if (error) throw error;
    
    // 4. Enviar email
    await this.enviarEmailConvite({
      email: dados.email,
      empresa: await getEmpresa(dados.empresaId),
      token,
      convidadoPor: getCurrentUser().nome,
      mensagem: dados.mensagem
    });
    
    return convite;
  }

  // Aceitar convite
  async aceitarConvite(token: string, senha: string) {
    // 1. Buscar convite
    const { data: convite, error } = await supabase
      .from('convites_pendentes')
      .select('*, empresa:empresas(*)')
      .eq('token', token)
      .eq('status', 'pendente')
      .single();
    
    if (error || !convite) {
      throw new Error('Convite inválido ou expirado');
    }
    
    // 2. Verificar expiração
    if (new Date(convite.data_expiracao) < new Date()) {
      await supabase
        .from('convites_pendentes')
        .update({ status: 'expirado' })
        .eq('id', convite.id);
      
      throw new Error('Convite expirado');
    }
    
    // 3. Criar usuário no Supabase Auth
    const { data: authUser, error: authError } = await supabase.auth.signUp({
      email: convite.email,
      password: senha,
      options: {
        data: {
          empresa_id: convite.empresa_id
        }
      }
    });
    
    if (authError) throw authError;
    
    // 4. Vincular à empresa (trigger já cria o usuário na tabela usuarios)
    const { data: usuario } = await supabase
      .from('usuarios')
      .select('*')
      .eq('auth_user_id', authUser.user!.id)
      .single();
    
    await supabase
      .from('usuarios_empresas')
      .insert({
        usuario_id: usuario.id,
        empresa_id: convite.empresa_id,
        papel: convite.papel,
        filiais_acesso: convite.filiais_acesso,
        convite_aceito: true,
        data_aceite: new Date().toISOString()
      });
    
    // 5. Atribuir perfil
    await supabase
      .from('usuarios')
      .update({ perfil_id: convite.perfil_id })
      .eq('id', usuario.id);
    
    // 6. Atualizar convite
    await supabase
      .from('convites_pendentes')
      .update({ 
        status: 'aceito',
        data_aceite: new Date().toISOString()
      })
      .eq('id', convite.id);
    
    // 7. Atualizar contador de uso
    await limitesService.atualizarContadoresMes(convite.empresa_id);
    
    return { usuario, empresa: convite.empresa };
  }

  // Reenviar convite
  async reenviarConvite(conviteId: string) {
    const { data: convite } = await supabase
      .from('convites_pendentes')
      .select('*, empresa:empresas(*)')
      .eq('id', conviteId)
      .single();
    
    // Gerar novo token e estender validade
    const novoToken = generateSecureToken();
    const novaExpiracao = new Date();
    novaExpiracao.setDate(novaExpiracao.getDate() + 7);
    
    await supabase
      .from('convites_pendentes')
      .update({
        token: novoToken,
        data_expiracao: novaExpiracao.toISOString(),
        status: 'pendente'
      })
      .eq('id', conviteId);
    
    // Reenviar email
    await this.enviarEmailConvite({
      email: convite.email,
      empresa: convite.empresa,
      token: novoToken,
      convidadoPor: getCurrentUser().nome
    });
  }

  // Cancelar convite
  async cancelarConvite(conviteId: string) {
    await supabase
      .from('convites_pendentes')
      .update({ status: 'cancelado' })
      .eq('id', conviteId);
  }
}

export const convitesService = new ConvitesService();
```

### Tela de Aceitar Convite

```typescript
// src/pages/AceitarConvite.tsx

const AceitarConvitePage = () => {
  const [token] = useSearchParams();
  const [convite, setConvite] = useState(null);
  const [loading, setLoading] = useState(true);
  
  const form = useForm({
    defaultValues: {
      nome: '',
      senha: '',
      confirmarSenha: ''
    }
  });

  useEffect(() => {
    carregarConvite();
  }, []);

  const carregarConvite = async () => {
    try {
      const { data } = await supabase
        .from('convites_pendentes')
        .select('*, empresa:empresas(*)')
        .eq('token', token.get('token'))
        .eq('status', 'pendente')
        .single();
      
      setConvite(data);
      
      // Pré-preencher email
      form.setValue('email', data.email);
    } catch (error) {
      toast.error('Convite inválido ou expirado');
    } finally {
      setLoading(false);
    }
  };

  const onSubmit = async (data) => {
    try {
      await convitesService.aceitarConvite(token.get('token'), data.senha);
      toast.success('Conta criada com sucesso!');
      navigate('/dashboard');
    } catch (error) {
      toast.error(error.message);
    }
  };

  if (loading) return <LoadingSpinner />;
  
  if (!convite) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Card className="w-full max-w-md">
          <CardHeader>
            <AlertCircle className="h-12 w-12 text-red-500 mb-4" />
            <CardTitle>Convite Inválido</CardTitle>
            <CardDescription>
              Este convite não é válido ou já expirou.
            </CardDescription>
          </CardHeader>
          <CardFooter>
            <Button asChild className="w-full">
              <Link href="/login">Ir para Login</Link>
            </Button>
          </CardFooter>
        </Card>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <div className="flex items-center gap-3 mb-4">
            <Building2 className="h-10 w-10 text-primary" />
            <div>
              <CardTitle>Você foi convidado!</CardTitle>
              <CardDescription>{convite.empresa.nome}</CardDescription>
            </div>
          </div>
          
          {convite.mensagem_personalizada && (
            <Alert>
              <MessageSquare className="h-4 w-4" />
              <AlertDescription>
                {convite.mensagem_personalizada}
              </AlertDescription>
            </Alert>
          )}
        </CardHeader>
        
        <CardContent>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
              <FormField
                name="email"
                label="Email"
                disabled
                value={convite.email}
              />
              
              <FormField
                name="nome"
                label="Seu Nome Completo"
                placeholder="Digite seu nome"
                required
              />
              
              <FormField
                name="senha"
                label="Senha"
                type="password"
                placeholder="Mínimo 6 caracteres"
                required
              />
              
              <FormField
                name="confirmarSenha"
                label="Confirmar Senha"
                type="password"
                placeholder="Digite a senha novamente"
                required
              />
              
              <div className="bg-muted p-4 rounded-lg space-y-2 text-sm">
                <p className="font-medium">Você será adicionado como:</p>
                <div className="flex items-center gap-2">
                  <Badge>{convite.papel}</Badge>
                  {convite.perfil && (
                    <Badge variant="outline">{convite.perfil.nome}</Badge>
                  )}
                </div>
                {convite.filiais_acesso?.length > 0 && (
                  <p className="text-muted-foreground">
                    Acesso a {convite.filiais_acesso.length} filial(is)
                  </p>
                )}
              </div>
              
              <Button type="submit" className="w-full">
                Criar Conta e Aceitar Convite
              </Button>
            </form>
          </Form>
        </CardContent>
        
        <CardFooter className="text-xs text-muted-foreground text-center">
          Ao criar sua conta, você concorda com nossos Termos de Uso e Política de Privacidade
        </CardFooter>
      </Card>
    </div>
  );
};
```

---

**FIM DESTE DOCUMENTO**

Próximos documentos:
1. **Migração de Dados Detalhada**
2. **Plano de Implementação Completo (Step-by-step)**
3. **Testes e QA**
4. **Deploy e Go-Live**

Deseja que eu continue com esses documentos?

