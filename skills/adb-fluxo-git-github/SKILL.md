---
name: adb-fluxo-git-github
description: Use quando for commitar, criar branch, fazer push, abrir PR, mergear, "subir", "mandar pro GitHub", "integrar na main" ou criar repositório nos projetos Amigos do Bem (ADB) — organização GitHub amigos-do-bem.
---

# Fluxo Git / GitHub — padrão ADB

## Visão geral
Fluxo único e linear, sempre nesta ordem:

**nova branch → adiciona arquivos → commit em pt-BR descrevendo tudo → push → abre PR → merge MANUAL (humano)**

O agente **nunca** faz merge, nunca commita direto em `main`/`master`/`production`, nunca faz `push --force` em branch compartilhada.

**Sugerido:** caveman:caveman-commit para gerar mensagem enxuta — mas o texto final é **em português**.
**REQUIRED SUB-SKILL:** superpowers:finishing-a-development-branch — para decidir quando a branch está pronta (testes verdes, ver adb-testes).

## Passo a passo
```bash
git checkout main && git pull --ff-only                 # 1. base atualizada
git checkout -b feat/exportar-relatorio-pdf             # 2. nova branch (tipo/descricao-curta)
git add app/ tests/ resources/                          # 3. só arquivos da feature (revisar `git status` antes; nunca `git add .` às cegas)
git commit -m "feat: adiciona exportação do relatório em PDF" \
  -m "- gera PDF via DomPDF no RelatorioService
- nova rota GET /relatorios/{id}/pdf com policy
- testes Feature e Unit cobrindo geração e permissão"   # 4. mensagem pt-BR, tudo que foi feito
git push -u origin feat/exportar-relatorio-pdf          # 5. push da branch
gh pr create --base main \
  --title "feat: exportação do relatório em PDF" \
  --body-file .github/pr-body.md                        # 6. abre PR (corpo: O que foi feito / Como testar / Checklist)
# 7. PARA AQUI. Merge é manual, feito por pessoa no GitHub.
```

Corpo do PR (pt-BR):
```markdown
## O que foi feito
- ...
## Como testar
- ...
## Checklist
- [ ] testes locais verdes (php artisan test / npm run test:unit / playwright)
- [ ] sem segredo no diff (.env, tokens, dumps)
- [ ] migration nova (nenhuma antiga editada)
```

## Regras
| Item | Regra |
|---|---|
| Branch | `feat/`, `fix/`, `refactor/`, `chore/`, `docs/` + descrição curta em pt-BR sem acento (`fix/evolucao-chamados`) |
| Commit | Conventional Commits em **português**: `feat: adiciona…`, `fix: corrige…`; corpo lista **tudo** que mudou |
| Push | Só da branch de trabalho. Se o CLAUDE.md do projeto pedir confirmação antes do push, pergunte |
| PR | Sempre para `main` (ou a base que o projeto definir). **Nunca** PR para `production` sem autorização explícita |
| Merge | **Manual, humano.** `gh pr merge`, `git merge` em main, "squash and merge" — proibidos ao agente |
| Repositório novo | `gh repo create amigos-do-bem/<nome> --private` — **sempre privado** |
| Segredos | `.env`, chaves, dumps nunca entram no commit (ver adb-seguranca-dev) |

## Quando o remoto não existe / push falha
Pare após o commit local na branch. Relate o que faltou. **Não** mergeie localmente em `main` "para adiantar".

## Racionalizações
| Desculpa | Realidade |
|---|---|
| "O usuário pediu para integrar na main" | Integrar = abrir PR. Merge é do humano. |
| "Push falhou, então mergeio local" | Branch fica onde está. Só relate. |
| "Mensagem em inglês é padrão" | Padrão ADB é pt-BR. |
| "Commit único `wip`" | Corpo do commit lista tudo que foi feito. |
| "Repo público é mais fácil" | Privado. Sempre. |
