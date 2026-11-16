# Choix du moteur et intégration de kode-sim

## Décision d'architecture

Kds conserve deux moteurs complémentaires :

- **KDS Native** : interface KGUI/LVGL officielle compilée pour Windows, légère et fluide. C'est le mode de navigation rapide et le banc de test graphique.
- **KDS Firmware** : exécution du vrai firmware KodeOS et des applications kode-sdk dans ESP32-P4 émulé, avec les composants de carte modélisés par le projet officiel `kode-sim`.

Le dépôt officiel à réutiliser est [kodediy/kode-sim](https://github.com/kodediy/kode-sim), version 0.2.0, commit de référence initial `e9404e4e0a9834044fb1ada36976a090c25cb70d` (2026-11-16). Il dépend d'[Espressif esp-emulator](https://github.com/espressif/esp-emulator), version `1.0.0`.

**Ne pas réécrire les Active Objects, les pilotes ou les modèles de puces déjà fournis par kode-sim.** Toute intégration doit conserver la traçabilité des sources et leurs licences GPL-3.0-or-later.

## Ce que kode-sim apporte déjà

D'après le README et le guide officiels :

- Le firmware tourne réellement sur un ESP32-P4 émulé : FreeRTOS, QP/C, Active Objects, kode-sdk et pilotes restent dans le firmware.
- Les puces de la carte sont modélisées côté Rust et reliées au P4 par la co-simulation : expander/boutons, contrôleur tactile, LED, haptique, chargeur, jauge, codec audio, IMU et magnétomètre.
- L'écran MIPI-DSI 410×502, la microSD, le C5/radio et l'USB sont encore partiellement fournis par `kemu`, une couche de remplacement liée au firmware.
- La carte SD est une image persistante sur le disque hôte ; FATFS, le pilote SD Kode et AO_Storage du firmware réel travaillent au-dessus du contrôleur simulé.
- Les applications doivent aujourd'hui être compilées depuis leurs sources avec `kode-sim build/run`. Les binaires catalogue compilés pour la carte ne sont pas encore tous compatibles avec le simulateur.

Ces limites doivent rester visibles dans l'interface et dans les rapports de test.

## Compatibilité Windows : état réel

Le dépôt `kode-sim` est annoncé comme conçu pour macOS Apple Silicon. Ses tests hôtes passent sur Linux, mais son guide indique que le build et l'exécution firmware sous Linux n'ont pas encore été essayés par les auteurs.

Il n'existe pas de binaire natif Windows x64 publié pour `esp-emu 1.0.0`. Les assets de cette version sont Linux x86_64/ARM64, macOS Apple Silicon et WebAssembly. Le code hôte actuel de kode-sim utilise aussi des interfaces Unix, les signaux POSIX, `flock`, `bash` et `rsync` : un build Windows natif direct demanderait un portage significatif, pas seulement un changement de compilateur.

### Chemin recommandé à court terme : moteur Linux sous WSL2

Pour valider le vrai firmware sur un PC Windows sans réécrire le moteur :

1. Garder KDS Native comme interface rapide et solution de secours.
2. Préparer un environnement Ubuntu WSL2 avec ESP-IDF v6.1, Rust, les outils requis et le binaire Linux x86_64 d'esp-emu 1.0.0.
3. Construire kode-sim depuis le commit épinglé ci-dessus, puis tester d'abord un exemple officiel kode-sdk, ensuite KodeOS.
4. Lancer kode-sim sans ouverture automatique de fenêtre et ouvrir son interface Web locale depuis Windows (Edge/WebView2) via le port localhost.
5. Ajouter un lanceur Windows qui vérifie WSL2, démarre le backend, attend le serveur local, puis ouvre l'interface. Ne pas annoncer un paquet autonome tant que l'installation WSL/IDF n'est pas reproductible.

WSL2 est une voie d'intégration à tester, pas une compatibilité Windows déjà démontrée. Le premier jalon est un test reproductible de build et de boot sous Ubuntu WSL2.

### Piste ultérieure : WebAssembly dans WebView2

Espressif publie également un build WebAssembly d'esp-emu, exécutable dans un navigateur. Cela ne rend pas kode-sim directement compatible WebAssembly : son orchestrateur Rust lance aujourd'hui un processus externe, utilise des sockets, des signaux et des outils système. Il faudrait porter la co-simulation des puces, le transport UART, les contrôles de flash et le cycle de vie du firmware vers une architecture navigateur/worker. Cette piste est intéressante pour une distribution sans WSL, mais elle est plus importante qu'un simple empaquetage WebView2.

## Ordre d'intégration

1. Épingler kode-sim et esp-emu à des versions/commits connus ; consigner licences et dépendances.
2. Faire tourner les suites hôtes de kode-sim et construire un exemple officiel dans Ubuntu WSL2.
3. Démarrer l'exemple dans esp-emu et vérifier console, fenêtre, boutons et tactile.
4. Construire KodeOS avec les adaptations amont demandées par kode-sim et vérifier son démarrage réel.
5. Vérifier écran 410×502, microSD persistante, audio, capteurs, USB et comportement des applications, fonctionnalité par fonctionnalité.
6. Relier le backend WSL2 au lanceur Kds Windows, avec arrêt propre et conservation des journaux.
7. Étudier le port WebAssembly seulement après validation du moteur de référence.

## Place du moteur KGUI natif

Le SDK officiel contient `components/kgui/sim`, qui compile les écrans KGUI réels avec LVGL et SDL2. Il reste utile pour une navigation très réactive, des captures et des tests d'interface. Il n'exécute pas le firmware ESP32, les Active Objects ni les pilotes réels.

Ne pas supprimer ce mode : il constitue une solution rapide lorsque l'utilisateur privilégie la fluidité, tandis que KDS Firmware sert à tester la compatibilité réelle du firmware.

## Critères d'acceptation KDS Firmware

- Le vrai firmware P4 démarre dans esp-emu ; la compilation seule ne suffit pas.
- Les logs de boot, les erreurs et les exceptions sont conservés.
- L'écran montre le vrai framebuffer KGUI et reçoit les entrées.
- La carte SD est utilisée par le vrai chemin FATFS/Kode/AO_Storage et ses données persistent.
- Le C5 n'est déclaré opérationnel que si son firmware et le lien P4↔C5 sont réellement fonctionnels.
- Chaque périphérique est classé comme émulé, remplacé par `kemu`, absent ou non testé.
- Le temps réel, le FPS, la latence entrée-écran, le CPU et la mémoire sont mesurés sur la machine hôte.
