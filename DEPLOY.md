# Guia de Deploy - Gerenciador de Tarefas

Este documento contém instruções para fazer deploy da aplicação em diferentes plataformas.

## Pré-requisitos

- Conta no GitHub (para conectar com as plataformas de deploy)
- Código da aplicação em um repositório Git

## Opções de Deploy Gratuitas

### 1. Render (Recomendado)

**Vantagens:**
- Deploy automático via GitHub
- PostgreSQL gratuito incluído
- SSL automático
- Fácil configuração

**Passos:**

1. Acesse [render.com](https://render.com) e crie uma conta
2. Conecte sua conta do GitHub
3. Clique em "New +" → "Blueprint"
4. Conecte seu repositório
5. O Render detectará automaticamente o arquivo `render.yaml`
6. Configure as variáveis de ambiente:
   - `RAILS_MASTER_KEY`: Execute `rails credentials:edit` localmente para obter
7. Clique em "Apply" para iniciar o deploy

### 2. Railway

**Vantagens:**
- Deploy muito simples
- PostgreSQL incluído
- Interface moderna

**Passos:**

1. Acesse [railway.app](https://railway.app) e crie uma conta
2. Clique em "New Project" → "Deploy from GitHub repo"
3. Selecione seu repositório
4. Railway detectará automaticamente que é uma aplicação Rails
5. Adicione um banco PostgreSQL:
   - Clique em "New" → "Database" → "Add PostgreSQL"
6. Configure as variáveis de ambiente:
   - `RAILS_MASTER_KEY`: Execute `rails credentials:edit` localmente para obter
   - `DATABASE_URL`: Será configurado automaticamente pelo Railway
7. O deploy iniciará automaticamente

### 3. Fly.io

**Vantagens:**
- Boa performance
- Configuração flexível
- PostgreSQL gratuito

**Passos:**

1. Instale o CLI do Fly.io: `curl -L https://fly.io/install.sh | sh`
2. Crie uma conta: `fly auth signup`
3. No diretório da aplicação, execute: `fly launch`
4. Siga as instruções para configurar a aplicação
5. Adicione PostgreSQL: `fly postgres create`
6. Configure a variável DATABASE_URL: `fly secrets set DATABASE_URL=sua_url_aqui`
7. Configure RAILS_MASTER_KEY: `fly secrets set RAILS_MASTER_KEY=sua_chave_aqui`
8. Deploy: `fly deploy`

## Configurações Importantes

### Variáveis de Ambiente Necessárias

- `RAILS_MASTER_KEY`: Chave secreta do Rails (obrigatória)
- `DATABASE_URL`: URL de conexão com PostgreSQL (configurada automaticamente)
- `RAILS_ENV=production`: Ambiente de produção
- `RAILS_SERVE_STATIC_FILES=true`: Para servir arquivos estáticos
- `RAILS_LOG_TO_STDOUT=true`: Para logs no console

### Obtendo a RAILS_MASTER_KEY

Execute no terminal local:
```bash
cat config/master.key
```

Ou edite as credenciais:
```bash
rails credentials:edit
```

## Verificação Pós-Deploy

Após o deploy, verifique:

1. **Aplicação carregando**: Acesse a URL fornecida pela plataforma
2. **Banco de dados**: Teste criando uma tarefa
3. **Funcionalidades**: Teste todas as funcionalidades (criar, editar, deletar, subtarefas)
4. **Responsividade**: Teste em diferentes dispositivos

## Troubleshooting

### Erro de Assets
Se os assets não carregarem:
```bash
# Localmente, execute:
rails assets:precompile
git add .
git commit -m "Precompile assets"
git push
```

### Erro de Banco de Dados
Verifique se:
- DATABASE_URL está configurada corretamente
- As migrações foram executadas (comando `release` no Procfile)

### Erro de RAILS_MASTER_KEY
- Certifique-se de que a variável está configurada na plataforma
- Verifique se o valor está correto (sem espaços ou quebras de linha)

## Atualizações

Para atualizar a aplicação:
1. Faça as alterações no código
2. Commit e push para o repositório
3. O deploy será automático (Render/Railway) ou execute `fly deploy` (Fly.io)

## Monitoramento

- **Render**: Logs disponíveis no dashboard
- **Railway**: Logs em tempo real no dashboard
- **Fly.io**: `fly logs` no terminal

## Custos

Todas as plataformas oferecem planos gratuitos adequados para projetos pessoais:
- **Render**: 750 horas/mês gratuitas
- **Railway**: $5 de crédito mensal
- **Fly.io**: Recursos limitados gratuitos

Para aplicações com mais tráfego, considere os planos pagos.
