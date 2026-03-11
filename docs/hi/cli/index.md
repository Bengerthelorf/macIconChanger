# CLI इंस्टॉलेशन

IconChanger में स्क्रिप्टिंग और ऑटोमेशन के लिए एक कमांड-लाइन इंटरफ़ेस शामिल है।

## ऐप से इंस्टॉल करें

1. IconChanger > **Settings** > **Advanced** खोलें।
2. **Command Line Tool** के अंतर्गत **Install** पर क्लिक करें।
3. अपना प्रशासक पासवर्ड दर्ज करें।

अब आपके टर्मिनल में `iconchanger` कमांड उपलब्ध है।

## मैन्युअल रूप से इंस्टॉल करें

यदि आप मैन्युअल रूप से इंस्टॉल करना चाहते हैं (जैसे, dotfiles स्क्रिप्ट में):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## इंस्टॉलेशन की पुष्टि

```bash
iconchanger --version
```

## अनइंस्टॉल

ऐप से: **Settings** > **Advanced** > **Uninstall**।

या मैन्युअली:

```bash
sudo rm /usr/local/bin/iconchanger
```

## अगले कदम

सभी उपलब्ध कमांड के लिए [कमांड संदर्भ](./commands) देखें।
