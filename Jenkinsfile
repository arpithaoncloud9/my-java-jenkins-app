pipeline {
   agent any
   // tools {
   //       maven 'Maven 3.9.11'
   // }
   stages {
     stage('Build') { // This is the name of the stage
       steps { // Define all the steps for the stage within this block
          echo 'Starting Maven build: mvn clean install' // Prints this message
          sh 'mvn clean install' // Runs mvn clean install
          echo 'Maven build completed successfully' // Prints this message
         }
     }
     stage('Test') {
       steps {
         sh 'mvn test'
       }
     }
      stage ('Completion') {
         steps {
         echo 'Build completed successfully' 
       }
     }
     
     stage('Docker Build & Push') {
         steps {
          echo 'Building and pushing Docker image'
            sh 'docker build -t myrepo/myapp:latest .'
            sh 'docker push myrepo/myapp:latest'
         }
      }

   }
}
