import { useEffect } from 'react';

interface SEOProps {
  title?: string;
  description?: string;
  image?: string;
  url?: string;
  type?: string;
}

export default function SEO({
  title = 'Silo Sabores Gourmet - Nhoques Artesanais Congelados',
  description = 'Nhoques artesanais congelados com o autêntico sabor da Itália. Qualidade premium, praticidade moderna. Entregas em Osasco/SP.',
  image = 'https://silosaboresgourmet.com.br/images/website/hero-gnocchi.jpg',
  url = 'https://silosaboresgourmet.com.br',
  type = 'website'
}: SEOProps) {
  useEffect(() => {
    // Atualizar título da página
    document.title = title;

    // Atualizar ou criar meta tags
    const updateMetaTag = (property: string, content: string, isProperty = false) => {
      const attribute = isProperty ? 'property' : 'name';
      let meta = document.querySelector(`meta[${attribute}="${property}"]`);
      
      if (!meta) {
        meta = document.createElement('meta');
        meta.setAttribute(attribute, property);
        document.head.appendChild(meta);
      }
      meta.setAttribute('content', content);
    };

    // Meta tags básicas
    updateMetaTag('description', description);
    updateMetaTag('author', 'Silo Sabores Gourmet');

    // Open Graph (Facebook, LinkedIn, etc.)
    updateMetaTag('og:title', title, true);
    updateMetaTag('og:description', description, true);
    updateMetaTag('og:image', image, true);
    updateMetaTag('og:url', url, true);
    updateMetaTag('og:type', type, true);
    updateMetaTag('og:site_name', 'Silo Sabores Gourmet', true);
    updateMetaTag('og:locale', 'pt_BR', true);

    // Twitter Card
    updateMetaTag('twitter:card', 'summary_large_image');
    updateMetaTag('twitter:title', title);
    updateMetaTag('twitter:description', description);
    updateMetaTag('twitter:image', image);

    // Schema.org JSON-LD
    const schemaScript = document.querySelector('script[type="application/ld+json"]');
    const schema = {
      '@context': 'https://schema.org',
      '@type': 'FoodEstablishment',
      name: 'Silo Sabores Gourmet',
      description: description,
      url: url,
      image: image,
      logo: 'https://silosaboresgourmet.com.br/images/website/readdy-logo.png',
      address: {
        '@type': 'PostalAddress',
        streetAddress: 'Rua Cravo, 82 - Jardim das Flores',
        addressLocality: 'Osasco',
        addressRegion: 'SP',
        postalCode: '06112-120',
        addressCountry: 'BR'
      },
      contactPoint: {
        '@type': 'ContactPoint',
        telephone: '+55-11-99414-4296',
        contactType: 'Customer Service',
        email: 'silosabores@gmail.com',
        areaServed: 'BR',
        availableLanguage: 'Portuguese'
      },
      openingHoursSpecification: [
        {
          '@type': 'OpeningHoursSpecification',
          dayOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
          opens: '09:00',
          closes: '18:00'
        },
        {
          '@type': 'OpeningHoursSpecification',
          dayOfWeek: 'Saturday',
          opens: '09:00',
          closes: '14:00'
        }
      ],
      servesCuisine: 'Italian',
      priceRange: '$$',
      sameAs: [
        'https://instagram.com/silosaboresgourmet',
        'https://www.facebook.com/silvanasaboresgourmet'
      ],
      menu: 'https://silosaboresgourmet.com.br/#cardapio',
      acceptsReservations: false,
      areaServed: {
        '@type': 'City',
        name: 'Osasco',
        containedIn: {
          '@type': 'State',
          name: 'São Paulo'
        }
      }
    };

    if (schemaScript) {
      schemaScript.textContent = JSON.stringify(schema);
    } else {
      const script = document.createElement('script');
      script.type = 'application/ld+json';
      script.textContent = JSON.stringify(schema);
      document.head.appendChild(script);
    }
  }, [title, description, image, url, type]);

  return null;
}

