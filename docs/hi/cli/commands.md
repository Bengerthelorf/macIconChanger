---
title: कमांड संदर्भ
section: cli
locale: hi
---

## अवलोकन

```
iconchanger <command> [options]
```

## कमांड

### `status`

वर्तमान कॉन्फ़िगरेशन स्थिति दिखाएं।

```bash
iconchanger status
```

दिखाता है:
- कॉन्फ़िगर किए गए ऐप एलियास की संख्या
- कैश किए गए आइकन की संख्या
- हेल्पर स्क्रिप्ट की स्थिति

---

### `list`

सभी एलियास और कैश किए गए आइकन की सूची बनाएं।

```bash
iconchanger list
```

सभी कॉन्फ़िगर किए गए एलियास और सभी कैश किए गए आइकन प्रविष्टियों की एक तालिका दिखाता है।

---

### `set-icon`

किसी एप्लिकेशन के लिए कस्टम आइकन सेट करें।

```bash
iconchanger set-icon <app-path> <image-path>
```

**आर्गुमेंट:**
- `app-path` — एप्लिकेशन का पथ (जैसे, `/Applications/Safari.app`)
- `image-path` — आइकन इमेज का पथ (PNG, JPEG, ICNS, आदि)

**उदाहरण:**

```bash
# Safari के लिए कस्टम आइकन सेट करें
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# रिलेटिव पथ भी काम करते हैं
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

कस्टम आइकन हटाएं और मूल आइकन रिस्टोर करें।

```bash
iconchanger remove-icon <app-path>
```

**उदाहरण:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

सभी कैश किए गए कस्टम आइकन रिस्टोर करें। सिस्टम अपडेट के बाद या जब ऐप अपने आइकन रीसेट कर दें, तब उपयोगी।

```bash
iconchanger restore [options]
```

**विकल्प:**
- `--dry-run` — बिना कोई बदलाव किए प्रीव्यू करें कि क्या रिस्टोर होगा
- `--verbose` — प्रत्येक आइकन के लिए विस्तृत आउटपुट दिखाएं
- `--force` — आइकन अपरिवर्तित दिखने पर भी रिस्टोर करें

**उदाहरण:**

```bash
# सभी कैश किए गए आइकन रिस्टोर करें
iconchanger restore

# प्रीव्यू करें कि क्या होगा
iconchanger restore --dry-run --verbose

# सब कुछ ज़बरदस्ती रिस्टोर करें
iconchanger restore --force
```

---

### `export`

एलियास और कैश किए गए आइकन कॉन्फ़िगरेशन को JSON फ़ाइल में एक्सपोर्ट करें।

```bash
iconchanger export <output-path>
```

**उदाहरण:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

एक कॉन्फ़िगरेशन फ़ाइल इंपोर्ट करें।

```bash
iconchanger import <input-path>
```

इंपोर्ट केवल नए आइटम जोड़ता है — यह मौजूदा प्रविष्टियों को कभी नहीं बदलता या हटाता।

**उदाहरण:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

इंपोर्ट करने से पहले कॉन्फ़िगरेशन फ़ाइल को वैलिडेट करें।

```bash
iconchanger validate <file-path>
```

बिना कोई बदलाव किए JSON संरचना, आवश्यक फ़ील्ड और डेटा अखंडता की जांच करता है।

**उदाहरण:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

macOS Tahoe के squircle jail से बचें — बंडल किए गए आइकन को कस्टम आइकन के रूप में फिर से लागू करके। कस्टम आइकन squircle प्रवर्तन को बायपास करते हैं, मूल आइकन आकार को संरक्षित करते हैं।

```bash
iconchanger escape-jail [app-path] [options]
```

**आर्गुमेंट:**
- `app-path` — (वैकल्पिक) किसी विशिष्ट `.app` बंडल का पथ। यदि छोड़ा जाता है, तो `/Applications` में सभी ऐप प्रोसेस होते हैं।

**विकल्प:**
- `--dry-run` — बिना बदलाव किए प्रीव्यू करें कि क्या होगा
- `--verbose` — विस्तृत आउटपुट दिखाएं

**उदाहरण:**

```bash
# /Applications में सभी ऐप के लिए jail से बचें
iconchanger escape-jail

# प्रीव्यू करें कि क्या होगा
iconchanger escape-jail --dry-run --verbose

# किसी विशिष्ट ऐप के लिए jail से बचें
iconchanger escape-jail /Applications/Safari.app
```

::: warning
कस्टम आइकन macOS Tahoe के Clear, Tinted, या Dark आइकन मोड का समर्थन नहीं करते। वे स्थिर बिटमैप के रूप में रहते हैं।
:::

---

### `completions`

टैब कम्पलीशन के लिए शेल कम्पलीशन स्क्रिप्ट जनरेट करें।

```bash
iconchanger completions <shell>
```

**आर्गुमेंट:**
- `shell` — शेल प्रकार: `zsh`, `bash`, या `fish`

**उदाहरण:**

```bash
# Zsh (~/.zshrc में जोड़ें)
source <(iconchanger completions zsh)

# Bash (~/.bashrc में जोड़ें)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```