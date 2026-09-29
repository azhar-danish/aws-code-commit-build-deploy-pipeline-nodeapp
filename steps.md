AWS CodeCommit

1. Create an IAM user  with name like aws-code-commit
2. Give Permission : 
	AWSCodeCommitFullAccess
	AWSCodeCommitPowerUser

3. Goto Security Credential
	HTTPS Git credentials for AWS CodeCommit (1) : create credential username and save password
	
4. Goto CodeCommit
5. Create a new repository
	Demo-repository
6. Git clone the above repository in your local machine
	git clone https://git-codecommit.ap-south-1.amazonaws.com/v1/repos/demo-repository
	Ask for user name and password: Put the username and password which has been save earlier in step 3
7. Create new file in your local machine
8. Do the basic git operation for pushing the code
	git add .
	git commit -m “first change”
	git push origin main
9. Code is pushed to the repository on main branch

10 create a branch
	Git checkout -b dev
 	Do change in the branch
Git add .
Git commit  -m “update change”
Git push origin dev

11. Merge dev branch with main via create pull request
12. After branch merging 



AWS CodeBuild

Create projects
Source > Aws Code Commit
Repository > demo-repository
Branch > Master
Operating system > Amazon Linux / Ubuntu
Runtime > Standard
Role Name : codebuild-demo-repository-service-role


{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:ap-south-1:024901689513:log-group:/aws/codebuild/<code-build-repository>",
                "arn:aws:logs:ap-south-1:024901689513:log-group:/aws/codebuild/<code-build-repository>:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
               "arn:aws:s3:::codepipeline-ap-south-1-<s3-bucket-nam>*",
	  "arn:aws:s3:::codepipeline-ap-south-1-<s3-bucket-nam>*/*"

            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:codecommit:ap-south-1:024901689513:<code-commit-repository>"
            ],
            "Action": [
                "codecommit:GitPull"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::<s3-bucket-name>",
                "arn:aws:s3:::<s3-bucket-name>/*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:ap-south-1:024901689513:report-group/<code-build-repository>-*"
            ]
        }
    ]
}
 

Buildspec > use a buildspec file
Buildspec name - optional > buildspec.yml
To be saved in code repository at root level with name buildspec.yml


version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 24
    commands:
      - echo "Installing system dependencies..."
      - # Update npm to the latest stable version if needed
      - npm install -g npm@latest
  
  pre_build:
    commands:
      - echo "Installing development and production application dependencies..."
      - npm ci
      - echo "Creating deployment environment configuration..."
      - # SECURE PRACTICE: Fetch production secrets dynamically from SSM Parameter Store at runtime
      - # aws ssm get-parameter --name "/demo-app/prod/database-url" --with-decryption --query "Parameter.Value" --output text > .env.tmp
      - # echo "DATABASE_URL=$(cat .env.tmp)" > .env
      - echo "NODE_ENV=development" >> .env
      - echo "PORT=3000" >> .env
      - # rm .env.tmp

  build:
    commands:
      - echo "Building application..."
      - # If you are using TypeScript, Next.js, or a bundler, uncomment the line below:
      - # npm run build
      - echo "Running automated test suites..."
      - # Uncomment the line below to ensure bad code breaks the build before deploying:
      - # npm test

  post_build:
    commands:
      - echo "Pruning development dependencies to optimize production artifact size..."
      - # Removes devDependencies so your deployment package stays small and fast
      - # npm prune --development
      - echo "Build process completed successfully on $(date)"

artifacts:
  files:
    - '**/*'
  exclude-paths:
    - 'node_modules/**/*'

cache:
  paths:
    - 'node_modules/**/*'




Artifacts
Artifact 1 - Primary
Type > Amazon S3
Bucket name > code-commit-artifacts-nginx
Name : artifact.zip
Path : 
Artifact Packing : .zip


Click on submit button
Select the project > click on Start Build button
Inside the phase detail we can check all running task
Now in s3 bucket (code_commit_bucket) an artifact.zip has been generated

AWS Code Deploy

Create Application
	Application name : demo-application
	Compute platform: EC2
Create Deployment Group 
Deployment Group Name : demo-app-demployment-grp
Servicerole 
Create a role with below permission 
	Role name :   code-deploy-service-role
