import { useState, useEffect } from "react";
import { useAuth } from "@/contexts/AuthContext";
import { clientesService } from "@/services/supabaseClientes";

export interface Customer {
  id: number;
  nome: string;
  email?: string;
  telefone: string;
  cpf_cnpj?: string;
  tipo_pessoa?: 'fisica' | 'juridica';
  endereco_rua?: string;
  endereco_numero?: string;
  endereco_complemento?: string;
  endereco_bairro: string;
  endereco_cidade?: string;
  endereco_estado?: string;
  endereco_cep?: string;
  observacoes?: string;
  status: 'ativo' | 'inativo';
  data_cadastro: string;
  total_pedidos: number;
  ultimo_pedido: string;
  total_gasto: number;
  
  // Campos calculados para compatibilidade com frontend atual
  name: string;
  phone: string;
  address: string;
  neighborhood: string;
  orders: number;
  lastOrder: string;
  totalSpent: number;
  notes?: string;
  customerStatus: "VIP" | "Ativo" | "Novo" | "Inativo";
  criado_por?: number;
}

interface CreateCustomerData {
  nome: string;
  email?: string;
  telefone?: string;
  cpf_cnpj?: string;
  tipo_pessoa: 'fisica' | 'juridica';
  endereco_rua?: string;
  endereco_numero?: string;
  endereco_complemento?: string;
  endereco_bairro?: string;
  endereco_cidade?: string;
  endereco_estado?: string;
  endereco_cep?: string;
  observacoes?: string;
}

interface UpdateCustomerData extends Partial<CreateCustomerData> {}

// Função para mapear dados do backend para o frontend
const mapCustomerFromBackend = (backendCustomer: any): Customer => {
  // Determinar status baseado em dados
  let customerStatus: "VIP" | "Ativo" | "Novo" | "Inativo" = "Ativo";
  
  // Garantir que os valores sejam números válidos
  const totalGasto = parseFloat(backendCustomer.total_gasto) || 0;
  const totalPedidos = parseInt(backendCustomer.total_pedidos) || 0;
  
  if (backendCustomer.status === 'inativo') {
    customerStatus = "Inativo";
  } else if (totalGasto > 500) {
    customerStatus = "VIP";
  } else if (backendCustomer.data_cadastro && new Date(backendCustomer.data_cadastro) > new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)) {
    customerStatus = "Novo";
  }

  const address = [
    backendCustomer.endereco_rua,
    backendCustomer.endereco_numero
  ].filter(Boolean).join(', ');

  // Formatar data do último pedido
  let lastOrderFormatted = '';
  if (backendCustomer.ultimo_pedido && backendCustomer.ultimo_pedido !== '') {
    try {
      lastOrderFormatted = new Date(backendCustomer.ultimo_pedido).toISOString().split('T')[0];
    } catch (e) {
      lastOrderFormatted = '';
    }
  }

  return {
    // Campos do backend
    id: backendCustomer.id,
    nome: backendCustomer.nome || '',
    email: backendCustomer.email || '',
    telefone: backendCustomer.telefone || '',
    cpf_cnpj: backendCustomer.cpf_cnpj || '',
    tipo_pessoa: backendCustomer.tipo_pessoa || 'fisica',
    endereco_rua: backendCustomer.endereco_rua || '',
    endereco_numero: backendCustomer.endereco_numero || '',
    endereco_complemento: backendCustomer.endereco_complemento || '',
    endereco_bairro: backendCustomer.endereco_bairro || '',
    endereco_cidade: backendCustomer.endereco_cidade || '',
    endereco_estado: backendCustomer.endereco_estado || '',
    endereco_cep: backendCustomer.endereco_cep || '',
    observacoes: backendCustomer.observacoes || '',
    status: backendCustomer.status || 'ativo',
    data_cadastro: backendCustomer.data_cadastro || '',
    total_pedidos: totalPedidos,
    ultimo_pedido: backendCustomer.ultimo_pedido || '',
    total_gasto: totalGasto,
    
    // Campos mapeados para compatibilidade
    name: backendCustomer.nome || '',
    phone: backendCustomer.telefone || '',
    address: address,
    neighborhood: backendCustomer.endereco_bairro || '',
    orders: totalPedidos,
    lastOrder: lastOrderFormatted,
    totalSpent: totalGasto,
    notes: backendCustomer.observacoes || '',
    customerStatus,
    criado_por: backendCustomer.criado_por,
  };
};

