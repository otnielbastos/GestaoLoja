import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Users as UsersIcon, Plus, Search, Edit, Trash2, UserCheck, UserX, Shield } from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/services/api";
import { useToast } from "@/hooks/use-toast";
import { PermissionsManager } from "@/components/PermissionsManager";

interface User {
  id: number;
  nome: string;
  email: string;
  perfil: string;
  perfil_id: number;
  ativo: boolean;
  ultimo_acesso: string;
  data_criacao: string;
}

interface Profile {
  id: number;
  nome: string;
  ativo: boolean;
}

export function Users() {
  const [users, setUsers] = useState<User[]>([]);
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [showModal, setShowModal] = useState(false);
  const [showPermissionsManager, setShowPermissionsManager] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [formData, setFormData] = useState({
    nome: "",
    email: "",
    password: "",
    perfil_id: 0,
    ativo: true
  });
  
  const { user: currentUser, checkPermission } = useAuth();
  const { toast } = useToast();

  // Verificar se o usuário tem permissão para acessar usuários
  if (!checkPermission('usuarios', 'visualizar')) {
    return (
      <div className="text-center py-12">
        <UserX className="w-16 h-16 text-gray-300 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-gray-600 mb-2">Acesso Negado</h3>
        <p className="text-gray-500">Você não tem permissão para acessar esta página.</p>
      </div>
    );
  }

  useEffect(() => {
    fetchUsers();
    fetchProfiles();
  }, []);

  // Fechar modal com ESC
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        if (showPermissionsManager) {
          setShowPermissionsManager(false);
        } else if (showModal) {
          setShowModal(false);
        }
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [showPermissionsManager, showModal]);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await api.usuarios.listar();
      if (response.success) {
        // Mapear os dados para o formato esperado pelo componente
        const mappedUsers = response.data.usuarios.map((user: any) => ({
          id: user.id,
          nome: user.nome,
          email: user.email,
          perfil: user.perfil?.nome || 'Sem perfil',
          perfil_id: user.perfil?.id || 0,
          ativo: user.ativo,
          ultimo_acesso: user.ultimo_acesso,
          data_criacao: user.data_criacao
        }));
        setUsers(mappedUsers);
      }
    } catch (error: any) {
      toast({
        title: "Erro",
        description: "Erro ao carregar usuários.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const fetchProfiles = async () => {
    try {
      const response = await api.usuarios.buscarPerfis();
      if (response.success) {
        setProfiles(response.data);
      }
    } catch (error: any) {
      console.error('Erro ao carregar perfis:', error);
    }
  };

  const handleCreate = () => {
    setEditingUser(null);
    setFormData({ nome: "", email: "", password: "", perfil_id: 0, ativo: true });
    setShowModal(true);
  };

  const handleEdit = (user: User) => {
    setEditingUser(user);
    setFormData({
      nome: user.nome,
      email: user.email,
      password: "", // Sempre limpar senha ao editar (não mostrar senha existente)
      perfil_id: user.perfil_id,
      ativo: user.ativo
    });
    setShowModal(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.nome || !formData.email || !formData.perfil_id) {
      toast({
        title: "Erro",
        description: "Preencha todos os campos obrigatórios.",
        variant: "destructive",
      });
      return;
    }

    if (!editingUser && !formData.password) {
      toast({
        title: "Erro",
        description: "Senha é obrigatória para novos usuários.",
        variant: "destructive",
      });
      return;
    }

    // Validação de senha se fornecida
    if (formData.password && formData.password.length < 6) {
      toast({
        title: "Erro",
        description: "A senha deve ter pelo menos 6 caracteres.",
        variant: "destructive",
      });
      return;
    }

    try {
      if (editingUser) {
        const updateData: any = {
          nome: formData.nome,
          email: formData.email,
          perfil_id: parseInt(formData.perfil_id.toString()),
          ativo: formData.ativo
        };
        
        // Incluir senha apenas se foi preenchida
        if (formData.password && formData.password.trim() !== '') {
          updateData.password = formData.password;
        }
        
        const response = await api.usuarios.atualizar(editingUser.id, updateData);
        toast({
          title: "Sucesso",
          description: response.message || "Usuário atualizado com sucesso.",
        });
      } else {
        await api.usuarios.criar({
          ...formData,
          perfil_id: parseInt(formData.perfil_id.toString())
        });
        toast({
          title: "Sucesso",
          description: "Usuário criado com sucesso.",
        });
      }
      
      setShowModal(false);
      fetchUsers();
    } catch (error: any) {
      toast({
        title: "Erro",
        description: error.message || "Erro ao salvar usuário.",
        variant: "destructive",
      });
    }
  };

  const toggleUserStatus = async (userId: number, currentStatus: boolean) => {
    try {
      if (currentStatus) {
        await api.usuarios.desativar(userId);
      } else {
        await api.usuarios.reativar(userId);
      }
      toast({
        title: "Sucesso",
        description: `Usuário ${currentStatus ? 'desativado' : 'ativado'} com sucesso.`,
      });
      fetchUsers();
    } catch (error: any) {
      toast({
        title: "Erro",
        description: error.message || "Erro ao alterar status do usuário.",
        variant: "destructive",
      });
    }
  };

  const filteredUsers = users.filter(user =>
    user.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.perfil.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-800 flex items-center gap-2">
            <UsersIcon className="w-8 h-8" />
            Usuários
          </h2>
          <p className="text-gray-600">Gerencie usuários e permissões do sistema</p>
        </div>
        <div className="flex gap-2">
          {checkPermission('usuarios', 'editar') && (
            <Button variant="outline" onClick={() => setShowPermissionsManager(true)}>
              <Shield className="h-4 w-4 mr-2" />
              Gerenciar Permissões
            </Button>
          )}
          {checkPermission('usuarios', 'criar') && (
            <Button onClick={handleCreate} className="bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white">
              <Plus className="w-4 h-4 mr-2" />
              Novo Usuário
            </Button>
          )}
        </div>
      </div>

      {/* Search */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-6">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <Input
              placeholder="Buscar usuários por nome, email ou perfil..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </CardContent>
      </Card>

      {/* Users List */}
      <Card className="border-0 shadow-md">
        <CardContent className="p-6">
          {loading ? (
            <div className="text-center py-8">Carregando usuários...</div>
          ) : (
            <div className="space-y-4">
              {filteredUsers.map((user) => (
                <div key={user.id} className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50">
                  <div className="flex-1">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
                        <UsersIcon className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-gray-800">{user.nome}</h3>
                        <p className="text-sm text-gray-600">{user.email}</p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-4">
                    <div className="text-center">
                      <Badge variant={user.ativo ? "default" : "secondary"}>
                        {user.perfil}
                      </Badge>
                      <p className="text-xs text-gray-500 mt-1">
                        {user.ativo ? "Ativo" : "Inativo"}
                      </p>
                    </div>
                    
                    <div className="text-right text-sm text-gray-500">
                      <p>Último acesso:</p>
                      <p>{user.ultimo_acesso ? formatDate(user.ultimo_acesso) : 'Nunca'}</p>
                    </div>
                    
                    <div className="flex gap-2">
                      {checkPermission('usuarios', 'editar') && (
                        <Button size="sm" variant="outline" onClick={() => handleEdit(user)} title="Editar usuário">
                          <Edit className="w-4 h-4" />
                        </Button>
                      )}
                      
                      {checkPermission('usuarios', 'editar') && user.id !== currentUser?.id && (
                        <Button 
                          size="sm" 
                          variant={user.ativo ? "outline" : "default"}
                          onClick={() => toggleUserStatus(user.id, user.ativo)}
                          className={user.ativo ? "text-red-600 hover:text-red-700" : "text-green-600 hover:text-green-700"}
                          title={user.ativo ? "Desativar usuário" : "Ativar usuário"}
                        >
                          {user.ativo ? <UserX className="w-4 h-4" /> : <UserCheck className="w-4 h-4" />}
                        </Button>
                      )}
                    </div>
                  </div>
                </div>
              ))}
              
              {filteredUsers.length === 0 && (
                <div className="text-center py-8">
                  <UsersIcon className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <h3 className="text-lg font-semibold text-gray-600 mb-2">Nenhum usuário encontrado</h3>
                  <p className="text-gray-500">
                    {searchTerm ? 'Tente buscar por outros termos.' : 'Comece criando alguns usuários.'}
                  </p>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Form Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <Card className="w-full max-w-md mx-4">
            <CardHeader>
              <CardTitle>{editingUser ? 'Editar Usuário' : 'Novo Usuário'}</CardTitle>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Nome *</label>
                  <Input
                    value={formData.nome}
                    onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                    placeholder="Nome completo"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-1">Email *</label>
                  <Input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    placeholder="email@exemplo.com"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-1">
                    {editingUser ? 'Nova Senha' : 'Senha *'}
                    {editingUser && (
                      <span className="text-xs text-gray-500 font-normal ml-2">
                        (deixe vazio para manter a senha atual)
                      </span>
                    )}
                  </label>
                  <Input
                    type="password"
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    placeholder={editingUser ? "Digite uma nova senha (mínimo 6 caracteres)" : "Senha (mínimo 6 caracteres)"}
                    minLength={editingUser ? 0 : 6}
                  />
                  {editingUser && formData.password && formData.password.length > 0 && formData.password.length < 6 && (
                    <p className="text-xs text-red-500 mt-1">A senha deve ter pelo menos 6 caracteres</p>
                  )}
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-1">Perfil *</label>
                  <select
                    value={formData.perfil_id}
                    onChange={(e) => setFormData({ ...formData, perfil_id: parseInt(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  >
                    <option value="">Selecione um perfil</option>
                    {profiles.map(profile => (
                      <option key={profile.id} value={profile.id}>
                        {profile.nome}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div className="flex gap-2 pt-4">
                  <Button type="submit" className="flex-1">
                    {editingUser ? 'Atualizar' : 'Criar'}
                  </Button>
                  <Button type="button" variant="outline" onClick={() => setShowModal(false)}>
                    Cancelar
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </div>
      )}

             {/* Permissions Manager Modal */}
       {showPermissionsManager && (
         <div 
           className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
           onClick={() => setShowPermissionsManager(false)}
         >
           <div 
             className="bg-white rounded-lg w-full max-w-6xl max-h-[90vh] overflow-hidden"
             onClick={(e) => e.stopPropagation()}
           >
             <div className="p-6">
               <PermissionsManager onClose={() => setShowPermissionsManager(false)} />
             </div>
           </div>
         </div>
       )}
    </div>
  );
} 