AmazonEC2FullAccess
AmazonEC2RoleforAWSCodeDeploy
AmazonEC2RoleforAWSCodeDeployLimited
AmazonS3FullAccess
AWSCodeDeployFullAccess
AWSCodeDeployRole	
Also click on Trust Policy


{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "codedeploy.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}




		Copy ARN no : arn:aws:iam::024901689513:role/code-deploy-service-role

Deployment type : in-place
Environment configuration : Amazon EC2 instances

Launch an EC2 instance : demo-app
Tag group 1
Key : Name , value : demo-app
Install AWS CodeDeploy Agent : Never
Load Balancer : unselect
Click on Create Deployment Group
Create an agent file in EC2 instance
agent.sh  => run as => sh agent.sh
#!/bin/bash
# This installs the CodeDeploy agent and its prerequisites on Ubuntu 22.04.
sudo apt-get update
sudo apt-get install ruby-full ruby-webrick wget -y
cd /tmp
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/releases/codedeploy-agent_1.3.2-1902_all.deb
mkdir codedeploy-agent_1.3.2-1902_ubuntu22
dpkg-deb -R codedeploy-agent_1.3.2-1902_all.deb codedeploy-agent_1.3.2-1902_ubuntu22
sed -i 's/Depends:ruby.*//' codedeploy-agent_1.3.2-1902_ubuntu22/DEBIAN/control
dpkg-deb -b codedeploy-agent_1.3.2-1902_ubuntu22/
sudo dpkg -i codedeploy-agent_1.3.2-1902_ubuntu22.deb
systemctl list-units --type=service | grep codedeploy
sudo service codedeploy-agent status




sudo systemctl status codedeploy-agent


And run 
sh agent.sh
	

Create another file updated_agent.sh
---------
sudo dpkg --purge codedeploy-agent


sudo apt update
sudo apt install -y wget


cd /tmp


wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latestv2/install


chmod +x install


sudo ./install auto


sudo /opt/codedeploy-agent/bin/codedeploy-agent --version


And then run as => sh updated-agent.sh

10.1  sudo systemctl status codedeploy-agent => to check codedeploy-agent

11.	Create a new file appspec.yml at root directory
	
version: 0.0
os: linux

files:
  - source: /
    destination: /var/www/demo-app-dev
    overwrite: true

hooks:
  BeforeInstall:
    - location: scripts/install_dependencies.sh
      timeout: 300
      runas: root

  AfterInstall:
    - location: scripts/configure_and_start.sh
      timeout: 300
      runas: root

  ValidateService:
    - location: scripts/validate_service.sh
      timeout: 180
      runas: root

 



12 . Create a new folder with name as script at root directory
	
Create a new file named as install_nginx.sh

#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx




Create a new file named as start_nginx.sh

#!/bin/bash
sudo systemctl start nginx




	and  then commit the changes

	git add .
	Git commit -m “add appsec.yml”
	git  push origin dev

13) Go to AWS Code Build and rebuild the project
14) click on start build
15) check the phase detail inside  the build project


Go to Code Deploy
1) Create the Deployment
2)Deployment settings
Application
Demo-application : demo-app-deployment-group
Revision type : My application is stored in Amazon S3
Revision location : s3://code-commit-artifacts-nginx/artifact.zip/
Revision filetype : .zip
3) click on create deployment button

Create a Role
1) Role name : ec2-code-deploy
	a)Attach Policy
		AmazonEC2FullAccess
		AmazonS3FullAccess
		AWSCodeDeployFullAccess
2) Goto EC2 instance : demo-app
	Action > Security > Modify IAM Role
3) Select the ec2-code-deploy and Update IAM Role

4) Go to EC2 instance and run
Sudo service codedeploy-agent restart	
sudo service codedeploy-agent status



AWS CodePipeline
1.	Create Pipeline
2.	Category : Build custom pipeline
3.	Pipeline name : demo-app-pipeline
4.	Execution mode : Queued
5.	Service role : New service role
6.	Role name : AWSCodePipelineServiceRole-ap-south-1-demo-app-pipeline
7.	Source 
	1.	Source provider : AWS Code Commit
	2. 	Repository name : demo-repository
	3.	Branch name : master
	4.	Create EventBridge rule to automatically detect source changes : true
	5.	Output artifact format : CodePipeline default
8.	Build provider : Other build providers - AWS Code Build 
1.	Project name : demo-app-build
2.	Build type : Single Build
3.	Service role override - optional : arn:aws:iam::024901689513:role/service-role/codebuild-demo-app-build-service-role




