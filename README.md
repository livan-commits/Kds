# Kds — simulateur indépendant Kode Dot

Kds est un projet indépendant construit à partir des sources publiques officielles de KodeDIY. Il vise à rendre l'interface Kode Dot utilisable de façon fluide sur Windows, puis à permettre l'exécution du véritable firmware dans un émulateur ESP32.

## Deux moteurs distincts

### KDS Native — disponible sur Windows

Recompile directement sur l'ordinateur les composants graphiques portables de KodeOS : le vrai KGUI, LVGL et les composants KUI compatibles. Le rendu utilise SDL2 sur Windows. Le paquet Windows prêt à essayer est disponible dans [Kds Windows preview](https://github.com/livan-commits/Kds/releases/download/windows-preview/kds-windows-preview.zip).

Ce mode propose les écrans face, launcher, loading, settings et touch_test. Il privilégie une navigation réactive. Il n'émule pas un processeur ESP32 et ne lance pas les applications firmware compilées pour la carte.

### KDS Firmware — premier démarrage réel validé sous Linux CI

Le mode firmware réutilise le projet officiel [kode-sim](https://github.com/kodediy/kode-sim) et Espressif esp-emu. Le workflow [GitHub Actions du 16 novembre 2026](https://github.com/livan-commits/Kds/actions/runs/43863415371) a compilé KodeOS avec les sources officielles épinglées, démarré le firmware P4 dans esp-emu et vérifié que le serveur Web de kode-sim répondait.

C'est un démarrage du vrai firmware dans un ESP32-P4 émulé, et non une simple maquette graphique. Cette validation a été faite sous Linux CI ; l'intégration sous Windows via WSL2 reste à réaliser. L'affichage, les boutons, les capteurs, l'audio, le stockage et les applications doivent encore être testés fonctionnalité par fonctionnalité.

## Sources officielles et traçabilité

- KodeOS : https://github.com/kodediy/KodeOS
- SDK : sous-module officiel de KodeOS
- kode-sim : https://github.com/kodediy/kode-sim
- Versions exactes : [upstream.lock.json](upstream.lock.json)

Les sources amont restent identifiables, avec leurs commits et licences. Les adaptations propres à Kds sont isolées dans les couches natives et le workflow.

## Principes

1. Préserver les sources amont et leurs licences ; éviter les copies non traçables.
2. Ne jamais présenter un périphérique virtuel comme un périphérique réellement émulé si son comportement n'est pas implémenté et testé.
3. Distinguer explicitement KGUI natif et firmware émulé.
4. Valider chaque étape par compilation, démarrage, journaux et scénarios reproductibles.
5. Ne déclarer la compatibilité Windows firmware qu'après validation WSL2 sur cette plateforme.

Consulter [la feuille de route](docs/ROADMAP.md), [la stratégie kode-sim](docs/EMULATOR-STRATEGY.md), [l'architecture](docs/ARCHITECTURE.md) et [le plan de portage natif](docs/NATIVE-PORT.md).
