
import Button from './Button';

export default function Header() {
  const scrollToOrder = () => {
    const orderSection = document.getElementById('pedido');
    if (orderSection) {
      orderSection.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <header className="bg-white shadow-sm sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center py-4">
          <div className="flex items-center gap-2 sm:gap-3">
            <img 
              src="https://static.readdy.ai/image/23c1b32f4c83ebfdc78e33fca9630083/514cab0691b1b648f73421df5e7f91a2.png" 
              alt="Silo Sabores Gourmet" 
              className="h-10 sm:h-12 md:h-16 w-auto"
            />
            <h1 className="text-lg sm:text-2xl md:text-3xl font-bold text-gray-900">
              Silo Sabores Gourmet
            </h1>

          </div>
          <nav className="hidden md:flex items-center space-x-8">
            <a href="#beneficios" className="text-gray-700 hover:text-red-600 transition-colors cursor-pointer">
              Por que escolher
            </a>
            <a href="#cardapio" className="text-gray-700 hover:text-red-600 transition-colors cursor-pointer">
              Cardápio
            </a>
            <a href="#pedido" className="text-gray-700 hover:text-red-600 transition-colors cursor-pointer">
              Fazer Encomenda
            </a>
          </nav>
          <Button onClick={scrollToOrder} size="md" className="text-sm px-3 py-2 sm:text-base sm:px-4 sm:py-2">
            Encomendar Agora
          </Button>
        </div>
      </div>
    </header>
  );
}
