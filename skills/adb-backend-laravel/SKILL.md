---
name: adb-backend-laravel
description: Use quando criar ou alterar código backend Laravel/PHP nos projetos Amigos do Bem (ADB) — rota, controller, model, migration, relacionamento Eloquent, regra de negócio, consulta, endpoint de API. Inclui modelagem de banco de dados.
---

# Backend Laravel — padrão ADB

## Visão geral
Toda feature backend segue **Controller → Service → Repository → Model**, com tipagem estrita.
Controller fino, regra no Service, SQL no Repository, Model só estado e relações.

**REQUIRED SUB-SKILL:** adb-testes + superpowers:test-driven-development — teste Feature/Unit escrito **antes** do código, mesmo sem `vendor`/projeto completo (nesse caso: escreve, e declara que não rodou). "Só arquivos soltos, sem projeto" não dispensa `tests/`.
**Referência externa:** https://skills.laravel.cloud/ (`laravel-patterns`, `laravel-security`, `laravel-tdd`).
Instalar num projeto: `composer require laravel/boost --dev` e depois o comando `php artisan boost:add-skill ...` mostrado na página do skill.

## Camadas (obrigatório)

| Camada | Pasta | Responsabilidade | Proibido |
|---|---|---|---|
| Controller | `app/Http/Controllers/` | receber `FormRequest`, chamar Service, devolver `Resource`/`JsonResponse` | query, regra, `if` de negócio |
| Service | `app/Services/` | regra de negócio, transação (`DB::transaction`), orquestração | `Model::where` direto, `response()` |
| Repository | `app/Repositories/` | **interface** `XRepository` + `EloquentXRepository`; toda consulta Eloquent/SQL | regra de negócio |
| Model | `app/Models/` | `$fillable`, `casts()` (método, Laravel 11+), relações, scopes | lógica de negócio |
| FormRequest | `app/Http/Requests/` | validação + autorização | — |
| Resource | `app/Http/Resources/` | formato JSON exposto (nunca devolver model cru) | — |
| Enum | `app/Enum/` | valores fixos (`enum X: string`) | strings mágicas |

Interface ↔ implementação registradas em `AppServiceProvider::register()` com `$this->app->bind(XRepository::class, EloquentXRepository::class)`.

## Tipagem otimizada (obrigatório em todo arquivo novo)
- `declare(strict_types=1);` na 1ª linha após `<?php`.
- Tipo em **todo** parâmetro, retorno e propriedade. `void`/`never` quando aplicável.
- Construtor com promoção: `public function __construct(private readonly XRepository $repo) {}`.
- Coleções: `Collection<int, Unidade>` no docblock; `LengthAwarePaginator` em listagens.
- Sem `mixed`, sem `array` sem docblock de forma (`@param array{nome: string, regiao_id: int} $dados`) — prefira DTO `readonly class` quando o array cresce.
- Enums PHP 8.1+ em vez de constantes soltas.

## Modelagem de banco
- Migration por tabela; **nunca editar migration já commitada** — criar nova (`add_x_to_y_table`).
- `foreignId('regiao_id')->constrained()->restrictOnDelete()` (cascade só em pivot/filho descartável).
- Índice em toda FK usada em filtro e em colunas de busca frequente; `unique` onde a regra exige.
- Tipos justos: `string(n)` com tamanho, `decimal(12,2)` para dinheiro, `date` vs `dateTime`, `boolean`, `softDeletes()` quando o dado tem valor histórico.
- Nomes em pt-BR snake_case, plural nas tabelas (`unidades`, `regioes`), pivot em ordem alfabética (`unidade_usuario`).
- Dados sensíveis (CPF, saúde, renda): ver adb-seguranca-dados antes de criar a coluna.

## Relacionamentos
- Declarar os dois lados (`belongsTo` + `hasMany`/`belongsToMany`), com tipo de retorno (`: BelongsTo`).
- Eager load (`with`) em listagens; N+1 é bug.
- Pivot com `withTimestamps()` e `withPivot()` quando há coluna extra.

## Exemplo mínimo (Service)
```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Unidade;
use App\Repositories\UnidadeRepository;
use Illuminate\Support\Facades\DB;

final class UnidadeService
{
    public function __construct(private readonly UnidadeRepository $repositorio) {}

    /** @param array{nome: string, regiao_id: int, gestores?: int[]} $dados */
    public function criar(array $dados): Unidade
    {
        return DB::transaction(function () use ($dados): Unidade {
            $unidade = $this->repositorio->criar($dados);
            $this->repositorio->sincronizarGestores($unidade, $dados['gestores'] ?? []);

            return $unidade;
        });
    }
}
```

## Checklist antes de dizer "pronto"
- [ ] Teste Feature (rota) + Unit (service) escritos **antes** e passando (`php artisan test`)
- [ ] `strict_types`, tipos em tudo, sem `mixed`
- [ ] Repository é interface + Eloquent, bind no provider
- [ ] Controller sem query/regra; Resource no retorno
- [ ] Migration nova, FKs `constrained`, índices
- [ ] Nenhum segredo/hardcode — ver adb-seguranca-dev

## Erros comuns
| Erro | Correção |
|---|---|
| Lógica no controller "porque é pequeno" | Cresce sempre. Service desde o 1º método. |
| `Model::where()` dentro do Service | Move para Repository. Service recebe interface. |
| Repository concreto sem interface | Cria interface; teste mocka a interface. |
| `protected $casts = []` | Laravel 11+: método `protected function casts(): array`. |
| Editar migration antiga | Nova migration sempre. |
| Retornar `$model` cru | `XResource::make($model)`. |
