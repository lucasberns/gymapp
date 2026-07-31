# 🏋️ Void v4

*Treino vira XP. XP vira rank.*

App de treino e nutrição em **um único arquivo**, feito como PWA — instala no celular, funciona offline e roda direto do GitHub Pages. Sem servidor, sem conta, sem complicação.

## ✨ Funcionalidades

- 📑 **Quatro abas:** Treino / Nutrição / Evolução / Config
- 💪 **Treinos:** lista de treinos com anel de progresso; cada exercício com carga (kg), repetições, botão +1 e marcação de concluído
- 📈 **Histórico de carga:** ao marcar um exercício como feito, a carga do dia é gravada (menu ⋯ → Histórico mostra a evolução)
- ⏱️ **Timer de descanso** com presets e aviso sonoro ao terminar
- 🥗 **Plano alimentar:** macros totais e consumidos, refeições com horário, tela de detalhe, ordenação por horário e **importação da dieta por texto** (cole e pronto)
- 🏆 **Ranks por grupo muscular:** treinar dá XP; suba de Ferro a Lenda em Peito, Costas, Pernas, Ombros, Bíceps, Tríceps e Abdômen
- 📊 **Aba Evolução:** dias treinados, ranks e gráfico de progressão de carga por exercício
- 🎨 **Temas:** Black e Purple
- 💾 **Backup:** exportar/importar dados em JSON
- 📱 **PWA instalável** com modo offline

## 📂 Arquivos do repositório

```
index.html            → o app inteiro
manifest.webmanifest  → configuração do PWA
sw.js                 → service worker (modo offline)
icons/                → ícones do app (PNG)
.nojekyll             → evita processamento do Jekyll no GitHub Pages
README.md             → este arquivo
```

## 🚀 Como publicar no GitHub Pages

1. **Crie um repositório público** no [GitHub](https://github.com/new) (ex.: `gymapp`).

2. **Envie todos os arquivos** do projeto. Você pode fazer isso de duas formas:

   **Opção A — Upload pela interface web:** na página do repositório, clique em **Add file → Upload files**, arraste todos os arquivos (incluindo a pasta `icons/`) e confirme o commit.

   **Opção B — Via git no terminal:**

   ```bash
   git init
   git add .
   git commit -m "Void v4"
   git branch -M main
   git remote add origin https://github.com/SEU-USUARIO/NOME-DO-REPO.git
   git push -u origin main
   ```

3. No repositório, vá em **Settings → Pages** e configure:
   - **Source:** Deploy from a branch
   - **Branch:** `main` — pasta `/ (root)`
   - Clique em **Save**

4. Aguarde **~1 minuto** e acesse a URL final:

   ```
   https://SEU-USUARIO.github.io/NOME-DO-REPO/
   ```

## 📱 Como instalar no iPhone

1. Abra a URL do app no **Safari**
2. Toque no botão **Compartilhar** (quadrado com seta para cima)
3. Escolha **Adicionar à Tela de Início**

Pronto! O app abre em **tela cheia**, com ícone próprio, e **funciona offline**.

## 💾 Backup dos dados

Os dados ficam salvos no **localStorage do dispositivo** — ou seja, **não sincronizam entre aparelhos**. Para não perder nada:

- Use **Config → Exportar dados** regularmente para baixar um arquivo JSON com tudo
- Para restaurar (ou migrar para outro aparelho), basta **importar** esse arquivo de backup

## 🔒 Privacidade

**Nenhum dado sai do seu dispositivo.** Sem contas, sem rastreamento, sem servidor. Tudo fica salvo localmente, só com você.
