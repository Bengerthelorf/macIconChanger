# Configuration initiale

IconChanger necessite des privileges d'administrateur pour modifier les icones des applications. Lors du premier lancement, l'application propose de configurer cela automatiquement.

## Configuration automatique (recommandee)

1. Lancez IconChanger.
2. Cliquez sur le bouton **Setup** lorsque vous y etes invite.
3. Saisissez votre mot de passe administrateur.

L'application installera un script auxiliaire dans `/usr/local/lib/iconchanger/` (appartenant a `root:wheel`) et configurera une regle sudoers delimitee pour qu'il puisse s'executer sans demander de mot de passe a chaque fois.

## Securite

IconChanger utilise plusieurs mesures de securite pour proteger le pipeline auxiliaire :

- **Repertoire auxiliaire appartenant a root** — Les fichiers auxiliaires se trouvent dans `/usr/local/lib/iconchanger/` avec la propriete `root:wheel`, empechant toute modification non privilegiee.
- **Verification d'integrite SHA-256** — Le script auxiliaire est verifie par rapport a un hachage connu avant chaque execution.
- **Regle sudoers delimitee** — L'entree sudoers n'accorde l'acces sans mot de passe qu'au script auxiliaire specifique, et non a des commandes arbitraires.
- **Journalisation d'audit** — Toutes les operations sur les icones sont enregistrees avec des horodatages pour la tracabilite.

## Configuration manuelle

Si la configuration automatique echoue, vous pouvez la realiser manuellement :

1. Ouvrez le Terminal.
2. Executez :

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Ajoutez la ligne suivante :

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Verification de la configuration

Apres la configuration, l'application devrait afficher la liste des applications dans la barre laterale. Si l'ecran de configuration reapparait, la configuration n'a peut-etre pas ete appliquee correctement.

Vous pouvez verifier la configuration depuis la barre de menus : cliquez sur le menu **...** et selectionnez **Check Setup Status**.

## Limitations

Les applications protegees par la Protection de l'integrite du systeme (SIP) de macOS ne peuvent pas voir leurs icones modifiees. Il s'agit d'une restriction de macOS qui ne peut pas etre contournee.

Les applications couramment protegees par SIP incluent :
- Finder
- Safari (sur certaines versions de macOS)
- Autres applications systeme dans `/System/Applications/`
