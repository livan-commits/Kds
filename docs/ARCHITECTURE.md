# Architecture cible

## Source de vérité

Le firmware KodeOS officiel reste la source de vérité. Le build récupère le dépôt `kodediy/KodeOS` au commit épinglé dans `upstream.lock.json`, avec ses sous-modules récursifs. Le SDK n'est pas remplacé par une copie approximative.

## Deux moteurs complémentaires

- **KDS Native (prioritaire pour la fluidité)** : recompiler les modules KodeOS portables pour Windows/Android, conserver le vrai KGUI/LVGL et intégrer une couche KDS-HAL pour remplacer les services matériels. Aucun CPU ESP n'est exécuté dans ce mode. Les détails sont dans [NATIVE-PORT.md](NATIVE-PORT.md).
- **KDS Firmware** : exécuter les images P4/C5 réelles dans un moteur d'émulation compatible. Ce mode sert à valider la compatibilité firmware et les périphériques.

## Couches firmware

- **CPU ESP32-P4** : exécuter le firmware réel avec un émulateur compatible avec le SoC et les instructions utilisées par KodeOS.
- **Mémoire** : séparer mémoire interne, PSRAM, flash, partitions et stockage persistant. Les accès mémoire doivent respecter les adresses et les tailles réellement attendues par le firmware.
- **Périphériques** : implémenter les contrôleurs requis par le démarrage KodeOS (horloges, interruptions, timers, UART, GPIO, I2C, SPI, stockage et affichage) et documenter chaque niveau de couverture.
- **ESP32-C5** : traiter comme un second processeur, avec son propre firmware et son transport inter-puce. Ne pas afficher « lancé » tant que son code s'exécute réellement.
- **KGUI** : utiliser le rendu LVGL/KGUI produit par le firmware. Le panneau 410×502 RGB565 doit être une sortie du firmware, pas une imitation DOM.
- **Hôte Windows/Android** : entrées, fenêtres, stockage et accélération graphique pour KDS Native; dans KDS Firmware, l'hôte fournit les périphériques virtuels et le rendu.

## Performance

Priorités mesurables :
1. Pas de copie complète de framebuffer à chaque tick si une zone n'a pas changé.
2. Publier les zones modifiées via un buffer partagé ou un transfert par lots, sans bloquer le thread UI.
3. Séparer le thread d'émulation, le transfert d'image et le rendu.
4. Limiter les conversions RGB565 et allocations temporaires.
5. Mesurer FPS affichés, temps CPU par tick, temps d'émulation, latence entrée→écran et mémoire.
6. Ne pas accélérer artificiellement l'horloge du firmware pour masquer une émulation lente.

## Étapes de validation

- Compiler d'abord KGUI officiel en natif, puis définir KDS-HAL à partir de l'inventaire des appels réels.
- Vérifier le mode KDS Native indépendamment du moteur firmware.

- Inventaire du démarrage KodeOS et de ses périphériques requis.
- Compilation reproductible du firmware amont P4 et C5.
- Démarrage du firmware et capture de la première image KGUI.
- Entrées boutons et tactile vérifiées dans les deux sens.
- Vérification des horloges, timers et persistance du stockage.
- Test de charge prolongé et mesure des performances.
- Test hors ligne après installation.

## Limites à annoncer

Une compilation réussie ne prouve pas que le firmware démarre. Un framebuffer visible ne prouve pas que les périphériques fonctionnent. Un C5 compilé n'est pas un C5 émulé. Chaque fonction doit être associée à un test.
