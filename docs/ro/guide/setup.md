# Configurarea initiala

IconChanger are nevoie de privilegii de administrator pentru a schimba pictogramele aplicatiilor. La prima lansare, aplicatia ofera posibilitatea de a configura automat aceste permisiuni.

## Configurare automata (recomandata)

1. Lanseaza IconChanger.
2. Apasa butonul **Setup** cand esti solicitat.
3. Introdu parola de administrator.

Aplicatia va crea un script ajutator la `~/.iconchanger/helper.sh` si va configura o regula sudoers pentru ca acesta sa poata rula fara a solicita parola de fiecare data.

## Configurare manuala

Daca configurarea automata esueaza, poti realiza configurarea manual:

1. Deschide Terminal.
2. Ruleaza:

```bash
sudo visudo
```

3. Adauga urmatoarea linie la sfarsit:

```
ALL ALL=(ALL) NOPASSWD: /Users/<numele-tau-de-utilizator>/.iconchanger/helper.sh
```

Inlocuieste `<numele-tau-de-utilizator>` cu numele tau real de utilizator macOS.

## Verificarea configurarii

Dupa configurare, aplicatia ar trebui sa afiseze lista de aplicatii in bara laterala. Daca vezi din nou ecranul de configurare, este posibil ca setarile sa nu fi fost aplicate corect.

Poti verifica configurarea din bara de meniu: apasa pe meniul **...** si selecteaza **Check Setup Status**.

## Limitari

Aplicatiile protejate de macOS System Integrity Protection (SIP) nu pot avea pictogramele schimbate. Aceasta este o restrictie macOS si nu poate fi ocolita.

Aplicatii frecvente protejate de SIP:
- Finder
- Safari (pe unele versiuni de macOS)
- Alte aplicatii de sistem din `/System/Applications/`
