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

[Seguimi su WhatsApp](https://whatsapp.com/channel/0029Vb7HTF8It5s4jT0nj20P)


---

## ⚙️ Yocto Builder

### ✅ Funzionalità principali

- Setup automatico dei layer (`poky`, `meta-openembedded`, `meta-raspberrypi`, `meta-qt6`, `meta-sa`)  
- Costruzione di immagini personalizzate (`sa-image-minimal`)  
- Esecuzione diretta in **QEMU** (ARM64)  
- Supporto a **Raspberry Pi 4 / CM5**  
- Generazione e installazione di SDK cross-compile

### 💡 Utilizzo

```bash
chmod +x yocto.sh
./yocto.sh
```

Menu interattivo:
| Opzione | Descrizione |
|:--------:|:------------|
| 1️⃣ | Clona e configura i layer necessari |
| 2️⃣ | Compila l’immagine custom |
| 3️⃣ | Avvia QEMU (emulazione ARM64) |
| 4️⃣ | Crea SDK |
| 5️⃣ | Installa SDK in `/opt/youngtimer-sdk` |

---

## 🧱 Architettura del progetto

```
cdy/
 ├── yocto.sh                 # Script principale per build Yocto
 ├── meta-sa/                 # Layer custom con ricette e immagini
 ├── Open_Youngtimer_Lab_MD_EN+IT/ # Documenti ufficiali dell'associazione
 ├── README.md                # Questo file
 └── LICENSE.txt
```

---

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
| [Bylaws (EN)](./Open_Youngtimer_Lab_MD_EN+ITT/EN/Bylaws.md) | 🇬🇧 | English version |

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
- ❤️ **Sostieni la campagna** — [GoFundMe: Sostieni Open Youngtimer Lab](./Open_Youngtimer_Lab_MD_EN+IT/IT/GoFundMe_Text.md).

---

## ⚠️ Avvertenza legale

Tutti i dispositivi e software prodotti da Open Youngtimer Lab hanno **scopo esclusivamente sperimentale e didattico**.  
Non sono omologati per uso su strada pubblica né certificati per installazione su veicoli in circolazione.

---

## 📄 Licenze

- Software e ricette Yocto: **MIT License**  
- Documentazione: **CC-BY-SA 4.0**  
- © 2025 Open Youngtimer Lab — Capriate San Gervasio (BG)
