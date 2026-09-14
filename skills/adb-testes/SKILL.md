---
name: adb-testes
description: Use quando implementar qualquer função, classe, endpoint, componente ou tela nos projetos Amigos do Bem (ADB), antes de escrever o código — e quando for dizer que algo "funciona", "está pronto" ou "foi validado". Cobre teste unitário (PHPUnit/Pest, Vitest) e e2e (Playwright).
---

# Testes — padrão ADB

## Visão geral
**Nenhum código de produção sem teste automatizado que falhou antes.** `php -l`, "script rápido no tinker", "revisei manualmente" e "não precisa rodar" **não são teste**.

**REQUIRED SUB-SKILL:** superpowers:test-driven-development (RED → GREEN → REFACTOR).
**REQUIRED SUB-SKILL:** superpowers:verification-before-completion — só afirme "passa" com a saída do comando na tela.

## Violar a letra da regra é violar a regra
Prazo apertado, "tarefa simples", "esqueleto sem vendor", "o usuário disse que não precisa rodar" — nada disso dispensa o teste. Se o ambiente não roda, **escreva o teste mesmo assim** e diga explicitamente que não foi executado.

## O que testar, com o quê
| Camada | Ferramenta | Arquivo | Mínimo |
|---|---|---|---|
| Service / util PHP | PHPUnit ou Pest (`tests/Unit`) | `XServiceTest.php` | caminho feliz + cada regra/borda + exceção |
| Endpoint Laravel | Feature test (`tests/Feature`) | `XControllerTest.php` | 200 com shape JSON, 422 validação, 401/403 permissão |
| Repository | Feature com `RefreshDatabase` + factory | `EloquentXRepositoryTest.php` | filtro, paginação, eager load |
| Composable / util TS | Vitest (`src/__tests__`) | `useX.spec.ts` | estados `carregando`/`erro`/dados, abort |
| Componente Vue | Vitest + @testing-library/vue | `X.spec.ts` | render por props, emit, skeleton visível quando carregando |
| Fluxo do usuário | **Playwright e2e** (`e2e/` ou `tests/`) | `x.spec.ts` | login → ação principal → resultado visível |

**Regra estrutural:** toda view/página nova (`src/views/**`, `src/pages/**`) nasce com o par `e2e/<nome-da-tela>.spec.ts` no mesmo commit. Sem o arquivo, a tela não existe para o PR. Login, cadastro e qualquer tela com formulário são as primeiras — não as últimas.

## O que NÃO exige teste novo
Reuso puro de helper/componente/dependência já existente, sem lógica nova (trocar `search` por `refDebounced(search)`, usar `formatCnpj` que já existe, adicionar `min="0"` num input). Não crie arquivo, função pura ou constante só para ter o que testar — isso é código a mais (ponytail). Surgiu regra nova? Aí nasce com teste.

## Fluxo obrigatório
1. Escrever o teste que descreve o comportamento. Rodar → **vermelho** (colar a saída).
2. Código mínimo. Rodar → **verde** (colar a saída).
3. Refatorar com verde.
4. Antes de PR: `php artisan test` / `npm run test:unit` / `npx playwright test` — todos verdes localmente (ver adb-pipeline-producao).

## Exemplo (Pest — service de prazo)
```php
<?php

declare(strict_types=1);

use App\Services\CalculadoraPrazoService;

it('pula fim de semana para prioridade alta', function () {
    $service = new CalculadoraPrazoService();
    $sexta = new DateTimeImmutable('2026-09-11');

    expect($service->calcularPrazo('alta', $sexta)->format('Y-m-d'))->toBe('2026-09-14');
});

it('rejeita prioridade desconhecida', function () {
    (new CalculadoraPrazoService())->calcularPrazo('urgente', new DateTimeImmutable());
})->throws(InvalidArgumentException::class);
```

## Playwright e2e — regras
- Seletores por papel/texto (`getByRole('button', { name: 'Entrar' })`), nunca por classe Tailwind.
- Sem `waitForTimeout`; use `expect(locator).toBeVisible()`.
- Login via `storageState` reaproveitado; API mockada com `page.route` quando o backend não está disponível.
- Rodar headless no CI, `--headed` só para depurar.

## Racionalizações que invalidam a entrega
| Desculpa | Realidade |
|---|---|
| "Validei com php -l e um script" | Lint ≠ teste. Script solto não fica no repo nem roda no CI. |
| "Não dá pra rodar sem vendor/node_modules" | Escreva o teste; declare que não rodou. Nunca omita. |
| "Não há projeto Laravel/Vite aqui, só arquivos soltos" | Crie `tests/` ou `__tests__/` ao lado dos arquivos. Teste escrito ≠ teste rodado; escrito é obrigatório, rodado é declarado. |
| "Unit já cobre a tela, e2e fica pra depois" | Unit não abre navegador. Tela nova sem `e2e/*.spec.ts` está incompleta. |
| "Prazo apertado, testo depois" | Teste depois nunca falha primeiro = não prova nada. |
| "É só uma tela de login" | Login é o fluxo mais crítico; e2e obrigatório. |
| "Revisei manualmente o TS" | `vue-tsc` + Vitest, ou não está verificado. |

## Red flags — pare e escreva o teste
- Código escrito e nenhum arquivo em `tests/` ou `__tests__/` tocado
- Relato final sem saída de comando de teste
- Palavras "provável", "deve funcionar", "checks baratos"
- View/página nova sem arquivo em `e2e/`
- Relato com "e2e não foi escrito" sem motivo de bloqueio técnico real
