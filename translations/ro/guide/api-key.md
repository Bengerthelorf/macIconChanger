# Cheie API

O cheie API de la [macosicons.com](https://macosicons.com/) este necesara pentru a cauta pictograme online. Fara aceasta, poti folosi in continuare fisiere imagine locale.

## Obtinerea unei chei API

1. Viziteaza [macosicons.com](https://macosicons.com/) si creeaza un cont.
2. Solicita o cheie API din setarile contului tau.
3. Copiaza cheia.

![Cum sa obtii o cheie API](/images/api-key.png)

## Introducerea cheii

1. Deschide IconChanger.
2. Mergi la **Settings** > **Advanced**.
3. Lipeste cheia API in campul **API Key**.
4. Apasa **Test Connection** pentru a verifica functionarea.

![Setarile cheii API](/images/api-key-settings.png)

## Utilizarea fara cheie API

Poti schimba pictogramele aplicatiilor si fara o cheie API prin:

- Folosirea fisierelor imagine locale (apasa **Choose from the Local** sau trage si plaseaza o imagine)
- Folosirea pictogramelor incluse in aplicatie (afisate in sectiunea "Local")

## Setari API avansate

In **Settings** > **Advanced** > **API Settings**, poti regla fin comportamentul API-ului:

| Setare | Implicit | Descriere |
|---|---|---|
| **Retry Count** | 0 (fara reincercare) | De cate ori sa se reincerce o solicitare esuata (0–3) |
| **Timeout** | 15 secunde | Timp de asteptare pentru fiecare incercare |
| **Monthly Limit** | 50 | Numar maxim de interogari API pe luna |

Contorul **Monthly Usage** arata utilizarea curenta. Se reseteaza automat in prima zi a fiecarei luni sau il poti reseta manual.

### Cache pentru cautarea pictogramelor

Activeaza **Cache API Results** pentru a salva rezultatele cautarii pe disc. Rezultatele din cache persista dupa repornirea aplicatiei, reducand utilizarea API-ului. Foloseste butonul de reimprospatare cand navighezi printre pictograme pentru a obtine rezultate actualizate.

## Depanare

Daca testul API esueaza:
- Verifica daca cheia este corecta (fara spatii suplimentare)
- Verifica conexiunea la internet
- API-ul macosicons.com poate fi temporar indisponibil
