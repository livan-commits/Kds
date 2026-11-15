# Feuille de route Kds

Le projet comporte deux moteurs complémentaires. **KDS Native** est la voie prioritaire pour obtenir une utilisation fluide sans émuler le processeur ESP. **KDS Firmware** reste le banc de compatibilité pour exécuter le vrai firmware P4/C5.

## Phase 1 — Base native fluide (priorité)

- [ ] Compiler le véritable KGUI officiel pour Windows avec SDL2.
- [ ] Vérifier les écrans face, launcher, loading, settings et touch_test.
- [ ] Vérifier navigation clavier/souris et capture tactile simulée.
- [ ] Construire un paquet Windows autonome, avec DLL et ressources, testable hors ligne.
- [ ] Mesurer FPS, latence entrée-écran, CPU et mémoire.

## Phase 2 — KodeOS natif sans ESP

- [ ] Cartographier les API ESP-IDF/FreeRTOS et les appels matériels dans KodeOS et le SDK.
- [ ] Définir les interfaces KDS-HAL à partir des appels réels (pas de stubs silencieux).
- [ ] Compiler les modules portables KodeOS/SDK sur Windows.
- [ ] Intégrer les vrais Active Objects QP/C compatibles avec le port hôte.
- [ ] Porter progressivement horloge, stockage, réseau, entrées, audio et périphériques virtuels.
- [ ] Démarrer le cœur KodeOS natif et vérifier ses services.
- [ ] Porter les applications dont le code source est disponible; documenter les binaires ESP32 non portables.

## Phase 3 — Android natif

- [ ] Réutiliser le cœur KodeOS portable et KDS-HAL.
- [ ] Ajouter affichage, tactile, boutons, stockage et audio Android.
- [ ] Produire un APK installable et tester hors ligne.
- [ ] Mesurer la fluidité sur appareil réel.

## Phase 4 — Compatibilité firmware

- [ ] Compiler reproductiblement les firmwares amont ESP32-P4 et ESP32-C5.
- [ ] Intégrer ESP-EMU pour exécuter le vrai firmware P4.
- [ ] Implémenter et tester les périphériques requis au démarrage.
- [ ] Activer le framebuffer KGUI réel, boutons et tactile.
- [ ] Étudier le C5 et vérifier le lien P4↔C5.
- [ ] Comparer les comportements entre KDS Native et KDS Firmware.

## Phase 5 — Livraison

- [ ] Application Windows avec sélection claire Native / Firmware.
- [ ] Stockage persistant distinct (flash simulée et carte SD virtuelle).
- [ ] Paquet autonome hors ligne.
- [ ] Rapport public des fonctionnalités réelles, des écarts et des performances.

Voir [le plan de portage natif](NATIVE-PORT.md) et [la stratégie firmware](EMULATOR-STRATEGY.md).
