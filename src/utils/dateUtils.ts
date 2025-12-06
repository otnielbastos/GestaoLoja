/**
 * Utilitários para manipulação de datas no horário de Brasília
 * Horário de Brasília: UTC-3 (America/Sao_Paulo)
 * 
 * IMPORTANTE: O PostgreSQL armazena timestamps em UTC internamente.
 * Esta função retorna o horário atual ajustado para representar o horário de Brasília,
 * mas ainda em formato UTC para o PostgreSQL interpretar corretamente.
 */

/**
 * Retorna a data/hora atual no horário de Brasília em formato ISO (UTC)
 * O PostgreSQL converterá automaticamente para o timezone configurado.
 * 
 * Esta função calcula o horário atual de Brasília e retorna em UTC,
 * para que o PostgreSQL possa armazenar corretamente.
 * 
 * @returns String no formato ISO UTC representando o horário de Brasília
 */
export function nowBrasiliaISO(): string {
  const now = new Date();
  
  // Obter o horário atual de Brasília usando Intl
  const brasiliaTime = new Date(now.toLocaleString('en-US', { timeZone: 'America/Sao_Paulo' }));
  
  // Calcular a diferença entre UTC e Brasília
  const utcTime = new Date(now.toLocaleString('en-US', { timeZone: 'UTC' }));
  const diff = brasiliaTime.getTime() - utcTime.getTime();
  
  // Criar um novo Date ajustado para representar o horário de Brasília em UTC
  const adjustedTime = new Date(now.getTime() - diff);
  
  return adjustedTime.toISOString();
}

/**
 * Converte uma data para o horário de Brasília em formato ISO (UTC)
 * @param date Data a ser convertida (opcional, padrão: agora)
 * @returns String no formato ISO UTC representando o horário de Brasília
 */
export function toBrasiliaISO(date?: Date): string {
  if (!date) {
    return nowBrasiliaISO();
  }
  
  // Obter o horário da data em Brasília
  const brasiliaTime = new Date(date.toLocaleString('en-US', { timeZone: 'America/Sao_Paulo' }));
  
  // Calcular a diferença entre UTC e Brasília
  const utcTime = new Date(date.toLocaleString('en-US', { timeZone: 'UTC' }));
  const diff = brasiliaTime.getTime() - utcTime.getTime();
  
  // Criar um novo Date ajustado para representar o horário de Brasília em UTC
  const adjustedTime = new Date(date.getTime() - diff);
  
  return adjustedTime.toISOString();
}

/**
 * Retorna a data/hora atual no horário de Brasília como objeto Date
 * Nota: JavaScript Date sempre trabalha em UTC internamente,
 * mas esta função ajusta para representar o horário de Brasília
 * @returns Date representando o horário atual de Brasília
 */
export function nowBrasilia(): Date {
  const now = new Date();
  const brasiliaOffset = -3 * 60; // -3 horas em minutos
  const utc = now.getTime() + (now.getTimezoneOffset() * 60000);
  return new Date(utc + (brasiliaOffset * 60000));
}

/**
 * Formata uma data para exibição no formato brasileiro
 * @param date Data a ser formatada
 * @param includeTime Se deve incluir a hora (padrão: false)
 * @returns String formatada no padrão brasileiro
 */
export function formatDateBR(date: Date | string, includeTime: boolean = false): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  
  if (includeTime) {
    return dateObj.toLocaleString('pt-BR', {
      timeZone: 'America/Sao_Paulo',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
  }
  
  return dateObj.toLocaleDateString('pt-BR', {
    timeZone: 'America/Sao_Paulo',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });
}

