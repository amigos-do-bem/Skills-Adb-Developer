---
name: adb-fluxo-git-github
description: Use quando for commitar, criar branch, fazer push, abrir PR, mergear, "subir", "mandar pro GitHub", "integrar na main" ou criar repositório nos projetos Amigos do Bem (ADB) — organização GitHub amigos-do-bem.
---

# Fluxo Git / GitHub — padrão ADB

## Visão geral
Fluxo único e linear, sempre nesta ordem:

**código da tarefa → nova branch → adiciona arquivos → commit em pt-BR descrevendo tudo → push → abre PR → merge MANUAL (humano)**

Nomenclatura baseada em [padroes-e-nomenclaturas-no-git](https://github.com/JuniorLima22/padroes-e-nomenclaturas-no-git): o **código da tarefa** (`SIGLA-número` do quadro da vitrine, ex.: `SGE-35`) vai no nome da branch e no rodapé do commit — é assim que o commit aparece na tarefa.

O agente **nunca** faz merge, nunca commita direto em `main`/`master`/`production`, nunca faz `push --force` em branch compartilhada.

**Sugerido:** caveman:caveman-commit para gerar mensagem enxuta — mas o texto final é **em português**.
**REQUIRED SUB-SKILL:** superpowers:finishing-a-development-branch — para decidir quando a branch está pronta (testes verdes, ver adb-testes).

## Passo a passo
```bash
# 0. código da tarefa: SGE-35 (sem tarefa no quadro? crie a tarefa antes; projeto fora da vitrine: use o código do issue/Jira; sem nenhum: pergunte)
git checkout main && git pull --ff-only                       # 1. base atualizada
git checkout -b feat/exportar-relatorio-pdf-SGE-35            # 2. tipo/descricao-curta-SIGLA-n
git add app/ tests/ resources/                                # 3. só arquivos da feature (revisar `git status`; nunca `git add .` às cegas)
git commit -F - <<'MSG'                                       # 4. tipo(escopo): assunto no imperativo + corpo + rodapé
feat(relatorio): adiciona exportação do relatório em PDF

- gera PDF via DomPDF no RelatorioService
- nova rota GET /relatorios/{id}/pdf com policy
- testes Feature e Unit cobrindo geração e permissão

Tarefa: SGE-35
MSG
git push -u origin feat/exportar-relatorio-pdf-SGE-35         # 5. push da branch
gh pr create --base main \
  --title "feat(relatorio): exportação do relatório em PDF" \
  --body-file .github/pr-body.md                              # 6. abre PR (corpo termina com "Tarefa: SGE-35")
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

Tarefa: SGE-35
```

## Regras
| Item | Regra |
|---|---|
| Tipos | `feat` (função nova), `fix` (bug), `docs`, `perf`, `refactor`, `style` (formatação), `test`, `improvement` (melhora algo que existe) |
| Branch | `<tipo>/<descricao-curta>-<SIGLA>-<n>`: pt-BR, minúsculas, sem acento, hífens; código no fim (`fix/evolucao-chamados-CHM-12`) |
| Commit | `<tipo>(<escopo>): <assunto no imperativo>` em **português** (`adiciona`, `corrige`, `altera`); escopo = onde mudou (`quadro`, `login`, `relatorio`), **nunca** o número da tarefa; corpo lista **tudo** que mudou; rodapé `Tarefa: SIGLA-n` (várias: `Tarefa: SGE-35, SGE-36`) e `BREAKING CHANGE: …` se houver |
| Branch com PR aberto | **Nunca renomear** — o GitHub fecha o PR. Precisa de código/nome novo? Ponha no título e no corpo do PR; o nome fica para a próxima branch |
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
| "Não tem código de tarefa, vai sem" | Crie a tarefa no quadro (ou peça o código). Sem código o commit não liga à tarefa. |
| "`feat(#35)` já diz a tarefa" | Escopo é a área do código; a tarefa vai no rodapé `Tarefa: SGE-35`. |
| "Renomeio a branch do PR para seguir o padrão" | Renomear fecha o PR. Corrija título/corpo; mantenha a branch. |
| "Repo público é mais fácil" | Privado. Sempre. |
