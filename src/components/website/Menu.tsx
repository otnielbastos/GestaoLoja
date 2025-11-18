
export default function Menu() {
  const products = [
    {
      id: 1,
      name: 'Nhoque Tradicional',
      description: 'Nhoque clássico feito com batata e farinha, com aquele sabor caseiro de família.',
      price: 'R$ 25,00',
      image: '/images/website/menu-nhoque-tradicional.png',
      category: 'nhoque'
    },
    {
      id: 2,
      name: 'Nhoque Recheado Calabresa com Mussarela',
      description: 'Nhoque especial recheado com calabresa defumada e mussarela derretida.',
      price: 'R$ 40,00',
      image: '/images/website/menu-nhoque-calabresa-mussarela.png',
      category: 'nhoque'
    },
    {
      id: 3,
      name: 'Nhoque Recheado Mussarela',
      description: 'Nhoque cremoso recheado com mussarela de primeira qualidade.',
      price: 'R$ 40,00',
      image: '/images/website/menu-nhoque-mussarela.png',
      category: 'nhoque'
    },
    {
      id: 4,
      name: 'Nhoque Recheado Mussarela com Catupiry',
      description: 'Combinação irresistível de mussarela e catupiry cremoso.',
      price: 'R$ 40,00',
      image: '/images/website/menu-nhoque-mussarela-catupiry.png',
      category: 'nhoque'
    },
    {
      id: 5,
      name: 'Nhoque Recheado Presunto com Mussarela',
      description: 'Nhoque saboroso com recheio de presunto e mussarela.',
      price: 'R$ 40,00',
      image: '/images/website/menu-nhoque-presunto-mussarela.png',
      category: 'nhoque'
    },
    {
      id: 6,
      name: 'Molho ao Sugo Extrato',
      description: 'Molho de tomate concentrado com ervas finas e temperos especiais.',
      price: 'R$ 20,00',
      image: '/images/website/menu-molho-sugo-extrato.png',
      category: 'molho'
    },
    {
      id: 7,
      name: 'Molho ao Sugo Natural',
      description: 'Molho de tomate natural com manjericão fresco e alho.',
      price: 'R$ 20,00',
      image: '/images/website/menu-molho-sugo-natural.png',
      category: 'molho'
    },
    {
      id: 8,
      name: 'Molho Bolonhesa Extrato',
      description: 'Molho bolonhesa concentrado com carne moída e tomates selecionados.',
      price: 'R$ 20,00',
      image: '/images/website/menu-molho-bolonhesa.png',
      category: 'molho'
    }
  ];

  const nhoques = products.filter(p => p.category === 'nhoque');
  const molhos = products.filter(p => p.category === 'molho');

  return (
    <section id="cardapio" className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h3 className="text-4xl font-bold text-gray-900 mb-4">
            Nosso Cardápio
          </h3>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Pacotes de 500g que servem de 2 a 3 pessoas. Todos os produtos são congelados e mantêm o sabor fresco.
          </p>
        </div>

        {/* Nhoques */}
        <div className="mb-16">
          <h4 className="text-3xl font-bold text-gray-900 mb-8 text-center">
            <i className="ri-restaurant-line mr-3 text-red-600"></i>
            Nhoques Artesanais
          </h4>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {nhoques.map((product) => (
              <div key={product.id} className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300" data-product-shop>
                <div 
                  className="h-48 bg-cover bg-center"
                  style={{ backgroundImage: `url('${product.image}')` }}
                ></div>
                <div className="p-6">
                  <div className="flex justify-between items-start mb-3">
                    <h5 className="text-lg font-bold text-gray-900">
                      {product.name}
                    </h5>
                    <span className="text-xl font-bold text-red-600 whitespace-nowrap">
                      {product.price}
                    </span>
                  </div>
                  <p className="text-gray-600 text-sm leading-relaxed">
                    {product.description}
                  </p>
                  <div className="mt-4 flex items-center text-sm text-gray-500">
                    <i className="ri-package-line mr-2"></i>
                    Pacote 500g (2-3 porções)
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Molhos */}
        <div>
          <h4 className="text-3xl font-bold text-gray-900 mb-8 text-center">
            <i className="ri-bowl-line mr-3 text-green-600"></i>
            Molhos Artesanais
          </h4>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {molhos.map((product) => (
              <div key={product.id} className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300" data-product-shop>
                <div 
                  className="h-48 bg-cover bg-center"
                  style={{ backgroundImage: `url('${product.image}')` }}
                ></div>
                <div className="p-6">
                  <div className="flex justify-between items-start mb-3">
                    <h5 className="text-lg font-bold text-gray-900">
                      {product.name}
                    </h5>
                    <span className="text-xl font-bold text-green-600 whitespace-nowrap">
                      {product.price}
                    </span>
                  </div>
                  <p className="text-gray-600 text-sm leading-relaxed">
                    {product.description}
                  </p>
                  <div className="mt-4 flex items-center text-sm text-gray-500">
                    <i className="ri-bottle-line mr-2"></i>
                    Pote 300ml
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Modo de Preparo */}
        <div className="mt-20 bg-gradient-to-r from-red-50 to-orange-50 rounded-2xl p-8">
          <div className="text-center mb-8">
            <h4 className="text-3xl font-bold text-gray-900 mb-4">
              <i className="ri-fire-line mr-3 text-orange-600"></i>
              Modo de Preparo
            </h4>
            <p className="text-lg text-gray-600">
              Siga estas instruções simples para preparar seus nhoques perfeitamente
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-8">
            {/* Preparo no Forno */}
            <div className="bg-white rounded-xl p-6 shadow-lg">
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mr-4">
                  <i className="ri-fire-fill text-red-600 text-xl"></i>
                </div>
                <h5 className="text-xl font-bold text-gray-900">Forno Convencional</h5>
              </div>
              <div className="space-y-4">
                <div className="flex items-start">
                  <span className="bg-red-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold mr-3 mt-1 flex-shrink-0">1</span>
                  <p className="text-gray-700">Descongele os nhoques.</p>
                </div>
                <div className="flex items-start">
                  <span className="bg-red-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold mr-3 mt-1 flex-shrink-0">2</span>
                  <p className="text-gray-700">Pré-aqueça o forno a <strong>180°C</strong>. Distribua o nhoque em uma assadeira e cubra com o molho de sua preferência.</p>
                </div>
                <div className="flex items-start">
                  <span className="bg-red-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold mr-3 mt-1 flex-shrink-0">3</span>
                  <p className="text-gray-700">Asse por aproximadamente <strong>20 minutos</strong>, até que esteja bem quente e o molho borbulhe levemente.</p>
                </div>
              </div>
            </div>

            {/* Preparo no Microondas */}
            <div className="bg-white rounded-xl p-6 shadow-lg">
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                  <i className="ri-wireless-charging-line text-blue-600 text-xl"></i>
                </div>
                <h5 className="text-xl font-bold text-gray-900">Microondas</h5>
              </div>
              <div className="space-y-4">
                <div className="flex items-start">
                  <span className="bg-blue-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold mr-3 mt-1 flex-shrink-0">1</span>
                  <p className="text-gray-700">Descongele os nhoques.</p>
                </div>
                <div className="flex items-start">
                  <span className="bg-blue-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold mr-3 mt-1 flex-shrink-0">2</span>
                  <p className="text-gray-700">Transfira o nhoque com molho para um recipiente próprio para microondas.</p>
                </div>
                <div className="flex items-start">
                  <span className="bg-blue-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold mr-3 mt-1 flex-shrink-0">3</span>
                  <p className="text-gray-700">Aqueça por cerca de <strong>5 minutos</strong> em potência alta. Ajuste o tempo conforme a potência do seu aparelho.</p>
                </div>
              </div>
            </div>
          </div>

          <div className="mt-8 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <div className="flex items-start">
              <i className="ri-lightbulb-line text-yellow-600 text-xl mr-3 mt-1"></i>
              <div>
                <h6 className="font-semibold text-yellow-800 mb-1">Dica Importante:</h6>
                <p className="text-yellow-700 text-sm">
                  Observe sempre para não superaquecer. O nhoque está pronto quando estiver bem quente por dentro e o molho borbulhando levemente.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
