---
title: Service d'arriere-plan
section: guide
order: 6
locale: fr
---

Le service d'arriere-plan maintient vos icones personnalisees intactes, meme apres les mises a jour des applications ou les modifications du systeme.

## Activation

Allez dans **Settings** > **Background** et activez **Run in Background**.

Lorsque cette option est activee, IconChanger continue de fonctionner apres la fermeture de la fenetre. Vous pouvez y acceder depuis la barre de menus ou le Dock.

## Fonctionnalites

### Restauration planifiee

Restaurez automatiquement toutes les icones personnalisees en cache a intervalles reguliers.

- Activez **Restore Icons on Schedule**
- Choisissez un intervalle : toutes les heures, 3 heures, 6 heures, 12 heures, quotidien ou un intervalle personnalise
- Les parametres affichent la date de la derniere restauration et de la prochaine

### Detection des mises a jour d'applications

Detectez quand les applications sont mises a jour et reappliquez automatiquement leurs icones personnalisees.

- Activez **Restore Icons When Apps Update**
- Definissez la frequence de verification des mises a jour (de toutes les 5 minutes a toutes les 2 heures, ou personnalisee)

### Visibilite de l'application

Controlez ou IconChanger apparait lorsqu'il fonctionne en arriere-plan :

- **Show in Menu Bar** — ajoute une icone dans la barre de menus
- **Show in Dock** — maintient l'application dans le Dock

Au moins l'une de ces options doit etre activee.

### Lancement au demarrage

Demarrez IconChanger automatiquement lorsque vous vous connectez a votre Mac.

- **Open Main Window** — lance normalement avec la fenetre principale
- **Start Hidden** — lance silencieusement en arriere-plan (necessite que "Run in Background" soit active)

::: info
"Start Hidden" n'affecte que le lancement a la connexion. Ouvrir l'application manuellement affichera toujours la fenetre principale.
:::

## Etat du service

Lorsque le service d'arriere-plan est actif, la page des parametres affiche :
- **Service Status** — indique si le service est en cours d'execution
- **Cached Icons** — nombre d'icones pretes a etre restaurees