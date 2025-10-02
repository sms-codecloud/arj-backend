# Hello World AWS Lambda Project

This project is a simple AWS Lambda function written in C#.NET Core that returns a greeting message. It is designed to be deployed using Terraform and managed through a Jenkins pipeline.

## Project Structure

- **src/hello_world**: Contains the source code for the Lambda function.
  - **Function.cs**: Implements the Lambda function handler.
  - **hello_world.csproj**: Project file for the hello_world Lambda function.
  - **aws-lambda-tools-defaults.json**: Default settings for deploying the Lambda function.

- **test/hello_world.Tests**: Contains unit tests for the Lambda function.
  - **FunctionTest.cs**: Unit tests for the `Function` class.
  - **hello_world.Tests.csproj**: Project file for the hello_world unit tests.

- **terraform**: Contains Terraform configuration files for deploying the Lambda function.
  - **main.tf**: Defines the Lambda function resource and its properties.
  - **variables.tf**: Input variables for the Terraform configuration.
  - **outputs.tf**: Outputs of the Terraform configuration.

- **scripts**: Contains shell scripts for building and deploying the Lambda function.
  - **build_and_zip.sh**: Builds the .NET project and creates a zip file of the output.
  - **deploy_with_terraform.sh**: Deploys the Lambda function using Terraform.

- **Jenkinsfile**: Defines the Jenkins pipeline for CI/CD.

- **hello_world.sln**: Solution file that includes the hello_world project and its associated test project.

- **.gitignore**: Specifies files and directories to be ignored by Git.

## Setup Instructions

1. **Clone the Repository**: 
   Clone this repository to your local machine.

2. **Install .NET Core**: 
   Ensure that .NET Core SDK is installed on your machine.

3. **Build the Project**: 
   Navigate to the `src/hello_world` directory and run the following command:
   ```
   dotnet build
   ```

4. **Run Tests**: 
   Navigate to the `test/hello_world.Tests` directory and run the following command:
   ```
   dotnet test
   ```

5. **Deploy to AWS Lambda**: 
   Use the provided Jenkins pipeline to automate the build and deployment process.

## Usage

To invoke the Lambda function, you can use the AWS Management Console or AWS CLI. The function takes a string input and returns a greeting message.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.