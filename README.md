# 🚗 Open Youngtimer Lab — Embedded Platform & Yocto Builder

[![License](https://img.shields.io/badge/License-MIT-blue)]()  
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey)]()  
[![Target](https://img.shields.io/badge/Target-Raspberry%20Pi%204%20%7C%20CM5-orange)]()  
[![Language](https://img.shields.io/badge/Written%20in-Bash-green)]()  

---

## 🪩 Panoramica

Questo repository unisce due componenti principali:

1. **Yocto Builder** — ambiente interattivo minimale per generare immagini Linux embedded su Raspberry Pi 4 e Compute Module 5.  
2. **Open Youngtimer Lab** — iniziativa no-profit dedicata allo sviluppo open-source di sistemi elettronici e software per le youngitimer altri veicoli d’epoca.

Il laboratorio Open Youngtimer Lab utilizzerà questa toolchain come base per costruire **dashboard digitali, moduli sensori e strumenti di telemetria** completamente open-source.

Nel repository convivono ricette Yocto e sorgenti Qt/QML: grazie al `CMakeLists.txt` di root puoi aprire l’intero workspace in QtCreator come progetto CMake e lavorare sugli stessi file che Yocto include via `EXTERNALSRC`.

[Seguimi su WhatsApp](https://whatsapp.com/channel/0029Vb7HTF8It5s4jT0nj20P)


---

## ⚙️ Yocto Builder

### ✅ Funzionalità principali

- Setup automatico dei layer (`poky`, `meta-openembedded`, `meta-raspberrypi`, `meta-qt6`, `meta-sa`)
- Costruzione di immagini personalizzate (`sa-image-minimal`)
- Esecuzione diretta in **QEMU** (ARM64)
- Supporto a **Raspberry Pi 4 / CM5**
- Generazione e installazione di SDK cross-compile
- Flash di una SD card pronta all'uso
- Modalità **DEV** veloce per avviare QEMU senza passaggi interattivi

### 💡 Utilizzo

Prerequisiti consigliati:

- Distribuzione Linux (x86_64) con almeno **200 GB** liberi su disco
- Dipendenze base: `git`, `tar`, `xz-utils`, `python3`, `gawk`, `wget`
- Connessione Internet stabile (per scaricare sorgenti e layer)
- Facoltativo: ambiente **Docker** o VM dedicata per non contaminare il sistema host
@@ -67,59 +69,80 @@ Menu interattivo:

Suggerimento: per avviare QEMU in modalità sviluppo senza passare dal menu usa
`./yocto.sh -d`, che salta direttamente all'opzione **3️⃣** con flag `SA_MODE=dev`.

### 📜 Cosa fa `yocto.sh` passo-passo

Il file [`yocto.sh`](./yocto.sh) è interamente auto-consistente e gestisce sia le verifiche dell'host sia le operazioni di build. In sintesi:

1. **Controllo dipendenze host** — verifica la presenza dei pacchetti `git`, `gawk`, `qemu-system-arm`, ecc. Se mancano, propone il comando `apt install` e consente di interrompere l'esecuzione in sicurezza.
2. **Modalità interattiva o quick** — in assenza di `-d` mostra il menu numerato qui sopra; con `-d` esegue direttamente l'opzione **3️⃣** in modalità sviluppo (`SA_MODE=dev`).
3. **Opzione 1: clonazione layer** — scarica i branch `scarthgap` di `poky`, `meta-openembedded`, `meta-raspberrypi` e il branch `6.7` di `meta-qt6`; crea inoltre le cartelle `downloads/` e `sstate-cache/` condivise tra le build.
4. **Opzione 2: build immagine** — chiede il target (`qemuarm64` o `raspberrypi4-64`), prepara un build directory dedicato (`build-qemu` o `build-rpi4`) usando `TEMPLATECONF=../meta-sa/conf/templates/default` e aggiunge automaticamente i layer mancanti prima di lanciare `bitbake sa-image-minimal`. Gli output finiscono in `build-*/tmp-musl/deploy/images/<MACHINE>/`.
5. **Opzione 3: avvio QEMU** — trova l’ultima immagine `qemuarm64` compilata e avvia `qemu-system-aarch64` con GPU virtio, input USB e porta SSH inoltrata (`hostfwd=tcp::2222-:22`). Il flag `SA_MODE=dev` abilita configurazioni di sviluppo nel boot argomento `console`.
6. **Opzioni 4–5: HOST SDK** — genera `buildtools-extended-tarball` in `build-tools/tmp/deploy/sdk/` e installa lo script `.sh` risultante in `/opt/youngtimer-sdk/<nome-sdk>` (utile per compilare gli strumenti host).
7. **Opzioni 6–7: TARGET SDK** — ripetono il flusso di build/installa per il toolchain destinato a `qemuarm64` o `raspberrypi4-64`, aggiungendo i pacchetti Qt (append di `qtbase-dev`, `qtdeclarative-dev`, `qtmultimedia-dev`). Dopo l’installazione, attiva l’ambiente con `source <sdk>/environment-setup-aarch64-*-linux`.
8. **Opzione 8: flash su SD** — individua l’ultima immagine `.wic.bz2` per Raspberry Pi 4, chiede conferma esplicita (`Type YES`) e la scrive sul device scelto tramite `dd` con progress bar `pv`.

Ogni blocco termina con messaggi di stato chiari (✅ / ❌) e uscita immediata in caso di errori per evitare side-effect indesiderati.

---

## 🧱 Architettura del progetto

```
cdy/
 ├── CMakeLists.txt                  # Workspace CMake per QtCreator (subdir qmllib + sapp)
 ├── yocto.sh                        # Script principale per build Yocto
 ├── meta-sa/                        # Layer custom con ricette, immagini e sorgenti condivisi
 │    └── recipes-qt/
 │         ├── qmllib/               # Modulo QML Sa.Graphics 1.0 (installato in /usr/lib/qml/Sa/Graphics)
 │         ├── sapp/                 # Applicazione Qt6 che importa Sa.Graphics
 │         └── packagegroups/        # Packagegroup che trascina modulo e app
 ├── Open_Youngtimer_Lab_MD_EN+IT/   # Documenti ufficiali dell'associazione
 ├── README.md                       # Questo file
 └── LICENSE.txt
```

---

## 🖥️ Sviluppo Qt/QML con Qt Creator

- **Apertura progetto**: importa il workspace dal `CMakeLists.txt` di root, che aggiunge le subdirectory `qmllib` e `sapp` e non richiede tool Yocto per configurare il progetto in IDE.
- **Separazione build**: le build Yocto restano gestite da `yocto.sh` e dal template `TEMPLATECONF`; in IDE puoi usare un kit desktop per iterare su QML/C++ senza incrociare la toolchain cross. Per validare sul target ricompila i pacchetti o l’immagine (`bitbake sa-image-minimal`).

### Qt Creator (Desktop host)

Configurazione per kit **Desktop** in Qt Creator, con percorsi parametrizzati. Sostituire i placeholder con i valori reali del proprio host. Sono disponibili screenshot di riferimento nella cartella `helper/` (`qtCreatorHelp1.png` e `qtCreatorHelp2.png`).

**Prerequisiti / variabili**

```
<PROJECT_ROOT>     # root del repository
<BUILD_DIR>        # build directory del kit
<SYSROOT_DESKTOP>  # prefisso di install (es. .../sysroot-desktop)
<QT_HOST_PREFIX>   # Qt host (es. .../Qt/6.7.3/gcc_64)
```

**Build Settings (CMake)**

1) **Current Configuration**  
   ```
   CMAKE_INSTALL_PREFIX=<SYSROOT_DESKTOP>
   ```

2) **Build Steps → Custom Process Step**  
   ```
   Command: cmake
   Arguments: --install %{buildDir}
   Working directory: %{buildDir}
   ```

**Run Settings**

1) **Run configuration**: Custom Executable  
   ```
   Executable: <SYSROOT_DESKTOP>/bin/sapp
   Working directory: <SYSROOT_DESKTOP>
   ```

2) **Environment**  
   ```
   QT_HOME=<QT_HOST_PREFIX>
   LD_LIBRARY_PATH=$QT_HOME/lib:<SYSROOT_DESKTOP>/lib:$LD_LIBRARY_PATH
   QT_PLUGIN_PATH=$QT_HOME/plugins
   QML_IMPORT_PATH=<SYSROOT_DESKTOP>/lib/qml
   QML2_IMPORT_PATH=<SYSROOT_DESKTOP>/lib/qml
   ```

**Nota importante**  
Lo step `cmake --install` è necessario perché l’applicazione e i moduli QML devono essere eseguiti dal layout installato sotto `<SYSROOT_DESKTOP>`. Le variabili di ambiente di run servono a risolvere Qt host e librerie quando si lancia l’eseguibile installato, e vanno impostate nella **Run configuration** di Qt Creator, non a livello globale di sistema.

## 🚀 Open Youngtimer Lab

Open Youngtimer Lab è un’associazione in formazione nata per condividere **strumenti embedded open-source** per le auto youngtimer.  
L’obiettivo è sviluppare dispositivi **replicabili e documentati**, utilizzando un ecosistema completamente libero basato su Yocto Linux, Qt 6 e Raspberry Pi CM5.

### 📄 Documentazione ufficiale

I documenti costitutivi e di progetto si trovano nella cartella [`Open_Youngtimer_Lab_MD_EN+IT`](./Open_Youngtimer_Lab_MD_EN+IT):

| Documento | Lingua | Descrizione |
|------------|--------|-------------|
| [Protocollo di intenti](./Open_Youngtimer_Lab_MD_EN+IT/IT/Protocollo_Intenti.md) | 🇮🇹 | Fondazione dell’associazione |
| [Statuto](./Open_Youngtimer_Lab_MD_EN+IT/IT/Statuto.md) | 🇮🇹 | Regole interne |
| [GoFundMe – Testo campagna](./Open_Youngtimer_Lab_MD_EN+IT/IT/GoFundMe_Text.md) | 🇮🇹 | Raccolta fondi ufficiale |
| [Bylaws (EN)](./Open_Youngtimer_Lab_MD_EN+IT/EN/Bylaws.md) | 🇬🇧 | English version |

---

## 🔬 Progetti embedded correlati

- **Dashboard Qt/QML** su Raspberry Pi CM5  
- **Modulo acquisizione segnali e sensori veicolo**  
- **Sistema fari intelligente e logica CAN-bus**  
- **Logger telemetrico e strumentazione 3D**  

Tutti i dispositivi sono **sperimentali e didattici**, non omologati per uso su strada.

---

## 💡 Come contribuire

- 🧰 **Contribuisci al codice Yocto / Qt** — tramite fork e pull request.  
- 💬 **Partecipa come socio sviluppatore** — vedi [Statuto](./Open_Youngtimer_Lab_MD_EN+IT/IT/Statuto.md).  
- ❤️ **Sostieni la campagna** —
  [GoFundMe: Sostieni Open Youngtimer Lab](./Open_Youngtimer_Lab_MD_EN+IT/IT/GoFundMe_Text.md)  
  [Link diretto alla raccolta](https://gofund.me/b0e7df704)


---

## ⚠️ Avvertenza legale

Tutti i dispositivi e software prodotti da Open Youngtimer Lab hanno **scopo esclusivamente sperimentale e didattico**.  
Non sono omologati per uso su strada pubblica né certificati per installazione su veicoli in circolazione.

---

## 📄 Licenze

- Software e ricette Yocto: **MIT License**  
- Documentazione: **CC-BY-SA 4.0**  
- © 2025 Open Youngtimer Lab — Capriate San Gervasio (BG)
