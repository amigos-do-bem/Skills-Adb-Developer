---
name: adb-design-ui
description: Use quando desenhar, estilizar ou revisar qualquer interface dos projetos Amigos do Bem (ADB) — tela nova, componente visual, login, dashboard, formulário, escolha de cor, fonte, ícone, protótipo HTML, revisão de usabilidade/UX.
---

# Design de interface — padrão ADB

## Visão geral
Identidade fixa: **Roboto**, cores **70 / 20 / 10**, ícones **Font Awesome**, usabilidade checada pelas **10 heurísticas de Nielsen**.
Design com **cuidado**: pense antes de estilizar — para quem é a tela, qual a ação principal, o que dá errado.

**REQUIRED SUB-SKILL (revisão):** nielsen-heuristics-audit e ui-design-review (mastepanoski) — em `~/.claude/skills/`. Rodar o audit em toda tela nova antes de entregar.
**Sugerido:** frontend-design (plugin) para direção estética, respeitando as regras abaixo.

## Tipografia
- Única família: `Roboto` (Google Fonts) com fallback `system-ui, sans-serif`. Não introduzir outra fonte.
- Escala: título 24–32/500, subtítulo 18–20/500, corpo 14–16/400, legenda 12/400. Line-height 1.5 no corpo.
- Tailwind: `font-sans` apontando para Roboto no tema (`--font-sans: "Roboto", ...`).

## Cores 70 / 20 / 10
| Faixa | Papel | Exemplo de uso |
|---|---|---|
| 70% | neutro/fundo (`background`, `surface`, texto) | página, cards, tabelas, texto |
| 20% | primária da marca (`primary`) | cabeçalho, navegação, títulos, botão primário |
| 10% | destaque/acento (`secondary`/`accent`) | CTA principal, badge, foco, alerta |

- Cores **só via tokens** do tema (`tailwind-theme.css`: `--sys-color-primary`, `--sys-color-secondary`, `--sys-color-background`…). Nunca hex solto no componente.
- Status: `success` verde, `warning` âmbar, `danger` vermelho, `info` azul — sempre com texto/ícone junto (cor nunca é o único sinal).
- Contraste mínimo WCAG AA (4.5:1 texto, 3:1 UI).

## Ícones
- **Font Awesome** (`@fortawesome/vue-fontawesome` + `free-solid-svg-icons`), registrar só os ícones usados na `library`.
- Não misturar bibliotecas (Lucide, Material, Bootstrap Icons, PrimeIcons) num mesmo projeto.
- Ícone sempre com rótulo textual ou `aria-label`.

## Heurísticas de Nielsen — checklist por tela
| # | Heurística | O que verificar |
|---|---|---|
| 1 | Visibilidade do status | Skeleton/carregando, "Salvando…", toast de sucesso |
| 2 | Linguagem do usuário | pt-BR, termos do domínio ONG (chamado, unidade, beneficiário) |
| 3 | Controle e liberdade | Cancelar, voltar, desfazer, fechar modal com Esc |
| 4 | Consistência | mesmos componentes Base*, mesma posição de botões |
| 5 | Prevenção de erro | validação inline, confirmar ação destrutiva (ConfirmDialog) |
| 6 | Reconhecimento > memória | labels visíveis, filtros mostram valor atual |
| 7 | Flexibilidade | atalhos, busca, filtros salvos |
| 8 | Estética minimalista | um CTA por tela, sem ruído |
| 9 | Recuperar de erro | mensagem diz o que aconteceu e o que fazer, botão "Tentar novamente" |
| 10 | Ajuda | tooltip/placeholder de exemplo onde há dúvida |

## Processo (think)
1. Listar: usuário, tarefa principal, dados exibidos, ações, estados (vazio, carregando, erro, sucesso).
2. Esboçar hierarquia: o que é 70/20/10 nesta tela.
3. Implementar com componentes Base* existentes antes de criar novo.
4. Rodar `nielsen-heuristics-audit` na tela; corrigir severidade ≥ 3.
5. Testar em 360px e 1280px; teclado (Tab/Enter/Esc).

## Erros comuns
| Erro | Correção |
|---|---|
| Outra fonte "porque combina" | Roboto. Sempre. |
| 60/30/10 ou paleta livre | 70/20/10 com tokens do tema. |
| Ícones inline SVG de outra lib | FontAwesome registrado na library. |
| Heurísticas "aplicadas intuitivamente" | Checklist acima, item a item, no relato final. |
| Cor como único indicador de status | Texto + ícone junto. |
