dockerComposePipeline(
  stack: [template: 'mariadb'],
  commands: ['sleep 30', 'rake'],
  artifacts: [junit: 'tmp/specs.xml',
              brakeman: 'tmp/brakeman.json'])
