---
title: इंपोर्ट और एक्सपोर्ट
section: guide
order: 8
locale: hi
---

अपने आइकन कॉन्फ़िगरेशन का बैकअप लें या उन्हें दूसरे Mac पर ट्रांसफ़र करें।

## क्या एक्सपोर्ट होता है

एक एक्सपोर्ट फ़ाइल (JSON) में शामिल है:
- **ऐप एलियास** — आपके कस्टम खोज नाम मैपिंग
- **कैश किए गए आइकन संदर्भ** — किन ऐप के कस्टम आइकन हैं और कैश की गई आइकन फ़ाइलें

## एक्सपोर्ट करना

### GUI से

**Settings** > **Advanced** > **Configuration** पर जाएं, और **Export** पर क्लिक करें।

### CLI से

```bash
iconchanger export ~/Desktop/my-icons.json
```

## इंपोर्ट करना

### GUI से

**Settings** > **Advanced** > **Configuration** पर जाएं, और **Import** पर क्लिक करें।

### CLI से

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
इंपोर्ट केवल नए आइटम **जोड़ता** है। यह आपके मौजूदा एलियास या कैश किए गए आइकन को कभी भी बदलता या हटाता नहीं है।
:::

## वैलिडेशन

इंपोर्ट करने से पहले, आप एक कॉन्फ़िगरेशन फ़ाइल को वैलिडेट कर सकते हैं:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

यह बिना कोई बदलाव किए फ़ाइल संरचना की जांच करता है।

## Dotfiles के साथ ऑटोमेशन

आप अपने dotfiles के हिस्से के रूप में IconChanger सेटअप को स्वचालित कर सकते हैं:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# ऐप इंस्टॉल करें
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# CLI इंस्टॉल करें (ऐप बंडल से)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# अपना आइकन कॉन्फ़िगरेशन इंपोर्ट करें
iconchanger import ~/dotfiles/iconchanger/config.json
```