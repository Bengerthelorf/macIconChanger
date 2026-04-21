---
title: Configurarea initiala
section: guide
order: 2
locale: ro
---

IconChanger are nevoie de privilegii de administrator pentru a schimba pictogramele aplicatiilor. La prima lansare, aplicatia ofera posibilitatea de a configura automat aceste permisiuni.

## Configurare automata (recomandata)

1. Lanseaza IconChanger.
2. Apasa butonul **Setup** cand esti solicitat.
3. Introdu parola de administrator.

Aplicatia va instala un script ajutator in `/usr/local/lib/iconchanger/` (detinut de `root:wheel`) si va configura o regula sudoers delimitata pentru ca acesta sa poata rula fara a solicita parola de fiecare data.

## Securitate

IconChanger utilizeaza mai multe masuri de securitate pentru a proteja pipeline-ul ajutator:

- **Director ajutator detinut de root** — Fisierele ajutatoare se afla in `/usr/local/lib/iconchanger/` cu proprietatea `root:wheel`, prevenind modificarile neprivilegiate.
- **Verificarea integritatii SHA-256** — Scriptul ajutator este verificat fata de un hash cunoscut inaintea fiecarei executii.
- **Regula sudoers delimitata** — Intrarea sudoers acorda acces fara parola doar scriptului ajutator specific, nu comenzilor arbitrare.
- **Jurnal de audit** — Toate operatiunile cu pictograme sunt inregistrate cu marcaje de timp pentru trasabilitate.

## Configurare manuala

Daca configurarea automata esueaza, poti realiza configurarea manual:

1. Deschide Terminal.
2. Ruleaza:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Adauga urmatoarea linie:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Verificarea configurarii

Dupa configurare, aplicatia ar trebui sa afiseze lista de aplicatii in bara laterala. Daca vezi din nou ecranul de configurare, este posibil ca setarile sa nu fi fost aplicate corect.

Poti verifica configurarea din bara de meniu: apasa pe meniul **...** si selecteaza **Check Setup Status**.

## Limitari

Aplicatiile protejate de macOS System Integrity Protection (SIP) nu pot avea pictogramele schimbate. Aceasta este o restrictie macOS si nu poate fi ocolita.

Aplicatii frecvente protejate de SIP:
- Finder
- Safari (pe unele versiuni de macOS)
- Alte aplicatii de sistem din `/System/Applications/`