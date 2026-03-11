<script setup>
import { ref } from 'vue'

const command = 'brew install Bengerthelorf/tap/iconchanger'
const copied = ref(false)

function copy() {
  navigator.clipboard.writeText(command)
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}
</script>

<template>
  <div class="brew-install">
    <div class="brew-install-inner">
      <code class="brew-command">$ {{ command }}</code>
      <button class="brew-copy" :class="{ copied }" @click="copy" :aria-label="copied ? 'Copied' : 'Copy'">
        <svg v-if="!copied" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
        <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
      </button>
    </div>
  </div>
</template>

<style scoped>
.brew-install {
  display: flex;
  align-items: center;
  padding-top: 24px;
}

@media (max-width: 959px) {
  .brew-install {
    justify-content: center;
  }
}

.brew-install-inner {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 8px 12px 8px 16px;
}

.brew-command {
  font-family: var(--vp-font-family-mono);
  font-size: 14px;
  color: var(--vp-c-text-1);
}

.brew-copy {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 6px;
  background: transparent;
  color: var(--vp-c-text-2);
  cursor: pointer;
  transition: color 0.2s, background 0.2s;
}

.brew-copy:hover {
  color: var(--vp-c-text-1);
  background: var(--vp-c-bg-mute);
}

.brew-copy.copied {
  color: var(--vp-c-green-1);
}
</style>
