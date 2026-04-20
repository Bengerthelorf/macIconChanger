export default {
  slug: 'iconchanger',
  install: {
    macos:  { name: 'macOS', cmd: 'brew install Bengerthelorf/tap/iconchanger', note: 'homebrew; universal binary — arm64 + x86_64' },
    dmg:    { name: 'DMG',   cmd: 'open https://github.com/Bengerthelorf/macIconChanger/releases/latest', note: 'download, drag to /Applications, launch' },
  },
  sections: [
    {
      label: 'guide',
      items: [
        'getting-started',
        'setup',
        'changing-icons',
        'aliases',
        'display-settings',
        'background-service',
        'api-key',
        'import-export',
      ],
    },
    { label: 'cli', items: ['cli/index', 'cli/commands'] },
  ],
  linkRewrites: {
    '/guide/': '/docs/',
    '/cli/':   '/docs/cli/',
  },
};
