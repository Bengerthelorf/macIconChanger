# Cle API

Une cle API de [macosicons.com](https://macosicons.com/) est necessaire pour rechercher des icones en ligne. Sans elle, vous pouvez toujours utiliser des fichiers image locaux.

## Obtenir une cle API

1. Rendez-vous sur [macosicons.com](https://macosicons.com/) et creez un compte.
2. Demandez une cle API depuis les parametres de votre compte.
3. Copiez la cle.

![Comment obtenir une cle API](/images/api-key.png)

## Saisir la cle

1. Ouvrez IconChanger.
2. Allez dans **Settings** > **Advanced**.
3. Collez votre cle API dans le champ **API Key**.
4. Cliquez sur **Test Connection** pour verifier qu'elle fonctionne.

![Parametres de la cle API](/images/api-key-settings.png)

## Utilisation sans cle API

Vous pouvez toujours changer les icones d'applications sans cle API en :

- Utilisant des fichiers image locaux (cliquez sur **Choose from the Local** ou glissez-deposez une image)
- Utilisant les icones integrees a l'application elle-meme (affichees dans la section "Local")

## Parametres API avances

Dans **Settings** > **Advanced** > **API Settings**, vous pouvez affiner le comportement de l'API :

| Parametre | Par defaut | Description |
|---|---|---|
| **Retry Count** | 0 (pas de nouvelle tentative) | Nombre de tentatives en cas d'echec d'une requete (0–3) |
| **Timeout** | 15 secondes | Delai d'attente pour chaque tentative de requete |
| **Monthly Limit** | 50 | Nombre maximal de requetes API par mois |

Le compteur **Monthly Usage** affiche votre utilisation actuelle. Il se reinitialise automatiquement le 1er de chaque mois, ou vous pouvez le reinitialiser manuellement.

### Cache de recherche d'icones

Activez **Cache API Results** pour enregistrer les resultats de recherche sur le disque. Les resultats en cache persistent apres le redemarrage de l'application, ce qui reduit l'utilisation de l'API. Utilisez le bouton d'actualisation lors de la navigation des icones pour obtenir des resultats a jour.

## Depannage

Si le test de l'API echoue :
- Verifiez que votre cle est correcte (pas d'espaces supplementaires)
- Verifiez votre connexion Internet
- L'API de macosicons.com peut etre temporairement indisponible
