# Tester une application firmware dans Kds

## Règle essentielle : construire avec kode-sim

Pour que l'écran de l'application soit transmis à la fenêtre du simulateur, l'application doit être construite avec **le même kode-sim épinglé que Kds**. Le build ajoute le composant firmware `kemu`, qui remplace notamment le panneau MIPI-DSI et transmet les images à kode-sim par UART.

Un binaire produit directement par `idf.py build` est un build ESP32-P4 classique : il ne contient pas automatiquement le pont KEMU. L'installer ensuite avec `kode-sim install --mailbox fichier.bin` ne peut pas ajouter ce pont après compilation. Les symptômes possibles sont une application qui démarre et dont LVGL annonce un écran actif, alors que la fenêtre continue d'afficher l'ancienne image.

La commande `kode-sim install` accepte le **dossier source ESP-IDF**. Elle construit l'application pour le simulateur, puis l'installe dans le KodeOS déjà lancé.

## Procédure depuis Windows / PowerShell

En supposant que le backend Kds est déjà lancé et que l'application se trouve dans `/home/pc/kd_full_test` :

```powershell
wsl -d Ubuntu -- bash /home/pc/Kds/scripts/kds-firmware-wsl.sh install-app /home/pc/kd_full_test
```

Le script :
1. charge ESP-IDF v6.1 et les outils Rust installés par Kds ;
2. vérifie les sources amont et le correctif KodeOS épinglés ;
3. construit kode-sim si nécessaire ;
4. appelle `kode-sim install --mailbox /home/pc/kd_full_test`, ce qui construit le projet avec KEMU puis installe l'application dans le simulateur en cours.

Le backend `kode-sim run` doit être actif sur le port 8765. La commande ne redémarre pas le backend.

## Important pour KD Full Test

Ne pas réutiliser `build/kd_full_test.bin` généré par `idf.py build` pour valider le rafraîchissement d'écran. Le conserver est utile pour les comparaisons, mais le test correct doit partir du dossier source `/home/pc/kd_full_test` via `install-app`.

Cette correction de méthode ne garantit pas à elle seule que le rendu sera visible : il faudra ensuite vérifier que les messages vidéo KEMU arrivent dans la fenêtre et que les images changent. Les boutons et le tactile qui fonctionnent ne suffisent pas à valider le chemin d'affichage.

## Sources amont

- [kode-sim, guide officiel](https://github.com/kodediy/kode-sim/blob/e9404e4e0a9834044fb1ada36976a090c25cb70d/docs/GUIDE.md)
- [kode-sim, CLI officielle](https://github.com/kodediy/kode-sim/blob/e9404e4e0a9834044fb1ada36976a090c25cb70d/crates/kode-sim/src/main.rs)
- Version exacte de kode-sim : `e9404e4e0a9834044fb1ada36976a090c25cb70d`
- Version exacte de KodeOS : `9bcfdb71b763ee7b5c14106358643ea611fc97db`
