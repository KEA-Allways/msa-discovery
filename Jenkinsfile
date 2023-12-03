pipeline {
    agent any



    environment {
        
        
        //서버 정보
        ip = "54.87.40.18"
        username = "ubuntu"
        
        //스프링 서버 정보
        springname = "discovery"
        port = "8761"
        
        //도커 정보
        imagename = "discovery-img"
        dockerCredential = 'docker-access-token'
        dockerImage = ''
        tagname = "dev"
        
        //깃 정보
        giturl = 'https://github.com/KEA-Allways/msa-discovery.git'
        gitCredential = "github-access-token"
        branchname = "prod"
    }

    stages {
        // git에서 repository clone
        stage('Prepare') {
          steps {
            echo 'Clonning Repository'
              git url: giturl,
              branch: branchname,
              credentialsId: gitCredential
            }
            post {
             success { 
               echo 'Successfully Cloned Repository'
             }
           	 failure {
               error 'This pipeline stops here...'
             }
          }
        }

        stage('Add Gradle Plugin') {
                    steps {
                        script {
                            // Gradle 플러그인을 추가할 파일 경로 설정
                            def buildGradleFile = "/build.gradle"
                            // 추가할 플러그인 이름 설정
                            def pluginName = 'id "org.sonarqube" version "4.2.1.3168"'

                            // build.gradle 파일을 읽어옴
                            def buildGradle = readFile(buildGradleFile)

                            // 플러그인을 추가할 위치 확인
                            def insertIndex = buildGradle.indexOf("plugins {") + 10

                            // sonarqube 플러그인을 추가
                            buildGradle = buildGradle.substring(0, insertIndex) + "\n    " + pluginName + "\n" + buildGradle.substring(insertIndex)

                            // build.gradle 파일 업데이트
                            writeFile(file: buildGradleFile, text: buildGradle)
                        }
                    }
                }
                stage('Build') {
                    steps {
                        sh '''
                        ./gradlew sonar \
                          -Dsonar.projectKey=msa-discovery \
                          -Dsonar.projectName=msa-discovery \
                          -Dsonar.host.url='http://18.204.16.65:9000' \
                          -Dsonar.token=sonarqube-access-token
                        '''
                    }
                }

        // gradle build
        stage('Bulid Gradle') {
          steps {
            echo 'Bulid Gradle'
            dir ('.'){
                sh """
                ./gradlew clean build --exclude-task test
                """
            }
          }
          post {
            failure {
              error 'This pipeline stops here...'
            }
          }
        }
        
        // docker build
        stage('Bulid Docker') {
          steps {
            echo 'Bulid Docker'
            script {
                imagename = "jmk7117/${imagename}"
                dockerImage = docker.build imagename
            }
          }
          post {
            failure {
              error 'This pipeline stops here...'
            }
          }
        }

        // docker push
        stage('Push Docker') {
          steps {
            echo 'Push Docker'
            script {
                docker.withRegistry( '', dockerCredential) {
                    dockerImage.push("dev")
                }
            }
          }
          post {
            failure {
              error 'This pipeline stops here...'
            }
          }
        }
        
        stage('Run Container on Dev Server') {
          steps {
            echo 'Run Container on Dev Server'
            
            sshagent(['ec2-ssh']) {

                sh 'ssh -o StrictHostKeyChecking=no ${username}@${ip} "whoami"'

                sh "ssh -o StrictHostKeyChecking=no ${username}@${ip} 'docker ps -f name=${springname} -q | xargs --no-run-if-empty docker container stop'"
                sh "ssh -o StrictHostKeyChecking=no ${username}@${ip} 'docker container ls -a -fname=${springname} -q | xargs --no-run-if-empty docker container rm'"
                sh "ssh -o StrictHostKeyChecking=no ${username}@${ip} 'docker images -f reference=${imagename}:${tagname} -q | xargs --no-run-if-empty docker image rmi'"

                sh "ssh -o StrictHostKeyChecking=no ${username}@${ip} 'docker pull ${imagename}:${tagname}'"
                sh "ssh -o StrictHostKeyChecking=no ${username}@${ip} 'docker run -d -p 80:${port} -p 8761:${port} --name ${springname} ${imagename}:${tagname}'"
            }
          }

          post {
                  success {
                      slackSend (
                          channel: '#jenkins',
                          color: '#00FF00',
                          message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"


                      )
                  }
                  failure {
                      slackSend (
                          channel: '#jenkins',
                          color: '#FF0000',
                          message: "FAIL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
                      )
                  }
              }
          
        }
    }
}