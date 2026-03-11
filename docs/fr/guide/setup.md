# Configuration initiale

IconChanger necessite des privileges d'administrateur pour modifier les icones des applications. Lors du premier lancement, l'application propose de configurer cela automatiquement.

## Configuration automatique (recommandee)

1. Lancez IconChanger.
2. Cliquez sur le bouton **Setup** lorsque vous y etes invite.
3. Saisissez votre mot de passe administrateur.

L'application creera un script auxiliaire dans `~/.iconchanger/helper.sh` et configurera une regle sudoers pour qu'il puisse s'executer sans demander de mot de passe a chaque fois.

## Configuration manuelle

Si la configuration automatique echoue, vous pouvez la realiser manuellement :

1. Ouvrez le Terminal.
2. Executez :

```bash
sudo visudo
```

3. Ajoutez la ligne suivante a la fin :

```
ALL ALL=(ALL) NOPASSWD: /Users/<votre-nom-utilisateur>/.iconchanger/helper.sh
```

Remplacez `<votre-nom-utilisateur>` par votre nom d'utilisateur macOS.

## Verification de la configuration

Apres la configuration, l'application devrait afficher la liste des applications dans la barre laterale. Si l'ecran de configuration reapparait, la configuration n'a peut-etre pas ete appliquee correctement.

Vous pouvez verifier la configuration depuis la barre de menus : cliquez sur le menu **...** et selectionnez **Check Setup Status**.

## Limitations

Les applications protegees par la Protection de l'integrite du systeme (SIP) de macOS ne peuvent pas voir leurs icones modifiees. Il s'agit d'une restriction de macOS qui ne peut pas etre contournee.

Les applications couramment protegees par SIP incluent :
- Finder
- Safari (sur certaines versions de macOS)
- Autres applications systeme dans `/System/Applications/`
