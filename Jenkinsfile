pipeline {
    options {
        // Required to clean before build
        skipDefaultCheckout(true)
        disableConcurrentBuilds abortPrevious: true
        office365ConnectorWebhooks([[
            name: 'AltaWeb - DevOps',
            notifyBuildStart: true,
            notifyAborted: true,
            notifyFailure: true,
            notifyNotBuilt: true,
            notifySuccess: true, 
            notifyUnstable: true,
            notifyRepeatedFailure: true,
            url: 'https://accusys.webhook.office.com/webhookb2/57ea2667-0ef3-49b0-bc68-018da201be7a@66a033ea-d9e9-457f-9467-66b9ab9ff084/JenkinsCI/3f1e19dd23184229a10fb78e54da1409/df5061bf-b813-43b4-a2aa-054b6e48ef60'
            ]])
        durabilityHint('MAX_SURVIVABILITY')
    }
    parameters {
        string name: 'sourceBranch'
        string name: 'targetBranch'
        string name: 'pullRequestId'
        string name: 'projectId'
        string name: 'repositoryId'
        string name: 'repositoryUrl'
        string name: 'repository'
        string name: 'status'
        string name: 'lastMergeCommitId'
        string name: 'lastMergeComment'
        string name: 'authorName'
        string name: 'authorEmail'
        string name: 'authorDate'
    }
    agent {
        kubernetes {
            yaml '''
            kind: Pod
            metadata:
              namespace: jenkins
              name: kaniko
            spec:
              containers:
              - name: develop
                image: gcr.io/kaniko-project/executor:debug
                imagePullPolicy: IfNotPresent
                command:
                - sleep
                args:
                - 99d
                volumeMounts:
                  - name: credentials-helper
                    mountPath: /kaniko/.docker
                  - name: maven-cache
                    mountPath: /root/.m2
              - name: aws-cli
                image: amazon/aws-cli:latest
                imagePullPolicy: IfNotPresent
                command:
                - sleep
                args:
                - 99d
              volumes:
              - name: credentials-helper
                configMap:
                  name: credentials-helper
              - name: maven-cache
                persistentVolumeClaim:
                  claimName: maven-cache
            '''
        }		  
    }
    triggers {
        GenericTrigger(
            genericVariables: [
                [key: 'sourceBranch', value: '$.resource.sourceRefName', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'targetBranch', value: '$.resource.targetRefName', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'pullRequestId', value: '$.resource.pullRequestId', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'projectId', value: '$.resource.repository.project.id', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'repositoryId', value: '$.resource.repository.id', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'repositoryUrl', value: '$.resource.repository.url', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'repository', value: '$.resource.repository.sshUrl', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'status', value: '$.resource.status', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'lastMergeCommitId', value: '$.resource.lastMergeCommit.commitId', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'lastMergeComment', value: '$.resource.lastMergeCommit.comment', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'authorName', value: '$.resource.lastMergeCommit.author.name', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'authorEmail', value: '$.resource.lastMergeCommit.author.email', expressionType: 'JSONPath', defaultValue: 'null'],
                [key: 'authorDate', value: '$.resource.lastMergeCommit.author.date', expressionType: 'JSONPath', defaultValue: 'null']
            ],
            causeString: 'Triggered by a Generic Webhook on $targetBranch',
            regexpFilterExpression: '',
            regexpFilterText: '',
            printContributedVariables: true,
            printPostContent: true,
            token: 'alta-web-app-current'
        )
    }
    environment {
        ECR_REGISTRY_URL = '038894392435.dkr.ecr.us-east-1.amazonaws.com/altaweb2-app-current'
        DH_REGISTRY_URL = 'accusystechnology/altaweb2-app-current'
        REGION = 'us-east-1'
        DOMAIN = 'accusys-artifacts'
        DOMAIN_OWNER = '038894392435'
        DEVELOP_BRANCH = 'current-develop'
        GIT_CREDENTIALS_ID = 'DevOps'
        AWS_CREDENTIALS_ID = 'ECR'
        PORTAINER_WEBHOOK = ''
    }
    stages {
        stage('Clone Repository') {
            steps {
                script {
                    if(status != 'completed'){
                        currentBuild.result = 'ABORTED'
                        error('Not a valid status for a Pull Request')
                    }
                }
                // Clean before build
                cleanWs()
                git url: 'http://tfs2018.accusysargbsas.local:8080/tfs/Productos%20y%20Arquitectura/Accusys_Facebank_2.0/_git/alta-web-app', branch: 'current-develop', credentialsId: 'DevOps'
                echo "${currentBuild.displayName}"
            }
        }
        stage('Checkout') {
            steps {
                sh "git checkout $lastMergeCommitId"
            }
        }
        /*
        stage('Restore files') {
            steps {
                sh 'git checkout origin/feature-docker -- settings.xml Dockerfile src/main/resources/application-docker.properties'
            }
        }
        */
        stage('Config files') {
            steps {
                configFileProvider(
                    [
                        configFile(
                            fileId: '138f4690-df41-413b-9068-9118376a2e30', 
                            variable: 'NPMRC'
                        )
                    ]
                ) {
                    sh 'cat \"$NPMRC\" > ./.npmrc'
                    sh 'ls -la'
                }
            }
        }
        stage('Build with Kaniko') {
            steps {
                script {
                    branch = targetBranch.replaceAll("refs/heads/","")
                    commitId = lastMergeCommitId.substring(0, 8)
                    json = readJSON file: 'package.json'
                    version = "${json.version}-${commitId}"
                    mergeComment = lastMergeComment.substring(0, lastMergeComment.indexOf(":"))
                }
                container(name: 'aws-cli') {
                    withCredentials(
                        [
                            usernamePassword(
                                credentialsId: "$AWS_CREDENTIALS_ID", 
                                usernameVariable: 'AWS_ACCESS_KEY_ID', 
                                passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                            )
                        ]
                    ) {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        '''
                        script {
                            env.CODEARTIFACT_AUTH_TOKEN = sh(
                                script: 'aws codeartifact get-authorization-token \
                                --region $REGION \
                                --domain $DOMAIN \
                                --domain-owner $DOMAIN_OWNER \
                                --query authorizationToken \
                                --output text', 
                                returnStdout: true).trim()
                        }
                    }
                }
                container(name: 'develop', shell: '/busybox/sh') {
                    withCredentials(
                        [
                            usernamePassword(
                                credentialsId: 'ECR', 
                                usernameVariable: 'AWS_ACCESS_KEY_ID', 
                                passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                            )
                        ]
                    ) {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        '''
                        sh """
                        #!/busybox/sh
                        /kaniko/executor -f "`pwd`/Dockerfile.dev" \
                        -c "`pwd`" \
                        --cache=true \
                        --build-arg "CODEARTIFACT_AUTH_TOKEN=$CODEARTIFACT_AUTH_TOKEN" \
                        --destination="$DH_REGISTRY_URL":"$version" \
                        --destination="$ECR_REGISTRY_URL":"$version" \
                        --label version="$version" \
                        --label branch="$branch" \
                        --label commit="$lastMergeCommitId" \
                        --label author="$authorName" \
                        --label email="$authorEmail" \
                        --label date="$authorDate" \
                        --label comment="$mergeComment"
                        """
                    }
                }
            }
        }
    }
    /*post {
        success {
            script {
                response = httpRequest httpMode: 'POST', url: "$PORTAINER_WEBHOOK?ESB_IMAGE_TAG=$version", validResponseCodes: "100:599"
                echo "Status: ${response.status}"
                echo "Response: ${response.content}"
            }
        }
    }*/
}