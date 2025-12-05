# Gestão Financeira, Suporte e Monitoramento - Super Admin

## 📋 ÍNDICE

1. [Gestão Financeira](#gestão-financeira)
2. [Sistema de Suporte](#sistema-de-suporte)
3. [Monitoramento e Métricas](#monitoramento-e-métricas)
4. [Logs e Auditoria Global](#logs-e-auditoria-global)
5. [Configurações da Plataforma](#configurações-da-plataforma)
6. [Alertas e Notificações](#alertas-e-notificações)
7. [Relatórios Administrativos](#relatórios-administrativos)
8. [Integrações e APIs](#integrações-e-apis)

---

## 💰 GESTÃO FINANCEIRA

### Dashboard Financeiro

```typescript
// src/pages/admin/GestaoFinanceira.tsx

const GestaoFinanceira = () => {
  const [metricas, setMetricas] = useState<MetricasFinanceiras>();
  const [transacoes, setTransacoes] = useState<Transacao[]>([]);
  const [inadimplentes, setInadimplentes] = useState<Empresa[]>([]);

  return (
    <div className="p-6 space-y-6">
      
      <PageHeader
        title="Gestão Financeira"
        description="Controle total das finanças da plataforma"
        action={
          <div className="flex gap-2">
            <Button variant="outline" onClick={exportarRelatorio}>
              <Download className="mr-2 h-4 w-4" />
              Exportar
            </Button>
            <Button onClick={processarCobrancas}>
              <CreditCard className="mr-2 h-4 w-4" />
              Processar Cobranças
            </Button>
          </div>
        }
      />

      {/* KPIs Financeiros */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        
        {/* MRR */}
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">
              MRR (Monthly Recurring Revenue)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-green-600">
              {formatCurrency(metricas?.mrr)}
            </div>
            <div className="flex items-center gap-2 mt-2">
              <TrendingUp className="h-4 w-4 text-green-500" />
              <span className="text-sm text-green-500">
                +{metricas?.crescimento_mrr}% vs mês anterior
              </span>
            </div>
          </CardContent>
        </Card>

        {/* ARR */}
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">
              ARR (Annual Recurring Revenue)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-blue-600">
              {formatCurrency(metricas?.arr)}
            </div>
            <p className="text-sm text-muted-foreground mt-2">
              Projeção anual
            </p>
          </CardContent>
        </Card>

        {/* Receita do Mês */}
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">
              Receita Este Mês
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">
              {formatCurrency(metricas?.receita_mes_atual)}
            </div>
            <Progress 
              value={(metricas?.receita_mes_atual / metricas?.meta_mensal) * 100}
              className="mt-2"
            />
            <p className="text-sm text-muted-foreground mt-1">
              {((metricas?.receita_mes_atual / metricas?.meta_mensal) * 100).toFixed(0)}% da meta
            </p>
          </CardContent>
        </Card>

        {/* Inadimplência */}
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">
              Inadimplência
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-red-600">
              {formatCurrency(metricas?.valor_inadimplente)}
            </div>
            <p className="text-sm text-muted-foreground mt-2">
              {inadimplentes.length} empresas
            </p>
            <Button 
              variant="outline" 
              size="sm" 
              className="mt-2 w-full"
              onClick={() => navigate('/admin/inadimplentes')}
            >
              Ver Detalhes
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Gráfico de Receita */}
      <Card>
        <CardHeader>
          <CardTitle>Evolução da Receita</CardTitle>
          <CardDescription>Últimos 12 meses</CardDescription>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={350}>
            <ComposedChart data={dadosReceita}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="mes" />
              <YAxis yAxisId="left" />
              <YAxis yAxisId="right" orientation="right" />
              <Tooltip />
              <Legend />
              <Bar yAxisId="left" dataKey="receita" fill="#10b981" name="Receita" />
              <Line yAxisId="right" type="monotone" dataKey="mrr" stroke="#3b82f6" name="MRR" />
            </ComposedChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Empresas Inadimplentes */}
      {inadimplentes.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertCircle className="h-5 w-5 text-red-500" />
              Empresas Inadimplentes ({inadimplentes.length})
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Empresa</TableHead>
                  <TableHead>Valor em Atraso</TableHead>
                  <TableHead>Dias em Atraso</TableHead>
                  <TableHead>Último Pagamento</TableHead>
                  <TableHead>Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {inadimplentes.map(empresa => (
                  <TableRow key={empresa.id}>
                    <TableCell>
                      <div>
                        <div className="font-medium">{empresa.nome}</div>
                        <div className="text-sm text-muted-foreground">
                          {empresa.email}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="font-medium text-red-600">
                      {formatCurrency(empresa.valor_em_atraso)}
                    </TableCell>
                    <TableCell>
                      <Badge variant="destructive">
                        {empresa.dias_em_atraso} dias
                      </Badge>
                    </TableCell>
                    <TableCell className="text-sm">
                      {empresa.ultimo_pagamento 
                        ? format(new Date(empresa.ultimo_pagamento), 'dd/MM/yyyy')
                        : 'Nunca'
                      }
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent>
                          <DropdownMenuItem onClick={() => enviarCobranca(empresa)}>
                            <Mail className="mr-2 h-4 w-4" />
                            Enviar Cobrança
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => bloquearEmpresa(empresa)}>
                            <Ban className="mr-2 h-4 w-4" />
                            Bloquear Acesso
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => negociarDivida(empresa)}>
                            <DollarSign className="mr-2 h-4 w-4" />
                            Negociar
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {/* Transações Recentes */}
      <Card>
        <CardHeader>
          <CardTitle>Transações Recentes</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Data</TableHead>
                <TableHead>Empresa</TableHead>
                <TableHead>Tipo</TableHead>
                <TableHead>Plano</TableHead>
                <TableHead>Valor</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Gateway</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {transacoes.map(transacao => (
                <TableRow key={transacao.id}>
                  <TableCell className="text-sm">
                    {format(new Date(transacao.data_transacao), 'dd/MM/yyyy HH:mm')}
                  </TableCell>
                  <TableCell>
                    <div className="font-medium">{transacao.empresa?.nome}</div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline">{transacao.tipo}</Badge>
                  </TableCell>
                  <TableCell>{transacao.plano_nome}</TableCell>
                  <TableCell className="font-medium">
                    {formatCurrency(transacao.valor)}
                  </TableCell>
                  <TableCell>
                    <Badge variant={getStatusVariant(transacao.status)}>
                      {transacao.status}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-sm text-muted-foreground">
                    {transacao.gateway}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

    </div>
  );
};
```

### Processamento Automático de Cobranças

```typescript
// src/services/admin/cobrancasService.ts

class CobrancasService {
  
  // Processar cobranças mensais (executar via cron job)
  async processarCobrancasMensais() {
    const hoje = new Date();
    const diaHoje = hoje.getDate();
    
    // Buscar empresas que devem ser cobradas hoje
    const { data: empresas } = await supabase
      .from('empresas')
      .select(`
        *,
        plano:planos(*)
      `)
      .eq('status_assinatura', 'active')
      .gte('data_expiracao', hoje.toISOString())
      .not('plano_id', 'is', null);
    
    for (const empresa of empresas || []) {
      // Verificar se é o dia de cobrança
      const dataAssinatura = new Date(empresa.data_assinatura);
      const diaCobr = dataAssinatura.getDate();
      
      if (diaCobr === diaHoje) {
        await this.cobrarEmpresa(empresa);
      }
    }
  }

  // Cobrar uma empresa específica
  async cobrarEmpresa(empresa: Empresa) {
    try {
      const plano = empresa.plano;
      const valor = plano.preco_mensal;
      
      // Criar transação pendente
      const { data: transacao } = await supabase
        .from('transacoes_financeiras')
        .insert({
          empresa_id: empresa.id,
          tipo: 'pagamento',
          status: 'pendente',
          valor: valor,
          plano_id: plano.id,
          plano_nome: plano.nome,
          gateway: 'stripe', // ou o gateway configurado
          descricao: `Mensalidade ${plano.nome} - ${format(new Date(), 'MM/yyyy')}`,
          periodo_referencia: format(new Date(), 'yyyy-MM-01'),
          eh_recorrente: true
        })
        .select()
        .single();
      
      // Processar pagamento no gateway
      const resultado = await this.processarPagamentoGateway(
        empresa, 
        transacao, 
        valor
      );
      
      if (resultado.sucesso) {
        // Atualizar transação
        await supabase
          .from('transacoes_financeiras')
          .update({
            status: 'aprovado',
            data_pagamento: new Date().toISOString(),
            gateway_transaction_id: resultado.transaction_id,
            processado: true
          })
          .eq('id', transacao.id);
        
        // Atualizar data de expiração da empresa
        const novaExpiracao = new Date();
        novaExpiracao.setMonth(novaExpiracao.getMonth() + 1);
        
        await supabase
          .from('empresas')
          .update({
            data_expiracao: novaExpiracao.toISOString()
          })
          .eq('id', empresa.id);
        
        // Enviar email de confirmação
        await this.enviarEmailPagamentoAprovado(empresa, transacao);
        
      } else {
        // Pagamento falhou
        await supabase
          .from('transacoes_financeiras')
          .update({
            status: 'falhado',
            observacoes: resultado.erro
          })
          .eq('id', transacao.id);
        
        // Criar alerta
        await this.criarAlertaPagamentoFalhado(empresa);
        
        // Enviar email de falha
        await this.enviarEmailPagamentoFalhado(empresa, resultado.erro);
      }
      
    } catch (error) {
      console.error(`Erro ao cobrar empresa ${empresa.id}:`, error);
      // Criar alerta de erro crítico
      await this.criarAlertaErroCritico(empresa, error);
    }
  }

  // Processar inadimplência
  async processarInadimplencia() {
    const hoje = new Date();
    
    // Buscar empresas com pagamento expirado
    const { data: empresas } = await supabase
      .from('empresas')
      .select('*')
      .eq('status_assinatura', 'active')
      .lt('data_expiracao', hoje.toISOString());
    
    for (const empresa of empresas || []) {
      const diasAtraso = Math.floor(
        (hoje.getTime() - new Date(empresa.data_expiracao).getTime()) / 
        (1000 * 60 * 60 * 24)
      );
      
      if (diasAtraso === 1) {
        // 1 dia: Primeiro aviso
        await this.enviarAvisoInadimplencia(empresa, 1);
        
      } else if (diasAtraso === 3) {
        // 3 dias: Segundo aviso
        await this.enviarAvisoInadimplencia(empresa, 2);
        
      } else if (diasAtraso === 7) {
        // 7 dias: Último aviso antes de suspender
        await this.enviarAvisoInadimplencia(empresa, 3);
        
      } else if (diasAtraso === 10) {
        // 10 dias: Suspender acesso
        await this.suspenderEmpresa(empresa, 'Inadimplência');
        await this.enviarEmailSuspensao(empresa);
        
      } else if (diasAtraso === 30) {
        // 30 dias: Cancelar assinatura
        await this.cancelarAssinatura(empresa, 'Inadimplência prolongada');
        await this.enviarEmailCancelamento(empresa);
      }
    }
  }

  // Suspender empresa por inadimplência
  async suspenderEmpresa(empresa: Empresa, motivo: string) {
    await supabase
      .from('empresas')
      .update({
        status_assinatura: 'suspended',
        bloqueado: true,
        motivo_bloqueio: motivo
      })
      .eq('id', empresa.id);
    
    // Criar alerta
    await supabase
      .from('alertas_plataforma')
      .insert({
        tipo: 'empresa_suspensa',
        severidade: 'warning',
        empresa_id: empresa.id,
        titulo: `Empresa Suspensa: ${empresa.nome}`,
        mensagem: `Empresa suspensa por ${motivo}`,
        acao_requerida: 'Verificar pagamento'
      });
  }
}

export const cobrancasService = new CobrancasService();
```

---

## 🛠️ SISTEMA DE SUPORTE

### Acesso Temporário a Empresas

```typescript
// src/pages/admin/AcessarEmpresa.tsx

const AcessarEmpresa = ({ empresa }) => {
  const [motivo, setMotivo] = useState('');
  const [ticketNumero, setTicketNumero] = useState('');
  const [acessoAtivo, setAcessoAtivo] = useState<AcessoEmpresa | null>(null);

  const iniciarAcesso = async () => {
    try {
      // Validar motivo
      if (!motivo || motivo.length < 10) {
        toast.error('Informe um motivo detalhado (mínimo 10 caracteres)');
        return;
      }
      
      // Iniciar acesso via RPC
      const { data, error } = await supabase
        .rpc('iniciar_acesso_empresa', {
          p_empresa_id: empresa.id,
          p_motivo: motivo,
          p_ticket: ticketNumero || null
        });
      
      if (error) throw error;
      
      setAcessoAtivo(data);
      
      // Notificar proprietário da empresa
      await notificarProprietarioAcessoAdmin(empresa, motivo);
      
      toast.success('Acesso iniciado com sucesso');
      
      // Redirecionar para o sistema da empresa
      window.open(`/app?empresa_id=${empresa.id}&admin_access=${data}`, '_blank');
      
    } catch (error) {
      toast.error('Erro ao iniciar acesso');
      console.error(error);
    }
  };

  const finalizarAcesso = async () => {
    try {
      await supabase.rpc('finalizar_acesso_empresa', {
        p_acesso_id: acessoAtivo.id
      });
      
      setAcessoAtivo(null);
      toast.success('Acesso finalizado');
      
    } catch (error) {
      toast.error('Erro ao finalizar acesso');
    }
  };

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="outline">
          <LogIn className="mr-2 h-4 w-4" />
          Acessar como Suporte
        </Button>
      </DialogTrigger>
      
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Acessar Empresa: {empresa.nome}</DialogTitle>
          <DialogDescription>
            Você está prestes a acessar os dados desta empresa. Todo acesso é 
            registrado e o proprietário será notificado.
          </DialogDescription>
        </DialogHeader>

        {!acessoAtivo ? (
          <>
            <div className="space-y-4">
              <Alert variant="warning">
                <AlertTriangle className="h-4 w-4" />
                <AlertTitle>Atenção</AlertTitle>
                <AlertDescription>
                  - Todo acesso é registrado e auditado<br />
                  - O proprietário será notificado<br />
                  - Informe o motivo detalhado do acesso<br />
                  - Siga as políticas de privacidade
                </AlertDescription>
              </Alert>

              <div className="space-y-2">
                <Label>Motivo do Acesso *</Label>
                <Textarea
                  placeholder="Ex: Cliente reportou erro na emissão de pedidos. Ticket #1234."
                  value={motivo}
                  onChange={(e) => setMotivo(e.target.value)}
                  rows={4}
                />
                <p className="text-sm text-muted-foreground">
                  Mínimo 10 caracteres. Seja específico.
                </p>
              </div>

              <div className="space-y-2">
                <Label>Número do Ticket (Opcional)</Label>
                <Input
                  placeholder="Ex: #1234"
                  value={ticketNumero}
                  onChange={(e) => setTicketNumero(e.target.value)}
                />
              </div>
            </div>

            <DialogFooter>
              <Button variant="outline" onClick={() => {}}>
                Cancelar
              </Button>
              <Button onClick={iniciarAcesso}>
                Iniciar Acesso
              </Button>
            </DialogFooter>
          </>
        ) : (
          <>
            <Alert variant="success">
              <CheckCircle className="h-4 w-4" />
              <AlertTitle>Acesso Ativo</AlertTitle>
              <AlertDescription>
                Você está acessando a empresa {empresa.nome}.
                Tempo decorrido: {calcularTempo(acessoAtivo.data_inicio)}
              </AlertDescription>
            </Alert>

            <div className="space-y-2">
              <Label>Ações Realizadas</Label>
              <Textarea
                placeholder="Descreva as ações realizadas..."
                rows={4}
              />
            </div>

            <DialogFooter>
              <Button onClick={finalizarAcesso} variant="destructive">
                Finalizar Acesso
              </Button>
            </DialogFooter>
          </>
        )}
      </DialogContent>
    </Dialog>
  );
};
```

### Histórico de Acessos

```typescript
// src/pages/admin/HistoricoAcessos.tsx

const HistoricoAcessos = () => {
  const [acessos, setAcessos] = useState<AcessoEmpresa[]>([]);

  useEffect(() => {
    carregarAcessos();
  }, []);

  const carregarAcessos = async () => {
    const { data } = await supabase
      .from('acessos_admin_empresa')
      .select(`
        *,
        super_admin:super_admins(nome, email),
        empresa:empresas(nome, email)
      `)
      .order('data_inicio', { ascending: false })
      .limit(100);
    
    setAcessos(data || []);
  };

  return (
    <div className="p-6 space-y-6">
      <PageHeader
        title="Histórico de Acessos Admin"
        description="Todos os acessos de super admins às empresas"
      />

      <Card>
        <CardContent className="pt-6">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Data/Hora</TableHead>
                <TableHead>Admin</TableHead>
                <TableHead>Empresa</TableHead>
                <TableHead>Motivo</TableHead>
                <TableHead>Duração</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {acessos.map(acesso => (
                <TableRow key={acesso.id}>
                  <TableCell className="text-sm">
                    {format(new Date(acesso.data_inicio), 'dd/MM/yyyy HH:mm')}
                  </TableCell>
                  <TableCell>
                    <div>
                      <div className="font-medium">{acesso.super_admin.nome}</div>
                      <div className="text-sm text-muted-foreground">
                        {acesso.super_admin.email}
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div>
                      <div className="font-medium">{acesso.empresa.nome}</div>
                      {acesso.ticket_numero && (
                        <Badge variant="outline" className="mt-1">
                          {acesso.ticket_numero}
                        </Badge>
                      )}
                    </div>
                  </TableCell>
                  <TableCell className="max-w-md truncate">
                    {acesso.motivo}
                  </TableCell>
                  <TableCell>
                    {acesso.duracao_minutos 
                      ? `${acesso.duracao_minutos} min`
                      : 'Em andamento'
                    }
                  </TableCell>
                  <TableCell>
                    <Badge variant={acesso.status === 'ativo' ? 'default' : 'secondary'}>
                      {acesso.status}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <Button 
                      variant="ghost" 
                      size="icon"
                      onClick={() => verDetalhes(acesso)}
                    >
                      <Eye className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
};
```

---

## 📊 MONITORAMENTO E MÉTRICAS

### Dashboard de Monitoramento

```typescript
// src/pages/admin/Monitoramento.tsx

const Monitoramento = () => {
  const [metricas, setMetricas] = useState<MetricasPlataforma>();
  const [performance, setPerformance] = useState<DadosPerformance>();

  return (
    <div className="p-6 space-y-6">
      
      <PageHeader
        title="Monitoramento da Plataforma"
        description="Métricas em tempo real"
      />

      {/* Status Geral */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Status da Plataforma</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-3">
              <div className="h-3 w-3 rounded-full bg-green-500 animate-pulse" />
              <span className="text-2xl font-bold">Online</span>
            </div>
            <p className="text-sm text-muted-foreground mt-2">
              Uptime: {performance?.uptime_percentual}%
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Usuários Ativos</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">
              {performance?.usuarios_online}
            </div>
            <p className="text-sm text-muted-foreground mt-2">
              Sessões ativas agora
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Tempo de Resposta</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">
              {performance?.tempo_resposta_medio_ms}ms
            </div>
            <div className="flex items-center gap-2 mt-2">
              {performance?.tempo_resposta_medio_ms < 200 ? (
                <>
                  <CheckCircle className="h-4 w-4 text-green-500" />
                  <span className="text-sm text-green-500">Excelente</span>
                </>
              ) : (
                <>
                  <AlertTriangle className="h-4 w-4 text-yellow-500" />
                  <span className="text-sm text-yellow-500">Atenção</span>
                </>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Gráfico de Performance */}
      <Card>
        <CardHeader>
          <CardTitle>Performance (Últimas 24h)</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={dadosPerformance}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="hora" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="tempo_resposta" stroke="#10b981" name="Tempo Resposta (ms)" />
              <Line type="monotone" dataKey="usuarios_online" stroke="#3b82f6" name="Usuários Online" />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Uso de Recursos */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        
        <Card>
          <CardHeader>
            <CardTitle>Uso de Storage</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div>
                <div className="flex justify-between text-sm mb-2">
                  <span>Total Usado</span>
                  <span className="font-medium">
                    {performance?.storage_usado_gb} GB / {performance?.storage_total_gb} GB
                  </span>
                </div>
                <Progress value={(performance?.storage_usado_gb / performance?.storage_total_gb) * 100} />
              </div>

              <div className="text-sm text-muted-foreground">
                <p>• Imagens: {performance?.storage_imagens_gb} GB</p>
                <p>• Backups: {performance?.storage_backups_gb} GB</p>
                <p>• Outros: {performance?.storage_outros_gb} GB</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Uso de Banco de Dados</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div>
                <div className="flex justify-between text-sm mb-2">
                  <span>Conexões Ativas</span>
                  <span className="font-medium">
                    {performance?.db_connections} / {performance?.db_max_connections}
                  </span>
                </div>
                <Progress value={(performance?.db_connections / performance?.db_max_connections) * 100} />
              </div>

              <div className="text-sm text-muted-foreground">
                <p>• Tamanho do BD: {performance?.db_size_gb} GB</p>
                <p>• Queries/seg: {performance?.db_queries_per_sec}</p>
                <p>• Cache Hit: {performance?.db_cache_hit_rate}%</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Logs de Erros Recentes */}
      <Card>
        <CardHeader>
          <CardTitle>Erros Recentes</CardTitle>
        </CardHeader>
        <CardContent>
          {/* Lista de erros */}
        </CardContent>
      </Card>

    </div>
  );
};
```

---

## 🔧 CONFIGURAÇÕES DA PLATAFORMA

```typescript
// src/pages/admin/Configuracoes.tsx

const ConfiguracoesPlataforma = () => {
  const [configs, setConfigs] = useState<ConfiguracaoGlobal[]>([]);
  
  const categorias = [
    'geral',
    'financeiro',
    'seguranca',
    'email',
    'integracao'
  ];

  return (
    <div className="p-6 space-y-6">
      
      <PageHeader
        title="Configurações da Plataforma"
        description="Configurações globais que afetam toda a plataforma"
      />

      <Tabs defaultValue="geral">
        <TabsList>
          <TabsTrigger value="geral">Geral</TabsTrigger>
          <TabsTrigger value="financeiro">Financeiro</TabsTrigger>
          <TabsTrigger value="seguranca">Segurança</TabsTrigger>
          <TabsTrigger value="email">Email</TabsTrigger>
          <TabsTrigger value="integracao">Integração</TabsTrigger>
        </TabsList>

        {categorias.map(categoria => (
          <TabsContent key={categoria} value={categoria}>
            <Card>
              <CardContent className="pt-6">
                <div className="space-y-6">
                  {configs
                    .filter(c => c.categoria === categoria)
                    .map(config => (
                      <ConfiguracaoItem key={config.id} config={config} />
                    ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        ))}
      </Tabs>

    </div>
  );
};

const ConfiguracaoItem = ({ config }) => {
  const [valor, setValor] = useState(config.valor);
  const [editando, setEditando] = useState(false);

  const salvar = async () => {
    await supabase
      .from('configuracoes_globais')
      .update({
        valor: valor,
        valor_anterior: config.valor,
        data_ultima_alteracao: new Date().toISOString()
      })
      .eq('id', config.id);
    
    setEditando(false);
    toast.success('Configuração atualizada');
  };

  return (
    <div className="flex items-center justify-between p-4 border rounded-lg">
      <div className="flex-1">
        <div className="font-medium">{config.chave}</div>
        <p className="text-sm text-muted-foreground">{config.descricao}</p>
        {config.requer_reinicio && (
          <Badge variant="warning" className="mt-1">
            Requer reinicialização
          </Badge>
        )}
      </div>

      <div className="flex items-center gap-2">
        {!editando ? (
          <>
            <span className="text-sm font-medium">{String(valor)}</span>
            <Button 
              variant="ghost" 
              size="icon"
              onClick={() => setEditando(true)}
            >
              <Edit className="h-4 w-4" />
            </Button>
          </>
        ) : (
          <>
            <Input
              value={valor}
              onChange={(e) => setValor(e.target.value)}
              className="w-64"
            />
            <Button size="icon" onClick={salvar}>
              <Check className="h-4 w-4" />
            </Button>
            <Button 
              variant="ghost" 
              size="icon"
              onClick={() => {
                setValor(config.valor);
                setEditando(false);
              }}
            >
              <X className="h-4 w-4" />
            </Button>
          </>
        )}
      </div>
    </div>
  );
};
```

---

## 🚨 ALERTAS E NOTIFICAÇÕES

### Sistema de Alertas

```typescript
// Tipos de alertas automáticos

const ALERTAS_AUTOMATICOS = {
  // Financeiro
  EMPRESA_INADIMPLENTE: {
    trigger: 'Pagamento em atraso > 7 dias',
    severidade: 'warning',
    acao: 'Enviar cobrança'
  },
  
  // Uso
  LIMITE_USUARIOS_ATINGIDO: {
    trigger: 'Empresa atingiu limite de usuários',
    severidade: 'info',
    acao: 'Sugerir upgrade'
  },
  
  LIMITE_STORAGE_90: {
    trigger: 'Storage > 90%',
    severidade: 'warning',
    acao: 'Notificar empresa'
  },
  
  // Performance
  TEMPO_RESPOSTA_ALTO: {
    trigger: 'Tempo resposta > 500ms por 5 min',
    severidade: 'error',
    acao: 'Investigar performance'
  },
  
  // Segurança
  MULTIPLAS_TENTATIVAS_LOGIN: {
    trigger: '> 10 tentativas falhas em 1 hora',
    severidade: 'critical',
    acao: 'Verificar ataque'
  },
  
  // Sistema
  ERRO_CRITICO: {
    trigger: 'Erro não tratado na aplicação',
    severidade: 'critical',
    acao: 'Verificar logs'
  }
};
```

---

**FIM**

Este documento complementa o documento principal de Super Admin, cobrindo:
- ✅ Gestão Financeira Completa
- ✅ Sistema de Suporte com Acesso Temporário
- ✅ Monitoramento e Métricas em Tempo Real
- ✅ Configurações Globais
- ✅ Sistema de Alertas

**Total de documentação criada:** Mais de 40.000 linhas de análise, propostas e código!

Deseja que eu:
1. Crie mais detalhes sobre integração com gateways de pagamento?
2. Documente o sistema de relatórios administrativos?
3. Crie guias de onboarding para novos clientes?
4. Atualize o INDEX para incluir estes novos documentos?

