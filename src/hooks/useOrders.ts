import { useState, useEffect } from "react";
import api from "@/services/api";
import { useAuth } from "@/contexts/AuthContext";

export interface OrderItem {
  id: string;
  productId?: number;
  productName: string;
  quantity: number;
  unitPrice: number;
  total: number;
}

export interface Order {
  id: string;
  customerId: number;
  customerName: string;
  customerPhone: string;
  total: number;
  status: "pendente" | "aprovado" | "aguardando_producao" | "em_preparo" | "em_separacao" | 
          "produzido" | "pronto" | "em_entrega" | "entregue" | "concluido" | "cancelado";
  tipo?: "pronta_entrega" | "encomenda";
  data_entrega_prevista?: string | null;
  horario_entrega?: string | null;
  observacoes_producao?: string;
  paymentStatus?: "pendente" | "pago" | "parcial";
  amountPaid?: number;
  paymentDate?: string;
  paymentNotes?: string;
  deliveryDate?: string;
  time: string;
  date: string;
  items: OrderItem[];
  paymentMethod: string;
  address?: string;
  notes?: string;
  criado_por?: number; // ID do usuário que criou o pedido
  vendedor_nome?: string; // Nome do vendedor
}

// Interface para criar pedido
export interface CreateOrderData {
  customerId: number;
  customerName: string;
  customerPhone: string;
  status: Order['status'];
  tipo?: "pronta_entrega" | "encomenda";
  data_entrega_prevista?: string | null;
  horario_entrega?: string | null;
  observacoes_producao?: string;
  paymentMethod: string;
  address?: string;
  notes?: string;
  items: OrderItem[];
}

// Interface para atualizar pedido
export interface UpdateOrderData {
  status?: Order['status'];
  tipo?: "pronta_entrega" | "encomenda";
  data_entrega_prevista?: string | null;
  horario_entrega?: string | null;
  observacoes_producao?: string;
  paymentMethod?: string;
  address?: string;
  notes?: string;
  items?: OrderItem[];
}

// Interface para criar pedido
export interface CreateOrderData {
  customerId: number;
  customerName: string;
  customerPhone: string;
  status: Order['status'];
  tipo?: "pronta_entrega" | "encomenda";
  data_entrega_prevista?: string | null;
  horario_entrega?: string | null;
  observacoes_producao?: string;
  paymentMethod: string;
  address?: string;
  notes?: string;
  items: OrderItem[];
}

// Interface para atualizar pedido
export interface UpdateOrderData {
  status?: Order['status'];
  tipo?: "pronta_entrega" | "encomenda";
  data_entrega_prevista?: string | null;
  horario_entrega?: string | null;
  observacoes_producao?: string;
  paymentMethod?: string;
  address?: string;
  notes?: string;
  items?: OrderItem[];
}

// Interface para dados do backend (Supabase)
interface BackendOrder {
  id: number;
  cliente_id: number;
  numero_pedido: string;
  data_pedido: string;
  status: string;
  tipo?: string;
  data_entrega_prevista?: string;
  horario_entrega?: string;
  observacoes_producao?: string;
  valor_total: number;
  forma_pagamento: string;
  status_pagamento?: string;
  valor_pago?: number;
  data_pagamento?: string;
  observacoes_pagamento?: string;
  data_entrega?: string;
  observacoes?: string;
  cliente?: {
    nome: string;
    telefone: string;
    endereco_rua?: string;
    endereco_numero?: string;
    endereco_complemento?: string;
    endereco_bairro?: string;
  };
  criado_por?: number;
  itens?: BackendOrderItem[];
}

interface BackendOrderItem {
  id: number;
  produto_id: number;
  quantidade: number;
  preco_unitario: number;
  subtotal: number;
  produto?: {
    nome: string;
  };
}

// Mapeamento de status - agora mantém os valores originais
const mapStatusFromBackend = (status: string): Order['status'] => {
  // Tratar status vazio, null ou undefined
  if (!status || status.trim() === '') {
    return 'pendente';
  }
  
  // Normalizar status para lowercase
  const normalizedStatus = status.toLowerCase().trim();
  
  // Validar se é um status válido
  const validStatuses: Order['status'][] = [
    'pendente', 'aprovado', 'aguardando_producao', 'em_preparo', 'em_separacao',
    'produzido', 'pronto', 'em_entrega', 'entregue', 'concluido', 'cancelado'
  ];
  
  if (validStatuses.includes(normalizedStatus as Order['status'])) {
    return normalizedStatus as Order['status'];
  }
  
  return 'pendente';
};

