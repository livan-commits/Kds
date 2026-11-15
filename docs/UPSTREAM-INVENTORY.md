# Inventaire des sources amont

Inventaire réalisé le 15 novembre 2026 à partir de KodeOS `develop` et de son sous-module SDK.

## Révisions épinglées

- KodeOS : `kodediy/KodeOS@9bcfdb71b763ee7b5c14106358643ea611fc97db`
- SDK : `kodediy/kode-sdk@1841cc8c13d4b2e3e4d7288b40cdac5de207a133`
- ESP-IDF : `v6.1`
- Licence du dépôt KodeOS : GPL-3.0-or-later. Le SDK contient également des composants tiers avec leurs propres licences ; conserver les notices amont.

Le workflow récupère récursivement KodeOS et ses sous-modules, vérifie les deux commits, compile les firmwares P4 et C5 et joint une archive complète des sources amont au même artefact que les binaires et leurs sommes SHA-256. Les sources ne sont pas modifiées ni réécrites dans ce dépôt.

## Ce qu'il faut conserver

### KodeOS

- `main/` : point d'entrée, initialise `kode_init()` puis `kgui_start()`.
- `components/kgui/` : écrans et navigation réels KGUI, polices, glyphes et ressources.
- `bootloader_components/` : adaptation du démarrage des applications.
- `storage_image/` et la génération d'image FAT : ressources du système.
- `tools/build_c5.sh` : construction du firmware du coprocesseur.
- `sdkconfig.defaults`, partition table et configuration de carte.

### SDK

Le SDK comporte notamment :
- `kbsp` : description de la carte et des connexions.
- `khal` : adaptation bas niveau vers ESP-IDF.
- `kdrv` : pilotes de périphériques (écran, tactile CST820, expandeur TCA6408A, boutons, stockage, audio, radio, NFC, RFID, IR, mouvement, alimentation, etc.).
- `kqp` et `kaos` : QP/C et Active Objects.
- `kode` / `kode_sys` : API et services système.
- `kui` : widgets, rendu, polices, images, Kody et outils.
- `kui/sim` : simulation de l'interface existante, à étudier comme référence pour les écrans et tests, sans la confondre avec l'émulation du firmware P4.

## Faits d'architecture importants

- La cible principale est l'ESP32-P4 double cœur RISC-V, avec flash et PSRAM externes.
- L'écran est 410×502 AMOLED avec tactile.
- Le Kode Dot comprend un ESP32-C5 séparé pour les radios.
- Une application KodeOS est un firmware complet séparé : ce n'est pas un plugin chargé dans un processus KodeOS déjà démarré. Le cycle de lancement passe par le bootloader et la flash.
- Le SDK utilise des Active Objects : les composants matériels sont possédés par des objets dédiés et communiquent par événements. Une simulation fidèle doit donc reproduire les interruptions, le timing, les bus et les états des pilotes, pas seulement afficher des pixels.

## Émulateur candidat

ESP-EMU d'Espressif annonce la prise en charge des firmwares ESP32-P4 et ESP32-C5, des deux cœurs P4, de la PSRAM, de la flash et des composants virtuels via co-simulation. Il fournit un runtime WebAssembly et un moteur natif Rust. C'est le premier moteur à évaluer pour éviter de réinventer un CPU RISC-V et ses périphériques.

La compatibilité générale du processeur ne garantit pas le support de chaque contrôleur propre au Kode Dot. Il faudra valider les périphériques réellement sollicités au boot, puis créer des composants virtuels pour ceux qui manquent. Le C5 ne sera déclaré actif qu'une fois son firmware lancé et son lien avec le P4 testé.

## Liens de référence

- https://github.com/kodediy/KodeOS
- https://github.com/kodediy/kode-sdk
- https://docs.kode.diy/internals/overview
- https://docs.kode.diy/sdk/overview
- https://github.com/espressif/esp-emulator
- https://github.com/espressif/esp-emulator/blob/main/docs/guides/PARTS.md
