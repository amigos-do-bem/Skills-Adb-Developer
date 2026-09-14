---
name: adb-padroes
description: Use ao iniciar qualquer tarefa nos projetos da ONG Amigos do Bem (ADB) — repositórios da organização GitHub amigos-do-bem, projetos Laravel (API) e Vue/TypeScript (frontend), sistemas DRM/ERP/SGE, GPS, chamados, padarias, educação — para saber qual skill do conjunto ADB aplicar.
---

# Padrões ADB — índice do conjunto

## Visão geral
Conjunto de skills que define **como** se desenvolve nos projetos Amigos do Bem. Este índice só aponta; cada skill traz as regras. Processo (superpowers) primeiro, depois implementação (adb-*) com o **menor diff que resolve** (ponytail), e comunicação enxuta (caveman). Ponytail governa o que se constrói; caveman, como se fala.

## Qual skill usar
| Situação | Skill |
|---|---|
| Vai criar/alterar feature (qualquer camada) | superpowers:brainstorming → superpowers:writing-plans → superpowers:test-driven-development |
| Vai escrever ou alterar código (qualquer camada, inclusive bug) | ponytail:ponytail antes da primeira linha — reusar o que já existe no repo/dependências antes de criar |
| Bug, teste falhando, comportamento estranho | superpowers:systematic-debugging |
| Backend Laravel/PHP, banco, migration, Eloquent | adb-backend-laravel |
| Frontend Vue/TypeScript, tela, componente, service | adb-frontend-vue-typescript |
| Cor, fonte, ícone, layout, UX, revisão de tela | adb-design-ui (+ nielsen-heuristics-audit, ui-design-review) |
| CPF, saúde, renda, exportação, cópia de banco, Cloudflare | adb-seguranca-dados |
| Teste unitário, e2e Playwright, "está pronto?" | adb-testes (+ superpowers:verification-before-completion) |
| Commit, branch, push, PR, repositório | adb-fluxo-git-github (+ superpowers:finishing-a-development-branch, caveman:caveman-commit) |
| Token, .env, .gitignore, rodar local | adb-seguranca-dev |
| Deploy, stage, produção, urgência | adb-pipeline-producao |
| Revisar PR/diff | caveman:caveman-review ou superpowers:requesting-code-review; ponytail:ponytail-review para caçar excesso (lib reinventada, abstração sem uso, dependência nova) |
| Escrever/alterar skill deste conjunto | superpowers:writing-skills |

## Plugins que fazem parte do conjunto
| Plugin | Papel | Instalação |
|---|---|---|
| **superpowers** | processo: brainstorming, TDD, debugging, planos, verificação, git worktrees | `/plugin install superpowers@claude-plugins-official` |
| **caveman** | comunicação enxuta (`/caveman`), commit (`/caveman-commit`, texto em pt-BR), review (`/caveman-review`), subagentes (`cavecrew`) | `/plugin marketplace add caveman` + `/plugin install caveman@caveman` |
| **ponytail** | código mínimo: escada YAGNI antes de escrever (`/ponytail lite\|full\|ultra`), review de excesso (`/ponytail-review`), auditoria (`/ponytail-audit`), dívida marcada `ponytail:` (`/ponytail-debt`) | `/plugin marketplace add DietrichGebert/ponytail` + `/plugin install ponytail@ponytail` |
| **frontend-design** | direção estética dentro das regras de adb-design-ui | `/plugin install frontend-design@claude-plugins-official` |
| vue-development (alexanderop) | padrões Vue 3 + TS + Testing Library | copiado em `~/.claude/skills/vue-development` |
| nielsen-heuristics-audit, ui-design-review (mastepanoski) | auditoria de UX/UI | copiados em `~/.claude/skills/` |
| Laravel skills (skills.laravel.cloud) | `laravel-patterns`, `laravel-security`, `laravel-tdd` | por projeto: `composer require laravel/boost --dev` + comando `php artisan boost:add-skill …` da página |

## Regras transversais (valem sempre)
- Idioma: código/identificadores de domínio, commits, PRs, mensagens ao usuário em **pt-BR**.
- Repositórios **privados** na org `amigos-do-bem`.
- Nada de segredo em código, chat ou commit.
- Nada sai para stage sem teste local verde; nada vai para produção sem OK humano.
- Menor diff que resolve: helper, componente ou dependência que já está no repo vem antes de arquivo novo. Arquivo/lib nova só quando há **lógica nova** — e aí ela nasce com teste (adb-testes). Trocar `x` por um helper existente não é lógica nova: não ganha arquivo, nem spec, nem constante própria.
- Ponytail decide o **tamanho** do código; adb-testes decide se **tem teste**. Quando parecerem conflitar: lógica nova → teste; reuso puro → sem teste novo.
- Se o projeto tiver `CLAUDE.md`, ele prevalece sobre estas skills onde houver conflito.

## Fluxo padrão de uma feature
brainstorming → plano → branch nova → TDD (adb-testes) → implementação mínima (ponytail + adb-backend-laravel / adb-frontend-vue-typescript / adb-design-ui) → segurança (adb-seguranca-dados / adb-seguranca-dev) → rodar local → commit pt-BR → push → PR → **merge humano** → stage → **fila humana** → produção → reports.