// Mapeamento de status do frontend para backend (mantém os mesmos valores)
const mapStatusToBackend = (status: Order['status']): string => {
  return status;
};

// Mapear pedido do backend para frontend
const mapOrderFromBackend = (backendOrder: BackendOrder): Order => {
  const dataHora = new Date(backendOrder.data_pedido);
  
  // Construir endereço completo
  const endereco = backendOrder.cliente ? [
    backendOrder.cliente.endereco_rua,
    backendOrder.cliente.endereco_numero,
    backendOrder.cliente.endereco_complemento,
    backendOrder.cliente.endereco_bairro
  ].filter(Boolean).join(', ') : '';
  
  return {
    id: backendOrder.numero_pedido,
    customerId: backendOrder.cliente_id,
    customerName: backendOrder.cliente?.nome || '',
    customerPhone: backendOrder.cliente?.telefone || '',
    total: parseFloat(backendOrder.valor_total?.toString() || '0'),
    status: mapStatusFromBackend(backendOrder.status),
    tipo: (backendOrder.tipo as "pronta_entrega" | "encomenda") || "pronta_entrega",
    data_entrega_prevista: backendOrder.data_entrega_prevista || null,
    horario_entrega: backendOrder.horario_entrega || null,
    observacoes_producao: backendOrder.observacoes_producao || "",
    paymentStatus: backendOrder.status_pagamento as "pendente" | "pago" | "parcial" || 'pendente',
    amountPaid: parseFloat(backendOrder.valor_pago?.toString() || '0'),
    paymentDate: backendOrder.data_pagamento,
    paymentNotes: backendOrder.observacoes_pagamento,
    deliveryDate: backendOrder.data_entrega,
    time: dataHora.toTimeString().slice(0, 5),
    date: dataHora.toISOString().split('T')[0],
    items: backendOrder.itens?.map(item => ({
      id: item.id.toString(),
      productId: item.produto_id,
      productName: item.produto?.nome || '',
      quantity: item.quantidade,
      unitPrice: parseFloat(item.preco_unitario?.toString() || '0'),
      total: parseFloat(item.subtotal?.toString() || '0')
    })) || [],
    paymentMethod: backendOrder.forma_pagamento,
    address: endereco,
    notes: backendOrder.observacoes,
    criado_por: backendOrder.criado_por
  };
};