// Função para mapear dados do frontend para o backend
const mapCustomerToBackend = (customer: Partial<Customer>) => {
  return {
    nome: customer.name || customer.nome,
    email: customer.email,
    telefone: customer.phone || customer.telefone,
    cpf_cnpj: customer.cpf_cnpj,
    tipo_pessoa: customer.tipo_pessoa || 'fisica',
    endereco_rua: customer.endereco_rua,
    endereco_numero: customer.endereco_numero,
    endereco_complemento: customer.endereco_complemento,
    endereco_bairro: customer.neighborhood || customer.endereco_bairro,
    endereco_cidade: customer.endereco_cidade,
    endereco_estado: customer.endereco_estado,
    endereco_cep: customer.endereco_cep,
    observacoes: customer.notes || customer.observacoes
  };
};

export function useCustomers() {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { user, hasRole } = useAuth();

  // Carregar clientes
  const loadCustomers = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // REGRA DE NEGÓCIO: Vendedor só vê clientes criados por ele
      const vendedorId = hasRole('Vendedor') ? user?.id : undefined;
      const response = await clientesService.listar(vendedorId);
      
      if (response.success) {
        const mappedCustomers = response.data.map(mapCustomerFromBackend);
        setCustomers(mappedCustomers);
      } else {
        throw new Error('Erro ao carregar clientes');
      }
    } catch (error: any) {
      console.error('Erro ao carregar clientes:', error);
      setError(error.message || 'Erro ao carregar clientes');
      setCustomers([]);
    } finally {
      setLoading(false);
    }
  };

  // Carregar na inicialização
  useEffect(() => {
    loadCustomers();
  }, [user]);

  // Criar cliente
  const createCustomer = async (customerData: Partial<Customer>): Promise<Customer> => {
    try {
      setError(null);
      
      // Mapear dados do frontend para o formato do backend
      const backendData: CreateCustomerData = {
        nome: customerData.name || customerData.nome || '',
        email: customerData.email || undefined,
        telefone: customerData.phone || customerData.telefone || '',
        cpf_cnpj: customerData.cpf_cnpj || undefined,
        tipo_pessoa: customerData.tipo_pessoa || 'fisica',
        endereco_rua: customerData.endereco_rua || undefined,
        endereco_numero: customerData.endereco_numero || undefined,
        endereco_complemento: customerData.endereco_complemento || undefined,
        endereco_bairro: customerData.neighborhood || customerData.endereco_bairro || undefined,
        endereco_cidade: customerData.endereco_cidade || undefined,
        endereco_estado: customerData.endereco_estado || undefined,
        endereco_cep: customerData.endereco_cep || undefined,
        observacoes: customerData.notes || customerData.observacoes || undefined,
      };
      
      const response = await clientesService.criar(backendData);
      
      if (response.success) {
        await loadCustomers(); // Recarregar lista
        return mapCustomerFromBackend(response.data);
      } else {
        throw new Error('Erro ao criar cliente');
      }
    } catch (error: any) {
      console.error('Erro ao criar cliente:', error);
      const errorMessage = error.message || 'Erro ao criar cliente';
      setError(errorMessage);
      throw new Error(errorMessage);
    }
  };

  // Atualizar cliente - REGRA DE NEGÓCIO: Verificar permissões
  const updateCustomer = async (id: number, updates: UpdateCustomerData): Promise<Customer> => {
    try {
      setError(null);
      
      // Verificar se o vendedor pode editar este cliente
      if (hasRole('Vendedor')) {
        const customer = customers.find(c => c.id === id);
        if (customer && customer.criado_por !== user?.id) {
          throw new Error('Você não tem permissão para editar este cliente');
        }
      }
      
      const response = await clientesService.atualizar(id, updates);
      
      if (response.success) {
        await loadCustomers(); // Recarregar lista
        return mapCustomerFromBackend(response.data);
      } else {
        throw new Error('Erro ao atualizar cliente');
      }
    } catch (error: any) {
      console.error('Erro ao atualizar cliente:', error);
      const errorMessage = error.message || 'Erro ao atualizar cliente';
      setError(errorMessage);
      throw new Error(errorMessage);
    }
  };

  // Deletar cliente - REGRA DE NEGÓCIO: Verificar permissões
  const deleteCustomer = async (id: number): Promise<void> => {
    try {
      setError(null);
      
      // Verificar se o vendedor pode deletar este cliente
      if (hasRole('Vendedor')) {
        const customer = customers.find(c => c.id === id);
        if (customer && customer.criado_por !== user?.id) {
          throw new Error('Você não tem permissão para excluir este cliente');
        }
      }
      
      const response = await clientesService.deletar(id);
      
      if (response.success) {
        await loadCustomers(); // Recarregar lista
      } else {
        throw new Error('Erro ao excluir cliente');
      }
    } catch (error: any) {
      console.error('Erro ao excluir cliente:', error);
      const errorMessage = error.message || 'Erro ao excluir cliente';
      setError(errorMessage);
      throw new Error(errorMessage);
    }
  };

  // Buscar cliente por ID
  const getCustomerById = async (id: number): Promise<Customer> => {
    try {
      setError(null);
      const response = await clientesService.buscarPorId(id);
      
      if (response.success) {
        return mapCustomerFromBackend(response.data);
      } else {
        throw new Error('Cliente não encontrado');
      }
    } catch (error: any) {
      console.error('Erro ao buscar cliente:', error);
      const errorMessage = error.message || 'Erro ao buscar cliente';
      setError(errorMessage);
      throw new Error(errorMessage);
    }
  };

  // Buscar clientes
  const searchCustomers = async (termo: string): Promise<Customer[]> => {
    try {
      setError(null);
      const response = await clientesService.buscar(termo);
      
      if (response.success) {
        return response.data.map(mapCustomerFromBackend);
      } else {
        throw new Error('Erro ao buscar clientes');
      }
    } catch (error: any) {
      console.error('Erro ao buscar clientes:', error);
      const errorMessage = error.message || 'Erro ao buscar clientes';
      setError(errorMessage);
      throw new Error(errorMessage);
    }
  };

  // Atualizar lista
  const refreshCustomers = () => {
    loadCustomers();
  };

  // Alias para compatibilidade com o componente existente
  const addCustomer = createCustomer;
  const getCustomer = getCustomerById;

  // Obter estatísticas dos clientes
  const getStatistics = async () => {
    try {
      const response = await clientesService.estatisticas();
      if (response.success) {
        return response.data;
      } else {
        throw new Error('Erro ao carregar estatísticas');
      }
    } catch (error: any) {
      console.error('Erro ao carregar estatísticas:', error);
      throw new Error(error.message || 'Erro ao carregar estatísticas');
    }
  };

  return {
    customers,
    loading,
    error,
    createCustomer,
    addCustomer, // Alias para compatibilidade
    updateCustomer,
    deleteCustomer,
    getCustomerById,
    getCustomer, // Alias para compatibilidade
    searchCustomers,
    refreshCustomers,
    getStatistics,
    // Estatísticas filtradas por vendedor
    totalCustomers: customers.length,
    activeCustomers: customers.filter(c => c.status === 'ativo').length,
    inactiveCustomers: customers.filter(c => c.status === 'inativo').length,
  };
}
