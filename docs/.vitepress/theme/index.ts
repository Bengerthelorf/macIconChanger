import DefaultTheme from 'vitepress/theme'
import HomeBrewInstall from './HomeBrewInstall.vue'
import { h } from 'vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'home-hero-actions-after': () => h(HomeBrewInstall)
    })
  }
}
