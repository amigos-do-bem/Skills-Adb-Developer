---
name: adb-pipeline-producao
description: Use quando for publicar, fazer deploy, "subir", "colocar em produção", "mandar pra stage/homologação", promover versão, ou quando alguém pede que uma feature "esteja em produção hoje" nos projetos Amigos do Bem (ADB).
---

# Pipeline até produção — padrão ADB

## Visão geral
Ordem fixa, sem pular etapa:

**Testes locais → Stage → Fila de teste (humano) → Produção → Reports e erros**

O agente vai **até o stage**. Fila de teste e produção são de **pessoas**. Urgência, apresentação para doadores ou pedido do gestor **não** encurtam o caminho — mudam a prioridade na fila humana.

**REQUIRED SUB-SKILL:** adb-testes, adb-seguranca-dev (etapa 1), adb-fluxo-git-github (PR).
**REQUIRED SUB-SKILL:** superpowers:verification-before-completion — cada etapa só é "feita" com saída de comando.

## Etapas
| # | Etapa | Quem | Entrada | Saída ("pronto" quando) |
|---|---|---|---|---|
| 1 | Testes locais | dev/agente | branch da feature | suíte verde local + smoke manual local; saída colada |
| 2 | Stage | dev/agente via PR + CI | PR aprovado, merge manual em `main`/`stage` | deploy em stage ok, migrations rodadas, smoke em URL de stage |
| 3 | Fila de teste (humano) | QA / gestor / solicitante | link de stage + roteiro "Como testar" do PR | pessoa registra **OK por escrito** (comentário no PR/ticket) |
| 4 | Produção | pessoa autorizada | OK da etapa 3 + tag de versão | deploy prod + smoke prod pela pessoa |
| 5 | Reports e erros | dev | prod no ar | monitorar logs/Sentry/Cloudflare por 24h; erro → `fix/` volta à etapa 1 |

## O que o agente faz
1. Etapa 1 completa (adb-seguranca-dev §Rodar localmente).
2. PR com seção **"Como testar"** escrita para quem vai testar na etapa 3 (passos, dados, resultado esperado).
3. Após merge humano: acompanhar deploy de stage (CI/`deploy:stage`), rodar smoke em stage, **anexar evidência** no PR.
4. Avisar a fila humana: quem testa, onde, o quê, prazo.
5. **Parar.** Não roda `deploy:prod`, não promove, não cria tag de release sem instrução explícita da pessoa responsável **após** o OK da etapa 3.
6. Se chamado pós-produção: ler reports/erros, abrir `fix/`, recomeçar da etapa 1.

## O que o agente nunca faz
- Executar `deploy:prod`, `vercel --prod`, `forge deploy production`, `git push production` ou equivalente.
- Escrever "gate simulado como OK", "validação assumida", "gestor deve aprovar" e seguir adiante.
- Mergear o próprio PR para chegar mais rápido ao stage (adb-fluxo-git-github).
- Pular stage "porque é hotfix".

## Racionalizações
| Desculpa | Realidade |
|---|---|
| "Gestor pediu produção hoje" | Prioridade na fila humana sobe. Etapas não caem. Avise o gestor do que falta. |
| "Simulei o gate de stage como OK para não travar" | Gate sem pessoa = sem gate. Pare e chame quem testa. |
| "Scripts são só echo, não faz mal rodar prod" | Comando é hábito. Nunca roda `prod`. |
| "Hotfix pequeno, direto pra prod" | Hotfix segue as 5 etapas, só mais rápido. |
| "Ninguém disponível para testar" | Relate o bloqueio. Não substitua a pessoa. |

## Relato final (modelo)
```
Etapa 1 — local: php artisan test → 42 passed; npm run test:unit → 18 passed; smoke em http://localhost:8000/relatorios/1/pdf ok
Etapa 2 — stage: PR #123 aberto (aguarda merge humano) | deploy stage ok, smoke https://stage.../pdf ok
Etapa 3 — fila humana: aguardando OK de <pessoa> — roteiro no PR
Etapa 4/5 — não iniciadas (depende do OK acima)
```
