
export default function Footer() {
  return (
    <footer className="bg-gray-900 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <div className="flex items-center gap-3 mb-4">
              <img 
                src="/images/website/readdy-logo.png" 
                alt="Silo Sabores Gourmet" 
                className="h-16 w-auto filter brightness-0 invert"
              />
              <h2 className="text-2xl font-bold text-white">Silo Sabores Gourmet</h2>
            </div>
            <p className="text-gray-300 mb-4">
              Nhoques artesanais congelados com o autêntico sabor da Itália. 
              Qualidade premium, praticidade moderna.
            </p>
            <div className="flex gap-4 mt-4">
              <a 
                href="https://instagram.com/silosaboresgourmet" 
                target="_blank" 
                rel="nofollow noopener noreferrer"
                className="w-10 h-10 bg-white/10 hover:bg-white/20 rounded-full flex items-center justify-center transition-colors cursor-pointer"
                aria-label="Instagram"
              >
                <i className="ri-instagram-line text-xl"></i>
              </a>
              <a 
                href="https://www.facebook.com/silvanasaboresgourmet" 
                target="_blank" 
                rel="nofollow noopener noreferrer"
                className="w-10 h-10 bg-white/10 hover:bg-white/20 rounded-full flex items-center justify-center transition-colors cursor-pointer"
                aria-label="Facebook"
              >
                <i className="ri-facebook-fill text-xl"></i>
              </a>
              <a 
                href="https://wa.me/5511994144296" 
                target="_blank" 
                rel="nofollow noopener noreferrer"
                className="w-10 h-10 bg-white/10 hover:bg-white/20 rounded-full flex items-center justify-center transition-colors cursor-pointer"
                aria-label="WhatsApp"
              >
                <i className="ri-whatsapp-line text-xl"></i>
              </a>
            </div>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-4">Contato</h3>
            <div className="space-y-2 text-gray-300">
              <p><i className="ri-phone-line mr-2"></i>(11) 99414-4296</p>
              <p><i className="ri-mail-line mr-2"></i>silosabores@gmail.com</p>
              <p><i className="ri-map-pin-line mr-2"></i>Rua Cravo, 82 - Jardim das Flores</p>
              <p className="ml-6">Osasco/SP - CEP: 06112-120</p>
            </div>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-4">Horário de Atendimento</h3>
            <div className="space-y-2 text-gray-300">
              <p><strong>Segunda a Sexta:</strong> 9h às 18h</p>
              <p><strong>Sábado:</strong> 9h às 14h</p>
              <p><strong>Domingo:</strong> Fechado</p>
            </div>
          </div>
        </div>
        
        <div className="border-t border-gray-700 mt-8 pt-8 text-center text-gray-400">
          <p>&copy; 2025 Silo Sabores Gourmet. Todos os direitos reservados.</p>
          <p className="mt-2">
            <a href="https://readdy.ai/?origin=logo" className="hover:text-white transition-colors">
              Powered by Readdy
            </a>
          </p>
        </div>
      </div>
    </footer>
  );
}
