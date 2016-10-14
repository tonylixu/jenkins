freeStyleJob('jenkins-dsl-test1') {
  scm {
    git {
      remote {
        url('https://github.com/tonylixu/jenkins-dsl')
      }
      branch('master')
    }
  }
  triggers {
     scm('H/15 * * * *')
  }

  steps {
    maven {
      mavenInstallation('3.1.1')
      goals('clean install')
    }
  }
}
