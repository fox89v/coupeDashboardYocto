# 🧠 Calderone idee — Cruscotto Embedded + Telemetria

## ⚙️ Sistema base / hardware
- Raspberry Pi **Compute Module 5**: eMMC 32 GB, BT 5.0, Wi-Fi 6, GPIO, CAN via MCP2515 o controller interno.  
- **Partizioni**: `/boot` (FAT), `/rootA` e `/rootB` (aggiornamenti sicuri), `/data` persistente.  
- `/data` ext4 con `noatime, commit=30, data=ordered`.  
- **Gestione alimentazione**: BAT+, IGN, batteria tampone / supercap, segnale PWR_FAIL.  
- **PMIC** con preavviso power-fail ≥ 200 ms.  
- **Modalità power**: RUN, PRE-SHUTDOWN, SLEEP.  
- **Temperatura**: ventola PWM o termocontrollo passivo; log termico.

## 🧾 Logging e telemetria
- Formato binario: header + blocchi 64 KB (CRC32).  
- Record: timestamp, id segnale, valore, CRC16.  
- Buffer RAM 128–256 KB → flush ogni 10–20 s.  
- Flush massivo su IGN→OFF.  
- Rotazione file: 50–200 MB.  
- 30 canali @ 50 Hz ≈ 0.7 GB/giorno (float).  
- Compressione LZ4 opzionale.  
- Tool PC: lettura binari → CSV/grafico.

## 🛰️ Comunicazione esterna
### Bluetooth Low Energy
- Service GATT “SA_LOG”: CTRL, META, DATA.  
- PHY 2M, MTU 247, interval 10–15 ms → 100–200 kB/s.  
- Blocchi 64 KB → chunk 1 KB + CRC16.  
- Resume, retry, compressione.  
- Manifest JSON: file_id, size, SHA-256, range, encrypt.  
- Cifratura AES-GCM a blocchi grandi.  
- App → proxy HTTPS/MQTT → cloud.

### Cloud
- Endpoint `/logs`: HEAD (check hash), POST (upload blob+manifest), GET (download).  
- Autenticazione: token dispositivo + firma manifest.  
- Idempotenza: “already uploaded” se duplicato.

### Logger USB
- MCU + CAN + USB Host.  
- Pulsanti: COPY 1H, 24H, 7D; Eject.  
- LED: GIALLO (copia), VERDE (ok), ROSSO (errore).  
- Copia `.bin`, `.meta`, `INDEX.json`.  
- FAT32/exFAT, rename atomico, fsync per file.

## 🧠 Stato di upload / multipli telefoni
- Ogni file ha `.meta` e `upload_state.json`.  
- Telefono scarica lista via BLE, controlla hash sul cloud.  
- Dopo upload, invia `SET uploaded=true`.  
- Stato idempotente → più telefoni, nessun duplicato.

## 🌐 Configurazione / UI
- `/data/config/`: `ui.json`, `signals.json`, `inputMap.json`.  
- `ConfigManager` Qt per carico/salvataggio.  
- `EventBus` singleton (CAN, BT, UI).  
- Pagine QML dinamiche, configurabili.  
- Esportazione/import via BLE o USB.

## 🔐 Sicurezza
- Cifratura AES-GCM locale.  
- Token dispositivo univoco (UUID hardware).  
- Log CRC-protetti.  
- Isolamento elettrico BT / logger.  

## 📦 File system e policy
- `/etc/` default di fabbrica.  
- `/data/` configurazioni e log persistenti.  
- `/var/` temporanei, `/tmp/` RAM, `/mnt/usb/` export.  
- fsck on boot, journaling commit 30 s.

## 📡 Estensioni future
- OTA (firmware/config).  
- Dashboard cloud per analisi.  
- Automotive Ethernet 100BASE-T1.  
- Compressione Zstd, cifratura lato cloud.  
- Grafico live via BLE (5 Hz).

## 🧰 Tooling
- Script Yocto per build automatica.  
- Tool “sa-log-decode” → CSV/grafico.  
- Stress test flash e power-cut.  
- Simulatore segnali CAN/analogici.

---
