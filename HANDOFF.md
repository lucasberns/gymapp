# Void (ex-GymApp) — Documento de Handoff / Contexto

> Documento para retomar o desenvolvimento em outra conversa. Cole este conteúdo
> (ou aponte o Claude para este arquivo) no início do novo chat. Descreve o projeto,
> todas as decisões tomadas, o estado atual e as pendências.
> **Última atualização deste doc:** referente ao estado após a v4.4.0 (rebrand Void).
> Nomes internos (chaves de `localStorage`, `id`s, comentários de código) continuam
> `gym_*` — só o nome/ícone voltados ao usuário mudaram. Não renomear storage, sem motivo.

---

## 1. O que é o projeto

**Void** (nome interno/repositório: GymApp) — app pessoal de academia (uso do
próprio dono, em pt-BR) para anotar:
- **Treinos**: vários treinos, cada um com exercícios (peso e reps da **última série** — só 1 série por exercício, é um registro, não um logger de séries múltiplas).
- **Plano alimentar**: refeições com título, horário e conteúdo; macros (kcal/prot/carbo/gordura) somados no topo, com total do dia e total consumido.

Design **minimalista, preto**. Dois temas: **Black** (padrão) e **Purple** — **ambos são escuros** (não existe tema claro dentro do app; "Purple" é preto-arroxeado com um leve glow).

Uso no **iPhone** como PWA (adicionar à tela de início pelo Safari).

---

## 2. Localização e estrutura

Diretório: `C:\Users\Lucas Alexandre\Documents\Claude Code\_Pessoal\GymHub`

```
index.html              # O APP INTEIRO (single-file: HTML + CSS + JS inline). ~1500 linhas.
manifest.webmanifest    # Manifesto PWA
sw.js                   # Service worker (offline). Cache atual: "gymapp-v4.4.0"
.nojekyll               # Vazio — impede o Jekyll no GitHub Pages
README.md               # Instruções de deploy + uso (pt-BR)
icons/
  icon-192.png              # 192x192 (escuro) — manifest/Android
  icon-512.png              # 512x512 (escuro) — manifest (any + maskable)
  apple-touch-icon.png      # 180x180 (escuro) — ícone da tela de início iOS
  apple-touch-icon-light.png# 180x180 (claro) — NÃO usado no momento (iOS não troca)
  favicon-dark.png          # 96x96 (escuro) — favicon aba (tema escuro)
  favicon-light.png         # 96x96 (claro)  — favicon aba (tema claro)
  source-dark.png           # FONTE 1024x1024 (dev — não precisa subir)
  source-light.png          # FONTE 1024x1024 (dev — não precisa subir)
  generate-app-icons.ps1    # Gerador de ícones (dev — não precisa subir)
```

