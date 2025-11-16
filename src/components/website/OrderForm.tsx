import { useState } from 'react';
import Button from './Button';
import QuantitySelector from './QuantitySelector';

interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
}

interface OrderItem {
  productId: number;
  quantity: number;
}

export default function OrderForm() {
  const products: Product[] = [
    { id: 1, name: 'Nhoque Tradicional', price: 40.00, category: 'nhoque' },
    { id: 2, name: 'Nhoque Recheado Calabresa com Mussarela', price: 40.00, category: 'nhoque' },
    { id: 3, name: 'Nhoque Recheado Mussarela', price: 40.00, category: 'nhoque' },
    { id: 4, name: 'Nhoque Recheado Mussarela com Catupiry', price: 40.00, category: 'nhoque' },
    { id: 5, name: 'Nhoque Recheado Presunto com Mussarela', price: 40.00, category: 'nhoque' },
    { id: 6, name: 'Molho ao Sugo Extrato', price: 20.00, category: 'molho' },
    { id: 7, name: 'Molho ao Sugo Natural', price: 20.00, category: 'molho' },
    { id: 8, name: 'Molho Bolonhesa Extrato', price: 20.00, category: 'molho' }
  ];

  const [orderItems, setOrderItems] = useState<OrderItem[]>(
    products.map(p => ({ productId: p.id, quantity: 0 }))
  );
  
  const [customerData, setCustomerData] = useState({
    name: '',
    phone: '',
    address: '',
    observations: ''
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitMessage, setSubmitMessage] = useState('');

  const updateQuantity = (productId: number, quantity: number) => {
    setOrderItems(prev => 
      prev.map(item => 
        item.productId === productId ? { ...item, quantity } : item
      )
    );
  };

  const getQuantity = (productId: number) => {
    return orderItems.find(item => item.productId === productId)?.quantity || 0;
  };

  const calculateTotal = () => {
    return orderItems.reduce((total, item) => {
      const product = products.find(p => p.id === item.productId);
      return total + (product ? product.price * item.quantity : 0);
    }, 0);
  };

  const getSelectedItems = () => {
    return orderItems.filter(item => item.quantity > 0);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const selectedItems = getSelectedItems();
    if (selectedItems.length === 0) {
      setSubmitMessage('Por favor, selecione pelo menos um produto.');
      return;
    }

    if (!customerData.name || !customerData.phone || !customerData.address) {
      setSubmitMessage('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    setIsSubmitting(true);
    setSubmitMessage('');

    try {
      const orderDetails = selectedItems.map(item => {
        const product = products.find(p => p.id === item.productId);
        return `${item.quantity}x ${product?.name} - R$ ${(product!.price * item.quantity).toFixed(2)}`;
      }).join('\n');

      const total = calculateTotal();

      // URL da API do backend (usa variável de ambiente ou localhost por padrão)
      const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';

      const response = await fetch(`${API_URL}/api/encomendas`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          nome: customerData.name,
          telefone: customerData.phone,
          endereco: customerData.address,
          observacoes: customerData.observations,
          pedido: orderDetails,
          total: `R$ ${total.toFixed(2)}`
        })
      });

      const data = await response.json();

      if (response.ok && data.success) {
        setSubmitMessage('Encomenda enviada com sucesso! Entraremos em contato em breve para confirmar os detalhes, pagamento e entrega.');
        setOrderItems(products.map(p => ({ productId: p.id, quantity: 0 })));
        setCustomerData({ name: '', phone: '', address: '', observations: '' });
      } else {
        setSubmitMessage(data.message || 'Erro ao enviar encomenda. Tente novamente.');
      }
    } catch (error) {
      setSubmitMessage('Erro ao enviar encomenda. Verifique sua conexão e tente novamente.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const nhoques = products.filter(p => p.category === 'nhoque');
  const molhos = products.filter(p => p.category === 'molho');

  return (
    <section id="pedido" className="py-20 bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h3 className="text-4xl font-bold text-gray-900 mb-4">
            Faça sua Encomenda
          </h3>
          <p className="text-xl text-gray-600 mb-6">
            Selecione os produtos e quantidades desejadas
          </p>
          
          {/* Aviso sobre Encomenda */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-8">
            <div className="flex items-start">
              <i className="ri-information-line text-blue-600 text-xl mr-3 mt-1"></i>
              <div className="text-left">
                <h4 className="font-semibold text-blue-900 mb-2">
                  📋 Como funciona nossa encomenda:
                </h4>
                <ul className="text-blue-800 space-y-1 text-sm">
                  <li>• Todos os pedidos são feitos por <strong>encomenda</strong></li>
                  <li>• Após enviar sua solicitação, nossa equipe entrará em contato</li>
                  <li>• Confirmaremos disponibilidade, prazo de entrega e forma de pagamento</li>
                  <li>• Produtos frescos preparados especialmente para você</li>
                  <li>• <strong>Atendemos exclusivamente a região de Osasco</strong></li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-lg p-8" data-readdy-form>
          {/* Seleção de Produtos */}
          <div className="mb-8">
            <h4 className="text-2xl font-bold text-gray-900 mb-6">
              <i className="ri-restaurant-line mr-2 text-red-600"></i>
              Nhoques Artesanais
            </h4>
            <div className="space-y-4">
              {nhoques.map((product) => (
                <div key={product.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:border-red-300 transition-colors">
                  <div className="flex-1">
                    <h5 className="font-semibold text-gray-900">{product.name}</h5>
                    <p className="text-red-600 font-bold">R$ {product.price.toFixed(2)}</p>
                    <p className="text-sm text-gray-500">Pacote 500g</p>
                  </div>
                  <QuantitySelector
                    value={getQuantity(product.id)}
                    onChange={(quantity) => updateQuantity(product.id, quantity)}
                  />
                </div>
              ))}
            </div>
          </div>

          <div className="mb-8">
            <h4 className="text-2xl font-bold text-gray-900 mb-6">
              <i className="ri-bowl-line mr-2 text-green-600"></i>
              Molhos Artesanais
            </h4>
            <div className="space-y-4">
              {molhos.map((product) => (
                <div key={product.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:border-green-300 transition-colors">
                  <div className="flex-1">
                    <h5 className="font-semibold text-gray-900">{product.name}</h5>
                    <p className="text-green-600 font-bold">R$ {product.price.toFixed(2)}</p>
                    <p className="text-sm text-gray-500">Porção individual</p>
                  </div>
                  <QuantitySelector
                    value={getQuantity(product.id)}
                    onChange={(quantity) => updateQuantity(product.id, quantity)}
                  />
                </div>
              ))}
            </div>
          </div>

          {/* Total */}
          {getSelectedItems().length > 0 && (
            <div className="mb-8 p-4 bg-gray-100 rounded-lg">
              <div className="flex justify-between items-center">
                <span className="text-lg font-semibold text-gray-900">Total Estimado:</span>
                <span className="text-2xl font-bold text-red-600">R$ {calculateTotal().toFixed(2)}</span>
              </div>
              <p className="text-sm text-gray-600 mt-2">
                * Valor sujeito à confirmação. Entraremos em contato para finalizar.
              </p>
            </div>
          )}

          {/* Dados do Cliente */}
          <div className="mb-8">
            <h4 className="text-2xl font-bold text-gray-900 mb-6">
              <i className="ri-user-line mr-2 text-blue-600"></i>
              Seus Dados para Contato
            </h4>
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
                  Nome Completo *
                </label>
                <input
                  type="text"
                  id="name"
                  name="nome"
                  value={customerData.name}
                  onChange={(e) => setCustomerData(prev => ({ ...prev, name: e.target.value }))}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm"
                  required
                />
              </div>
              <div>
                <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
                  WhatsApp *
                </label>
                <input
                  type="tel"
                  id="phone"
                  name="telefone"
                  value={customerData.phone}
                  onChange={(e) => setCustomerData(prev => ({ ...prev, phone: e.target.value }))}
                  placeholder="(11) 99999-9999"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm"
                  required
                />
              </div>
            </div>
            <div className="mt-6">
              <label htmlFor="address" className="block text-sm font-medium text-gray-700 mb-2">
                Endereço para Entrega em Osasco *
              </label>
              <textarea
                id="address"
                name="endereco"
                value={customerData.address}
                onChange={(e) => setCustomerData(prev => ({ ...prev, address: e.target.value }))}
                rows={3}
                maxLength={500}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm"
                placeholder="Rua, número, bairro, Osasco, CEP"
                required
              ></textarea>
              <p className="text-sm text-gray-500 mt-1">
                * Entregamos apenas na região de Osasco
              </p>
            </div>
            <div className="mt-6">
              <label htmlFor="observations" className="block text-sm font-medium text-gray-700 mb-2">
                Observações (opcional)
              </label>
              <textarea
                id="observations"
                name="observacoes"
                value={customerData.observations}
                onChange={(e) => setCustomerData(prev => ({ ...prev, observations: e.target.value }))}
                rows={2}
                maxLength={500}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm"
                placeholder="Instruções especiais, preferências de horário para contato, etc."
              ></textarea>
            </div>
          </div>

          {/* Mensagem de Status */}
          {submitMessage && (
            <div className={`mb-6 p-4 rounded-lg ${submitMessage.includes('sucesso') ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
              {submitMessage}
            </div>
          )}

          {/* Botão de Envio */}
          <Button
            type="submit"
            size="lg"
            fullWidth
            disabled={isSubmitting || getSelectedItems().length === 0}
            className="text-lg"
          >
            {isSubmitting ? (
              <>
                <i className="ri-loader-4-line mr-2 animate-spin"></i>
                Enviando Encomenda...
              </>
            ) : (
              <>
                <i className="ri-send-plane-line mr-2"></i>
                Solicitar Encomenda
              </>
            )}
          </Button>
          
          <p className="text-center text-sm text-gray-600 mt-4">
            Ao solicitar, você concorda que nossa equipe entre em contato para confirmar detalhes e pagamento.
          </p>
        </form>
      </div>
    </section>
  );
}