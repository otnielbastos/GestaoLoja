
import Button from './Button';

export default function Hero() {
  const scrollToOrder = () => {
    const orderSection = document.getElementById('pedido');
    if (orderSection) {
      orderSection.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section 
      className="relative min-h-screen flex items-center justify-center bg-cover bg-center"
      style={{
        backgroundImage: `linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4)), url('https://readdy.ai/api/search-image?query=Delicious%20homemade%20gnocchi%20pasta%20with%20rich%20tomato%20sauce%20and%20fresh%20basil%20leaves%20on%20rustic%20wooden%20table%2C%20warm%20Italian%20kitchen%20atmosphere%2C%20golden%20lighting%2C%20appetizing%20food%20photography%2C%20cozy%20restaurant%20ambiance%2C%20traditional%20Italian%20cooking%2C%20steam%20rising%20from%20hot%20pasta&width=1920&height=1080&seq=hero-gnocchi&orientation=landscape')`
      }}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div className="text-center text-white">
          <h2 className="text-5xl md:text-6xl font-bold mb-6 leading-tight">
            O Sabor da Itália em Casa
          </h2>
          <p className="text-xl md:text-2xl mb-4 font-medium">
            Nhoques Artesanais Congelados
          </p>
          <p className="text-lg md:text-xl mb-8 text-gray-200">
            Prontos em Minutos, Sabor Caseiro Garantido!
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Button onClick={scrollToOrder} size="lg" className="text-lg px-10 py-4">
              <i className="ri-shopping-cart-line mr-2"></i>
              Fazer Pedido Agora
            </Button>
            <Button 
              variant="outline" 
              size="lg" 
              className="text-lg px-10 py-4 bg-white/10 border-white text-white hover:bg-white hover:text-red-600"
              onClick={() => document.getElementById('cardapio')?.scrollIntoView({ behavior: 'smooth' })}
            >
              Ver Cardápio
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
}
