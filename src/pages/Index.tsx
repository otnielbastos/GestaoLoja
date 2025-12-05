import React, { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { SidebarProvider } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/AppSidebar";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { Dashboard } from "@/components/Dashboard";
import { Products } from "@/components/Products";
import { Orders } from "@/components/Orders";
import { Customers } from "@/components/Customers";
import { Stock } from "@/components/Stock";
import { Deliveries } from "@/components/Deliveries";
import Reports from "@/components/Reports";
import ProductSalesReport from "@/components/ProductSalesReport";
import { Users } from "@/components/Users";
import Profile from "@/components/Profile";
import { NavigationProvider } from "@/contexts/NavigationContext";
import { ProtectedComponent } from "@/components/ProtectedComponent";
import { PagePermission } from "@/types/permissions";

export type ActivePage = 'dashboard' | 'products' | 'orders' | 'customers' | 'stock' | 'deliveries' | 'reports' | 'product-sales' | 'users' | 'profile';

const Index = () => {
  const [activePage, setActivePage] = useState<ActivePage>('dashboard');

  const getPagePermission = (page: ActivePage): PagePermission => {
    const pageMap: Record<ActivePage, PagePermission> = {
      'dashboard': 'dashboard',
      'products': 'produtos',
      'orders': 'pedidos',
      'customers': 'clientes',
      'stock': 'estoque',
      'deliveries': 'entregas',
      'reports': 'relatorios',
      'product-sales': 'relatorios', // Usa a mesma permissão de relatórios
      'users': 'usuarios',
      'profile': 'dashboard' // Profile usa a mesma permissão do dashboard (sempre acessível)
    };
    return pageMap[page];
  };

  const renderContent = () => {
    const pagePermission = getPagePermission(activePage);
    
    const getComponent = () => {
      switch (activePage) {
        case 'dashboard':
          return <Dashboard />;
        case 'products':
          return <Products />;
        case 'orders':
          return <Orders />;
        case 'customers':
          return <Customers />;
        case 'stock':
          return <Stock />;
        case 'deliveries':
          return <Deliveries />;
        case 'reports':
          return <Reports />;
        case 'product-sales':
          return <ProductSalesReport />;
        case 'users':
          return <Users />;
        case 'profile':
          return <Profile />;
        default:
          return <Dashboard />;
      }
    };

    // Dashboard e Profile sempre visíveis, outras páginas protegidas
    if (activePage === 'dashboard' || activePage === 'profile') {
      return getComponent();
    }

    return (
      <ProtectedComponent page={pagePermission}>
        {getComponent()}
      </ProtectedComponent>
    );
  };

  return (
    <NavigationProvider activePage={activePage} setActivePage={setActivePage}>
      <SidebarProvider>
        <div className="min-h-screen flex w-full bg-gradient-to-br from-gray-50 to-blue-50">
          <AppSidebar activePage={activePage} setActivePage={setActivePage} />
          <main className="flex-1 flex flex-col">
            <header className="bg-white/80 backdrop-blur-sm border-b border-gray-200 p-4 sticky top-0 z-10">
              <div className="flex items-center gap-4">
                <SidebarTrigger />
                <div>
                  <h1 className="text-2xl font-bold text-gray-800">Sistema de Gestão da Loja</h1>
                  <p className="text-sm text-gray-600">Gerencie sua loja de forma eficiente</p>
                </div>
              </div>
            </header>
            <div className="flex-1 p-6">
              {renderContent()}
            </div>
          </main>
                  </div>
        </SidebarProvider>
      </NavigationProvider>
    );
};

export default Index;
