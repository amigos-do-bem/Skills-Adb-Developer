# Skills-Adb-Developer

Conjunto de skills do Claude Code com os **padrões de desenvolvimento da Amigos do Bem**.
Uma skill por tópico; o índice `adb-padroes` aponta qual usar. Todas em pt-BR. Processo (superpowers), código mínimo (ponytail) e comunicação enxuta (caveman) fazem parte do conjunto.

## Instalação

**Como plugin (recomendado — atualiza junto com o repositório):**
```
/plugin marketplace add amigos-do-bem/Skills-Adb-Developer
/plugin install skills-adb-developer@skills-adb-developer
```

**Como skills pessoais (`~/.claude/skills`):**
```bash
git clone git@github.com:amigos-do-bem/Skills-Adb-Developer.git
./Skills-Adb-Developer/instalar.sh
```
Reinicie a sessão do Claude Code depois de instalar.

**Plugins que fazem parte do conjunto** (instalar também):
```
/plugin install superpowers@claude-plugins-official      # processo: brainstorming, TDD, debugging, planos, verificação
/plugin marketplace add caveman && /plugin install caveman@caveman   # comunicação enxuta, /caveman-commit, /caveman-review
/plugin install frontend-design@claude-plugins-official  # direção estética (dentro das regras de adb-design-ui)
/plugin marketplace add DietrichGebert/ponytail && /plugin install ponytail@ponytail   # código mínimo (escada YAGNI), /ponytail-review
```

**Laravel (por projeto):** skills de https://skills.laravel.cloud/ (`laravel-patterns`, `laravel-security`, `laravel-tdd`):
```bash
composer require laravel/boost --dev
php artisan boost:add-skill <owner/skill>   # comando exato na página de cada skill
```

## Skills

| Skill | Tópico | Regra central |
|---|---|---|
| `adb-padroes` | Índice | Qual skill usar; regras transversais (pt-BR, repos privados, merge humano) |
| `adb-backend-laravel` | Backend Laravel/PHP | Controller → Service → Repository (interface) → Model; `strict_types`; modelagem e relacionamentos |
| `adb-frontend-vue-typescript` | Frontend TypeScript | Vue 3 `<script setup>` + Tailwind; service/composable/view; assíncrono com **Skeleton**, erro e vazio |
| `adb-design-ui` | Design | **Roboto**, cores **70/20/10** via tokens, **Font Awesome**, checklist das 10 heurísticas de Nielsen |
| `adb-seguranca-dados` | Segurança dos bancos (DRM, ERP, SGE) | Mascaramento por padrão, sensível só com Gate + auditoria, anonimização fora de produção, **acesso aos bancos só por VPN**, Cloudflare |
| `adb-testes` | Testes | TDD obrigatório: PHPUnit/Pest, Vitest, **Playwright e2e** por tela; lint não é teste |
| `adb-fluxo-git-github` | Versionamento | branch → add → commit pt-BR → push → PR → **merge manual**; repositórios privados |
| `adb-seguranca-dev` | Segurança de desenvolvimento | `.env`, PHP, `.gitignore`, rodar e testar localmente antes de stage |
| `adb-pipeline-producao` | Lógica até produção | local → stage → **fila de teste humana** → produção → reports; agente para no stage |
| `vue-development` | Terceiro (MIT, Alexander Opalic) | Padrões Vue 3 + TS + Testing Library |
| `nielsen-heuristics-audit` | Terceiro (MIT, mastepanoski) | Auditoria pelas 10 heurísticas |
| `ui-design-review` | Terceiro (MIT, mastepanoski) | Revisão visual (tipografia, cor, espaçamento) |

Licenças dos terceiros em `terceiros/`.

## Fluxo padrão de uma feature

brainstorming → plano → branch nova → TDD (`adb-testes`) → implementação (`adb-backend-laravel` / `adb-frontend-vue-typescript` / `adb-design-ui`) → segurança (`adb-seguranca-dados` / `adb-seguranca-dev`) → rodar local → commit pt-BR → push → PR → **merge humano** → stage → **fila humana** → produção → reports.

## Como as skills foram validadas

Cada skill `adb-*` seguiu TDD de documentação (`superpowers:writing-skills`): cenário rodado por um agente **sem** a skill (baseline, falhas registradas), skill escrita contra essas falhas, cenário repetido **com** a skill, brechas fechadas e re-testadas. Exemplos de falhas do baseline corrigidas: lib nova + spec + constante para encaixar um `refDebounced` que já existia (4 arquivos para 2 linhas); merge local na `main` sem PR; `deploy:prod` executado com "gate de stage simulado como OK"; CPF e laudo médico completos para qualquer autenticado; fonte e paleta fora do padrão; `php -l` apresentado como teste.

## Alterar uma skill

1. Rodar o cenário sem a mudança e registrar o comportamento.
2. Editar `skills/<nome>/SKILL.md` (frontmatter `name` + `description` começando com "Use quando…").
3. Rodar de novo com a mudança; fechar racionalizações novas na tabela da skill.
4. PR seguindo `adb-fluxo-git-github`.
