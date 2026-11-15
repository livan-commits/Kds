# Kds — simulateur Kode Dot

Projet indépendant de simulation de KodeOS/Kode Dot, reconstruit proprement à partir des sources publiques officielles de KodeDIY.

## Objectif

Exécuter le vrai firmware KodeOS et le vrai KGUI sur Windows, avec une interface fidèle au Kode Dot et des interactions fluides. Le projet ne doit pas remplacer KGUI par une maquette HTML.

## Sources officielles

- KodeOS : https://github.com/kodediy/KodeOS
- Documentation : https://docs.kode.diy/internals/overview
- SDK : référencé par le sous-module officiel de KodeOS
- Firmware cible initial : ESP32-P4
- Coprocesseur : ESP32-C5 (à intégrer au runtime après validation de son protocole)

Le commit KodeOS et les sous-modules doivent être figés dans le manifeste de build. Toute mise à jour de source doit être explicite et traçable.

## Principes

1. Préserver les sources amont : ne pas recopier aveuglément des fichiers de dépendances ; les récupérer depuis les dépôts officiels avec leurs commits exacts et licences.
2. Émulation réelle : distinguer les fonctions exécutées par le firmware de celles simulées par des périphériques virtuels.
3. Performance : éviter les copies de framebuffer inutiles, les lectures mémoire répétées et les échanges synchrones bloquants ; privilégier les workers, les régions modifiées et le rendu GPU lorsque cela est compatible.
4. Hors ligne : toutes les ressources nécessaires doivent être embarquées dans le paquet Windows.
5. Vérification : chaque étape doit compiler, démarrer et être testée avec des scénarios reproductibles.

## État

Le dépôt vient d'être initialisé. Aucun exécutable ni niveau de fluidité n'est revendiqué à ce stade.

Voir [l'architecture et le plan de réalisation](docs/ARCHITECTURE.md).
