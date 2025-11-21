pipeline {
   agent any
   stages {
     stage('Build') {
       steps {
         sh 'mvn clean install'
       }
     }
     stage('Test') {
       steps {
         sh 'mvn test'
       }
     }
     stage('Deploy') {
       steps {
         sh 'docker build -t myapp .'
         sh 'docker push myrepo/myapp'
       }
     }
   }
}