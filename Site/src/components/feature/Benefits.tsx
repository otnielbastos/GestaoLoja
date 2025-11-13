
export default function Benefits() {
  const benefits = [
    {
      icon: 'ri-heart-line',
      title: 'Fresco e Artesanal',
      description: 'Feito com ingredientes de alta qualidade, mantendo o sabor caseiro tradicional da Itália.',
      image: 'https://readdy.ai/api/search-image?query=Fresh%20artisanal%20pasta%20ingredients%20on%20marble%20counter%2C%20high%20quality%20flour%2C%20fresh%20eggs%2C%20herbs%2C%20traditional%20Italian%20cooking%20preparation%2C%20clean%20kitchen%20workspace%2C%20natural%20lighting%2C%20premium%20food%20ingredients%2C%20rustic%20wooden%20utensils&width=400&height=300&seq=fresh-artisanal&orientation=landscape'
    },
    {
      icon: 'ri-time-line',
      title: 'Conveniência Total',
      description: 'Refeições deliciosas prontas em poucos minutos. Perfeito para o dia a dia corrido.',
      image: 'https://readdy.ai/api/search-image?query=Quick%20and%20convenient%20meal%20preparation%2C%20steaming%20hot%20gnocchi%20in%20modern%20kitchen%2C%20timer%20showing%20few%20minutes%2C%20busy%20lifestyle%20cooking%20solution%2C%20efficient%20meal%20prep%2C%20contemporary%20kitchen%20setting%2C%20time-saving%20cooking&width=400&height=300&seq=convenience&orientation=landscape'
    },
    {
      icon: 'ri-restaurant-line',
      title: 'Variedade Única',
      description: 'Diversidade de sabores e recheios especiais, além de molhos artesanais para acompanhar.',
      image: 'https://readdy.ai/api/search-image?query=Variety%20of%20colorful%20gnocchi%20with%20different%20fillings%20and%20sauces%2C%20multiple%20plates%20showcasing%20different%20flavors%2C%20cheese-filled%2C%20meat-filled%2C%20traditional%20varieties%2C%20Italian%20restaurant%20presentation%2C%20appetizing%20food%20display&width=400&height=300&seq=variety&orientation=landscape'
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
