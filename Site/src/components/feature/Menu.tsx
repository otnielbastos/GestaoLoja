
export default function Menu() {
  const products = [
    {
      id: 1,
      name: 'Nhoque Tradicional',
      description: 'Nhoque clássico feito com batata e farinha, sabor autêntico da tradição italiana.',
      price: 'R$ 40,00',
      image: 'https://readdy.ai/api/search-image?query=Traditional%20potato%20gnocchi%20on%20white%20plate%20with%20simple%20tomato%20sauce%2C%20classic%20Italian%20pasta%20dish%2C%20rustic%20wooden%20table%2C%20traditional%20recipe%2C%20homemade%20appearance%2C%20appetizing%20presentation%2C%20golden%20lighting%2C%20restaurant%20quality%20food%20photography&width=400&height=300&seq=traditional-gnocchi&orientation=landscape',
      category: 'nhoque'
    },
    {
      id: 2,
      name: 'Nhoque Recheado Calabresa com Mussarela',
      description: 'Nhoque especial recheado com calabresa defumada e mussarela derretida.',
      price: 'R$ 40,00',
      image: 'https://readdy.ai/api/search-image?query=Stuffed%20gnocchi%20with%20pepperoni%20and%20mozzarella%20cheese%20filling%2C%20cut%20open%20showing%20melted%20cheese%20and%20meat%20inside%2C%20Italian%20comfort%20food%2C%20rich%20and%20hearty%20meal%2C%20appetizing%20close-up%20photography%2C%20warm%20lighting%2C%20restaurant%20presentation&width=400&height=300&seq=calabresa-gnocchi&orientation=landscape',
      category: 'nhoque'
    },
    {
      id: 3,
      name: 'Nhoque Recheado Mussarela',
      description: 'Nhoque cremoso recheado com mussarela de primeira qualidade.',
      price: 'R$ 40,00',
      image: 'https://readdy.ai/api/search-image?query=Cheese-filled%20gnocchi%20with%20melted%20mozzarella%20center%2C%20creamy%20texture%2C%20golden%20cheese%20stretching%2C%20comfort%20food%20photography%2C%20Italian%20cuisine%2C%20appetizing%20presentation%2C%20warm%20restaurant%20lighting%2C%20premium%20quality%20ingredients&width=400&height=300&seq=mozzarella-gnocchi&orientation=landscape',
      category: 'nhoque'
    },
    {
      id: 4,
      name: 'Nhoque Recheado Mussarela com Catupiry',
      description: 'Combinação irresistível de mussarela e catupiry cremoso.',
      price: 'R$ 40,00',
      image: 'https://readdy.ai/api/search-image?query=Gourmet%20gnocchi%20filled%20with%20mozzarella%20and%20cream%20cheese%2C%20ultra%20creamy%20texture%2C%20premium%20cheese%20combination%2C%20Brazilian-Italian%20fusion%20cuisine%2C%20rich%20and%20indulgent%20meal%2C%20professional%20food%20photography%2C%20elegant%20presentation&width=400&height=300&seq=catupiry-gnocchi&orientation=landscape',
      category: 'nhoque'
    },
    {
      id: 5,
      name: 'Nhoque Recheado Presunto com Mussarela',
      description: 'Nhoque saboroso com recheio de presunto e mussarela.',
      price: 'R$ 40,00',
      image: 'https://readdy.ai/api/search-image?query=Ham%20and%20cheese%20stuffed%20gnocchi%2C%20savory%20filling%20with%20premium%20ham%20and%20mozzarella%2C%20hearty%20Italian%20pasta%20dish%2C%20comfort%20food%20presentation%2C%20appetizing%20cross-section%20view%2C%20restaurant%20quality%20photography%2C%20warm%20lighting&width=400&height=300&seq=ham-gnocchi&orientation=landscape',
      category: 'nhoque'
    },
    {
      id: 6,
      name: 'Molho ao Sugo Extrato',
      description: 'Molho de tomate concentrado com ervas finas e temperos especiais.',
      price: 'R$ 20,00',
      image: 'https://readdy.ai/api/search-image?query=Rich%20tomato%20sauce%20in%20glass%20jar%2C%20concentrated%20sugo%20with%20herbs%2C%20Italian%20pasta%20sauce%2C%20deep%20red%20color%2C%20traditional%20recipe%2C%20premium%20quality%20sauce%2C%20kitchen%20ingredients%20photography%2C%20rustic%20presentation&width=400&height=300&seq=sugo-extrato&orientation=landscape',
      category: 'molho'
    },
    {
      id: 7,
      name: 'Molho ao Sugo Natural',
      description: 'Molho de tomate natural com manjericão fresco e alho.',
      price: 'R$ 20,00',
      image: 'https://readdy.ai/api/search-image?query=Natural%20tomato%20sauce%20with%20fresh%20basil%20leaves%2C%20homemade%20pasta%20sauce%2C%20bright%20red%20color%2C%20fresh%20herbs%2C%20traditional%20Italian%20cooking%2C%20glass%20container%2C%20kitchen%20ingredients%2C%20natural%20lighting%2C%20appetizing%20presentation&width=400&height=300&seq=sugo-natural&orientation=landscape',
      category: 'molho'
    },
    {
      id: 8,
      name: 'Molho Bolonhesa Extrato',
      description: 'Molho bolonhesa concentrado com carne moída e tomates selecionados.',
      price: 'R$ 20,00',
      image: 'https://readdy.ai/api/search-image?query=Rich%20bolognese%20sauce%20with%20ground%20meat%2C%20concentrated%20Italian%20meat%20sauce%2C%20deep%20red%20color%20with%20visible%20meat%20pieces%2C%20traditional%20recipe%2C%20premium%20pasta%20sauce%2C%20glass%20jar%20presentation%2C%20appetizing%20food%20photography&width=400&height=300&seq=bolognese&orientation=landscape',
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
