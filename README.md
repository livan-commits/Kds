# Kds — simulateur indépendant Kode Dot

Kds est un projet indépendant construit à partir des sources publiques officielles de KodeDIY. Il vise à rendre l'interface Kode Dot utilisable de façon fluide sur Windows, puis Android, sans prétendre remplacer le matériel réel.

## Deux moteurs distincts

### KDS Native — priorité Windows puis Android

Recompile directement sur l'ordinateur les composants graphiques portables de KodeOS : le vrai KGUI, LVGL et les composants KUI compatibles. Le rendu utilise SDL2 sur Windows. Un KDS-HAL remplacera progressivement les services matériels ESP-IDF par des services natifs explicites.

Ce mode n'émule pas un processeur ESP32. Il vise la meilleure fluidité possible pour naviguer dans l'interface et tester les composants/apps dont le code source peut être porté et recompilé.

### KDS Firmware — compatibilité firmware

Objectif séparé : exécuter les véritables images ESP32-P4 et ESP32-C5 dans un runtime d'émulation compatible. La compilation des images firmware est une étape préalable, pas une preuve qu'elles démarrent dans l'émulateur. Les périphériques et les échanges P4↔C5 devront être validés séparément.

Les applications compilées pour ESP32 ne fonctionnent pas directement dans KDS Native : elles nécessitent leur code source et un portage/recompilation.

## Sources officielles et traçabilité

- KodeOS : https://github.com/kodediy/KodeOS
- Documentation : https://docs.kode.diy/internals/overview
- SDK : sous-module officiel de KodeOS
- Versions exactes : [upstream.lock.json](upstream.lock.json)

Les sources amont restent identifiables, avec leurs commits et licences. Les adaptations propres à Kds sont isolées dans le workflow et les couches natives.

## Principes

1. Préserver les sources amont et leurs licences ; éviter les copies non traçables.
2. Ne jamais présenter un périphérique virtuel comme un périphérique réellement émulé si son comportement n'est pas implémenté et testé.
3. Optimiser le rendu natif : éviter les copies framebuffer inutiles et les échanges synchrones bloquants.
4. Prévoir une distribution Windows hors ligne, avec les bibliothèques nécessaires embarquées.
5. Valider chaque étape par compilation, lancement, captures d'écran et scénarios reproductibles.

## État du développement

Les workflows CI construisent séparément les firmwares amont P4/C5 et le KGUI natif Windows. Ces validations ne signifient pas encore que KodeOS complet démarre sous Windows. Consulter [la feuille de route](docs/ROADMAP.md), [l'architecture](docs/ARCHITECTURE.md) et [le plan de portage natif](docs/NATIVE-PORT.md).
