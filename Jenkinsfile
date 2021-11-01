dockerComposePipeline(
  stack: [template: 'postgres-selenium'],
  commands: [
    [
        [exec: 'rake check RAILS_ENV=test'],
        // TODO: Figure out why yarn doesn't install ESLint in CI
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
      // 'ESLint'       : 'artifacts/eslint',
      'RuboCop'      : 'artifacts/rubocop',
      'Brakeman'     : 'artifacts/brakeman'
    ],
    raw     : 'artifacts/screenshots/**/*.png'
  ]
)
