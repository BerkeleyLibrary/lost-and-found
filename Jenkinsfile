dockerComposePipeline(
  stack: [template: 'postgres-selenium'],
  commands: [
    [
        [exec: 'rake check RAILS_ENV=test'],
        // TODO: get ESLint working & update JS code style
        // 'rake js:eslint NODE_ENV=development',
        'rake rubocop',
        'rake brakeman',
        'rake bundle:audit'
    ],
  ],
  artifacts: [
    junit   : 'artifacts/rspec/**/*.xml',
    html    : [
      'Code Coverage': 'artifacts/rcov',
      'RuboCop'      : 'artifacts/rubocop',
      'Brakeman'     : 'artifacts/brakeman',
        // TODO: get ESLint working & update JS code style
        // 'ESLint'       : 'artifacts/eslint'
    ],
    raw     : 'artifacts/screenshots/**/*.png'
  ]
)
