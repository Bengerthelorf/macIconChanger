---
title: CLI Kurulumu
section: cli
locale: tr
---

IconChanger, betik yazma ve otomasyon için bir komut satırı arayüzü içerir.

## Uygulamadan Kurulum

1. IconChanger > **Settings** > **Advanced** bölümünü açın.
2. **Command Line Tool** altında **Install** düğmesine tıklayın.
3. Yönetici parolanızı girin.

`iconchanger` komutu artık terminalinizde kullanılabilir durumdadır.

## Manuel Kurulum

Manuel olarak kurmayı tercih ediyorsanız (ör. bir dotfiles betiğinde):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Kurulumu Doğrulama

```bash
iconchanger --version
```

## Kaldırma

Uygulamadan: **Settings** > **Advanced** > **Uninstall**.

Veya manuel olarak:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Sonraki Adımlar

Tüm kullanılabilir komutlar için [Komut Referansı](./commands) sayfasına bakın.