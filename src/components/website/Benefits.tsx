
export default function Benefits() {
  const benefits = [
    {
      icon: 'ri-heart-line',
      title: 'Fresco e Artesanal',
      description: 'Feito com ingredientes de alta qualidade, mantendo o sabor caseiro tradicional da Itália.',
      // image: '/images/website/benefit-fresh-artisanal.jpg'
      image: '/images/website/Massa2.png'
    },
    {
      icon: 'ri-time-line',
      title: 'Conveniência Total',
      description: 'Refeições deliciosas prontas em poucos minutos. Perfeito para o dia a dia corrido.',
      image: '/images/website/benefit-convenience.jpg'
    },
    {
      icon: 'ri-restaurant-line',
      title: 'Variedade Única',
      description: 'Diversidade de sabores e recheios especiais, além de molhos artesanais para acompanhar.',
      image: '/images/website/benefit-variety.png'
    }
  ];

  return (
    <section id="beneficios" className="py-20 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h3 className="text-4xl font-bold text-gray-900 mb-4">
            Por que escolher nossos nhoques?
          </h3>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Combinamos tradição italiana com praticidade moderna para levar o melhor da gastronomia até sua mesa
          </p>
        </div>
        
        <div className="grid md:grid-cols-3 gap-8">
          {benefits.map((benefit, index) => (
            <div key={index} className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300">
              <div className="h-48 bg-cover bg-center" style={{ backgroundImage: `url('${benefit.image}')` }}></div>
              <div className="p-8">
                <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mb-6 mx-auto">
                  <i className={`${benefit.icon} text-2xl text-red-600`}></i>
                </div>
                <h4 className="text-xl font-bold text-gray-900 mb-4 text-center">
                  {benefit.title}
                </h4>
                <p className="text-gray-600 text-center leading-relaxed">
                  {benefit.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
