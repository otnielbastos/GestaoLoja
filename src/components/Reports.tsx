import { useState, useEffect } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { BarChart3, TrendingUp, DollarSign, Calendar, Download, Filter, Package, CheckCircle, Clock, XCircle } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from "recharts";
import { relatoriosService } from "@/services/supabaseRelatorios";

function Reports() {
  const [selectedPeriod, setSelectedPeriod] = useState("7d");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  // Estados para os dados
  const [dashboardData, setDashboardData] = useState<any>(null);
  const [salesData, setSalesData] = useState<any[]>([]);
  const [topProducts, setTopProducts] = useState<any[]>([]);
  const [paymentMethods, setPaymentMethods] = useState<any[]>([]);
  const [neighborhoods, setNeighborhoods] = useState<any[]>([]);
  const [financialData, setFinancialData] = useState<any>(null);

  // Função para carregar todos os dados
  const carregarDados = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Carregar dados em paralelo
      const [
        dashboardResponse,
        vendasResponse,
        produtosResponse,
        pagamentosResponse,
        bairrosResponse,
        financialResponse
      ] = await Promise.all([
        relatoriosService.obterDashboard(selectedPeriod),
        relatoriosService.obterVendasPorDia(),
        relatoriosService.obterTopProdutos(),
        relatoriosService.obterMetodosPagamento(),
        relatoriosService.obterPedidosPorBairro(),
        relatoriosService.obterRelatorioFinanceiro(selectedPeriod)
      ]);
      
      setDashboardData(dashboardResponse);
      setSalesData(vendasResponse);
      setTopProducts(produtosResponse);
      setPaymentMethods(pagamentosResponse);
      setNeighborhoods(bairrosResponse);
      setFinancialData(financialResponse);
      
    } catch (err) {
      console.error('Erro ao carregar dados dos relatórios:', err);
      setError('Erro ao carregar dados dos relatórios. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  // Carregar dados quando o componente monta ou o período muda
  useEffect(() => {
    carregarDados();
  }, [selectedPeriod]);

  // Função para calcular variação percentual
  const calcularVariacao = (atual: number, anterior: number): string => {
    if (anterior === 0) return "+0%";
    const variacao = ((atual - anterior) / anterior) * 100;
    return `${variacao >= 0 ? '+' : ''}${variacao.toFixed(1)}%`;
  };

  // Função para formatar moeda
  const formatarMoeda = (valor: number): string => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(valor);
  };

  if (loading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div className="flex flex-col items-center justify-center h-64 text-center">
          <div className="text-red-500 mb-4">
            <BarChart3 className="w-16 h-16 mx-auto mb-2" />
            <p className="text-lg font-medium">{error}</p>
          </div>
          <Button onClick={carregarDados} className="bg-blue-600 hover:bg-blue-700">
            Tentar Novamente
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-2">
            <BarChart3 className="w-8 h-8" />
            Relatórios
          </h2>
          <p className="text-gray-600">Análise completa do desempenho da loja - Teste</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline">
            <Filter className="w-4 h-4 mr-2" />
            Filtros
          </Button>
          <Button className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white">
            <Download className="w-4 h-4 mr-2" />
            Exportar
          </Button>
        </div>
      </div>

      {/* Period Selector */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-6">
          <div className="flex flex-wrap gap-2">
            {[
              { label: "Últimos 7 dias", value: "7d" },
              { label: "Últimos 30 dias", value: "30d" },
              { label: "Este mês", value: "month" },
              { label: "Personalizado", value: "custom" },
            ].map((period) => (
              <Button
                key={period.value}
                variant={selectedPeriod === period.value ? "default" : "outline"}
                onClick={() => setSelectedPeriod(period.value)}
                className={selectedPeriod === period.value ? "bg-gradient-to-r from-blue-500 to-purple-600" : ""}
              >
                {period.label}
              </Button>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {dashboardData && [
          {
            title: "Receita Total",
            value: formatarMoeda(dashboardData.receita_total),
            change: calcularVariacao(dashboardData.receita_total, dashboardData.receita_anterior),
            changeType: dashboardData.receita_total >= dashboardData.receita_anterior ? "positive" : "negative",
            icon: DollarSign,
            color: "text-green-600",
            bgColor: "bg-green-100",
          },
          {
            title: "Pedidos",
            value: dashboardData.total_pedidos.toString(),
            change: calcularVariacao(dashboardData.total_pedidos, dashboardData.pedidos_anterior),
            changeType: dashboardData.total_pedidos >= dashboardData.pedidos_anterior ? "positive" : "negative",
            icon: BarChart3,
            color: "text-blue-600",
            bgColor: "bg-blue-100",
          },
          {
            title: "Ticket Médio",
            value: formatarMoeda(dashboardData.ticket_medio),
            change: calcularVariacao(dashboardData.ticket_medio, dashboardData.ticket_medio_anterior),
            changeType: dashboardData.ticket_medio >= dashboardData.ticket_medio_anterior ? "positive" : "negative",
            icon: TrendingUp,
            color: "text-purple-600",
            bgColor: "bg-purple-100",
          },
          {
            title: "Taxa Conversão",
            value: `${dashboardData.taxa_conversao.toFixed(1)}%`,
            change: calcularVariacao(dashboardData.taxa_conversao, dashboardData.taxa_conversao_anterior),
            changeType: dashboardData.taxa_conversao >= dashboardData.taxa_conversao_anterior ? "positive" : "negative",
            icon: Calendar,
            color: "text-orange-600",
            bgColor: "bg-orange-100",
          },
        ].map((kpi, index) => (
          <Card key={index} className="hover:shadow-lg transition-shadow duration-200 border-0 shadow-md">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 font-medium">{kpi.title}</p>
                  <p className="text-2xl font-bold text-gray-800">{kpi.value}</p>
                  <p className={`text-xs ${kpi.changeType === 'positive' ? 'text-green-600' : 'text-red-600'}`}>
                    {kpi.change} vs período anterior
                  </p>
                </div>
                <div className={`p-3 rounded-full ${kpi.bgColor}`}>
                  <kpi.icon className={`w-6 h-6 ${kpi.color}`} />
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Relatório Financeiro e de Pedidos */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle>Relatório Financeiro e de Pedidos</CardTitle>
          <CardDescription>Análise completa de valores e quantidades de pedidos no período selecionado</CardDescription>
        </CardHeader>
        <CardContent>
          {financialData && (
            <div className="space-y-6">
              {/* KPIs Financeiros */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="p-4 bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg border border-blue-200">
                  <div className="flex items-center justify-between mb-2">
                    <p className="text-sm font-medium text-blue-700">Valor Total dos Pedidos</p>
                    <DollarSign className="w-5 h-5 text-blue-600" />
                  </div>
                  <p className="text-2xl font-bold text-blue-900">{formatarMoeda(financialData.valor_total_pedidos)}</p>
                  <p className="text-xs text-blue-600 mt-1">Todos os status</p>
                </div>
                
                <div className="p-4 bg-gradient-to-br from-green-50 to-green-100 rounded-lg border border-green-200">
                  <div className="flex items-center justify-between mb-2">
                    <p className="text-sm font-medium text-green-700">Valor Pago</p>
                    <CheckCircle className="w-5 h-5 text-green-600" />
                  </div>
                  <p className="text-2xl font-bold text-green-900">{formatarMoeda(financialData.valor_pago)}</p>
                  <p className="text-xs text-green-600 mt-1">
                    {financialData.percentual_pago?.toFixed(1)}% do total
                  </p>
                </div>
                
                <div className="p-4 bg-gradient-to-br from-orange-50 to-orange-100 rounded-lg border border-orange-200">
                  <div className="flex items-center justify-between mb-2">
                    <p className="text-sm font-medium text-orange-700">Valor Pendente</p>
                    <Clock className="w-5 h-5 text-orange-600" />
                  </div>
                  <p className="text-2xl font-bold text-orange-900">{formatarMoeda(financialData.valor_pendente)}</p>
                  <p className="text-xs text-orange-600 mt-1">
                    {financialData.percentual_pendente?.toFixed(1)}% do total
                  </p>
                </div>
                
                <div className="p-4 bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg border border-purple-200">
                  <div className="flex items-center justify-between mb-2">
                    <p className="text-sm font-medium text-purple-700">Ticket Médio</p>
                    <TrendingUp className="w-5 h-5 text-purple-600" />
                  </div>
                  <p className="text-2xl font-bold text-purple-900">{formatarMoeda(financialData.ticket_medio || 0)}</p>
                  <p className="text-xs text-purple-600 mt-1">Por pedido</p>
                </div>
              </div>

              {/* KPIs de Quantidade */}
              <div className={`grid grid-cols-1 sm:grid-cols-2 ${financialData.quantidade_cancelado && financialData.quantidade_cancelado > 0 ? 'lg:grid-cols-4' : 'lg:grid-cols-3'} gap-4`}>
                <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
                  <div className="flex items-center justify-between mb-2">
                    <p className="text-sm font-medium text-gray-700">Total de Pedidos</p>
                    <Package className="w-5 h-5 text-gray-600" />
                  </div>
                  <p className="text-2xl font-bold text-gray-900">{financialData.quantidade_pedidos}</p>
                  <p className="text-xs text-gray-600 mt-1">Todos os status</p>
                </div>
                
                <div className="p-4 bg-green-50 rounded-lg border border-green-200">
                  <div className="flex items-center justify-between mb-2">
                    <p className="text-sm font-medium text-green-700">Pedidos Entregues</p>
                    <CheckCircle className="w-5 h-5 text-green-600" />
                  </div>
                  <p className="text-2xl font-bold text-green-900">{financialData.quantidade_entregue}</p>
                  <p className="text-xs text-green-600 mt-1">
                    {financialData.quantidade_pedidos > 0 
                      ? ((financialData.quantidade_entregue / financialData.quantidade_pedidos) * 100).toFixed(1)
                      : 0}% do total
                  </p>
                </div>
                
                <div className="p-4 bg-orange-50 rounded-lg border border-orange-200">
                  <div className="flex items-center justify-between mb-2">
                    <p className="text-sm font-medium text-orange-700">Pedidos Pendentes</p>
                    <Clock className="w-5 h-5 text-orange-600" />
                  </div>
                  <p className="text-2xl font-bold text-orange-900">{financialData.quantidade_pendente}</p>
                  <p className="text-xs text-orange-600 mt-1">
                    {financialData.quantidade_pedidos > 0 
                      ? ((financialData.quantidade_pendente / financialData.quantidade_pedidos) * 100).toFixed(1)
                      : 0}% do total
                  </p>
                </div>
                
                {financialData.quantidade_cancelado !== undefined && financialData.quantidade_cancelado !== null && financialData.quantidade_cancelado > 0 && (
                  <div className="p-4 bg-red-50 rounded-lg border border-red-200">
                    <div className="flex items-center justify-between mb-2">
                      <p className="text-sm font-medium text-red-700">Pedidos Cancelados</p>
                      <XCircle className="w-5 h-5 text-red-600" />
                    </div>
                    <p className="text-2xl font-bold text-red-900">{financialData.quantidade_cancelado}</p>
                    <p className="text-xs text-red-600 mt-1">
                      {financialData.quantidade_pedidos > 0 
                        ? ((financialData.quantidade_cancelado / financialData.quantidade_pedidos) * 100).toFixed(1)
                        : 0}% do total
                    </p>
                  </div>
                )}
              </div>

              {/* Gráfico de Barras - Comparação Valores */}
              <div className="mt-6">
                <h3 className="text-lg font-semibold text-gray-800 mb-4">Distribuição de Valores</h3>
                <ResponsiveContainer width="100%" height={200}>
                  <BarChart data={[
                    { name: 'Total', valor: financialData.valor_total_pedidos, fill: '#6366F1' },
                    { name: 'Pago', valor: financialData.valor_pago, fill: '#10B981' },
                    { name: 'Pendente', valor: financialData.valor_pendente, fill: '#F59E0B' }
                  ]}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis />
                    <Bar dataKey="valor" radius={4}>
                      {[
                        { name: 'Total', fill: '#6366F1' },
                        { name: 'Pago', fill: '#10B981' },
                        { name: 'Pendente', fill: '#F59E0B' }
                      ].map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.fill} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Sales Chart */}
        <Card className="border-0 shadow-md">
          <CardHeader>
            <CardTitle>Vendas por Dia</CardTitle>
            <CardDescription>Receita e número de pedidos dos últimos 7 dias</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={salesData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="day" />
                <YAxis />
                <Bar dataKey="vendas" fill="#3B82F6" radius={4} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Payment Methods Chart */}
        <Card className="border-0 shadow-md">
          <CardHeader>
            <CardTitle>Métodos de Pagamento</CardTitle>
            <CardDescription>Distribuição dos métodos de pagamento</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-center">
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={paymentMethods}
                    cx="50%"
                    cy="50%"
                    outerRadius={80}
                    dataKey="value"
                    label={({ name, value }) => `${name}: ${value}%`}
                  >
                    {paymentMethods.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top Products */}
        <Card className="border-0 shadow-md">
          <CardHeader>
            <CardTitle>Produtos Mais Vendidos</CardTitle>
            <CardDescription>Ranking dos produtos por quantidade vendida</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {topProducts.length > 0 ? (
                topProducts.map((product, index) => (
                  <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-bold text-sm">
                        {index + 1}
                      </div>
                      <div>
                        <p className="font-medium text-gray-800">{product.name}</p>
                        <p className="text-sm text-gray-600">{product.sold} unidades</p>
                      </div>
                    </div>
                    <p className="font-bold text-green-600">{product.revenue}</p>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-gray-500">
                  <p>Nenhum produto vendido no período selecionado</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Neighborhoods */}
        <Card className="border-0 shadow-md">
          <CardHeader>
            <CardTitle>Pedidos por Bairro</CardTitle>
            <CardDescription>Distribuição geográfica dos pedidos dos últimos 30 dias</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {neighborhoods.length > 0 ? (
                neighborhoods.map((neighborhood, index) => (
                  <div key={index} className="space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="font-medium text-gray-800">{neighborhood.name}</span>
                      <span className="text-sm text-gray-600">{neighborhood.orders} pedidos</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-gradient-to-r from-blue-500 to-purple-600 h-2 rounded-full transition-all duration-500"
                        style={{ width: `${neighborhood.percentage}%` }}
                      />
                    </div>
                    <p className="text-xs text-gray-500">{neighborhood.percentage}% do total</p>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-gray-500">
                  <p>Nenhum pedido com endereço registrado no período selecionado</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Export Options */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <CardTitle>Exportar Relatórios</CardTitle>
          <CardDescription>Baixe relatórios detalhados em diferentes formatos</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <Button variant="outline" className="justify-start">
              <Download className="w-4 h-4 mr-2" />
              Relatório de Vendas (PDF)
            </Button>
            <Button variant="outline" className="justify-start">
              <Download className="w-4 h-4 mr-2" />
              Dados de Produtos (Excel)
            </Button>
            <Button variant="outline" className="justify-start">
              <Download className="w-4 h-4 mr-2" />
              Relatório Financeiro (PDF)
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

export default Reports;
