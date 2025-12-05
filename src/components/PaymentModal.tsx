import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Order } from "@/hooks/useOrders";

interface PaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (paymentData: {
    status_pagamento?: "pendente" | "pago" | "parcial";
    valor_pago?: number;
    observacoes_pagamento?: string;
    valor_desconto?: number;
    percentual_desconto?: number;
    tipo_desconto?: "valor" | "percentual" | null;
  }) => void;
  order?: Order;
}

const paymentStatusOptions = [
  { value: "pendente", label: "Pendente" },
  { value: "parcial", label: "Pagamento Parcial" },
  { value: "pago", label: "Pago Integralmente" }
];

export function PaymentModal({ isOpen, onClose, onSubmit, order }: PaymentModalProps) {
  const [formData, setFormData] = useState({
    status_pagamento: "pendente" as "pendente" | "pago" | "parcial",
    valor_pago: 0,
    observacoes_pagamento: "",
    tipo_desconto: null as "valor" | "percentual" | null,
    valor_desconto: 0,
    percentual_desconto: 0,
  });

  // Se o modal não estiver aberto, não renderizar nada
  if (!isOpen) {
    return null;
  }

  useEffect(() => {
    try {
      if (order) {
        setFormData({
          status_pagamento: (order.paymentStatus as "pendente" | "pago" | "parcial") || "pendente",
          valor_pago: Number(order.amountPaid) || 0,
          observacoes_pagamento: order.paymentNotes || "",
          tipo_desconto: (order.tipo_desconto as "valor" | "percentual" | null) || null,
          valor_desconto: Number(order.valor_desconto) || 0,
          percentual_desconto: Number(order.percentual_desconto) || 0,
        });
      } else {
        // Resetar quando não há pedido
        setFormData({
          status_pagamento: "pendente",
          valor_pago: 0,
          observacoes_pagamento: "",
          tipo_desconto: null,
          valor_desconto: 0,
          percentual_desconto: 0,
        });
      }
    } catch (error) {
      console.error('Erro ao inicializar formData no PaymentModal:', error);
      // Valores padrão em caso de erro
      setFormData({
        status_pagamento: "pendente",
        valor_pago: 0,
        observacoes_pagamento: "",
        tipo_desconto: null,
        valor_desconto: 0,
        percentual_desconto: 0,
      });
    }
  }, [order, isOpen]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validação: Valor Pago não pode ser vazio ou zero
    if (!formData.valor_pago || formData.valor_pago <= 0) {
      alert('O campo "Valor Pago" é obrigatório e deve ser maior que zero.');
      return;
    }
    
    onSubmit({
      status_pagamento: formData.status_pagamento,
      valor_pago: formData.valor_pago,
      observacoes_pagamento: formData.observacoes_pagamento,
      valor_desconto: formData.tipo_desconto === 'valor' ? formData.valor_desconto : 0,
      percentual_desconto: formData.tipo_desconto === 'percentual' ? formData.percentual_desconto : 0,
      tipo_desconto: formData.tipo_desconto,
    });
    onClose();
  };

  const handleChange = (field: string, value: string | number) => {
    setFormData(prev => {
      const newData = {
        ...prev,
        [field]: value
      };
      
      // Se o status foi alterado para "pago", preencher automaticamente o valor final
      if (field === 'status_pagamento' && value === 'pago' && order) {
        const valorOriginalCalc = order.total || 0;
        const descontoCalc = newData.tipo_desconto === 'valor' 
          ? newData.valor_desconto 
          : newData.tipo_desconto === 'percentual' 
            ? (valorOriginalCalc * newData.percentual_desconto) / 100 
            : 0;
        const valorFinalCalc = valorOriginalCalc - descontoCalc;
        newData.valor_pago = valorFinalCalc;
      }
      
      // Se o status foi alterado para "pendente", zerar o valor pago
      if (field === 'status_pagamento' && value === 'pendente') {
        newData.valor_pago = 0;
      }
      
      // Se o valor foi alterado, ajustar automaticamente o status
      if (field === 'valor_pago') {
        const valorPago = typeof value === 'number' ? value : parseFloat(value.toString()) || 0;
        const valorOriginalCalc = order?.total || 0;
        const descontoCalc = newData.tipo_desconto === 'valor' 
          ? newData.valor_desconto 
          : newData.tipo_desconto === 'percentual' 
            ? (valorOriginalCalc * newData.percentual_desconto) / 100 
            : 0;
        const valorFinalCalc = valorOriginalCalc - descontoCalc;
        
        if (valorPago === 0) {
          newData.status_pagamento = 'pendente';
        } else if (valorPago >= valorFinalCalc) {
          newData.status_pagamento = 'pago';
          newData.valor_pago = valorFinalCalc; // Garantir que não ultrapasse o valor final
        } else {
          newData.status_pagamento = 'parcial';
        }
      }
      
      // Quando tipo de desconto muda, limpar o outro campo
      if (field === 'tipo_desconto') {
        if (value === 'valor') {
          newData.percentual_desconto = 0;
        } else if (value === 'percentual') {
          newData.valor_desconto = 0;
        } else {
          newData.valor_desconto = 0;
          newData.percentual_desconto = 0;
        }
      }
      
      // Quando valor_desconto ou percentual_desconto é alterado, atualizar automaticamente o valor_pago
      if ((field === 'valor_desconto' || field === 'percentual_desconto' || field === 'tipo_desconto') && order) {
        const valorOriginalCalc = order.total || 0;
        let descontoCalc = 0;
        
        if (newData.tipo_desconto === 'valor') {
          descontoCalc = Number(newData.valor_desconto) || 0;
        } else if (newData.tipo_desconto === 'percentual') {
          const percentual = Number(newData.percentual_desconto) || 0;
          descontoCalc = (valorOriginalCalc * percentual) / 100;
        }
        
        const valorFinalCalc = Math.max(0, valorOriginalCalc - descontoCalc);
        
        // Atualizar valor_pago automaticamente com o valor final (original - desconto)
        newData.valor_pago = valorFinalCalc;
        
        // Ajustar status automaticamente baseado no valor final
        if (valorFinalCalc === 0) {
          newData.status_pagamento = 'pendente';
        } else {
          // Como o valor_pago foi atualizado para o valor final, o status deve ser 'pago'
          newData.status_pagamento = 'pago';
        }
      }
      
      return newData;
    });
  };

  // Calcular valores com segurança - usar try-catch para evitar erros
  // IMPORTANTE: valor_total (order.total) é o valor ORIGINAL (não muda)
  // O desconto é calculado sobre o valor_total original
  let valorOriginal = 0;
  let descontoAtual = 0;
  let valorFinal = 0;
  let remainingAmount = 0;

  try {
    if (order) {
      // valor_total é o valor original (inalterado)
      valorOriginal = Number(order.total) || 0;
      if (isNaN(valorOriginal)) valorOriginal = 0;
      
      // Calcular desconto sobre o valor original
      if (formData.tipo_desconto === 'valor') {
        descontoAtual = Number(formData.valor_desconto) || 0;
        if (isNaN(descontoAtual)) descontoAtual = 0;
      } else if (formData.tipo_desconto === 'percentual') {
        const percentual = Number(formData.percentual_desconto) || 0;
        if (isNaN(percentual)) {
          descontoAtual = 0;
        } else {
          descontoAtual = (valorOriginal * percentual) / 100;
        }
      } else {
        descontoAtual = 0;
      }
      
      // Valor final a pagar = valor original - desconto
      valorFinal = Math.max(0, valorOriginal - descontoAtual);
      if (isNaN(valorFinal)) valorFinal = 0;
      
      const valorPago = Number(formData.valor_pago) || 0;
      remainingAmount = Math.max(0, valorFinal - (isNaN(valorPago) ? 0 : valorPago));
      if (isNaN(remainingAmount)) remainingAmount = 0;
    }
  } catch (error) {
    console.error('Erro ao calcular valores no PaymentModal:', error);
    // Valores padrão em caso de erro
    valorOriginal = order ? (Number(order.total) || 0) : 0;
    descontoAtual = 0;
    valorFinal = valorOriginal;
    remainingAmount = valorFinal;
  }

  try {
    return (
      <Dialog open={isOpen} onOpenChange={onClose}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-2xl font-bold">
              Controle de Pagamento {order ? `- ${order.id || 'N/A'}` : ''}
            </DialogTitle>
            <DialogDescription className="text-base">
              Gerencie o pagamento e descontos do pedido
            </DialogDescription>
          </DialogHeader>
          
          {!order ? (
            <div className="p-4 text-center text-gray-500">
              <p>Carregando informações do pedido...</p>
            </div>
          ) : (
          <form onSubmit={handleSubmit} className="space-y-6">
          {order && (
            <div className="bg-gradient-to-br from-gray-50 to-gray-100 p-6 rounded-xl border-2 border-gray-200 shadow-sm space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-1">
                  <p className="text-sm text-gray-600 font-medium">Cliente</p>
                  <p className="text-lg font-semibold text-gray-900">{order.customerName}</p>
                </div>
                <div className="space-y-1">
                  <p className="text-sm text-gray-600 font-medium">Método de Pagamento</p>
                  <p className="text-lg font-semibold text-gray-900">{order.paymentMethod}</p>
                </div>
              </div>
              
              <div className="border-t border-gray-300 pt-4 space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-base font-medium text-gray-700">Valor Original:</span>
                  <span className="text-lg font-semibold text-gray-900">R$ {isNaN(valorOriginal) ? '0.00' : valorOriginal.toFixed(2)}</span>
                </div>
                {descontoAtual > 0 && (
                  <div className="flex justify-between items-center bg-red-50 p-3 rounded-lg border border-red-200">
                    <div className="flex items-center gap-2">
                      <span className="text-base font-medium text-red-700">Desconto:</span>
                      {formData.tipo_desconto === 'percentual' && (
                        <span className="text-sm text-red-600 bg-red-100 px-2 py-1 rounded">
                          {formData.percentual_desconto || 0}%
                        </span>
                      )}
                    </div>
                    <span className="text-lg font-bold text-red-700">
                      - R$ {isNaN(descontoAtual) ? '0.00' : descontoAtual.toFixed(2)}
                    </span>
                  </div>
                )}
                <div className="flex justify-between items-center bg-green-50 p-4 rounded-lg border-2 border-green-300">
                  <span className="text-lg font-bold text-gray-800">Valor a Pagar:</span>
                  <span className="text-2xl font-bold text-green-600">R$ {isNaN(valorFinal) ? '0.00' : valorFinal.toFixed(2)}</span>
                </div>
              </div>
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-3">
              <Label htmlFor="status_pagamento" className="text-base font-semibold">Status do Pagamento</Label>
              <Select 
                value={formData.status_pagamento} 
                onValueChange={(value) => handleChange('status_pagamento', value)}
              >
                <SelectTrigger className="h-11 text-base">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {paymentStatusOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <Label htmlFor="valor_pago" className="text-base font-semibold">Valor Pago</Label>
              {order && formData.status_pagamento !== 'pago' && (
                <Button 
                  type="button" 
                  variant="outline" 
                  size="sm"
                  onClick={() => handleChange('valor_pago', valorFinal)}
                  className="text-xs"
                >
                  Pagar Total
                </Button>
              )}
            </div>
            <Input
              id="valor_pago"
              type="number"
              step="0.01"
              min="0"
              max={isNaN(valorFinal) ? undefined : valorFinal}
              value={formData.valor_pago}
              onChange={(e) => handleChange('valor_pago', parseFloat(e.target.value) || 0)}
              placeholder="0.00"
              className={`h-11 text-base ${formData.status_pagamento === 'pago' ? 'bg-green-50 border-green-300' : ''}`}
            />
            {order && remainingAmount > 0 && formData.status_pagamento !== 'pago' && (
              <div className="bg-orange-50 border border-orange-200 rounded-lg p-2">
                <p className="text-sm font-medium text-orange-700">
                  Restante: <span className="font-bold">R$ {isNaN(remainingAmount) ? '0.00' : remainingAmount.toFixed(2)}</span>
                </p>
              </div>
            )}
            {order && formData.status_pagamento === 'pago' && formData.valor_pago >= valorFinal && (
              <div className="bg-green-50 border border-green-200 rounded-lg p-2">
                <p className="text-sm font-medium text-green-700">
                  ✅ Pagamento integral confirmado
                </p>
              </div>
            )}
            {order && formData.status_pagamento === 'parcial' && formData.valor_pago > 0 && (
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-2">
                <p className="text-sm font-medium text-blue-700">
                  💰 Pagamento parcial de <span className="font-bold">R$ {isNaN(formData.valor_pago) ? '0.00' : formData.valor_pago.toFixed(2)}</span>
                </p>
              </div>
            )}
            </div>
          </div>

          {/* Seção de Desconto */}
          <div className="border-t border-gray-200 pt-6 space-y-4">
            <div className="flex items-center gap-2 mb-4">
              <Label className="text-lg font-bold text-gray-800">Aplicar Desconto</Label>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="tipo_desconto" className="text-base font-semibold">Tipo de Desconto</Label>
                <Select 
                  value={formData.tipo_desconto || "none"} 
                  onValueChange={(value) => handleChange('tipo_desconto', value === "none" ? null : value as "valor" | "percentual")}
                >
                  <SelectTrigger className="h-11 text-base">
                    <SelectValue placeholder="Selecione o tipo de desconto" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">Sem desconto</SelectItem>
                    <SelectItem value="valor">Valor (R$)</SelectItem>
                    <SelectItem value="percentual">Percentual (%)</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {formData.tipo_desconto === 'valor' && (
                <div className="space-y-2">
                  <Label htmlFor="valor_desconto" className="text-base font-semibold">Valor do Desconto (R$)</Label>
                  <Input
                    id="valor_desconto"
                    type="number"
                    step="0.01"
                    min="0"
                    max={isNaN(valorOriginal) ? undefined : valorOriginal}
                    value={formData.valor_desconto}
                    onChange={(e) => handleChange('valor_desconto', parseFloat(e.target.value) || 0)}
                    placeholder="0.00"
                    className="h-11 text-base"
                  />
                  {formData.valor_desconto > 0 && (
                    <div className="bg-blue-50 border border-blue-200 rounded-lg p-2">
                      <p className="text-sm font-medium text-blue-700">
                        Desconto de <span className="font-bold">R$ {isNaN(formData.valor_desconto) ? '0.00' : formData.valor_desconto.toFixed(2)}</span> aplicado
                      </p>
                    </div>
                  )}
                </div>
              )}

              {formData.tipo_desconto === 'percentual' && (
                <div className="space-y-2">
                  <Label htmlFor="percentual_desconto" className="text-base font-semibold">Percentual do Desconto (%)</Label>
                  <Input
                    id="percentual_desconto"
                    type="number"
                    step="0.01"
                    min="0"
                    max="100"
                    value={formData.percentual_desconto}
                    onChange={(e) => handleChange('percentual_desconto', parseFloat(e.target.value) || 0)}
                    placeholder="0.00"
                    className="h-11 text-base"
                  />
                  {formData.percentual_desconto > 0 && (
                    <div className="bg-blue-50 border border-blue-200 rounded-lg p-2">
                      <p className="text-sm font-medium text-blue-700">
                        Desconto de <span className="font-bold">{formData.percentual_desconto || 0}%</span> sobre R$ {isNaN(valorOriginal) ? '0.00' : valorOriginal.toFixed(2)} = <span className="font-bold">R$ {isNaN(descontoAtual) ? '0.00' : descontoAtual.toFixed(2)}</span>
                      </p>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="observacoes_pagamento" className="text-base font-semibold">Observações do Pagamento</Label>
            <Textarea
              id="observacoes_pagamento"
              value={formData.observacoes_pagamento}
              onChange={(e) => handleChange('observacoes_pagamento', e.target.value)}
              placeholder="Observações sobre o pagamento..."
              rows={4}
              className="text-base"
            />
          </div>

          <div className="flex gap-4 pt-6 border-t border-gray-200">
            <Button 
              type="button" 
              variant="outline" 
              onClick={onClose} 
              className="flex-1 h-12 text-base font-semibold"
            >
              Cancelar
            </Button>
            <Button 
              type="submit" 
              className="flex-1 h-12 text-base font-semibold bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 shadow-lg"
            >
              Salvar Pagamento
            </Button>
          </div>
          </form>
          )}
        </DialogContent>
      </Dialog>
    );
  } catch (error) {
    console.error('Erro ao renderizar PaymentModal:', error);
    return (
      <Dialog open={isOpen} onOpenChange={onClose}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Erro ao carregar modal de pagamento</DialogTitle>
          </DialogHeader>
          <div className="p-4">
            <p className="text-red-600 mb-4">Ocorreu um erro ao carregar o modal de pagamento.</p>
            <Button onClick={onClose} className="w-full">
              Fechar
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    );
  }
} 