pipeline {
   agent any
   // tools {
   //       maven 'Maven 3.9.11'
   // }
   stages {
     stage('Nel') {
       steps {
          echo 'Starting Maven build: mvn clean install'
          sh 'mvn clean install'
          echo 'Maven build completed successfully'
         }
     }
     stage('Arp') {
       steps {
         sh 'mvn test'
       }
     }
     // stage('Deploy') {
     //   steps {
     //    sh 'docker build -t myapp .'
     //     sh 'docker push myrepo/myapp'
     //   }
     // }
   }
}
