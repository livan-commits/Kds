# Choix du moteur et intégration de kode-sim

## Décision d'architecture

Kds conserve deux moteurs complémentaires :

- **KDS Native** : interface KGUI/LVGL officielle compilée pour Windows, légère et fluide. C'est le mode de navigation rapide et le banc de test graphique.
- **KDS Firmware** : exécution du vrai firmware KodeOS et des applications kode-sdk dans ESP32-P4 émulé, avec les composants de carte modélisés par le projet officiel `kode-sim`.

Le dépôt officiel à réutiliser est [kodediy/kode-sim](https://github.com/kodediy/kode-sim), version 0.2.0, commit épinglé dans `upstream.lock.json`. Il dépend d'[Espressif esp-emulator](https://github.com/espressif/esp-emulator), version `1.0.0`.

**Ne pas réécrire les Active Objects, les pilotes ou les modèles de puces déjà fournis par kode-sim.** Toute intégration doit conserver la traçabilité des sources et leurs licences GPL-3.0-or-later.

## Ce qui est désormais validé

Le workflow GitHub Actions [run 43863415371](https://github.com/livan-commits/Kds/actions/runs/43863415371) a terminé avec succès le 16 novembre 2026. Il a :

1. compilé kode-sim 0.2.0 sous Ubuntu ;
2. construit le vrai firmware KodeOS P4 à partir des révisions KodeOS/SDK épinglées ;
3. produit le binaire flash fusionné et l'ELF ;
4. lancé ce firmware avec `kode-sim run` et `esp-emu` ;
5. attendu l'état « the Kode Dot is at http://127.0.0.1:8765 » ;
6. récupéré la page HTTP locale avec curl et vérifié qu'elle n'était pas vide ;
7. vérifié l'absence de message de crash pendant le test.

Le journal du job « Boot real KodeOS firmware in esp-emu on Linux » confirme : « KodeOS booted in esp-emu and kode-sim served its local page successfully. »

**Portée exacte de cette validation :** elle prouve un build et un démarrage du firmware dans le runner Linux CI, puis la disponibilité du serveur Web de kode-sim. Elle ne prouve pas encore que chaque périphérique fonctionne, que toutes les applications démarrent, ni que le moteur fonctionne sous WSL2 ou sur le PC Windows de l'utilisateur. La page n'a pas encore été inspectée visuellement ni testée en interaction humaine.

Les artefacts firmware de ce run sont conservés temporairement dans [l'artefact CI kode-sim](https://github.com/livan-commits/Kds/actions/runs/43863415371/artifacts/14224643272).

## Ce que kode-sim apporte

D'après le README et le guide officiels :

- Le firmware tourne réellement sur un ESP32-P4 émulé : FreeRTOS, QP/C, Active Objects, kode-sdk et pilotes restent dans le firmware.
- Les puces de la carte sont modélisées côté Rust et reliées au P4 par la co-simulation : expander/boutons, contrôleur tactile, LED, haptique, chargeur, jauge, codec audio, IMU et magnétomètre.
- L'écran MIPI-DSI 410×502, la microSD, le C5/radio et l'USB sont encore partiellement fournis par `kemu`, une couche de remplacement liée au firmware.
- La carte SD est une image persistante sur le disque hôte ; FATFS, le pilote SD Kode et AO_Storage du firmware réel travaillent au-dessus du contrôleur simulé.
- Les applications doivent aujourd'hui être compilées depuis leurs sources avec `kode-sim build/run`. Les binaires catalogue compilés pour la carte ne sont pas encore tous compatibles avec le simulateur.

Ces limites doivent rester visibles dans l'interface et dans les rapports de test.

## Préparation spécifique de KodeOS

Le lancement de KodeOS par `kode-sim` demande une compilation sans radio, car le C5 n'est pas encore émulé. Le SDK épinglé contient le correctif du drain DSI (`PANEL_READ_DRAIN_MAX`) du [PR kode-sdk#122](https://github.com/kodediy/kode-sdk/pull/122), nécessaire pour éviter le blocage de l'AO écran sans hôte DSI. Le [problème KodeOS#67](https://github.com/kodediy/KodeOS/issues/67) signale des appels radio/réseau non protégés quand `CONFIG_KODEOS_RADIO=n`. Kds conserve le patch local de compatibilité sous `patches/kodeos-radio-disabled.patch`.

Le job CI vérifie que le patch s'applique proprement à la révision KodeOS épinglée et que le correctif DSI est présent. Le build KodeOS via kode-sim et son démarrage dans esp-emu réussissent maintenant dans le workflow Linux.

## Compatibilité Windows : état réel

Le binaire natif Windows disponible est **KDS Native**, c'est-à-dire KGUI/LVGL/SDL2. Il ne contient pas le moteur firmware esp-emu. Le paquet est disponible ici : [Kds Windows preview](https://github.com/livan-commits/Kds/releases/download/windows-preview/kds-windows-preview.zip).

Le moteur firmware a été compilé et testé sous Ubuntu CI. Cela ne prouve pas encore le fonctionnement sous Windows/WSL2. Le code hôte de kode-sim utilise des interfaces Unix, signaux POSIX, `flock`, `bash` et `rsync`; un binaire Windows natif direct demanderait un portage important.

### Prochaine voie : Ubuntu WSL2

1. Préparer un environnement Ubuntu WSL2 avec ESP-IDF v6.1, Rust et les outils requis.
2. Reproduire dans WSL2 les tests hôtes déjà réussis sur runner Ubuntu.
3. Reproduire le build KodeOS et le démarrage `esp-emu` maintenant validés en CI.
4. Ouvrir l'interface Web de kode-sim depuis Windows via localhost.
5. Ajouter un lanceur Windows qui vérifie WSL2, démarre le backend, attend le serveur local, puis ouvre l'interface.
6. Vérifier l'arrêt propre et la persistance des données SD/flash.

WSL2 est la prochaine intégration à réaliser, pas une compatibilité déjà démontrée.

### Piste ultérieure : WebAssembly dans WebView2

Espressif publie également un build WebAssembly d'esp-emu. Cela ne rend pas kode-sim directement compatible WebAssembly : son orchestrateur Rust lance aujourd'hui un processus externe, utilise des sockets, des signaux et des outils système. Il faudrait porter la co-simulation des puces, le transport UART, les contrôles de flash et le cycle de vie du firmware vers une architecture navigateur/worker.

## Place du moteur KGUI natif

Le SDK officiel contient `components/kgui/sim`, qui compile les écrans KGUI réels avec LVGL et SDL2. Il reste utile pour une navigation très réactive, des captures et des tests d'interface. Il n'exécute pas le firmware ESP32, les Active Objects ni les pilotes réels.

Ne pas supprimer ce mode : il constitue une solution rapide lorsque l'utilisateur privilégie la fluidité, tandis que KDS Firmware sert à tester la compatibilité réelle du firmware.

## Critères d'acceptation restants pour KDS Firmware

- [x] Le vrai firmware P4 démarre dans esp-emu sous Linux CI et le serveur Web répond.
- [ ] Inspecter visuellement l'écran et vérifier les interactions réelles.
- [ ] Reproduire le build et le boot sous Ubuntu WSL2.
- [ ] Vérifier écran 410×502, boutons, tactile et rafraîchissement.
- [ ] Vérifier la microSD persistante, audio, capteurs et stockage.
- [ ] Tester les applications construites depuis leurs sources.
- [ ] Mesurer FPS, latence entrée-écran, CPU et mémoire.
- [ ] Relier le backend WSL2 au lanceur Kds Windows avec arrêt propre et conservation des données.
- Le C5 n'est déclaré opérationnel que si son firmware et le lien P4↔C5 sont réellement fonctionnels.
