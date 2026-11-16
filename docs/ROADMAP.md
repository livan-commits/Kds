# Feuille de route Kds

Kds garde deux moteurs : **KDS Native** pour une interface KGUI fluide et **KDS Firmware** pour exécuter le vrai firmware KodeOS. La découverte du dépôt officiel `kodediy/kode-sim` fait de sa réutilisation la priorité pour le mode firmware ; nous ne devons pas réimplémenter ses pilotes, ses Active Objects ou ses modèles de puces.

## Phase 1 — Base graphique Windows (disponible, à consolider)

- [x] Compiler le véritable KGUI officiel pour Windows avec SDL2.
- [x] Fournir les écrans face, launcher, loading, settings et touch_test.
- [x] Navigation clavier/souris et capture tactile simulée.
- [x] Paquet Windows avec SDL2 et lanceur.
- [ ] Mesurer FPS, latence entrée-écran, CPU et mémoire sur une machine Windows réelle.

## Phase 2 — Réutiliser kode-sim (priorité technique)

- [x] Identifier le dépôt officiel et son architecture : P4 émulé + co-simulation des puces + `kemu`.
- [x] Épingler le commit d'étude `e9404e4e0a9834044fb1ada36976a090c25cb70d` et esp-emu `1.0.0`.
- [ ] Préparer Ubuntu WSL2 avec ESP-IDF v6.1, Rust, rsync et mtools.
- [ ] Exécuter les tests hôtes de kode-sim dans WSL2.
- [ ] Compiler et démarrer un exemple officiel kode-sdk dans esp-emu.
- [ ] Compiler KodeOS et vérifier son vrai démarrage dans le simulateur.
- [ ] Vérifier le framebuffer 410×502, boutons, tactile, microSD, audio et capteurs.
- [ ] Relier le serveur local de kode-sim au lanceur Kds Windows.
- [ ] Mesurer les performances et les limites du firmware émulé.

## Phase 3 — Distribution Windows unifiée

- [ ] Lanceur Windows avec choix KGUI natif / KodeOS firmware.
- [ ] Installation et contrôle de l'environnement WSL2 reproductibles.
- [ ] Ouverture de l'interface du backend dans Edge/WebView2 via localhost.
- [ ] Démarrage/arrêt propre du backend et conservation des données SD/flash.
- [ ] Documentation claire des prérequis, des fonctions émulées et des limites.

## Phase 4 — Réduction des dépendances

- [ ] Étudier l'intégration directe d'esp-emu WebAssembly dans WebView2.
- [ ] Porter les modèles de puces et la co-simulation dans le navigateur si cela réduit réellement les prérequis.
- [ ] Ne remplacer WSL2 qu'après validation de l'équivalence fonctionnelle et des performances.

## Phase 5 — Android et compatibilité avancée

- [ ] Évaluer la faisabilité Android du moteur natif KGUI.
- [ ] Étudier un backend firmware Android seulement si esp-emu/WSL ou une cible native équivalente le permet.
- [ ] Vérifier le C5 et les fonctions Bluetooth, NFC, RFID et IR au fur et à mesure du support amont.

Voir [la stratégie d'intégration kode-sim](EMULATOR-STRATEGY.md), [le plan de portage natif](NATIVE-PORT.md) et [l'architecture](ARCHITECTURE.md).
