# KDS Native — portage sans émulation ESP

## Objectif

Exécuter les parties portables du véritable KodeOS directement sur le processeur hôte Windows ou Android. Ce mode ne simule ni le jeu d'instructions Xtensa/RISC-V ni le SoC ESP32-P4. Il recompile le code compatible pour l'architecture hôte et remplace les services matériels par une couche d'adaptation KDS-HAL.

Ce mode doit rester distinct du mode firmware qui exécute une image ESP32 réelle dans ESP-EMU.

## Règle de fidélité

Réutiliser autant que possible les sources officielles KodeOS, SDK, KGUI, LVGL, QP/C et les applications dont le code source est disponible. Ne pas réécrire les écrans en HTML et ne pas présenter une implémentation native comme le firmware original.

Les fichiers amont restent épinglés par commit. Les adaptations Kds sont isolées dans ce dépôt ou dans des patches documentés, afin de faciliter les synchronisations futures.

## Architecture

- `kodeos_core`: code système portable réellement compilable sur l'hôte.
- `kgui`: vrais écrans KGUI et LVGL, compilés pour l'hôte avec SDL2 sur Windows et une surface native Android.
- `kds_hal`: interfaces hôtes pour temps, stockage, événements, entrées, réseau, audio et affichage.
- `kds_storage`: stockage persistant local. Sur Windows, répertoire utilisateur configurable représentant flash et carte SD virtuelle distinctes.
- `kds_devices`: périphériques virtuels explicitement identifiés (GPIO, I2C, SPI, NFC, RFID, IR, capteurs, coprocesseur).
- `kds_app_host`: charge uniquement les applications portées/recompilées pour la cible hôte. Les binaires ESP32 natifs ne sont pas des plugins hôtes.

## Contrats HAL initiaux

| Service | Interface KDS | Implémentation Windows | Implémentation Android |
|---|---|---|---|
| Temps monotone/RTC | clock | QPC + horloge système | clock monotone + horloge système |
| Affichage | display | SDL2 | surface Android |
| Entrées | input | clavier/souris/manette | tactile/boutons |
| Stockage | storage | fichiers locaux | stockage app privé |
| Réseau | network | sockets OS | sockets Android |
| Audio | audio | SDL/audio OS | AudioTrack/AAudio |
| Boutons | buttons | raccourcis clavier configurables | événements tactiles/boutons |
| Périphériques Dot | devices | modèles virtuels | modèles virtuels |

Les contrats doivent être affinés après inventaire des API réellement appelées par KodeOS et le SDK. Aucun faux succès : un périphérique absent renvoie un état non pris en charge ou une erreur documentée.

## Ordre d'implémentation

1. Compiler le vrai KGUI officiel pour Windows et valider la navigation.
2. Extraire les services portables de KodeOS/SDK en gardant les mêmes API publiques autant que possible.
3. Implémenter KDS-HAL Windows et tests unitaires de chaque service.
4. Intégrer QP/C et les Active Objects qui ne dépendent pas directement de FreeRTOS/ESP-IDF; adapter les ports OS uniquement si nécessaire.
5. Porter le démarrage KodeOS et activer progressivement les services.
6. Faire une seconde cible Android en réutilisant le cœur portable et le HAL.
7. Mesurer latence tactile→écran, FPS, charge CPU et mémoire.

## Ce que ce mode ne promet pas

- Il ne lance pas directement les fichiers binaires compilés pour ESP32-P4/C5.
- Il ne reproduit pas automatiquement les pilotes ou temporisations électriques du matériel réel.
- Le C5 est remplacé par des services hôtes seulement pour les fonctions dont le protocole est compris et implémenté.
- Les écarts avec le firmware doivent être listés par fonctionnalité.

## Critères d'acceptation

- Les écrans sont issus des sources KGUI amont, pas d'une maquette.
- Les services hôtes ont des tests automatisés.
- Les applications hôtes sont explicitement identifiées comme recompilées/portées.
- L'application Windows démarre hors ligne et conserve ses données.
- Android réutilise le même cœur portable.
- Le mode firmware ESP-EMU reste disponible séparément pour les tests de compatibilité matérielle.
