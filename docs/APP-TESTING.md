# Tester une application firmware dans Kds

## Règle essentielle : construire avec kode-sim

Pour que l'écran de l'application soit transmis à la fenêtre du simulateur, l'application doit être construite avec **le même kode-sim épinglé que Kds**. Le build ajoute le composant firmware `kemu`, qui remplace notamment le panneau MIPI-DSI et transmet les images à kode-sim par UART.

Un binaire produit directement par `idf.py build` est un build ESP32-P4 classique : il ne contient pas automatiquement le pont KEMU. L'installer ensuite avec `kode-sim install --mailbox fichier.bin` ne peut pas ajouter ce pont après compilation.

La commande `kode-sim install` accepte le **dossier source ESP-IDF**. Elle construit l'application pour le simulateur, puis l'installe dans le KodeOS déjà lancé.

## Installer le jeu officiel Kody Kart

Kds sait maintenant récupérer une révision précise du dépôt officiel puis la compiler avec le pont KEMU et l'envoyer à la mailbox du simulateur :

Depuis PowerShell, à la racine du dépôt Kds :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Kds-Firmware-WSL.ps1 -Action install-kody-kart
```

Le script clone [kodediy/kode-app-kody_kart](https://github.com/kodediy/kode-app-kody_kart) dans `~/.local/share/kds-firmware/apps/kody-kart`, épingle le commit `4ee77321442035c35da4dd3994e5cdef055564db`, puis lance `kode-sim install --mailbox` sur le dossier source. Le dépôt du jeu reste intact : aucune modification n'est faite dans les sources officielles.

**Prérequis d'accès SDK :** le fichier `main/idf_component.yml` du jeu référence `kodediy/kode-sdk` via SSH. La clé SSH GitHub configurée dans Ubuntu/WSL doit donc avoir le droit de lire ce dépôt. Si la compilation échoue à l'étape de récupération du SDK, il faudra d'abord corriger cet accès SSH ; ne remplace pas la dépendance par une copie ou une version non épinglée.

Le backend `kode-sim run` doit déjà être actif sur le port 8765. L'installation redémarre le firmware émulé dans ce backend, elle ne lance pas un second simulateur.

## Installer une autre application ESP-IDF

Si une autre application est déjà présente sous forme de dossier source dans WSL, utiliser :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Kds-Firmware-WSL.ps1 -Action install-app -Project /chemin/linux/du/projet
```

Le projet doit contenir un `CMakeLists.txt` ESP-IDF.

## Pourquoi ne pas utiliser un ancien fichier .bin ?

Un binaire créé par `idf.py build` sans le composant KEMU ne peut pas acquérir le pont d'affichage après compilation. Il faut toujours repartir du dossier source et utiliser `install-app` ou `install-kody-kart`.

## Sources amont épinglées

- [kode-sim, guide officiel](https://github.com/kodediy/kode-sim/blob/e9404e4e0a9834044fb1ada36976a090c25cb70d/docs/GUIDE.md)
- [kode-sim, CLI officielle](https://github.com/kodediy/kode-sim/blob/e9404e4e0a9834044fb1ada36976a090c25cb70d/crates/kode-sim/src/main.rs)
- [Kody Kart, dépôt officiel](https://github.com/kodediy/kode-app-kody_kart)
- Version exacte de kode-sim : `e9404e4e0a9834044fb1ada36976a090c25cb70d`
- Version exacte de KodeOS : `9bcfdb71b763ee7b5c14106358643ea611fc97db`
- Version exacte de Kody Kart : `4ee77321442035c35da4dd3994e5cdef055564db`
