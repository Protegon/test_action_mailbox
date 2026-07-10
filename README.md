# Sistema de chamados por IMAP

Este app lê e-mails da pasta `INBOX` via `net-imap`, cria chamados em SQLite e
lista os chamados recebidos em uma interface HTML básica.

## Configuração

Crie um arquivo `.env` na raiz do projeto usando `.env.example` como base:

```bash
IMAP_HOST=greenmail
IMAP_PORT=3143
IMAP_SSL=false
IMAP_USERNAME=support
IMAP_PASSWORD=change-me
IMAP_FOLDER=INBOX
IMAP_POLL_INTERVAL_MINUTES=5
SMTP_HOST=localhost
SMTP_PORT=3025
SMTP_TO=support@mail.example.com
```

`IMAP_POLL_INTERVAL_MINUTES` é usado pelo Solid Queue recurring scheduler e
deve ser informado como número de minutos. Exemplo: `5`.

## Banco de dados

Os chamados ficam na tabela `tickets`:

- `email_from`: endereço do remetente, tratado como usuário
- `title`: assunto do e-mail
- `content`: conteúdo do e-mail

Execute as migrations antes de iniciar o app:

```bash
bin/rails db:migrate
```

## Execução

Suba o app Rails normalmente e mantenha o worker do Solid Queue rodando para a
sincronização periódica:

```bash
bin/rails server
bin/jobs
```

A lista de chamados fica disponível em `/`.

## Docker Compose

Também é possível subir a aplicação com Docker Compose:

```bash
docker compose up --build
```

O serviço `web` expõe a aplicação em `http://localhost:3000`. O serviço
`worker` executa o Solid Queue e processa a sincronização IMAP recorrente. Os
arquivos SQLite ficam persistidos no volume `rails-storage`.

O Compose também sobe o GreenMail como servidor SMTP + IMAP de teste:

- SMTP: `localhost:3025`
- IMAP: `localhost:3143`
- usuário IMAP: `support`
- senha IMAP: `change-me`

Para enviar um e-mail de teste ao GreenMail pelo container Rails:

```bash
docker compose run --rm web ./bin/rails runner script/send_test_ticket_email_via_greenmail.rb
```

Depois disso, o `worker` lê a INBOX do GreenMail via IMAP e cria o chamado.
