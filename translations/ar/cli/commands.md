# مرجع الأوامر

## نظرة عامة

```
iconchanger <command> [options]
```

## الأوامر

### `status`

عرض حالة الإعدادات الحالية.

```bash
iconchanger status
```

يعرض:
- عدد الأسماء البديلة المُهيّأة للتطبيقات
- عدد الأيقونات المخزنة مؤقتًا
- حالة البرنامج المساعد

---

### `list`

عرض قائمة بجميع الأسماء البديلة والأيقونات المخزنة مؤقتًا.

```bash
iconchanger list
```

يعرض جدولًا بجميع الأسماء البديلة المُهيّأة وجميع إدخالات الأيقونات المخزنة مؤقتًا.

---

### `set-icon`

تعيين أيقونة مخصصة لتطبيق.

```bash
iconchanger set-icon <app-path> <image-path>
```

**المعاملات:**
- `app-path` — مسار التطبيق (مثل `/Applications/Safari.app`)
- `image-path` — مسار صورة الأيقونة (PNG، JPEG، ICNS، إلخ.)

**أمثلة:**

```bash
# تعيين أيقونة مخصصة لـ Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# المسارات النسبية تعمل أيضًا
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

إزالة أيقونة مخصصة واستعادة الأيقونة الأصلية.

```bash
iconchanger remove-icon <app-path>
```

**مثال:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

استعادة جميع الأيقونات المخصصة المخزنة مؤقتًا. مفيد بعد تحديث النظام أو عندما تُعيد التطبيقات تعيين أيقوناتها.

```bash
iconchanger restore [options]
```

**الخيارات:**
- `--dry-run` — معاينة ما سيتم استعادته دون إجراء تغييرات
- `--verbose` — عرض مخرجات مفصلة لكل أيقونة
- `--force` — الاستعادة حتى لو بدت الأيقونة دون تغيير

**أمثلة:**

```bash
# استعادة جميع الأيقونات المخزنة مؤقتًا
iconchanger restore

# معاينة ما سيحدث
iconchanger restore --dry-run --verbose

# فرض استعادة كل شيء
iconchanger restore --force
```

---

### `export`

تصدير الأسماء البديلة وإعدادات الأيقونات المخزنة مؤقتًا إلى ملف JSON.

```bash
iconchanger export <output-path>
```

**مثال:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

استيراد ملف إعدادات.

```bash
iconchanger import <input-path>
```

الاستيراد يضيف عناصر جديدة فقط — لا يستبدل أو يزيل الإدخالات الموجودة.

**مثال:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

التحقق من صحة ملف إعدادات قبل الاستيراد.

```bash
iconchanger validate <file-path>
```

يتحقق من بنية JSON والحقول المطلوبة وسلامة البيانات دون إجراء تغييرات.

**مثال:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

الخروج من سجن squircle في macOS Tahoe بإعادة تطبيق الأيقونات المضمّنة كأيقونات مخصصة. الأيقونات المخصصة تتجاوز فرض squircle، مما يحافظ على شكل الأيقونة الأصلي.

```bash
iconchanger escape-jail [app-path] [options]
```

**المعاملات:**
- `app-path` — (اختياري) مسار حزمة `.app` محددة. إذا لم يُحدد، تتم معالجة جميع التطبيقات في `/Applications`.

**الخيارات:**
- `--dry-run` — معاينة ما سيتم تنفيذه دون إجراء تغييرات
- `--verbose` — عرض مخرجات مفصلة

**أمثلة:**

```bash
# الخروج من السجن لجميع التطبيقات في /Applications
iconchanger escape-jail

# معاينة ما سيحدث
iconchanger escape-jail --dry-run --verbose

# الخروج من السجن لتطبيق محدد
iconchanger escape-jail /Applications/Safari.app
```

::: warning
الأيقونات المخصصة لا تدعم أوضاع Clear أو Tinted أو Dark في macOS Tahoe. تبقى كصور نقطية ثابتة.
:::

---

### `completions`

توليد سكربتات إكمال الأوامر للصدفة لدعم الإكمال بالضغط على Tab.

```bash
iconchanger completions <shell>
```

**المعاملات:**
- `shell` — نوع الصدفة: `zsh` أو `bash` أو `fish`

**أمثلة:**

```bash
# Zsh (أضف إلى ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (أضف إلى ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
