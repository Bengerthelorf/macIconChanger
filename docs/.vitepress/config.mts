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