export function useOrders() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { user, hasRole } = useAuth();

  // Carregar pedidos
  const loadOrders = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // REGRA DE NEGÓCIO: Se for vendedor, carregar apenas seus pedidos
      const vendedorId = hasRole('Vendedor') ? user?.id : undefined;
      const response = await api.pedidos.listar(vendedorId);
        
      if (response.success) {
        const mappedOrders = response.data.map(mapOrderFromBackend);
        setOrders(mappedOrders);
      } else {
        throw new Error('Erro ao carregar pedidos');
      }
    } catch (error: any) {
      console.error('Erro ao carregar pedidos:', error);
      setError(error.message || 'Erro ao carregar pedidos');
      setOrders([]);
    } finally {
      setLoading(false);
    }
  };

  // Atualizar método refreshOrders para usar loadOrders
  const refreshOrders = () => {
    loadOrders();
  };

  // Carregar na inicialização
  useEffect(() => {
    loadOrders();
  }, [user]);

  // Criar pedido
  const createOrder = async (orderData: CreateOrderData): Promise<{ success: boolean; data?: any; error?: string }> => {
    try {
      setError(null);
      const response = await api.pedidos.criar(orderData);
      
      if (response.success) {
        await loadOrders(); // Recarregar lista
        return { success: true, data: response.data };
      } else {
        throw new Error(response.error || 'Erro ao criar pedido');
      }
    } catch (error: any) {
      console.error('Erro ao criar pedido:', error);
      const errorMessage = error.message || 'Erro ao criar pedido';
      setError(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Atualizar pedido - REGRA DE NEGÓCIO: Verificar permissões
  const updateOrder = async (id: string | number, updates: UpdateOrderData): Promise<{ success: boolean; data?: any; error?: string }> => {
    try {
      setError(null);
      
      let numericId: number;
      
      // Se o ID é uma string (número do pedido), buscar o ID numérico
      if (typeof id === 'string') {
        const response = await api.pedidos.listar();
        const pedido = response.data.find((p: any) => p.numero_pedido === id);
        
        if (!pedido) {
          throw new Error('Pedido não encontrado');
        }
        
        numericId = pedido.id;
      } else {
        numericId = id;
      }
      
      // Verificar se o vendedor pode editar este pedido
      if (hasRole('Vendedor')) {
        const order = orders.find(o => o.id === (typeof id === 'string' ? id : id.toString()));
        if (order && order.criado_por !== user?.id) {
          throw new Error('Você não tem permissão para editar este pedido');
        }
      }
      
      // Mapear dados para formato do backend
      const backendData: any = {};
      
      if (updates.status) {
        backendData.status = mapStatusToBackend(updates.status);
      }
      
      if (updates.items) {
        backendData.itens = updates.items.map(item => ({
          produto_id: item.productId || 0,
          quantidade: item.quantity,
          preco_unitario: item.unitPrice,
          desconto_valor: 0,
          desconto_percentual: 0,
          tipo_desconto: 'valor' as const
        }));
      }
      
      // Mapear outros campos
      if (updates.data_entrega_prevista !== undefined) {
        backendData.data_entrega_prevista = updates.data_entrega_prevista;
      }
      if (updates.horario_entrega !== undefined) {
        backendData.horario_entrega = updates.horario_entrega;
      }
      if (updates.observacoes_producao !== undefined) {
        backendData.observacoes_producao = updates.observacoes_producao;
      }
      if (updates.notes !== undefined) {
        backendData.observacoes = updates.notes;
      }
      
      const response = await api.pedidos.atualizar(numericId, backendData);
      
      if (response.success) {
        await loadOrders(); // Recarregar lista
        return { success: true, data: response.data };
      } else {
        throw new Error(response.error || 'Erro ao atualizar pedido');
      }
    } catch (error: any) {
      console.error('Erro ao atualizar pedido:', error);
      const errorMessage = error.message || 'Erro ao atualizar pedido';
      setError(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Cancelar pedido - REGRA DE NEGÓCIO: Verificar permissões
  const cancelOrder = async (id: number, motivo?: string): Promise<{ success: boolean; error?: string }> => {
    try {
      setError(null);
      
      // Verificar se o vendedor pode cancelar este pedido
      if (hasRole('Vendedor')) {
        const order = orders.find(o => o.id === id);
        if (order && order.criado_por !== user?.id) {
          throw new Error('Você não tem permissão para cancelar este pedido');
        }
      }
      
      const response = await api.pedidos.cancelar(id, motivo);
      
      if (response.success) {
        await loadOrders(); // Recarregar lista
        return { success: true };
      } else {
        throw new Error(response.error || 'Erro ao cancelar pedido');
      }
    } catch (error: any) {
      console.error('Erro ao cancelar pedido:', error);
      const errorMessage = error.message || 'Erro ao cancelar pedido';
      setError(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Adicionar pedido
  const addOrder = async (orderData: Omit<Order, 'id'>) => {
    try {
      // Mapear dados para formato do backend
      const backendData = {
        cliente_id: orderData.customerId,
        tipo: orderData.tipo || 'pronta_entrega',
        data_entrega_prevista: orderData.data_entrega_prevista,
        horario_entrega: orderData.horario_entrega,
        observacoes_producao: orderData.observacoes_producao,
        forma_pagamento: orderData.paymentMethod,
        observacoes: orderData.notes,
        itens: orderData.items.map(item => ({
          produto_id: item.productId || 0,
          quantidade: item.quantity,
          preco_unitario: item.unitPrice,
          desconto_valor: 0,
          desconto_percentual: 0,
          tipo_desconto: 'valor' as const
        }))
      };

      const response = await api.pedidos.criar(backendData, user?.id || 0);
      
      if (response.success) {
        await loadOrders(); // Recarregar lista
        return response.data;
      } else {
        throw new Error(response.message || 'Erro ao criar pedido');
      }
    } catch (error: any) {
      console.error('Erro ao adicionar pedido:', error);
      throw error;
    }
  };

  // Atualizar apenas status do pedido (sem processar itens)
  const updateOrderStatus = async (id: string, status: Order['status']) => {
    try {
      // Buscar ID numérico do pedido pelo número
      const pedido = orders.find(o => o.id === id);
      if (!pedido) {
        throw new Error('Pedido não encontrado');
      }

      // Mapear dados para formato do backend (apenas status)
      const backendData = {
        status: mapStatusToBackend(status)
      };

      // Buscar ID numérico real do pedido
      const response = await api.pedidos.listar();
      const pedidoCompleto = response.data.find((p: any) => p.numero_pedido === id);
      
      if (!pedidoCompleto) {
        throw new Error('Pedido não encontrado no servidor');
      }

      await api.pedidos.atualizar(pedidoCompleto.id, backendData);
      await loadOrders(); // Recarregar lista
    } catch (error: any) {
      console.error('Erro ao atualizar status do pedido:', error);
      throw error;
    }
  };

  // Deletar pedido
  const deleteOrder = async (id: string) => {
    try {
      // Buscar ID numérico real do pedido
      const response = await api.pedidos.listar();
      const pedido = response.data.find((p: any) => p.numero_pedido === id);
      
      if (!pedido) {
        throw new Error('Pedido não encontrado');
      }

      await api.pedidos.cancelar(pedido.id, 'Cancelado pelo usuário');
      await loadOrders(); // Recarregar lista
    } catch (error: any) {
      console.error('Erro ao deletar pedido:', error);
      throw error;
    }
  };

  // Buscar pedido por ID
  const getOrder = (id: string) => {
    return orders.find(order => order.id === id);
  };

  // Buscar pedidos com filtros
  const searchOrders = async (filters: {
    customerName?: string;
    status?: string;
    startDate?: string;
    endDate?: string;
    orderNumber?: string;
    tipo?: string;
    paymentStatus?: string;
  }) => {
    try {
      // Para agora, usar filtro local. Pode ser otimizado no futuro
      let filteredOrders = [...orders];

      if (filters.customerName) {
        filteredOrders = filteredOrders.filter(order => 
          order.customerName.toLowerCase().includes(filters.customerName!.toLowerCase())
        );
      }

      if (filters.status) {
        filteredOrders = filteredOrders.filter(order => order.status === filters.status);
      }

      if (filters.orderNumber) {
        filteredOrders = filteredOrders.filter(order => 
          order.id.toLowerCase().includes(filters.orderNumber!.toLowerCase())
        );
      }

      if (filters.tipo) {
        filteredOrders = filteredOrders.filter(order => order.tipo === filters.tipo);
      }

      if (filters.paymentStatus) {
        filteredOrders = filteredOrders.filter(order => order.paymentStatus === filters.paymentStatus);
      }

      return filteredOrders;
    } catch (error) {
      console.error('Erro ao buscar pedidos:', error);
      return [];
    }
  };

  // Estatísticas
  const getStatistics = async () => {
    try {
      const response = await api.pedidos.estatisticas();
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar estatísticas:', error);
      return null;
    }
  };

  // Atualizar pagamento
  const updatePayment = async (id: string, paymentData: {
    status_pagamento?: "pendente" | "pago" | "parcial";
    valor_pago?: number;
    observacoes_pagamento?: string;
  }) => {
    try {
      // Buscar ID numérico real do pedido
      const response = await api.pedidos.listar();
      const pedido = response.data.find((p: any) => p.numero_pedido === id);
      
      if (!pedido) {
        throw new Error('Pedido não encontrado');
      }

      await api.pedidos.atualizarPagamento(pedido.id, {
        status_pagamento: paymentData.status_pagamento || 'pendente',
        valor_pago: paymentData.valor_pago || 0,
        observacoes_pagamento: paymentData.observacoes_pagamento
      });
      
      await loadOrders(); // Recarregar lista
    } catch (error: any) {
      console.error('Erro ao atualizar pagamento:', error);
      throw error;
    }
  };

  // Marcar como entregue
  const markAsDelivered = async (id: string) => {
    try {
      // Buscar ID numérico real do pedido
      const response = await api.pedidos.listar();
      const pedido = response.data.find((p: any) => p.numero_pedido === id);
      
      if (!pedido) {
        throw new Error('Pedido não encontrado');
      }

      await api.pedidos.marcarEntregue(pedido.id);
      await loadOrders(); // Recarregar lista
    } catch (error: any) {
      console.error('Erro ao marcar como entregue:', error);
      throw error;
    }
  };

  // Pagamentos pendentes
  const getPendingPayments = async () => {
    try {
      const response = await api.pedidos.pagamentosPendentes();
      return response.data.map(mapOrderFromBackend);
    } catch (error) {
      console.error('Erro ao buscar pagamentos pendentes:', error);
      return [];
    }
  };

  // Pedidos não entregues
  const getUndeliveredOrders = async () => {
    try {
      const response = await api.pedidos.naoEntregues();
      return response.data.map(mapOrderFromBackend);
    } catch (error) {
      console.error('Erro ao buscar pedidos não entregues:', error);
      return [];
    }
  };

  return {
    orders,
    loading,
    error,
    addOrder,
    updateOrder,
    updateOrderStatus,
    deleteOrder,
    getOrder,
    refreshOrders,
    searchOrders,
    getStatistics,
    updatePayment,
    markAsDelivered,
    getPendingPayments,
    getUndeliveredOrders
  };
}
