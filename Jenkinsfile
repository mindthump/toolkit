final String gandalfQuote = 'Do not meddle in the affairs of Wizards...'

pipeline {
  agent {
    kubernetes {
      label "${UUID.randomUUID().toString()}"
    }
  }

  options {
    timeout(time: 60, unit: 'MINUTES')
    skipDefaultCheckout()
  }

  environment {
    SOME_ENVVAR = 'This must be in the environment for some reason.'
  }

  stages {
    stage('Test variable usages') {
      steps {
        echo(gandalfQuote)
        script {
          // This is a *shadow*
          gandalfQuote = '...for it makes them sticky and hard to chew ...'
          echo(gandalfQuote)
          // Treated strictly as an environment variable this is immutable, but without warning/error
          echo(SOME_ENVVAR)
          echo(env.SOME_ENVVAR)
          SOME_ENVVAR = 'This a shadow.'
          env.SOME_ENVVAR = 'This has no effect on the value.'
          echo("Interpolated bare 'SOME_ENVVAR': ${SOME_ENVVAR}")
          echo("Interpolated 'SOME_ENVVAR' with env. prefix: ${env.SOME_ENVVAR}")
          echo('SOME_ENVVAR in a shell environment:')
          sh('''\
            #!/bin/bash -eu
            echo "\$SOME_ENVVAR"
            '''.stripIndent())
        }
      }
    }
  }
}

// It changed...
gandalfQuote = 'Can\'t touch this.'

echo(gandalfQuote)
