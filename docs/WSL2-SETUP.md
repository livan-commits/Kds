# Lancer le vrai firmware KodeOS depuis Windows avec WSL2

> **État expérimental :** le script d'amorçage est ajouté au dépôt, mais il n'a pas encore été exécuté sur une machine Windows/WSL2. Le démarrage de KodeOS est validé sur runner Ubuntu GitHub Actions uniquement.

## Prérequis

- Windows 10 récent ou Windows 11 avec WSL2 activé.
- Une distribution Ubuntu installée sous WSL2 (nom par défaut : `Ubuntu`).
- Connexion Internet et plusieurs Go d'espace libre.
- Droits sudo dans Ubuntu.

## Installation

Depuis l'explorateur Windows, ouvrez le dossier du dépôt Kds et exécutez PowerShell :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Kds-Firmware-WSL.ps1 -Action setup
```

Le script installe les dépendances Linux, le toolchain Rust/Cargo nécessaire à kode-sim, ESP-IDF v6.1 pour ESP32-P4, puis récupère les commits officiels épinglés de KodeOS et kode-sim. Il copie également le patch de compatibilité KodeOS requis par le mode sans radio C5.

La première installation et la première compilation peuvent prendre un certain temps. Ubuntu demandera le mot de passe sudo.

## Démarrage

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Kds-Firmware-WSL.ps1 -Action run
```

Le backend lance `kode-sim run` sur le vrai firmware KodeOS dans esp-emu. La page locale est servie par kode-sim ; si aucun navigateur n'est ouvert automatiquement, ouvrir l'adresse locale affichée dans le terminal Ubuntu.

## Données et sources

Les sources, outils, cache firmware et image microSD persistante sont stockés dans :

```
~/.local/share/kds-firmware/
```

Les versions sont épinglées dans le script. Le backend utilise le P4 émulé ; il ne prétend pas émuler le C5, le Bluetooth, le NFC, le RFID ou l'infrarouge. Le panneau, la carte SD et certains services sont encore gérés par les remplacements logiciels amont `kemu`, comme indiqué dans la documentation officielle de kode-sim.

## Limites actuelles

- Le script est un prototype d'intégration, pas encore un installateur Windows certifié.
- Le démarrage sous Linux CI est validé ; le fonctionnement sur WSL2 doit encore être reproduit et vérifié.
- Le lanceur graphique KGUI Windows reste indépendant et plus léger. Il n'exécute pas le firmware.
- La page Web doit être testée visuellement et les boutons/tactile doivent faire l'objet de tests d'interaction avant de déclarer le simulateur complet.
- Pour revenir au mode natif Windows, utilisez le paquet [Kds Windows preview](https://github.com/livan-commits/Kds/releases/download/windows-preview/kds-windows-preview.zip).

Consulter la [stratégie d'émulation](EMULATOR-STRATEGY.md) et le [dépôt officiel kode-sim](https://github.com/kodediy/kode-sim).
