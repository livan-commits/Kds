# Feuille de route Kds

Kds conserve deux moteurs : **KDS Native** pour une interface KGUI fluide et **KDS Firmware** pour exécuter le vrai firmware KodeOS. Le dépôt officiel `kodediy/kode-sim` est maintenant la base du mode firmware.

## Phase 1 — Base graphique Windows

- [x] Compiler le véritable KGUI officiel pour Windows avec SDL2.
- [x] Fournir les écrans face, launcher, loading, settings et touch_test.
- [x] Navigation clavier/souris et capture tactile simulée.
- [x] Paquet Windows avec SDL2 et lanceur.
- [ ] Mesurer FPS, latence entrée-écran, CPU et mémoire sur une machine Windows réelle.

## Phase 2 — Moteur firmware officiel kode-sim

- [x] Identifier et épingler kode-sim et esp-emu.
- [x] Exécuter les tests hôtes officiels de kode-sim sous Ubuntu CI.
- [x] Construire KodeOS avec kode-sim et ESP-IDF 6.1 sous Linux CI.
- [x] Démarrer le vrai firmware KodeOS P4 dans esp-emu sous Linux CI.
- [x] Vérifier que kode-sim annonce son serveur Web prêt et que la page HTTP répond.
- [ ] Inspecter visuellement l'affichage et tester les entrées.
- [ ] Reproduire le build et le démarrage dans Ubuntu WSL2.
- [ ] Vérifier le framebuffer 410×502, boutons, tactile, microSD, audio et capteurs.
- [ ] Tester les applications compilées depuis leurs sources.
- [ ] Mesurer les performances et les limites du firmware émulé.

## Phase 3 — Distribution Windows unifiée

- [ ] Lanceur Windows avec choix KGUI natif / KodeOS firmware.
- [ ] Installation et contrôle de l'environnement WSL2 reproductibles.
- [ ] Ouverture de l'interface du backend dans Edge/WebView2 via localhost.
- [ ] Démarrage/arrêt propre du backend et conservation des données SD/flash.
- [ ] Documentation claire des prérequis, fonctions émulées et limites.

## Phase 4 — Réduction des dépendances

- [ ] Étudier l'intégration directe d'esp-emu WebAssembly dans WebView2.
- [ ] Porter les modèles de puces et la co-simulation dans le navigateur si cela réduit réellement les prérequis.
- [ ] Ne remplacer WSL2 qu'après validation de l'équivalence fonctionnelle et des performances.

## Phase 5 — Android et compatibilité avancée

- [ ] Évaluer la faisabilité Android du moteur natif KGUI.
- [ ] Étudier un backend firmware Android seulement si esp-emu/WSL ou une cible native équivalente le permet.
- [ ] Vérifier le C5 et les fonctions Bluetooth, NFC, RFID et IR au fur et à mesure du support amont.

Le démarrage Linux CI est documenté dans [la stratégie kode-sim](EMULATOR-STRATEGY.md). Voir aussi [le plan de portage natif](NATIVE-PORT.md) et [l'architecture](ARCHITECTURE.md).
