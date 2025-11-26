# Regras de Estoque Implementadas

## Resumo das Implementações

As regras solicitadas foram implementadas no sistema Supabase com as seguintes funcionalidades:

### Regra 1: Pedidos tipo "Encomenda" - Entrada automática no estoque

✅ **IMPLEMENTADO** em `src/services/supabasePedidos.ts`

**Funcionamento:**
- Quando um pedido do tipo "Encomenda" tem seu status alterado de "Em Preparo" para "Produzido"
- O sistema automaticamente gera uma entrada no estoque
- Esta entrada é registrada apenas no estoque de "encomenda" (separado do estoque de pronta entrega)
- Uma movimentação automática é criada na tabela `movimentacoes_estoque`
- O campo `estoque_processado` é marcado como `true` para evitar duplicações

**Código implementado:**
```typescript
// Regra: Produção finalizada (em_preparo -> produzido) para encomendas
if (pedidoAtual.status === 'em_preparo' && novoStatus === 'produzido' && pedidoAtual.tipo === 'encomenda' && !pedidoAtual.estoque_processado) {
  await processarEntradaAutomaticaEstoque(id, pedidoAtual.itens, pedidoAtual.tipo);
  
  // Marcar que o estoque foi processado para evitar duplicações
  await supabase
    .from('pedidos')
    .update({ estoque_processado: true })
    .eq('id', id);
}
```

### Regra 2: Pedidos tipo "Pronta Entrega" - Visualização e controle do estoque

✅ **IMPLEMENTADO** em múltiplos arquivos

**Funcionamento:**
- Pedidos de "Pronta Entrega" mostram apenas o saldo do estoque disponível para pronta entrega
- O estoque de encomenda não é visível/disponível para estes pedidos
- A validação é feita na criação do pedido
- A saída do estoque acontece imediatamente na criação do pedido (não na entrega)

**Arquivos implementados:**

1. **`src/components/ProductSelect.tsx`** - Novo componente criado
   - Mostra estoque disponível baseado no tipo de pedido
   - Para pronta entrega: mostra apenas `quantidade_pronta_entrega`
   - Para encomenda: mostra "Será produzido"
   - Desabilita produtos sem estoque para pronta entrega

2. **`src/components/OrderItems.tsx`** - Atualizado
   - Usa o novo `ProductSelect` com tipo de pedido
   - Passa o `tipoPedido` para controlar a visualização

3. **`src/components/OrderFormModal.tsx`** - Atualizado
   - Passa o tipo de pedido para o componente `OrderItems`

4. **`src/services/supabasePedidos.ts`** - Validação e processamento
   - Valida estoque disponível na criação de pedidos de pronta entrega
   - Faz saída automática do estoque na criação (não na entrega)

## Estrutura do Banco de Dados

### Tabela `estoque`
```sql
- quantidade_atual: TOTAL do estoque
- quantidade_pronta_entrega: Estoque disponível para pronta entrega
- quantidade_encomenda: Estoque produzido para encomendas
```

### Tabela `movimentacoes_estoque`
```sql
- tipo_estoque: 'pronta_entrega' | 'encomenda'
- tipo_operacao: 'manual' | 'automatica'
- pedido_id: Referência ao pedido (quando automático)
```

## Fluxo de Funcionamento

### Para Pedidos de Pronta Entrega:
1. **Criação do Pedido:**
   - Sistema verifica se há estoque suficiente em `quantidade_pronta_entrega`
   - Se sim, permite a criação
   - **Saída automática do estoque acontece na criação**

2. **Interface:**
   - Mostra apenas produtos com estoque disponível para pronta entrega
   - Produtos sem estoque aparecem desabilitados

### Para Pedidos de Encomenda:
1. **Criação do Pedido:**
   - Não há verificação de estoque (será produzido)
   - Todos os produtos aparecem disponíveis

2. **Mudança para "Produzido":**
   - **Entrada automática no estoque de encomenda**
   - Movimentação registrada automaticamente

3. **Entrega:**
   - Saída do estoque de encomenda
   - Apenas se já houve entrada (produto foi produzido)

## Componentes de Interface

### `EstoqueStatus.tsx`
- Componente para visualizar o status do estoque
- Mostra separadamente estoque de pronta entrega e encomenda
- Indica qual tipo está disponível para o pedido atual
- Inclui explicação das regras

### `ProductSelect.tsx`
- Componente especializado para seleção de produtos
- Adapta a visualização baseado no tipo de pedido
- Mostra estoque disponível ou "Será produzido"

## Logs e Rastreabilidade

Todas as operações automáticas são registradas:
- Tabela `movimentacoes_estoque` com `tipo_operacao = 'automatica'`
- Campo `pedido_id` para rastrear origem
- Campo `tipo_estoque` para separar tipos
- Observações detalhadas sobre a operação

## Validações Implementadas

1. **Estoque insuficiente:** Bloqueia criação de pedidos de pronta entrega sem estoque
2. **Entrega sem produção:** Bloqueia entrega de encomendas sem produção finalizada
3. **Duplicação:** Previne múltiplas entradas/saídas para o mesmo pedido
4. **Separação de estoques:** Encomendas não acessam estoque de pronta entrega

## Status da Implementação

✅ **Regra 1 - COMPLETA:** Entrada automática para encomendas produzidas
✅ **Regra 2 - COMPLETA:** Visualização separada de estoque por tipo
✅ **Interface adaptativa** baseada no tipo de pedido
✅ **Validações de estoque** implementadas
✅ **Movimentações automáticas** registradas
✅ **Componentes especializados** criados 