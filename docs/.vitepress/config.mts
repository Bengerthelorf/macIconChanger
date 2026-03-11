import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'IconChanger',
  description: 'Customize macOS app icons with ease',
  base: '/macIconChanger/',

  head: [
    ['link', { rel: 'icon', type: 'image/png', href: '/macIconChanger/images/favicon.png' }],
  ],

  locales: {
    root: {
      label: 'English',
      lang: 'en',
    },
    zh: {
      label: '简体中文',
      lang: 'zh-Hans',
      themeConfig: {
        nav: [
          { text: '指南', link: '/zh/guide/getting-started' },
          { text: 'CLI', link: '/zh/cli/' },
          {
            text: '下载',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/zh/guide/': [
            {
              text: '入门',
              items: [
                { text: '快速开始', link: '/zh/guide/getting-started' },
                { text: '权限配置', link: '/zh/guide/setup' },
                { text: 'API 密钥', link: '/zh/guide/api-key' },
              ],
            },
            {
              text: '使用',
              items: [
                { text: '更改图标', link: '/zh/guide/changing-icons' },
                { text: '应用别名', link: '/zh/guide/aliases' },
                { text: '后台服务', link: '/zh/guide/background-service' },
                { text: '导入与导出', link: '/zh/guide/import-export' },
              ],
            },
          ],
          '/zh/cli/': [
            {
              text: '命令行工具',
              items: [
                { text: '安装', link: '/zh/cli/' },
                { text: '命令参考', link: '/zh/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    fr: {
      label: 'Français',
      lang: 'fr',
      themeConfig: {
        nav: [
          { text: 'Guide', link: '/fr/guide/getting-started' },
          { text: 'CLI', link: '/fr/cli/' },
          {
            text: 'Télécharger',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/fr/guide/': [
            {
              text: 'Prise en main',
              items: [
                { text: 'Démarrage rapide', link: '/fr/guide/getting-started' },
                { text: 'Configuration initiale', link: '/fr/guide/setup' },
                { text: 'Clé API', link: '/fr/guide/api-key' },
              ],
            },
            {
              text: 'Utilisation',
              items: [
                { text: 'Changer les icônes', link: '/fr/guide/changing-icons' },
                { text: 'Alias d\'applications', link: '/fr/guide/aliases' },
                { text: 'Service d\'arrière-plan', link: '/fr/guide/background-service' },
                { text: 'Import et export', link: '/fr/guide/import-export' },
              ],
            },
          ],
          '/fr/cli/': [
            {
              text: 'Outil en ligne de commande',
              items: [
                { text: 'Installation', link: '/fr/cli/' },
                { text: 'Référence des commandes', link: '/fr/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    ja: {
      label: '日本語',
      lang: 'ja',
      themeConfig: {
        nav: [
          { text: 'ガイド', link: '/ja/guide/getting-started' },
          { text: 'CLI', link: '/ja/cli/' },
          {
            text: 'ダウンロード',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/ja/guide/': [
            {
              text: 'はじめに',
              items: [
                { text: 'クイックスタート', link: '/ja/guide/getting-started' },
                { text: '初期設定', link: '/ja/guide/setup' },
                { text: 'API キー', link: '/ja/guide/api-key' },
              ],
            },
            {
              text: '使い方',
              items: [
                { text: 'アイコンの変更', link: '/ja/guide/changing-icons' },
                { text: 'アプリのエイリアス', link: '/ja/guide/aliases' },
                { text: 'バックグラウンドサービス', link: '/ja/guide/background-service' },
                { text: 'インポート＆エクスポート', link: '/ja/guide/import-export' },
              ],
            },
          ],
          '/ja/cli/': [
            {
              text: 'コマンドラインツール',
              items: [
                { text: 'インストール', link: '/ja/cli/' },
                { text: 'コマンドリファレンス', link: '/ja/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    ko: {
      label: '한국어',
      lang: 'ko',
      themeConfig: {
        nav: [
          { text: '가이드', link: '/ko/guide/getting-started' },
          { text: 'CLI', link: '/ko/cli/' },
          {
            text: '다운로드',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/ko/guide/': [
            {
              text: '시작하기',
              items: [
                { text: '빠른 시작', link: '/ko/guide/getting-started' },
                { text: '초기 설정', link: '/ko/guide/setup' },
                { text: 'API 키', link: '/ko/guide/api-key' },
              ],
            },
            {
              text: '사용법',
              items: [
                { text: '아이콘 변경', link: '/ko/guide/changing-icons' },
                { text: '앱 별칭', link: '/ko/guide/aliases' },
                { text: '백그라운드 서비스', link: '/ko/guide/background-service' },
                { text: '가져오기 및 내보내기', link: '/ko/guide/import-export' },
              ],
            },
          ],
          '/ko/cli/': [
            {
              text: '명령줄 도구',
              items: [
                { text: '설치', link: '/ko/cli/' },
                { text: '명령어 레퍼런스', link: '/ko/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    es: {
      label: 'Español',
      lang: 'es',
      themeConfig: {
        nav: [
          { text: 'Guía', link: '/es/guide/getting-started' },
          { text: 'CLI', link: '/es/cli/' },
          {
            text: 'Descargar',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/es/guide/': [
            {
              text: 'Primeros pasos',
              items: [
                { text: 'Inicio rápido', link: '/es/guide/getting-started' },
                { text: 'Configuración inicial', link: '/es/guide/setup' },
                { text: 'Clave API', link: '/es/guide/api-key' },
              ],
            },
            {
              text: 'Uso',
              items: [
                { text: 'Cambiar iconos', link: '/es/guide/changing-icons' },
                { text: 'Alias de aplicaciones', link: '/es/guide/aliases' },
                { text: 'Servicio en segundo plano', link: '/es/guide/background-service' },
                { text: 'Importar y exportar', link: '/es/guide/import-export' },
              ],
            },
          ],
          '/es/cli/': [
            {
              text: 'Herramienta de línea de comandos',
              items: [
                { text: 'Instalación', link: '/es/cli/' },
                { text: 'Referencia de comandos', link: '/es/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    de: {
      label: 'Deutsch',
      lang: 'de',
      themeConfig: {
        nav: [
          { text: 'Anleitung', link: '/de/guide/getting-started' },
          { text: 'CLI', link: '/de/cli/' },
          {
            text: 'Herunterladen',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/de/guide/': [
            {
              text: 'Erste Schritte',
              items: [
                { text: 'Schnellstart', link: '/de/guide/getting-started' },
                { text: 'Ersteinrichtung', link: '/de/guide/setup' },
                { text: 'API-Schlüssel', link: '/de/guide/api-key' },
              ],
            },
            {
              text: 'Verwendung',
              items: [
                { text: 'Symbole ändern', link: '/de/guide/changing-icons' },
                { text: 'App-Aliasse', link: '/de/guide/aliases' },
                { text: 'Hintergrunddienst', link: '/de/guide/background-service' },
                { text: 'Import & Export', link: '/de/guide/import-export' },
              ],
            },
          ],
          '/de/cli/': [
            {
              text: 'Kommandozeilen-Werkzeug',
              items: [
                { text: 'Installation', link: '/de/cli/' },
                { text: 'Befehlsreferenz', link: '/de/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    tr: {
      label: 'Türkçe',
      lang: 'tr',
      themeConfig: {
        nav: [
          { text: 'Rehber', link: '/tr/guide/getting-started' },
          { text: 'CLI', link: '/tr/cli/' },
          {
            text: 'İndir',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/tr/guide/': [
            {
              text: 'Başlangıç',
              items: [
                { text: 'Hızlı Başlangıç', link: '/tr/guide/getting-started' },
                { text: 'İlk Kurulum', link: '/tr/guide/setup' },
                { text: 'API Anahtarı', link: '/tr/guide/api-key' },
              ],
            },
            {
              text: 'Kullanım',
              items: [
                { text: 'Simge Değiştirme', link: '/tr/guide/changing-icons' },
                { text: 'Uygulama Takma Adları', link: '/tr/guide/aliases' },
                { text: 'Arka Plan Hizmeti', link: '/tr/guide/background-service' },
                { text: 'İçe ve Dışa Aktarma', link: '/tr/guide/import-export' },
              ],
            },
          ],
          '/tr/cli/': [
            {
              text: 'Komut Satırı Aracı',
              items: [
                { text: 'Kurulum', link: '/tr/cli/' },
                { text: 'Komut Referansı', link: '/tr/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    pl: {
      label: 'Polski',
      lang: 'pl',
      themeConfig: {
        nav: [
          { text: 'Przewodnik', link: '/pl/guide/getting-started' },
          { text: 'CLI', link: '/pl/cli/' },
          {
            text: 'Pobierz',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/pl/guide/': [
            {
              text: 'Pierwsze kroki',
              items: [
                { text: 'Szybki start', link: '/pl/guide/getting-started' },
                { text: 'Konfiguracja początkowa', link: '/pl/guide/setup' },
                { text: 'Klucz API', link: '/pl/guide/api-key' },
              ],
            },
            {
              text: 'Użytkowanie',
              items: [
                { text: 'Zmiana ikon', link: '/pl/guide/changing-icons' },
                { text: 'Aliasy aplikacji', link: '/pl/guide/aliases' },
                { text: 'Usługa w tle', link: '/pl/guide/background-service' },
                { text: 'Import i eksport', link: '/pl/guide/import-export' },
              ],
            },
          ],
          '/pl/cli/': [
            {
              text: 'Narzędzie wiersza poleceń',
              items: [
                { text: 'Instalacja', link: '/pl/cli/' },
                { text: 'Referencja poleceń', link: '/pl/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    nl: {
      label: 'Nederlands',
      lang: 'nl',
      themeConfig: {
        nav: [
          { text: 'Handleiding', link: '/nl/guide/getting-started' },
          { text: 'CLI', link: '/nl/cli/' },
          {
            text: 'Downloaden',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/nl/guide/': [
            {
              text: 'Aan de slag',
              items: [
                { text: 'Snelstart', link: '/nl/guide/getting-started' },
                { text: 'Eerste configuratie', link: '/nl/guide/setup' },
                { text: 'API-sleutel', link: '/nl/guide/api-key' },
              ],
            },
            {
              text: 'Gebruik',
              items: [
                { text: 'Iconen wijzigen', link: '/nl/guide/changing-icons' },
                { text: 'App-aliassen', link: '/nl/guide/aliases' },
                { text: 'Achtergronddienst', link: '/nl/guide/background-service' },
                { text: 'Importeren en exporteren', link: '/nl/guide/import-export' },
              ],
            },
          ],
          '/nl/cli/': [
            {
              text: 'Opdrachtregelhulpmiddel',
              items: [
                { text: 'Installatie', link: '/nl/cli/' },
                { text: 'Opdrachtreferentie', link: '/nl/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    sv: {
      label: 'Svenska',
      lang: 'sv',
      themeConfig: {
        nav: [
          { text: 'Guide', link: '/sv/guide/getting-started' },
          { text: 'CLI', link: '/sv/cli/' },
          {
            text: 'Ladda ner',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/sv/guide/': [
            {
              text: 'Kom igång',
              items: [
                { text: 'Snabbstart', link: '/sv/guide/getting-started' },
                { text: 'Första konfigurationen', link: '/sv/guide/setup' },
                { text: 'API-nyckel', link: '/sv/guide/api-key' },
              ],
            },
            {
              text: 'Användning',
              items: [
                { text: 'Ändra ikoner', link: '/sv/guide/changing-icons' },
                { text: 'App-alias', link: '/sv/guide/aliases' },
                { text: 'Bakgrundstjänst', link: '/sv/guide/background-service' },
                { text: 'Import och export', link: '/sv/guide/import-export' },
              ],
            },
          ],
          '/sv/cli/': [
            {
              text: 'Kommandoradsverktyg',
              items: [
                { text: 'Installation', link: '/sv/cli/' },
                { text: 'Kommandoreferens', link: '/sv/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    da: {
      label: 'Dansk',
      lang: 'da',
      themeConfig: {
        nav: [
          { text: 'Guide', link: '/da/guide/getting-started' },
          { text: 'CLI', link: '/da/cli/' },
          {
            text: 'Download',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/da/guide/': [
            {
              text: 'Kom i gang',
              items: [
                { text: 'Hurtig start', link: '/da/guide/getting-started' },
                { text: 'Indledende opsætning', link: '/da/guide/setup' },
                { text: 'API-nøgle', link: '/da/guide/api-key' },
              ],
            },
            {
              text: 'Brug',
              items: [
                { text: 'Skift ikoner', link: '/da/guide/changing-icons' },
                { text: 'App-aliasser', link: '/da/guide/aliases' },
                { text: 'Baggrundstjeneste', link: '/da/guide/background-service' },
                { text: 'Import og eksport', link: '/da/guide/import-export' },
              ],
            },
          ],
          '/da/cli/': [
            {
              text: 'Kommandolinjeværktøj',
              items: [
                { text: 'Installation', link: '/da/cli/' },
                { text: 'Kommandoreference', link: '/da/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    fi: {
      label: 'Suomi',
      lang: 'fi',
      themeConfig: {
        nav: [
          { text: 'Opas', link: '/fi/guide/getting-started' },
          { text: 'CLI', link: '/fi/cli/' },
          {
            text: 'Lataa',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/fi/guide/': [
            {
              text: 'Aloitus',
              items: [
                { text: 'Pikaopas', link: '/fi/guide/getting-started' },
                { text: 'Alkumääritys', link: '/fi/guide/setup' },
                { text: 'API-avain', link: '/fi/guide/api-key' },
              ],
            },
            {
              text: 'Käyttö',
              items: [
                { text: 'Kuvakkeiden vaihtaminen', link: '/fi/guide/changing-icons' },
                { text: 'Sovellusten aliakset', link: '/fi/guide/aliases' },
                { text: 'Taustapalvelu', link: '/fi/guide/background-service' },
                { text: 'Tuonti ja vienti', link: '/fi/guide/import-export' },
              ],
            },
          ],
          '/fi/cli/': [
            {
              text: 'Komentorivityökalu',
              items: [
                { text: 'Asennus', link: '/fi/cli/' },
                { text: 'Komentojen viite', link: '/fi/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    it: {
      label: 'Italiano',
      lang: 'it',
      themeConfig: {
        nav: [
          { text: 'Guida', link: '/it/guide/getting-started' },
          { text: 'CLI', link: '/it/cli/' },
          {
            text: 'Scarica',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/it/guide/': [
            {
              text: 'Primi passi',
              items: [
                { text: 'Guida rapida', link: '/it/guide/getting-started' },
                { text: 'Configurazione iniziale', link: '/it/guide/setup' },
                { text: 'Chiave API', link: '/it/guide/api-key' },
              ],
            },
            {
              text: 'Utilizzo',
              items: [
                { text: 'Cambiare le icone', link: '/it/guide/changing-icons' },
                { text: 'Alias delle app', link: '/it/guide/aliases' },
                { text: 'Servizio in background', link: '/it/guide/background-service' },
                { text: 'Importazione ed esportazione', link: '/it/guide/import-export' },
              ],
            },
          ],
          '/it/cli/': [
            {
              text: 'Strumento da riga di comando',
              items: [
                { text: 'Installazione', link: '/it/cli/' },
                { text: 'Riferimento dei comandi', link: '/it/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    pt: {
      label: 'Português',
      lang: 'pt',
      themeConfig: {
        nav: [
          { text: 'Guia', link: '/pt/guide/getting-started' },
          { text: 'CLI', link: '/pt/cli/' },
          {
            text: 'Baixar',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/pt/guide/': [
            {
              text: 'Primeiros passos',
              items: [
                { text: 'Início rápido', link: '/pt/guide/getting-started' },
                { text: 'Configuração inicial', link: '/pt/guide/setup' },
                { text: 'Chave de API', link: '/pt/guide/api-key' },
              ],
            },
            {
              text: 'Uso',
              items: [
                { text: 'Alterar ícones', link: '/pt/guide/changing-icons' },
                { text: 'Aliases de apps', link: '/pt/guide/aliases' },
                { text: 'Serviço em segundo plano', link: '/pt/guide/background-service' },
                { text: 'Importar e exportar', link: '/pt/guide/import-export' },
              ],
            },
          ],
          '/pt/cli/': [
            {
              text: 'Ferramenta de linha de comando',
              items: [
                { text: 'Instalação', link: '/pt/cli/' },
                { text: 'Referência de comandos', link: '/pt/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    ru: {
      label: 'Русский',
      lang: 'ru',
      themeConfig: {
        nav: [
          { text: 'Руководство', link: '/ru/guide/getting-started' },
          { text: 'CLI', link: '/ru/cli/' },
          {
            text: 'Скачать',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/ru/guide/': [
            {
              text: 'Начало работы',
              items: [
                { text: 'Быстрый старт', link: '/ru/guide/getting-started' },
                { text: 'Первоначальная настройка', link: '/ru/guide/setup' },
                { text: 'API-ключ', link: '/ru/guide/api-key' },
              ],
            },
            {
              text: 'Использование',
              items: [
                { text: 'Изменение иконок', link: '/ru/guide/changing-icons' },
                { text: 'Псевдонимы приложений', link: '/ru/guide/aliases' },
                { text: 'Фоновый сервис', link: '/ru/guide/background-service' },
                { text: 'Импорт и экспорт', link: '/ru/guide/import-export' },
              ],
            },
          ],
          '/ru/cli/': [
            {
              text: 'Командная строка',
              items: [
                { text: 'Установка', link: '/ru/cli/' },
                { text: 'Справочник команд', link: '/ru/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    ar: {
      label: 'العربية',
      lang: 'ar',
      themeConfig: {
        nav: [
          { text: 'الدليل', link: '/ar/guide/getting-started' },
          { text: 'CLI', link: '/ar/cli/' },
          {
            text: 'تحميل',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/ar/guide/': [
            {
              text: 'البداية',
              items: [
                { text: 'البدء السريع', link: '/ar/guide/getting-started' },
                { text: 'الإعداد الأولي', link: '/ar/guide/setup' },
                { text: 'مفتاح API', link: '/ar/guide/api-key' },
              ],
            },
            {
              text: 'الاستخدام',
              items: [
                { text: 'تغيير الأيقونات', link: '/ar/guide/changing-icons' },
                { text: 'أسماء بديلة للتطبيقات', link: '/ar/guide/aliases' },
                { text: 'الخدمة الخلفية', link: '/ar/guide/background-service' },
                { text: 'الاستيراد والتصدير', link: '/ar/guide/import-export' },
              ],
            },
          ],
          '/ar/cli/': [
            {
              text: 'أداة سطر الأوامر',
              items: [
                { text: 'التثبيت', link: '/ar/cli/' },
                { text: 'مرجع الأوامر', link: '/ar/cli/commands' },
              ],
            },
          ],
        },
      },
    },
    'zh-Hant': {
      label: '繁體中文',
      lang: 'zh-Hant',
      themeConfig: {
        nav: [
          { text: '指南', link: '/zh-Hant/guide/getting-started' },
          { text: 'CLI', link: '/zh-Hant/cli/' },
          {
            text: '下載',
            link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
          },
        ],
        sidebar: {
          '/zh-Hant/guide/': [
            {
              text: '入門',
              items: [
                { text: '快速開始', link: '/zh-Hant/guide/getting-started' },
                { text: '權限設定', link: '/zh-Hant/guide/setup' },
                { text: 'API 金鑰', link: '/zh-Hant/guide/api-key' },
              ],
            },
            {
              text: '使用',
              items: [
                { text: '變更圖示', link: '/zh-Hant/guide/changing-icons' },
                { text: '應用程式別名', link: '/zh-Hant/guide/aliases' },
                { text: '背景服務', link: '/zh-Hant/guide/background-service' },
                { text: '匯入與匯出', link: '/zh-Hant/guide/import-export' },
              ],
            },
          ],
          '/zh-Hant/cli/': [
            {
              text: '命令列工具',
              items: [
                { text: '安裝', link: '/zh-Hant/cli/' },
                { text: '命令參考', link: '/zh-Hant/cli/commands' },
              ],
            },
          ],
        },
      },
    },
  },

  themeConfig: {
    logo: '/images/icon.png',

    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'CLI', link: '/cli/' },
      {
        text: 'Download',
        link: 'https://github.com/Bengerthelorf/macIconChanger/releases/latest',
      },
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Quick Start', link: '/guide/getting-started' },
            { text: 'Initial Setup', link: '/guide/setup' },
            { text: 'API Key', link: '/guide/api-key' },
          ],
        },
        {
          text: 'Usage',
          items: [
            { text: 'Changing Icons', link: '/guide/changing-icons' },
            { text: 'App Aliases', link: '/guide/aliases' },
            { text: 'Background Service', link: '/guide/background-service' },
            { text: 'Import & Export', link: '/guide/import-export' },
          ],
        },
      ],
      '/cli/': [
        {
          text: 'Command Line Tool',
          items: [
            { text: 'Installation', link: '/cli/' },
            { text: 'Command Reference', link: '/cli/commands' },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/Bengerthelorf/macIconChanger' },
    ],

    editLink: {
      pattern: 'https://github.com/Bengerthelorf/macIconChanger/edit/main/docs/:path',
    },

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2022-present Bengerthelorf',
    },

    search: {
      provider: 'local',
    },
  },
})
