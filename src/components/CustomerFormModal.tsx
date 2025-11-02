import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Customer } from "@/hooks/useCustomers";

interface CustomerFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (customer: Omit<Customer, 'id'>) => void;
  customer?: Customer;
}

const tiposPessoa = [
  { value: "fisica", label: "Pessoa Física" },
  { value: "juridica", label: "Pessoa Jurídica" }
];

const estados = [
  "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"
];

export function CustomerFormModal({ isOpen, onClose, onSubmit, customer }: CustomerFormModalProps) {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    cpf_cnpj: "",
    tipo_pessoa: "fisica" as 'fisica' | 'juridica',
    endereco_rua: "",
    endereco_numero: "",
    endereco_complemento: "",
    neighborhood: "",
    endereco_cidade: "",
    endereco_estado: "",
    endereco_cep: "",
    notes: "",
  });

  useEffect(() => {
    if (customer) {
      setFormData({
        name: customer.name,
        email: customer.email || "",
        phone: customer.phone,
        cpf_cnpj: customer.cpf_cnpj || "",
        tipo_pessoa: customer.tipo_pessoa || "fisica",
        endereco_rua: customer.endereco_rua || "",
        endereco_numero: customer.endereco_numero || "",
        endereco_complemento: customer.endereco_complemento || "",
        neighborhood: customer.neighborhood,
        endereco_cidade: customer.endereco_cidade || "",
        endereco_estado: customer.endereco_estado || "",
        endereco_cep: customer.endereco_cep || "",
        notes: customer.notes || "",
      });
    } else {
      setFormData({
        name: "",
        email: "",
        phone: "",
        cpf_cnpj: "",
        tipo_pessoa: "fisica",
        endereco_rua: "",
        endereco_numero: "",
        endereco_complemento: "",
        neighborhood: "",
        endereco_cidade: "",
        endereco_estado: "",
        endereco_cep: "",
        notes: "",
      });
    }
  }, [customer, isOpen]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const customerData: Omit<Customer, 'id'> = {
      // Campos mapeados
      name: formData.name,
      phone: formData.phone,
      neighborhood: formData.neighborhood,
      email: formData.email,
      notes: formData.notes,
      
      // Campos calculados (serão preenchidos pelo backend)
      orders: 0,
      lastOrder: "",
      totalSpent: 0,
      address: "",
      customerStatus: "Novo",
      
      // Campos do banco
      nome: formData.name,
      telefone: formData.phone,
      cpf_cnpj: formData.cpf_cnpj,
      tipo_pessoa: formData.tipo_pessoa,
      endereco_rua: formData.endereco_rua,
      endereco_numero: formData.endereco_numero,
      endereco_complemento: formData.endereco_complemento,
      endereco_bairro: formData.neighborhood,
      endereco_cidade: formData.endereco_cidade,
      endereco_estado: formData.endereco_estado,
      endereco_cep: formData.endereco_cep,
      observacoes: formData.notes,
      status: "ativo",
      data_cadastro: "",
      total_pedidos: 0,
      ultimo_pedido: "",
      total_gasto: 0,
    };

    onSubmit(customerData);
    onClose();
  };

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>
            {customer ? 'Editar Cliente' : 'Novo Cliente'}
          </DialogTitle>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Dados Básicos */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800">Dados Básicos</h3>
            
            <div>
              <Label htmlFor="name">Nome Completo *</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => handleChange('name', e.target.value)}
                required
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="email">E-mail</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleChange('email', e.target.value)}
                />
              </div>
              <div>
                <Label htmlFor="phone">Telefone</Label>
                <Input
                  id="phone"
                  value={formData.phone}
                  onChange={(e) => handleChange('phone', e.target.value)}
                  placeholder="(11) 99999-9999"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="tipo_pessoa">Tipo de Pessoa</Label>
                <Select value={formData.tipo_pessoa} onValueChange={(value) => handleChange('tipo_pessoa', value)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {tiposPessoa.map((tipo) => (
                      <SelectItem key={tipo.value} value={tipo.value}>
                        {tipo.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="cpf_cnpj">
                  {formData.tipo_pessoa === 'fisica' ? 'CPF' : 'CNPJ'}
                </Label>
                <Input
                  id="cpf_cnpj"
                  value={formData.cpf_cnpj}
                  onChange={(e) => handleChange('cpf_cnpj', e.target.value)}
                  placeholder={formData.tipo_pessoa === 'fisica' ? '000.000.000-00' : '00.000.000/0000-00'}
                />
              </div>
            </div>
          </div>

          {/* Endereço */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800">Endereço</h3>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="md:col-span-2">
                <Label htmlFor="endereco_rua">Rua/Avenida</Label>
                <Input
                  id="endereco_rua"
                  value={formData.endereco_rua}
                  onChange={(e) => handleChange('endereco_rua', e.target.value)}
                />
              </div>
              <div>
                <Label htmlFor="endereco_numero">Número</Label>
                <Input
                  id="endereco_numero"
                  value={formData.endereco_numero}
                  onChange={(e) => handleChange('endereco_numero', e.target.value)}
                />
              </div>
            </div>

            <div>
              <Label htmlFor="endereco_complemento">Complemento</Label>
              <Input
                id="endereco_complemento"
                value={formData.endereco_complemento}
                onChange={(e) => handleChange('endereco_complemento', e.target.value)}
                placeholder="Apartamento, casa, etc."
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="neighborhood">Bairro</Label>
                <Input
                  id="neighborhood"
                  value={formData.neighborhood}
                  onChange={(e) => handleChange('neighborhood', e.target.value)}
                />
              </div>
              <div>
                <Label htmlFor="endereco_cidade">Cidade</Label>
                <Input
                  id="endereco_cidade"
                  value={formData.endereco_cidade}
                  onChange={(e) => handleChange('endereco_cidade', e.target.value)}
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="endereco_estado">Estado</Label>
                <Select value={formData.endereco_estado} onValueChange={(value) => handleChange('endereco_estado', value)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione o estado" />
                  </SelectTrigger>
                  <SelectContent>
                    {estados.map((estado) => (
                      <SelectItem key={estado} value={estado}>
                        {estado}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="endereco_cep">CEP</Label>
                <Input
                  id="endereco_cep"
                  value={formData.endereco_cep}
                  onChange={(e) => handleChange('endereco_cep', e.target.value)}
                  placeholder="00000-000"
                />
              </div>
            </div>
          </div>

          {/* Observações */}
          <div>
            <Label htmlFor="notes">Observações</Label>
            <Textarea
              id="notes"
              value={formData.notes}
              onChange={(e) => handleChange('notes', e.target.value)}
              placeholder="Observações sobre o cliente..."
              rows={3}
            />
          </div>

          <div className="flex gap-2 pt-4">
            <Button type="button" variant="outline" onClick={onClose} className="flex-1">
              Cancelar
            </Button>
            <Button type="submit" className="flex-1 bg-gradient-to-r from-purple-500 to-pink-600 hover:from-purple-600 hover:to-pink-700">
              {customer ? 'Salvar' : 'Criar'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