8.1      Navigate to AWSCodePipelineServiceRole-ap-south-1-demo-app-pipeline
	
Choose the Permissions tab, and then choose Add permissions.
Choose the Create inline policy option.
Navigate to the JSON tab in the policy editor.
Copy and paste the following policy document into the policy editor. This policy document is a starting point, and you might want to add more permissions. Edit the "Action" and "Resource" fields to match the specific actions and resources required for your use case:


Format 

Role : AWSCodePipelineServiceRole-ap-south-1-demo-app-pipeline
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Sid": "AllowCodeBuildManagement",
           "Effect": "Allow",
           "Action": [
               "codebuild:StartBuild",
               "codebuild:BatchGetBuilds"
           ],
           "Resource": [
               "arn:aws:codebuild:us-east-1:024901689513:project/<YOUR_CODEBUILD_PROJECT_NAME>"
           ]
       },
       {
           "Sid": "AllowPassRoleToCodeBuild",
           "Effect": "Allow",
           "Action": [
               "iam:PassRole"
           ],
           "Resource": [
               "arn:aws:iam::024901689513:role/service-role/<YOUR_CODEBUILD_SERVICE_ROLE_NAME>"
           ]
       },
       {
           "Sid": "AllowCodeDeployDeployment",
           "Effect": "Allow",
           "Action": [
               "codedeploy:CreateDeployment",
               "codedeploy:GetDeployment"
           ],
           "Resource": [
               "arn:aws:codedeploy:us-east-1:024901689513:deploymentgroup:<YOUR_CODEDEPLOY_APPLICATION_NAME>/<YOUR_CODEDEPLOY_DEPLOYMENT_GROUP_NAME>"
           ]
       },
       {
           "Sid": "AllowCodeDeployApplicationActions",
           "Effect": "Allow",
           "Action": [
               "codedeploy:RegisterApplicationRevision",
               "codedeploy:GetApplicationRevision"
           ],
           "Resource": [
               "arn:aws:codedeploy:us-east-1:024901689513:application:<YOUR_CODEDEPLOY_APPLICATION_NAME"
           ]
       }
   ]
}












example:

{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "AllowCodeBuildManagement",
			"Effect": "Allow",
			"Action": [
				"codebuild:StartBuild",
				"codebuild:BatchGetBuilds"
			],
			"Resource": [
				"arn:aws:codebuild:ap-south-1:024901689513:project/demo-repository"
			]
		},
		{
			"Sid": "AllowPassRoleToCodeBuild",
			"Effect": "Allow",
			"Action": [
				"iam:PassRole"
			],
			"Resource": [
				"arn:aws:iam::024901689513:role/service-role/codebuild-demo-app-build-service-role"
			]
		},
		{
			"Sid": "AllowCodeDeployDeployment",
			"Effect": "Allow",
			"Action": [
				"codedeploy:CreateDeployment",
				"codedeploy:GetDeployment"
			],
			"Resource": [
				"arn:aws:codedeploy:ap-south-1:024901689513:deploymentgroup:demo-application/demo-app-demployment-grp"
			]
		},
		{
			"Sid": "AllowCodeDeployApplicationActions",
			"Effect": "Allow",
			"Action": [
				"codedeploy:RegisterApplicationRevision",
				"codedeploy:GetApplicationRevision"
			],
			"Resource": [
				"arn:aws:codedeploy:ap-south-1:024901689513:application:demo-application"
			]
		}
	]
}

Review the updated policy for correctness, and then choose Next.





9. 	Add deploy stage
	1.	Deploy provider: AWS Code Deploy
2.	Application name : Demo-application
3.	Deployment group:demo-app-deployment-group		



	
10. Role to modify :codebuild-demo-app-build-service-role

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCodeBuildCloudWatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-south-1:024901689513:log-group:/aws/codebuild/demo-repository",
                "arn:aws:logs:ap-south-1:024901689513:log-group:/aws/codebuild/demo-repository:*"
            ]
        }
    ]
}






Open the AWS Console and navigate to IAM > Roles.
Search for and click on codebuild-demo-app-build-service-role.
Under the Permissions
 tab, click Add permissions > Create inline policy.
Switch to the JSON tab, paste the policy block above, and click Next.
Name the policy (e.g., CodeBuildCloudWatchLogsPolicy) and click Create policy.





