import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Product } from "@/hooks/useProducts";
import { Upload } from "lucide-react";
import api, { getImageUrl } from "@/services/api";

interface ProductFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: Omit<Product, 'id'>) => void;
  product?: Product;
}

export function ProductFormModal({ isOpen, onClose, onSubmit, product }: ProductFormModalProps) {
  const [formData, setFormData] = useState<Omit<Product, 'id'>>({
    nome: '',
    descricao: '',
    preco_venda: 0,
    preco_custo: 0,
    quantidade_minima: 0,
    quantidade_atual: 0,
    categoria: '',
    unidade_medida: '',
    tipo_produto: 'producao_propria',
    status: 'ativo',
    imagem_url: ''
  });

  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string>('');
  const [isUploading, setIsUploading] = useState(false);

  // Atualizar o formulário quando o produto mudar
  useEffect(() => {
    if (product) {
      setFormData({
        nome: product.nome,
        descricao: product.descricao || '',
        preco_venda: product.preco_venda,
        preco_custo: product.preco_custo,
        quantidade_minima: product.quantidade_minima,
        quantidade_atual: product.quantidade_atual,
        categoria: product.categoria,
        unidade_medida: product.unidade_medida,
        tipo_produto: product.tipo_produto,
        status: product.status,
        imagem_url: product.imagem_url || ''
      });
      setPreviewUrl(product.imagem_url ? getImageUrl(product.imagem_url) : '');
    } else {
      setFormData({
        nome: '',
        descricao: '',
        preco_venda: 0,
        preco_custo: 0,
        quantidade_minima: 0,
        quantidade_atual: 0,
        categoria: '',
        unidade_medida: '',
        tipo_produto: 'producao_propria',
        status: 'ativo',
        imagem_url: ''
      });
      setPreviewUrl('');
    }
    setSelectedImage(null);
  }, [product, isOpen]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      let finalImageUrl = formData.imagem_url;

      // Se há uma nova imagem selecionada, faz o upload
      if (selectedImage) {
        setIsUploading(true);
        const formDataUpload = new FormData();
        formDataUpload.append('imagem', selectedImage);
        
        try {
          const response = await api.produtos.uploadImagem(selectedImage);
          finalImageUrl = response.data.imageUrl;
        } catch (error: any) {
          console.error('Erro detalhado do upload:', {
            error,
            response: error.response?.data,
            status: error.response?.status
          });
          throw new Error(error.response?.data?.error || 'Erro ao fazer upload da imagem');
        }
      }

      // Submete o formulário com a URL da imagem atualizada
      await onSubmit({
        ...formData,
        imagem_url: finalImageUrl
      });
      
      onClose();
    } catch (error: any) {
      console.error('Erro ao salvar produto:', error);
      // Aqui você pode adicionar uma notificação de erro para o usuário
    } finally {
      setIsUploading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name.includes('preco') || name.includes('quantidade') ? Number(value) : value
    }));
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setSelectedImage(file);
      
      // Criar URL temporária para preview
      const previewUrl = URL.createObjectURL(file);
      setPreviewUrl(previewUrl);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[800px] max-h-[90vh] flex flex-col p-0">
        <DialogHeader className="p-6 pb-2">
          <DialogTitle>{product ? 'Editar Produto' : 'Novo Produto'}</DialogTitle>
          <DialogDescription>
            {product ? 'Edite as informações do produto abaixo.' : 'Preencha as informações para criar um novo produto.'}
          </DialogDescription>
        </DialogHeader>
        
        <div className="flex-1 overflow-y-auto px-6">
          <form id="productForm" onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-6">
              {/* Coluna da esquerda */}
              <div className="space-y-3">
                {product && (
                  <div className="space-y-2">
                    <Label htmlFor="id">ID do Produto</Label>
                    <Input
                      id="id"
                      name="id"
                      value={product.id}
                      disabled
                      className="bg-gray-100"
                    />
                  </div>
                )}

                <div className="space-y-2">
                  <Label htmlFor="nome">Nome</Label>
                  <Input
                    id="nome"
                    name="nome"
                    value={formData.nome}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="descricao">Descrição</Label>
                  <textarea
                    id="descricao"
                    name="descricao"
                    value={formData.descricao}
                    onChange={handleChange}
                    className="w-full min-h-[80px] rounded-md border border-input bg-background px-3 py-2"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="preco_venda">Preço de Venda</Label>
                    <Input
                      id="preco_venda"
                      name="preco_venda"
                      type="number"
                      step="0.01"
                      value={formData.preco_venda}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="preco_custo">Preço de Custo</Label>
                    <Input
                      id="preco_custo"
                      name="preco_custo"
                      type="number"
                      step="0.01"
                      value={formData.preco_custo}
                      onChange={handleChange}
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Coluna da direita */}
              <div className="space-y-3">
                <div className="space-y-2">
                  <Label>Imagem do Produto</Label>
                  <div className="border-2 border-dashed rounded-lg p-4 text-center">
                    {previewUrl ? (
                      <div className="relative">
                        <img
                          src={previewUrl}
                          alt="Preview"
                          className="max-h-[150px] mx-auto rounded-lg"
                        />
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          className="absolute top-2 right-2"
                          onClick={() => {
                            setSelectedImage(null);
                            setPreviewUrl('');
                            setFormData(prev => ({ ...prev, imagem_url: '' }));
                          }}
                        >
                          Remover
                        </Button>
                      </div>
                    ) : (
                      <div className="py-4">
                        <Upload className="w-12 h-12 mx-auto text-gray-400 mb-2" />
                        <Label htmlFor="image" className="cursor-pointer text-sm text-gray-600">
                          Clique para fazer upload
                        </Label>
                        <Input
                          id="image"
                          type="file"
                          accept="image/*"
                          className="hidden"
                          onChange={handleImageChange}
                        />
                      </div>
                    )}
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="quantidade_atual">Quantidade Atual</Label>
                    <Input
                      id="quantidade_atual"
                      name="quantidade_atual"
                      type="number"
                      value={formData.quantidade_atual}
                      disabled
                      className="bg-gray-100"
                    />
                    <p className="text-xs text-gray-500">Controlado automaticamente pelas movimentações de estoque</p>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="quantidade_minima">Quantidade Mínima</Label>
                    <Input
                      id="quantidade_minima"
                      name="quantidade_minima"
                      type="number"
                      value={formData.quantidade_minima}
                      onChange={handleChange}
                      required
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="categoria">Categoria</Label>
                    <Input
                      id="categoria"
                      name="categoria"
                      value={formData.categoria}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="unidade_medida">Unidade de Medida</Label>
                    <Input
                      id="unidade_medida"
                      name="unidade_medida"
                      value={formData.unidade_medida}
                      onChange={handleChange}
                      required
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="tipo_produto">Tipo de Produto</Label>
                    <select
                      id="tipo_produto"
                      name="tipo_produto"
                      value={formData.tipo_produto}
                      onChange={handleChange}
                      className="w-full rounded-md border border-input bg-background px-3 py-2"
                      required
                    >
                      <option value="producao_propria">Produção Própria</option>
                      <option value="revenda">Revenda</option>
                      <option value="materia_prima">Matéria-Prima</option>
                    </select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="status">Status</Label>
                    <select
                      id="status"
                      name="status"
                      value={formData.status}
                      onChange={handleChange}
                      className="w-full rounded-md border border-input bg-background px-3 py-2"
                      required
                    >
                      <option value="ativo">Ativo</option>
                      <option value="inativo">Inativo</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
          </form>
        </div>

        <div className="flex justify-end gap-2 p-6 border-t">
          <Button type="button" variant="outline" onClick={onClose}>
            Cancelar
          </Button>
          <Button type="submit" form="productForm" disabled={isUploading}>
            {isUploading ? 'Enviando...' : product ? 'Salvar' : 'Criar'}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
