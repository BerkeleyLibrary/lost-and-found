import Rails from '@rails/ujs'

import * as ActiveStorage from '@rails/activestorage'

Rails.start()
ActiveStorage.start()

// TODO: only load this on edit items page
window.addEventListener('DOMContentLoaded', () => {
  const claimed = document.getElementById('claimed')
  if (!claimed) {
    return
  }

  const claimedBy = document.getElementById('claimed_by')
  if (!claimedBy) {
    return
  }

  const claimedByLabel = document.getElementById('claimed_by_label')
  if (!claimedByLabel) {
    return
  }

  claimed.addEventListener('change', () => {
    if (claimed.checked) {
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
