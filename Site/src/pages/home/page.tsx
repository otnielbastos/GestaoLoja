
import Header from '../../components/feature/Header';
import Hero from '../../components/feature/Hero';
import Benefits from '../../components/feature/Benefits';
import Menu from '../../components/feature/Menu';
import OrderForm from '../../components/feature/OrderForm';
import Footer from '../../components/feature/Footer';

export default function Home() {
  return (
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
  );
}
