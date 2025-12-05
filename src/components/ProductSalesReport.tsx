import { useState, useEffect } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Package, TrendingUp, DollarSign, Download, Filter, ShoppingCart } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, ResponsiveContainer, Tooltip, Legend, Cell } from "recharts";
import { relatoriosService } from "@/services/supabaseRelatorios";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

function ProductSalesReport() {
  const [selectedPeriod, setSelectedPeriod] = useState<'dia' | 'semana' | 'mes' | 'custom'>('mes');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [produtosData, setProdutosData] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  
  // Estados para período personalizado
  const [dataInicio, setDataInicio] = useState("");
  const [dataFim, setDataFim] = useState("");

  // Carregar dados
  const carregarDados = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Validar datas se for período personalizado
      if (selectedPeriod === 'custom') {
        if (!dataInicio || !dataFim) {
          setError('Por favor, selecione a data de início e fim.');
          setLoading(false);
          return;
        }
        
        if (new Date(dataInicio) > new Date(dataFim)) {
          setError('A data de início não pode ser maior que a data fim.');
          setLoading(false);
          return;
        }
      }
      
      const dados = await relatoriosService.obterRelatorioVendasProdutos(
        selectedPeriod,
        dataInicio,
        dataFim
      );
      setProdutosData(dados);
      
      console.log('📊 Relatório de Produtos - Dados recebidos:', dados);
      
    } catch (err) {
      console.error('Erro ao carregar dados do relatório de produtos:', err);
      setError('Erro ao carregar dados do relatório. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  // Carregar dados quando o componente monta ou o período muda
  useEffect(() => {
    // Se não for período personalizado, carregar automaticamente
    if (selectedPeriod !== 'custom') {
      carregarDados();
    }
  }, [selectedPeriod]);

  // Função para formatar moeda
  const formatarMoeda = (valor: number): string => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(valor);
  };

  // Função para exportar para CSV
  const exportarCSV = () => {
    if (produtosData.length === 0) return;
    
    const headers = ['Nome do Produto', 'Valor Unitário', 'Quantidade Vendida', 'Valor Total'];
    const csvContent = [
      headers.join(','),
      ...produtosFiltrados.map(produto => 
        [
          `"${produto.nome_produto}"`,
          produto.valor_unitario.toFixed(2),
          produto.quantidade_vendida,
          produto.valor_total.toFixed(2)
        ].join(',')
      )
    ].join('\n');
    
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `relatorio-produtos-vendidos-${selectedPeriod}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // Filtrar produtos por busca
  const produtosFiltrados = produtosData.filter(produto =>
    produto.nome_produto.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Calcular totais
  const totalQuantidade = produtosData.reduce((sum, p) => sum + p.quantidade_vendida, 0);
  const totalValor = produtosData.reduce((sum, p) => sum + p.valor_total, 0);
  const ticketMedio = produtosData.length > 0 ? totalValor / totalQuantidade : 0;

  // Função para formatar nome do produto no gráfico
  const formatarNomeGrafico = (nome: string, maxLength: number = 35) => {
    if (nome.length <= maxLength) return nome;
    
    // Tenta quebrar em palavras
    const palavras = nome.split(' ');
    let linhaAtual = '';
    const linhas: string[] = [];
    
    palavras.forEach(palavra => {
      if ((linhaAtual + palavra).length <= maxLength) {
        linhaAtual += (linhaAtual ? ' ' : '') + palavra;
      } else {
        if (linhaAtual) linhas.push(linhaAtual);
        linhaAtual = palavra;
      }
    });
    
    if (linhaAtual) linhas.push(linhaAtual);
    
    // Retorna as primeiras 2 linhas
    return linhas.slice(0, 2).join('\n');
  };

  // Dados para o gráfico (top 10 produtos)
  const dadosGrafico = produtosFiltrados.slice(0, 10).map(produto => ({
    nome: formatarNomeGrafico(produto.nome_produto),
    nomeCompleto: produto.nome_produto, // Para o tooltip
    valor: produto.valor_total,
    quantidade: produto.quantidade_vendida
  }));

  // Cores para o gráfico
  const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6', '#F97316', '#6366F1', '#84CC16'];

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
            <Package className="w-16 h-16 mx-auto mb-2" />
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
      {/* Cabeçalho */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-2">
            <Package className="w-8 h-8" />
            Relatório de Produtos Vendidos
          </h2>
          <p className="text-gray-600">Análise detalhada das vendas por produto</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={exportarCSV} disabled={produtosData.length === 0}>
            <Download className="w-4 h-4 mr-2" />
            Exportar CSV
          </Button>
        </div>
      </div>

      {/* Seletor de Período */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-6">
          <div className="space-y-4">
            <div className="flex flex-wrap gap-2">
              {[
                { label: "Último Dia", value: "dia" as const },
                { label: "Última Semana", value: "semana" as const },
                { label: "Último Mês", value: "mes" as const },
                { label: "Período Personalizado", value: "custom" as const },
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
            
            {/* Campos de Data Personalizada */}
            {selectedPeriod === 'custom' && (
              <div className="flex flex-col sm:flex-row gap-4 items-end p-4 bg-blue-50 rounded-lg border border-blue-200">
                <div className="flex-1">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Data Início
                  </label>
                  <Input
                    type="date"
                    value={dataInicio}
                    onChange={(e) => setDataInicio(e.target.value)}
                    className="w-full"
                  />
                </div>
                <div className="flex-1">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Data Fim
                  </label>
                  <Input
                    type="date"
                    value={dataFim}
                    onChange={(e) => setDataFim(e.target.value)}
                    className="w-full"
                  />
                </div>
                <Button 
                  onClick={carregarDados}
                  disabled={!dataInicio || !dataFim}
                  className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700"
                >
                  Aplicar Filtro
                </Button>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Cards de KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="hover:shadow-lg transition-shadow duration-200 border-0 shadow-md">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 font-medium">Total de Produtos</p>
                <p className="text-2xl font-bold text-gray-800">{produtosData.length}</p>
                <p className="text-xs text-gray-500">Produtos vendidos</p>
              </div>
              <div className="p-3 rounded-full bg-blue-100">
                <Package className="w-6 h-6 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-lg transition-shadow duration-200 border-0 shadow-md">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 font-medium">Quantidade Total</p>
                <p className="text-2xl font-bold text-gray-800">{totalQuantidade}</p>
                <p className="text-xs text-gray-500">Unidades vendidas</p>
              </div>
              <div className="p-3 rounded-full bg-green-100">
                <ShoppingCart className="w-6 h-6 text-green-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-lg transition-shadow duration-200 border-0 shadow-md">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 font-medium">Valor Total</p>
                <p className="text-2xl font-bold text-gray-800">{formatarMoeda(totalValor)}</p>
                <p className="text-xs text-gray-500">Receita total</p>
              </div>
              <div className="p-3 rounded-full bg-purple-100">
                <DollarSign className="w-6 h-6 text-purple-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-lg transition-shadow duration-200 border-0 shadow-md">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 font-medium">Preço Médio</p>
                <p className="text-2xl font-bold text-gray-800">{formatarMoeda(ticketMedio)}</p>
                <p className="text-xs text-gray-500">Por unidade</p>
              </div>
              <div className="p-3 rounded-full bg-orange-100">
                <TrendingUp className="w-6 h-6 text-orange-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Gráfico de Barras - Top 10 Produtos */}
      {dadosGrafico.length > 0 && (
        <Card className="border-0 shadow-md">
          <CardHeader>
            <CardTitle>Top 10 Produtos por Valor Total</CardTitle>
            <CardDescription>Produtos com maior faturamento no período selecionado</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={500}>
              <BarChart data={dadosGrafico} layout="vertical" margin={{ left: 20, right: 20, top: 20, bottom: 20 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" />
                <YAxis 
                  dataKey="nome" 
                  type="category" 
                  width={250}
                  tick={{ fontSize: 12 }}
                  interval={0}
                />
                <Tooltip 
                  content={({ active, payload }) => {
                    if (active && payload && payload.length) {
                      const data = payload[0].payload;
                      return (
                        <div className="bg-white p-4 border border-gray-300 rounded-lg shadow-lg">
                          <p className="font-bold text-gray-800 mb-2">{data.nomeCompleto}</p>
                          <p className="text-sm text-gray-600">
                            <span className="font-medium">Valor Total:</span> {formatarMoeda(data.valor)}
                          </p>
                          <p className="text-sm text-gray-600">
                            <span className="font-medium">Quantidade:</span> {data.quantidade} unidades
                          </p>
                        </div>
                      );
                    }
                    return null;
                  }}
                />
                <Legend />
                <Bar dataKey="valor" name="Valor Total (R$)" fill="#3B82F6" radius={4}>
                  {dadosGrafico.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}

      {/* Tabela de Produtos */}
      <Card className="border-0 shadow-md">
        <CardHeader>
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
              <CardTitle>Lista Completa de Produtos Vendidos</CardTitle>
              <CardDescription>Ordenados do maior para o menor valor total</CardDescription>
            </div>
            <div className="w-full sm:w-64">
              <Input
                placeholder="Buscar produto..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full"
              />
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {produtosFiltrados.length === 0 ? (
            <div className="text-center py-12">
              <Package className="w-16 h-16 mx-auto mb-4 text-gray-400" />
              <p className="text-lg text-gray-600 mb-2">
                {searchTerm ? 'Nenhum produto encontrado' : 'Nenhum produto vendido no período selecionado'}
              </p>
              {searchTerm && (
                <Button variant="outline" onClick={() => setSearchTerm('')}>
                  Limpar Busca
                </Button>
              )}
            </div>
          ) : (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-12">#</TableHead>
                    <TableHead>Nome do Produto</TableHead>
                    <TableHead className="text-right">Valor Unitário</TableHead>
                    <TableHead className="text-right">Quantidade Vendida</TableHead>
                    <TableHead className="text-right">Valor Total</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {produtosFiltrados.map((produto, index) => (
                    <TableRow key={index} className="hover:bg-gray-50">
                      <TableCell className="font-medium text-gray-500">{index + 1}</TableCell>
                      <TableCell className="font-medium">{produto.nome_produto}</TableCell>
                      <TableCell className="text-right">{formatarMoeda(produto.valor_unitario)}</TableCell>
                      <TableCell className="text-right">
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                          {produto.quantidade_vendida} un
                        </span>
                      </TableCell>
                      <TableCell className="text-right font-bold text-green-600">
                        {formatarMoeda(produto.valor_total)}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Rodapé com Totais */}
      {produtosFiltrados.length > 0 && (
        <Card className="border-0 shadow-md bg-gradient-to-r from-blue-50 to-purple-50">
          <CardContent className="p-6">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-center">
              <div>
                <p className="text-sm text-gray-600 font-medium">Total de Produtos Exibidos</p>
                <p className="text-2xl font-bold text-gray-800">{produtosFiltrados.length}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600 font-medium">Quantidade Total Vendida</p>
                <p className="text-2xl font-bold text-gray-800">
                  {produtosFiltrados.reduce((sum, p) => sum + p.quantidade_vendida, 0)} un
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-600 font-medium">Valor Total</p>
                <p className="text-2xl font-bold text-green-600">
                  {formatarMoeda(produtosFiltrados.reduce((sum, p) => sum + p.valor_total, 0))}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

export default ProductSalesReport;

