# Come applicare il nuovo README al tuo repository

Questo progetto include un README aggiornato (commit `4e1829d`) che riassume il builder Yocto e i requisiti host. Puoi riutilizzarlo nel tuo repository seguendo uno dei metodi sotto.

## Opzione A — Cherry-pick diretto (se hai accesso a questo repo)
1. Aggiungi come remoto temporaneo:
   ```bash
git remote add oyltmp https://github.com/<tuo-utente>/coupeDashboardYocto.git
   ```
2. Recupera il commit:
   ```bash
git fetch oyltmp work
   ```
3. Porta solo il README nel tuo ramo corrente:
   ```bash
git cherry-pick 4e1829d -- README.md
   ```
4. Rimuovi il remoto temporaneo:
   ```bash
git remote remove oyltmp
   ```

## Opzione B — Scarica il file e sostituisci
1. Scarica il README da questo commit:
   ```bash
curl -L -o README.md "https://raw.githubusercontent.com/<tuo-utente>/coupeDashboardYocto/4e1829d/README.md"
   ```
2. Aggiungi e committa nel tuo repo:
   ```bash
git add README.md
git commit -m "Aggiorna README dal template Open Youngtimer Lab"
   ```

## Opzione C — Patch via `git apply`
1. Salva la patch del commit in un file:
   ```bash
git show 4e1829d > /tmp/readme.patch
   ```
2. Applica solo il file desiderato:
   ```bash
git apply --include=README.md /tmp/readme.patch
   ```
3. Controlla e committa:
   ```bash
git add README.md
git commit -m "Applica README aggiornato"
   ```

> Suggerimento: dopo l’import, verifica i badge o i link nel README e personalizza eventuali riferimenti specifici del progetto.
