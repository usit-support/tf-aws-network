# Operação de Nuvem AWS com Pipeline Terraform 🚀

Este documento fornece instruções detalhadas para configurar e gerenciar sua infraestrutura na nuvem usando Terraform na AWS. 

## 1. Requisitos

- **AWS Account**: Crie sua conta na [Console AWS](https://console.aws.amazon.com/console/home).
- **GitHub Account**: Necessário para versionamento. [github.com](https://github.com).
- **Terraform Account**: Use sua conta do GitHub para login no [terraform.io](https://app.terraform.io).

##### Estimativa de custos: Todo o workshop no máximo 1 ou $2 doletas.
 ( no final do workshop vamos rodar um "terraform destroy")
- O maior custo vai ser o "AWS NAT Gateway" na região da Virginia https://aws.amazon.com/vpc/pricing
``` bash
Price per NAT gateway ($/hour) $0.045
```

##### 2 - Configurando a AWS . 
 - 2.1 - Precisamos criar um usuário no IAM chamado "terraform". 
 - 2.2 - Escolha a opção sem acesso ao AWS MANAGEMENT CONSOLE.
 - 2.3 - Atribua a policy "AmazonVPCFullAccess"
 https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/home

##### 3 - Configurando seu Notebook, ( brew é o instalador do MACBOOK, em Linux apt, yum, em Windows baixe os .msi )
- 3.1 - Instalando a "command line" da AWS
``` bash
brew install awscli

aws --version
aws-cli/2.15.37 Python/3.11.9 ...
```
Instalação no Windows - [AWSCLIV2.msi](https://awscli.amazonaws.com/AWSCLIV2.msi)

ver https://aws.amazon.com/cli/

- 3.2 - Criar o profile "terraform" no arquivo ~/.aws/credentials
``` bash
aws configure --profile terraform
AWS Access Key ID [None]: AKIA............CO
AWS Secret Access Key [None]: 22..............................09
Default region name [None]: us-east-1
Default output format [None]: json
```

- 3.3 - Criar as variáveis de embiente para executarmos o terraform local.
```bash
export TF_VAR_aws_access_key=AKIA............CO
export TF_VAR_aws_secret_key=22..............................09
```

- 3.4 - Testar as credenciais (itens 1, 2 e 3)
``` bash
aws ec2 describe-vpcs --profile terraform
{
    "Vpcs": [
        {
            "CidrBlock": "172.31.0.0/16",
```

##### Solução de possível ERRO.
- 3.3.1 - Verificar se existe as chaves no profile [terraform] dentro do arquivo ~/.aws/credentials
``` bash
cat ~/.aws/credentials
[terraform]
aws_access_key_id = AKIA............CO
aws_secret_access_key = 22..............................09
```

- 3.4 - Instalando o Terraform
[terraform_1.8.0_windows_amd64.zip](https://releases.hashicorp.com/terraform/1.8.0/terraform_1.8.0_windows_amd64.zip)

``` bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

terraform --version   
Terraform v1.8.0 on darwin_arm64
```
Ver https://developer.hashicorp.com/terraform/install

- 3.5 - verificar a versão do GIT
```bash
git --version
git version 2.39.3
```

##### 4 - Configurando o github.com
- **Crie o repositório github **: Precisamos de um repositório no [github.com/seu-user/tf-aws-network](https://github.com/) para versionarmos o código da infraestrutura.

##### 5 - Configurando o app.terraform.io
- **Crie a Organização no app.terraform.io/app/**: [/app/organizations](https://app.terraform.io/app/organizations/new) 
- **Crie o Workspace no app.terraform.io**: [/NOME_DA_ORGANIZACAO/workspaces/new](https://app.terraform.io/app/NOME_DA_ORGANIZACAO/workspaces/new) 
Precisamos criar uma workspace no Terraform Cloud para planejar e executar nosso código de infraestrutura.
- **Configure as "Terraform Variables" para acesso a AWS**: https://app.terraform.io/app/NOME_DA_ORGANIZACAO/workspaces/NOME_DO_SEU_WORKSPACE/variables 
```bash
Terraform Variables "aws_access_key"
Terraform Variables "aws_secret_key"
```