**Sem build, sem dependências, sem CDN.** Tudo é vanilla e inline. Roda abrindo o
`index.html` direto (file://) e também servido (https).

---

## 3. Stack e decisões-chave

- **Armazenamento: `localStorage`.** Escolha explícita do usuário entre as opções que
  ele mapeou (localStorage / Google Drive API / Supabase-Firebase / n8n). Optou por
  localStorage pela simplicidade. Chaves: `gym_workouts`, `gym_meals`, `gym_theme`.
- **Deploy: GitHub Pages.** Por isso **todos os caminhos são relativos** (`./`, `icons/...`,
  nunca começa com `/`) — funciona sob `usuario.github.io/repo/`.
- **PWA**: instalável, offline via service worker (cache-first + fallback de navegação
  para `./index.html`).
- **Segurança**: `esc()` escapa todo dado do usuário injetado em HTML; `safeId()` valida
  ids interpolados em handlers `onclick`; import de backup é normalizado/validado.

---

## 4. Histórico de versões

- **v1** — App base: abas Treino/Nutrição, cards, localStorage. Design preto minimalista.
- **v2 (deploy GitHub Pages + PWA)** — virou PWA (manifest/sw/icons); séries/reps/kg,
  check de concluído + progresso, timer de descanso, macros consumido vs. total,
  exportar/importar backup JSON, aba Config com temas.
- **v3 (refatoração da aba Treino)** — mudanças estruturais descritas abaixo.
- **Ícones v3.0.1** — ícones profissionais (halter, gradiente roxo) gerados a partir de
  2 imagens; ver seção 7.
- **v4.0.0** — (1) **Histórico de carga por exercício**: ao marcar como feito, grava
  `{d, w, r}` em `exercise.hist` (1 entrada/dia, máx. 30); menu ⋯ do exercício ganhou
  "Histórico" (bottom sheet). (2) **Nutrição no padrão v3**: lista compacta (check +
  nome + horário · kcal + ⋯ + ›) e tela full-screen `#meal-detail` com horário,
  conteúdo e macros; campo `collapsed` removido do modelo; botão "+" no header
  (adeus botão inferior). (3) **Anel de progresso** (SVG) nas linhas da lista de
  treinos. (4) **SW network-first para navegações** — não precisa mais bumpar o CACHE
  ao mudar só o `index.html`. (5) Limpeza: `autoResize`/`autoResizeAll` mortos,
  `index.html.v2bak`, CSS órfão, ícone light fora do precache.
- **v4.1.0** — (1) **Aba Evolução** (4ª aba): tiles "dias treinados"/"esta semana",
  **ranks por grupo muscular** e lista de progressão de carga (tap → histórico com
  gráfico SVG). (2) **Sistema de XP/ranks**: +15 XP por exercício concluído (1x/dia,
  anti-farm via hist), grupo detectado por palavra-chave no nome (`detectGroup`,
  tríceps antes de bíceps por causa de "rosca testa"); tiers Ferro→Bronze→Prata→Ouro→
  Platina→Esmeralda→Diamante→Mestre→Grão-Mestre→Lenda (0/100/250/500/900/1400/2000/
  2800/3800/5000 XP). Inspirado em apps tipo GymLevels (ranks por músculo).
  (3) **Importar dieta por texto** (Nutrição → "Importar dieta"): cola texto, blocos
  separados por linha em branco, parser best-effort de nome/horário/macros, preview
  ao vivo, Adicionar ou Substituir tudo. (4) Gráfico de carga no sheet de histórico.
  Novo storage: `gym_stats = { xp: {grupo: n}, days: ['YYYY-MM-DD'] }` (normalizado
  por `normalizeStats`, incluído no export/import/apagar tudo).
- **v4.2.0** — (1) Peso corporal na aba Evolução (REMOVIDO na v4.3 — o usuário quis
  dizer peso dos exercícios). (2) **"Resetar treino"** no menu ⋯ do treino:
  desmarca todos os checks (hist e XP do dia ficam). (3) Keywords de pernas ampliadas:
  `flexor`/`extensor` (pegam "flexora"/"extensora"), adutor, abdutor, glúteo, gêmeos —
  fix do "Mesa flexora" caindo em Outros. (4) Tab bar mais baixa: `--tab-h` 64→56px e
  `padding-bottom: max(safe-bottom − 14px, 0)` nos botões (knobs comentados no CSS).
- **v4.3.0** — Peso corporal removido (era mal-entendido; "peso" = carga dos
  exercícios). Os **gráficos de carga agora aparecem inline** nos cards de
  "Progressão de carga" da aba Evolução (antes só dentro do sheet de histórico),
  com delta total no subtítulo (▲/▼ vs. primeiro registro). Tap no card continua
  abrindo o histórico detalhado.
- **v4.4.0** — **Rebrand**: GymApp → **Void** (`<title>`, manifest `name`/`short_name`/
  `description`, About screen, README, tagline "Treino vira XP. XP vira rank.").
  Nomes internos (`gym_*` no storage, comentários) preservados de propósito — trocar
  storage key não traz benefício e arrisca perder dados de quem já usa. **Ícone novo**:
  halter em fundo roxo escuro com glow (enviado pelo usuário), salvo como
  `icons/source-dark.png`; como só veio 1 imagem, `source-light.png` é cópia do mesmo
  arquivo (sem variante clara separada — decisão consciente, o ícone instalado no
  iOS é estático mesmo, ver seção 7). Todos os PNGs regerados via
  `generate-app-icons.ps1`. `sw.js` `CACHE` bumpado para `gymapp-v4.4.0` (troca de
  ícone exige bump, network-first só cobre o HTML).

### Recursos REMOVIDOS a pedido (não reintroduzir sem pedir):
- Ícones de grupo muscular (foram testados como emoji e depois como SVG — o usuário
  **não gostou** e mandou remover).
- `confirm()` ao deletar treino/exercício/refeição — **deletar é direto, sem confirmação**.
- **Bloqueio (lock) de treino** — removido na v3.
- Campo **"Séries"** por exercício — removido na v3 (só 1 série).

---

## 5. Estado atual das funcionalidades (v3)

### Aba Treino
- Título grande **"Treinos"** + botão **"+"** redondo no topo (header) que cria treino.
- A aba mostra **só a LISTA** de treinos (cards compactos, tappáveis): nome + subtítulo
  com contagem de exercícios + progresso `N/M` + menu **⋯** + chevron `›`.
- Tocar no card abre uma **tela full-screen** `#workout-detail` (overlay que cobre a tab
  bar; fecha pelo **botão voltar**). É onde ficam os exercícios do treino.
- Cada exercício (na tela de detalhe): círculo de **check** (marca feito), **nome**
  (texto estático, editado via ⋯ → Editar nome), menu **⋯**, e os campos peso/reps em
  **"pills"** (estilo arredondado) + botão **"+1"** para incrementar 1 rep rápido.
- **Menu ⋯** (bottom sheet) — igual para item da lista e para exercício — agrupa:
  **Editar nome, Mover para cima, Mover para baixo, Duplicar, Excluir** (Excluir em
  vermelho; mover desabilitado nas pontas).
- Nome (treino e exercício) só é editável pelo **sheet de renomear** (`openRename`/
  `saveRename`). Ao **adicionar exercício**, o sheet de renomear abre automaticamente.
- Progresso `N/M` + barra; carimba `lastCompleted` (ISO) quando todos ficam feitos.
- **Timer de descanso** (FAB flutuante): presets 30s/1:00/1:30/2:00/3:00 + custom,
  pausar/retomar/cancelar, badge com tempo, beep (WebAudio, criado em gesto p/ iOS),
  vibração se disponível. FAB visível na aba Treino e na tela de detalhe.

### Aba Nutrição (reformulada na v4 — mesmo padrão da aba Treino)
- Barra de macros no topo: total do dia + linha "Consumido" (soma das refeições com
  check) + barra de progresso de kcal.
- Botões "Resetar dia" e "Ordenar por horário".
- **Lista compacta** de refeições: check de "comido" (esmaece a linha), nome,
  subtítulo "horário · kcal", menu ⋯ e chevron ›. Tocar abre a tela full-screen
  `#meal-detail` (horário, conteúdo, 4 macros). Menu ⋯ = Editar nome / Mover /
  Duplicar / Excluir. Botão "+" redondo no header cria refeição.

### Aba Config
- **Tema**: cards Black / Purple (persiste em `gym_theme`; atualiza `meta[theme-color]`).
- **Dados**: Exportar (baixa `gym-backup-AAAA-MM-DD.json`, shape
  `{version:2, exportedAt, theme, workouts, meals}`), Importar (valida + normaliza +
  confirma + troca), Apagar tudo (duplo confirm).
- **Sobre**: versão do app (`APP_VERSION = '3.0.0'`), nota de localStorage, dica de
  instalar no iPhone.

### Funções-chave no JS (nomes reais, para orientar edições)
`load`/`save`/`uid`/`safeId`/`esc`/`fmtDate` · `normalizeWorkouts`/`normalizeMeals`
(migração; descartam campos legados muscle/sets/locked/collapsed sem quebrar) ·
`setTheme`/`applyTheme` · `switchTab` · `renderWorkouts`/`renderWorkoutDetail`/
`refreshWorkouts`/`ringSvg` · `openWorkout`/`closeWorkout` · `addWorkout`/`removeWorkout`/
`moveWorkout`/`duplicateWorkout` · `addExercise`/`removeExercise`/`moveExercise`/
`duplicateExercise`/`toggleExerciseDone`/`recordHistory`/`incReps`/`updateExField` ·
`openWorkoutMenu`/`openExerciseMenu`/`openMealMenu` (menu ⋯) · `openRename`/`saveRename`
(types: workout/exercise/meal) · `openHistory`/`closeHistory` ·
refeições: `renderMeals`/`renderMealDetail`/`refreshMeals`/`openMeal`/`closeMeal`/
`addMeal`/`removeMeal`/`moveMeal`/`duplicateMeal`/`toggleMealDone`/`updateMealField` ·
stats/ranks: `renderStats`/`detectGroup`/`rankFor`/`chartSvg`/`normalizeStats`/`localDay`
(constantes `RANKS`/`GROUP_KEYWORDS`/`GROUP_LABELS`/`XP_PER_EXERCISE`) ·
treino: `resetWorkout` (desmarca checks) ·
dieta: `parseDietText`/`openDietImport`/`previewDietImport`/`applyDietImport` ·
timer: `openTimerSheet`/`startTimer`/`pauseResumeTimer`/`cancelTimer`/`beep` ·
dados: `exportData`/`importData`/`clearAllData`/`toast`.

---

## 6. Modelo de dados (localStorage)

```js
// gym_workouts: array de treinos
{ id, name, exercises: [ {id, name, weight, reps, done, hist} ], lastCompleted? }
//   exercise = UMA série só: weight (kg, string), reps (string), done (bool)
//   hist = histórico de carga: [{d: ISO, w: string, r: string}], 1/dia, máx. 30.
//   Gravado por recordHistory() quando o exercício é marcado como feito.

// gym_meals: array de refeições (collapsed foi removido na v4)
{ id, name, time, content, kcal, prot, carb, fat, done }

// gym_theme: 'black' | 'purple'

// gym_stats (v4.1+): gamificação + atividade
{ xp: { peito: 560, ... }, days: ['2026-07-13', ...] }
//   xp por grupo (peito/costas/pernas/ombros/biceps/triceps/abdomen/outros)
//   days = dias com pelo menos 1 exercício concluído (máx. 730)
//   (weight/peso corporal existiu só na v4.2; normalizeStats descarta)
```
`normalizeWorkouts`/`normalizeMeals` rodam em `load()` e migram dados antigos
(descartam `muscle`, `sets`, `locked`, `collapsed`), regeneram ids inválidos, ignoram
entradas malformadas, validam `hist`. Import usa as mesmas funções. Export: `{version: 4, ...}`.

---

## 7. PWA / Ícones

- **manifest.webmanifest**: name/short_name "Void", `start_url`/`scope` = `"./"`,
  standalone, bg/theme `#000000`, ícones 192/512 (any) + 512 (maskable) — todos escuros.
- **sw.js**: `CACHE = "gymapp-v4.4.0"`. Precache: `./`, `./index.html`,
  `./manifest.webmanifest`, os PNGs de ícone usados. **Navegações são network-first**
  (v4): mudanças no `index.html` aparecem no próximo load online, sem bump de cache.
  Só bump o `CACHE` se mudar ícones/manifest (assets continuam cache-first).
- **Ícones**: halter com gradiente roxo. Dark = halter branco em fundo escuro→roxo;
  Light = halter escuro em fundo claro→roxo. Gerados de `source-dark.png`/`source-light.png`
  (1024²) via `icons/generate-app-icons.ps1`.

### ⚠️ Limitação importante (ícone x tema)
O ícone do PWA na **tela de início do iPhone é ESTÁTICO** — o iOS "fotografa" no momento
de adicionar e **não troca** quando você muda o tema do sistema. `prefers-color-scheme`
em `apple-touch-icon` é **ignorado** para o ícone instalado (só apps nativos via Xcode
trocam). Por isso o app usa **um único** `apple-touch-icon` (o **escuro**). A troca
claro/escuro **funciona só no favicon da aba** do navegador (desktop/Android).
→ Se o usuário quiser o ícone **claro** como fixo, trocar o `href` do `apple-touch-icon`
para `icons/apple-touch-icon-light.png` no `<head>` e re-subir.
→ Para ver ícone novo no iPhone: remover da tela de início e adicionar de novo (cache do iOS).

---

## 8. Deploy (GitHub Pages)

Arquivos que **precisam** ir para o repositório:
```
index.html  sw.js  manifest.webmanifest  .nojekyll  README.md
icons/icon-192.png  icons/icon-512.png  icons/apple-touch-icon.png
icons/apple-touch-icon-light.png  icons/favicon-dark.png  icons/favicon-light.png
```
Não precisa subir: `source-*.png`, `generate-app-icons.ps1`, `HANDOFF.md`.

Comandos:
```bash
git add index.html sw.js manifest.webmanifest .nojekyll README.md icons/
git commit -m "..."
git push
```
GitHub → Settings → Pages → Deploy from a branch → `main` / root. URL:
`https://SEU-USUARIO.github.io/NOME-DO-REPO/`.
Desde a v4 o SW é **network-first para navegações**: mudanças no `index.html`
aparecem sozinhas no próximo load online. Só bump o `CACHE` no `sw.js` se mudar
ícones/manifest.

---

## 9. Preferências do usuário / regras de trabalho

- **Antes de gerar qualquer código que persiste dados**, perguntar (1) o que salvar e
  (2) qual storage usar (localStorage / Google Drive / Supabase-Firebase / n8n). O usuário
  tem infra própria de **n8n**.
- **Idioma da interface: sempre pt-BR.**
- **Imagens de referência (ex1/ex2/ex3)**: o usuário enviou 3 prints de um app de
  referência que guiam o **design visual futuro**, mas **só aplicar o visual quando ele
  pedir explicitamente**. Até lá, manter a identidade atual (preto + purple).
- Deletar é **sem confirmação**. Não reintroduzir ícones de grupo muscular nem lock.
- Ele usa iPhone/Safari; pesa o trade-off simplicidade × durabilidade dos dados.

---

## 10. Pendências / próximos passos possíveis

- **Redesign visual** com base nos prints de referência (ex1/ex2/ex3): o usuário
  autorizou na v4, mas os prints não estavam disponíveis na conversa — foi aplicado
  só o anel de progresso (descrito no handoff). Quando ele enviar os prints, aplicar
  o restante (header estilo "Workouts", botão "Start", tipografia).
- Ícone da tela de início é fixo (escuro). Trocar para claro é 1 linha, se quiser.
- Backup só local (localStorage não sincroniza entre aparelhos). Se um dia quiser
  multi-device, considerar n8n (infra do usuário) ou Supabase — mas exige a pergunta de
  storage antes.
- (Nenhum bug conhecido em aberto no momento.)

---

## 11. Como retomar em outro chat

1. Abrir a pasta `C:\Users\Lucas Alexandre\Documents\Claude Code\- Pessoal\App Gym` no
   Claude Code (a memória do projeto já carrega automaticamente o resumo).
2. Colar este `HANDOFF.md` (ou pedir "leia o HANDOFF.md") para o contexto completo.
3. Continuar de onde parou. O app inteiro está em `index.html`.
