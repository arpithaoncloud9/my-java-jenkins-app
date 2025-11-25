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
        echo 'Starting Docker login and image push'

        withCredentials([usernamePassword(credentialsId: 'docker-token',
                                         usernameVariable: 'DOCKER_USER',
                                         passwordVariable: 'DOCKER_PASS')]) {
            sh '''
            mkdir -p $HOME/.docker
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            '''
        }

        sh 'docker build -t arpithaoncloud9/my-java-new-app:latest .'
        sh 'docker push arpithaoncloud9/my-java-new-app:latest'

        echo 'Docker image pushed successfully'
    }
}

   }
}
