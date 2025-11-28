# 🚗 Open Youngtimer Lab — Yocto Builder & Embedded Platform

Toolkit open-source per generare immagini Linux embedded su Raspberry Pi 4 / Compute Module 5, eseguire build in QEMU ARM64 e distribuire SDK pronti per Qt 6. Il progetto sostiene l’associazione **Open Youngtimer Lab**, dedicata a dashboard digitali e moduli elettronici per veicoli youngtimer.

[![License](https://img.shields.io/badge/License-MIT-blue)]()
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey)]()
[![Target](https://img.shields.io/badge/Target-Raspberry%20Pi%204%20%7C%20CM5-orange)]()
[![Language](https://img.shields.io/badge/Written%20in-Bash-green)]()

---

## 🪩 Panoramica
Questo repository unisce:

1. **Yocto Builder** — script interattivo (`yocto.sh`) per clonare i layer, generare immagini personalizzate e gestire SDK host/target.
2. **Open Youngtimer Lab** — iniziativa no‑profit che sviluppa strumenti embedded open-source (dashboard Qt/QML, moduli sensori, telemetria, logica fari/CAN). I documenti ufficiali sono inclusi nella cartella `Open_Youngtimer_Lab_MD_EN+IT`.

---

## ⚙️ Funzionalità del builder
- Setup automatico dei layer: `poky`, `meta-openembedded`, `meta-raspberrypi`, `meta-qt6`, `meta-sa` (layer custom del progetto).
- Build di `sa-image-minimal` per QEMU ARM64 o Raspberry Pi 4 / CM5.
- Avvio diretto in **QEMU** con modalità **DEV/PROD**.
- Generazione e installazione di **HOST SDK** (buildtools-extended) e **TARGET SDK** (meta-toolchain) con selezione interattiva.
- Flash di immagini `.wic.bz2` su SD card con progresso via `pv`.

---

## 🧰 Requisiti host (Debian/Ubuntu)
Il builder verifica automaticamente queste dipendenze prima di procedere:
`git gawk wget diffstat unzip texinfo gcc g++ make cmake chrpath cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm qemu-system-arm qemu-user-static cpulimit pv`

- **Comando rapido**: installa i pacchetti mancanti con `sudo apt install -y git gawk wget diffstat unzip texinfo gcc g++ make cmake chrpath cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm qemu-system-arm qemu-user-static cpulimit pv`.
- **Spazio e risorse**: prevedi almeno **80 GB** liberi su disco e **16 GB** di RAM per una build Yocto fluida.
- **Supporto a QEMU**: abilita la virtualizzazione hardware (KVM) se disponibile per velocizzare l’esecuzione in emulazione.

---

## 🚀 Avvio rapido
```bash
chmod +x yocto.sh
./yocto.sh
```
Menu principale:

| Opzione | Descrizione |
|:-------:|:------------|
| 1️⃣ | Clona e configura i layer Yocto |
| 2️⃣ | Compila l’immagine `sa-image-minimal` |
| 3️⃣ | Avvia QEMU ARM64 (DEV/PROD) |
| 4️⃣ | Genera HOST SDK (`buildtools-extended`) |
| 5️⃣ | Installa HOST SDK in `/opt/youngtimer-sdk` |
| 6️⃣ | Genera TARGET SDK (`meta-toolchain`) |
| 7️⃣ | Installa TARGET SDK (selezione build QEMU/RPi) |
| 8️⃣ | Flasha l’ultima immagine su SD card |

### Modalità DEV rapida
Esegui `./yocto.sh -d` per saltare il menu e avviare QEMU in modalità **DEV** con l’ultima immagine QEMU disponibile.

### Percorso di build
- `build-qemu/` per target `qemuarm64`
- `build-rpi4/` per target `raspberrypi4-64`

Durante la configurazione (opzione 2/6) scegli il target desiderato; lo script imposta `MACHINE`, `BUILDDIR` e `TEMPLATECONF` (`meta-sa/conf/templates/default`).

### Output principali
- Immagini: `build-*/tmp-musl/deploy/images/<machine>/`
- HOST SDK: `build-tools/tmp/deploy/sdk/`
- TARGET SDK: `build-*/tmp/deploy/sdk/`

---

## 📚 Documentazione dell’associazione
La cartella [`Open_Youngtimer_Lab_MD_EN+IT`](./Open_Youngtimer_Lab_MD_EN+IT) contiene i documenti ufficiali:

| Documento | Lingua | Descrizione |
|-----------|--------|-------------|
| [Protocollo di intenti](./Open_Youngtimer_Lab_MD_EN+IT/IT/Protocollo_Intenti.md) | 🇮🇹 | Fondazione dell’associazione |
| [Statuto](./Open_Youngtimer_Lab_MD_EN+IT/IT/Statuto.md) | 🇮🇹 | Regole interne |
| [GoFundMe – Testo campagna](./Open_Youngtimer_Lab_MD_EN+IT/IT/GoFundMe_Text.md) | 🇮🇹 | Raccolta fondi |
| [Protocol of Intent](./Open_Youngtimer_Lab_MD_EN+IT/EN/Protocol_of_Intent.md) | 🇬🇧 | English overview |
| [Bylaws (EN)](./Open_Youngtimer_Lab_MD_EN+IT/EN/Bylaws.md) | 🇬🇧 | English bylaws |
| [GoFundMe – Campaign text](./Open_Youngtimer_Lab_MD_EN+IT/EN/GoFundMe_Text_EN.md) | 🇬🇧 | Fundraising text |

---

## 🧱 Struttura del repository
```
coupeDashboardYocto/
 ├── yocto.sh                  # Script principale per gestione Yocto/QEMU/SDK
 ├── meta-sa/                  # Layer custom con ricette, immagini, template conf
 ├── Open_Youngtimer_Lab_MD_EN+IT/  # Documentazione ufficiale (IT/EN)
 ├── helper/qtcreator_kit_config.md # Esempio di kit Qt Creator con toolchain Yocto
 ├── LICENSE.txt               # MIT per codice Yocto
 └── README.md
```

---

## 💻 Integrazione con Qt Creator
Per usare la toolchain Yocto in Qt Creator/QML, consulta `helper/qtcreator_kit_config.md` con percorsi preconfigurati per compilatori, debugger e variabili d’ambiente della SDK QEMU ARM64.

---

## 💡 Contribuire
- **Sviluppo Yocto / Qt**: invia PR con ricette, patch o migliorie al layer `meta-sa`.
- **Soci sviluppatori**: consulta lo [Statuto](./Open_Youngtimer_Lab_MD_EN+IT/IT/Statuto.md).
- **Supporto economico**: leggi il testo [GoFundMe](./Open_Youngtimer_Lab_MD_EN+IT/IT/GoFundMe_Text.md) o la [versione EN](./Open_Youngtimer_Lab_MD_EN+IT/EN/GoFundMe_Text_EN.md).

---

## ⚠️ Avvertenza legale
I dispositivi e il software del progetto hanno **scopo esclusivamente sperimentale e didattico**. Non sono omologati per uso su strada né certificati per installazione su veicoli in circolazione.

---

## 📄 Licenze
- Codice Yocto e script: **MIT License** (vedi `LICENSE.txt`).
- Documentazione: **CC-BY-SA 4.0**.
- © 2025 Open Youngtimer Lab — Capriate San Gervasio (BG)
