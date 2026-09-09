---
name: adb-seguranca-dev
description: Use quando configurar integração externa, token, chave de API, senha de banco, URL de serviço, variável de ambiente, novo projeto Laravel/PHP, .gitignore, ou antes de subir qualquer código para stage nos projetos Amigos do Bem (ADB).
---

# Segurança de desenvolvimento — padrão ADB

## Visão geral
Quatro regras fixas: **segredo só no `.env`**, **PHP no backend**, **`.gitignore` completo**, **rodou e testou localmente antes de stage**.

**REQUIRED SUB-SKILL:** adb-testes — "testou localmente" = suíte automatizada verde.
**Relacionado:** adb-seguranca-dados (dados pessoais), adb-pipeline-producao (ordem dos ambientes).

## `.env`
- Token, senha, chave, URL de serviço externo, instance id → **variável no `.env`**, lido em `config/*.php` via `env()`. Código usa `config('services.zapi.token')`, **nunca** `env()` fora de `config/`.
- `.env.example` sempre atualizado com a chave nova e valor vazio/fictício.
- Um `.env` por ambiente (`.env.staging`, `.env.production` ficam no servidor, não no repo). Frontend: `VITE_*` em `.env.development|staging|production`; só valor público (URL da API), nunca segredo — o bundle é público.
- Segredo que apareceu em chat, prompt, print ou commit está **vazado**: rotacionar antes de subir.
- `php artisan config:cache` após alterar `.env` em servidor.

```php
// config/services.php
'zapi' => [
    'url'      => env('ZAPI_BASE_URL', 'https://api.z-api.io/instances'),
    'instance' => env('ZAPI_INSTANCE_ID'),
    'token'    => env('ZAPI_TOKEN'),
],
```

## PHP
- Backend em **PHP 8.2+ / Laravel** (ver adb-backend-laravel). Sem scripts Node/Python soltos fazendo papel de backend.
- `composer audit` sem vulnerabilidade alta antes de PR. Dependência nova precisa de justificativa no PR.
- Validação sempre server-side (`FormRequest`); frontend valida só para UX.

## `.gitignore` (mínimo)
```gitignore
# Laravel
/vendor
/node_modules
/public/build
/public/hot
/public/storage
/storage/*.key
/storage/logs/*
.env
.env.*
!.env.example
.phpunit.result.cache
/.phpunit.cache
auth.json
*.sql
*.dump
# Frontend
dist
dist-ssr
*.local
/test-results/
/playwright-report/
/playwright/.cache/
# Editor / SO
.idea
.vscode/*
!.vscode/extensions.json
.DS_Store
```
Antes do 1º commit de projeto novo: `git status` não pode listar `.env`, dump, `vendor`.

## Rodar localmente antes de stage (obrigatório)
1. Descobrir como o projeto roda: `README.md`, `CLAUDE.md`, `composer.json`/`package.json` scripts, `docker-compose.yml`, `.env.example`.
2. Subir local: `php artisan serve` (ou Sail/Docker), `npm run dev`; migrar com `php artisan migrate --seed` em banco local.
3. Rodar a suíte: `php artisan test`, `npm run test:unit`, `npx playwright test` — **saída verde colada no relato**.
4. Exercitar a feature manualmente na URL local (smoke).
5. Só então: PR → stage (adb-fluxo-git-github, adb-pipeline-producao).

Se não conseguir rodar localmente, **dizer isso explicitamente** e não afirmar que está pronto para stage.

## Checklist de PR
- [ ] Nenhum valor secreto no diff (`git diff | grep -iE "token|secret|password|key"` revisado)
- [ ] `.env.example` atualizado
- [ ] `.gitignore` cobre arquivos novos gerados
- [ ] Rodou local + testes verdes (saída no relato)
- [ ] Segredo exposto no chat → rotacionado

## Racionalizações
| Desculpa | Realidade |
|---|---|
| "Hardcode só para testar, depois tiro" | Vai pro commit. `.env` desde a 1ª linha. |
| "É só URL, não é segredo" | URL com token/instance no caminho é segredo. `.env`. |
| "Não dá pra rodar local, testo no stage" | Stage não é ambiente de teste do dev. Faça rodar local ou declare o bloqueio. |
| "O `.env` já está no gitignore padrão" | Confira `git status`. Esqueleto mínimo muitas vezes não tem. |
