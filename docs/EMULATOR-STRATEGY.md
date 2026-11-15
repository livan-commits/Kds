# Choix du moteur et modes d'exécution

## Pourquoi deux modes complémentaires

Le SDK officiel contient déjà `components/kgui/sim`. Ce programme compile les écrans KGUI réels de KodeOS avec LVGL et SDL2, dans une fenêtre native ou en capture PNG. Il sert à obtenir une interface native fluide et à valider les écrans et interactions UI.

Ce mode n'exécute pas le firmware ESP32-P4, les Active Objects ni les pilotes réels. Il doit donc être présenté comme **KGUI natif**, pas comme une émulation complète de KodeOS.

Le mode **KodeOS firmware** doit charger l'image flash produite par le vrai build P4 dans ESP-EMU. ESP-EMU 1.0.0 annonce les CPU P4 (double cœur) et C5, la mémoire/PSRAM, le firmware ESP-IDF et les périphériques virtuels par co-simulation. Les composants spécifiques du Kode Dot devront être modélisés et testés.

## Cible Windows

Les assets publiés d'ESP-EMU 1.0.0 contiennent le moteur natif Linux x86_64 / Linux ARM64 / macOS ARM64 ainsi que le runtime WebAssembly ; il n'y a pas de binaire moteur Windows x64 dans cette publication. Le premier chemin Windows complet sera donc le runtime WASM officiel intégré dans une application locale WebView2, avec tous les fichiers inclus et sans CDN.

Le mode KGUI natif est compilé directement pour Windows avec SDL2. Il donnera une référence de fluidité et permettra de distinguer un problème d'interface d'un problème de vitesse d'émulation CPU.

## Règles de performance

- CPU d'émulation isolé du thread de rendu.
- Transfert de framebuffer en blocs et uniquement lorsque la séquence/zone modifiée change.
- Aucun polling mémoire à haute fréquence si l'image n'a pas changé.
- Utiliser les symboles ELF exportés pour trouver les buffers, pas des adresses codées en dur.
- Éviter la conversion de pixels si le format source peut être consommé directement.
- Mesurer MIPS/temps émulé, FPS, latence entrée-écran, CPU hôte et mémoire.
- Garder une horloge invitée fidèle ; ne pas accélérer le temps système pour faire croire à de meilleures performances.

## Critères d'acceptation

### KGUI natif
- Compilation Windows réussie à partir des sources amont épinglées.
- Les écrans face, launcher, loading, settings et touch_test s'affichent.
- Les entrées clavier/souris et la navigation sont documentées.
- Le paquet contient les DLL nécessaires et démarre hors ligne.

### KodeOS firmware
- Le vrai firmware P4 démarre dans ESP-EMU.
- La sortie console et les exceptions sont conservées dans les logs.
- Les périphériques requis au démarrage répondent correctement.
- Le framebuffer correspond au vrai KGUI et se met à jour sans blocage.
- Les boutons et le tactile injectés modifient le vrai état du firmware.
- Le C5 est considéré opérationnel seulement si son firmware démarre et que le lien P4↔C5 est fonctionnel.
