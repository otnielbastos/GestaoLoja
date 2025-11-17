import Header from '@/components/website/Header';
import Hero from '@/components/website/Hero';
import Benefits from '@/components/website/Benefits';
import Menu from '@/components/website/Menu';
import OrderForm from '@/components/website/OrderForm';
import Footer from '@/components/website/Footer';
import SEO from '@/components/website/SEO';

export default function Home() {
  return (
    <>
      <SEO />
      <div className="min-h-screen">
        <Header />
        <main>
          <Hero />
          <Benefits />
          <Menu />
          <OrderForm />
        </main>
        <Footer />
      </div>
    </>
  );
}

