function preferedColorScheme() {
  return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark': 'light'
}

function run() {
  document.querySelector('html').classList.add(preferedColorScheme())
}

run()
