import Rails from '@rails/ujs'

import * as ActiveStorage from '@rails/activestorage'
Rails.start()
ActiveStorage.start()

// TODO: only load this on edit items page
window.addEventListener('DOMContentLoaded', () => {
  const status = document.getElementById('status')
  if (!status) {
    console.log('#status not found')
    return
  }

  const claimedBy = document.getElementById('claimed_by')
  if (!claimedBy) {
    console.log('#claimed_by not found')
    return
  }

  const claimedByLabel = document.getElementById('claimed_by_label')
  if (!claimedByLabel) {
    console.log('#claimed_by_label not found')
    return
  }

  status.addEventListener('change', () => {
    const statusVal = status.value
    // TODO: replace magic number with enum
    if (statusVal === '3') {
      claimedBy.setAttribute('required', true)
      claimedBy.style.display = 'inline-block'
      claimedByLabel.style.display = 'inline-block'
    } else {
      claimedBy.setAttribute('required', false)
      claimedBy.style.display = 'none'
      claimedByLabel.style.display = 'none'
    }
  })
})

export function toggleFunction () {
  document.getElementById('navbar-dropdown').classList.toggle('collapse')
}
