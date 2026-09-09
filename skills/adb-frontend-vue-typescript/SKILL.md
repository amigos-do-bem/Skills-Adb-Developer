---
name: adb-frontend-vue-typescript
description: Use quando criar ou alterar frontend TypeScript/Vue 3 nos projetos Amigos do Bem (ADB) — tela, view, componente, composable, service de API, store Pinia, listagem, formulário, chamada axios, estado de carregamento.
---

# Frontend Vue 3 + TypeScript — padrão ADB

## Visão geral
Stack fixa: **Vue 3 `<script setup lang="ts">` + Tailwind CSS + Pinia + Vue Router + axios**.
Toda chamada de dado é assíncrona e **toda tela/lista/card que espera dado mostra Skeleton**.
Estilo só com classes Tailwind e tokens do tema (`tailwind-theme.css`) — nada de CSS escrito à mão.

**REQUIRED SUB-SKILL:** vue-development (alexanderop) — padrões de componente, composable, teste. Instalado em `~/.claude/skills/vue-development`.
**REQUIRED SUB-SKILL:** adb-design-ui — fonte, cores, ícones, heurísticas.
**REQUIRED SUB-SKILL:** superpowers:test-driven-development — Vitest antes do código; e2e em adb-testes.

## Estrutura de pastas (por feature)
```
src/
  views/<Feature>/<Feature>Lista.vue       # página: orquestra, sem regra
  components/<feature>/<Feature>Tabela.vue # UI pura, props tipadas, emits tipados
  components/shared/Skeleton*.vue          # skeletons reutilizáveis
  composables/use<Feature>.ts              # estado assíncrono + regra de tela
  services/<feature>Service.ts             # só HTTP; retorna tipos, nunca `any`
  types/<feature>.ts                       # interfaces/enum do domínio
  stores/<feature>Store.ts                 # Pinia só p/ estado compartilhado entre telas
```

## Padrões de projeto (obrigatório)
| Padrão | Onde | Regra |
|---|---|---|
| Service (Adapter) | `services/` | função por endpoint, `Promise<T>`, instância axios única (`http.ts`, `baseURL` de `import.meta.env.VITE_API_URL`) |
| Composable (estado) | `composables/` | expõe `{ dados, carregando, erro, carregar }`; sem template, sem `alert` |
| Container/Presentational | `views/` vs `components/` | view busca dado; componente só recebe props e emite |
| Props/Emits tipados | componentes | `defineProps<{ itens: Chamado[] }>()`, `defineEmits<{ novo: [] }>()`, `defineModel<T>()` |
| Enum + label map | `types/` | `type Status = 'aberto' \| 'fechado'`; `STATUS_LABEL: Record<Status, string>` |

## Assíncrono + Skeleton (obrigatório)
Todo composable de carga segue este contrato:
```ts
// composables/useChamados.ts
import { ref, shallowRef } from 'vue'
import { listarChamados } from '@/services/chamadoService'
import type { Chamado, ChamadoStatus } from '@/types/chamado'

export function useChamados() {
  const chamados = shallowRef<Chamado[]>([])
  const carregando = ref(false)
  const erro = ref<string | null>(null)
  let controle: AbortController | undefined

  async function carregar(status?: ChamadoStatus): Promise<void> {
    controle?.abort()
    controle = new AbortController()
    carregando.value = true
    erro.value = null
    try {
      chamados.value = await listarChamados({ status }, controle.signal)
    } catch (e) {
      if (!(e instanceof DOMException && e.name === 'AbortError')) {
        erro.value = 'Não foi possível carregar os chamados. Tente novamente.'
      }
    } finally {
      carregando.value = false
    }
  }

  return { chamados, carregando, erro, carregar }
}
```
No template, **três estados sempre**: `<SkeletonTabela v-if="carregando" :linhas="5" />`, erro com botão "Tentar novamente", vazio com texto contextual. Skeleton = mesma geometria do conteúdo final, `animate-pulse`, `aria-busy="true"` no container.
Ações (salvar, excluir): botão com `:disabled="enviando"` + texto "Salvando…"; nunca duplo envio.

## Clean code
- Nome em pt-BR para domínio (`chamado`, `unidade`), inglês para técnico (`ref`, `props`).
- Função ≤ 30 linhas; componente ≤ 250 linhas — acima disso, extrai componente/composable.
- Sem `any`; erro em `catch` é `unknown` e é estreitado.
- Sem lógica no template além de ternário simples; use `computed`.
- Datas via util única (`utils/data.ts`), moeda via `utils/moeda.ts`.

## Checklist antes de dizer "pronto"
- [ ] Teste Vitest do composable/componente escrito antes e passando
- [ ] View nova → `e2e/<tela>.spec.ts` (Playwright) no mesmo commit
- [ ] Skeleton + erro + vazio nos três lugares
- [ ] Só Tailwind (zero `<style>` com regras próprias, exceto tokens do tema)
- [ ] Props/emits tipados, `service` sem `any`
- [ ] Ícones FontAwesome, fonte Roboto (adb-design-ui)
- [ ] `vue-tsc --noEmit` sem erro

## Erros comuns
| Erro | Correção |
|---|---|
| `<style scoped>` com CSS próprio | Classes Tailwind; cor via token `bg-primaria` etc. |
| `carregando` sem skeleton ("só um spinner") | Skeleton com o formato do conteúdo. Spinner só em botão. |
| axios direto na view | `services/xService.ts` + composable. |
| Filtro muda e resposta antiga chega depois | `AbortController` (acima). |
| Store Pinia para dado de uma tela só | Composable local. Store = compartilhado. |
