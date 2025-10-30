# 🚀 Automatizando tarefas com AWS Lambda e S3

Este projeto demonstra como criar uma **infraestrutura serverless** utilizando **AWS CloudFormation**, **Lambda** e **S3**, de forma totalmente automatizada via **AWS CLI**.  
A ideia é servir como base para implementar funções que executam tarefas automatizadas, como processar arquivos, disparar eventos ou agendar rotinas.

---

## 🧩 Estrutura do projeto

lambda-s3-automation/

│

├── templates/

│ └── main.yaml # Template CloudFormation (infraestrutura)

│

├── scripts/

│ └── deploy.sh # Comandos principais usados

│

├── handler.py # Código da função Lambda

│

├── requirements.txt # Dependências (se houver)

│
└── comandos.sh # Comandos executados para teste


---

## ⚙️ 1. Configuração do ambiente

Antes de começar, verifique se possui:

- ✅ **AWS CLI** instalado e configurado (`aws configure`)
- ✅ Um perfil AWS válido com permissões para:
  - CloudFormation
  - IAM
  - S3
  - Lambda
- ✅ Região configurada para **sa-east-1 (São Paulo)**  
  (confirme com `aws configure list`)

---

## 🪣 2. Criar o bucket S3 para os artefatos

Crie um bucket onde será armazenado o pacote da função Lambda:

```bash
aws s3 mb s3://my-lambda-artifacts-dev --region sa-east-1
```

## 🧾 3. Template CloudFormation (templates/main.yaml)

```bash
AWSTemplateFormatVersion: '2010-09-09'
Description: Deploy de uma função Lambda com integração ao S3.

Resources:
  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: LambdaS3AutomationRole
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        - arn:aws:iam::aws:policy/AmazonS3FullAccess

  LambdaFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: my-lambda-task-dev
      Handler: handler.lambda_handler
      Role: !GetAtt LambdaExecutionRole.Arn
      Code:
        S3Bucket: my-lambda-artifacts-dev
        S3Key: lambda-code.zip
      Runtime: python3.12
      Timeout: 30
```

## 💻 4. Código da função Lambda (src/handler.py)

```bash
import json

def lambda_handler(event, context):
    print("Evento recebido:", json.dumps(event))
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Execução concluída com sucesso!"})
    }
```

## 📦 5. Empacotar e enviar o código ao S3

Compacte o código:

```bash
zip -r ../lambda-code.zip .
```

```bash
aws s3 cp ../lambda-code.zip s3://my-lambda-artifacts-dev/lambda-code.zip
```

## 🧱 6. Criar a Stack no CloudFormation

Rode o comando:

```bash
aws cloudformation create-stack \
  --stack-name lambda-s3-automation-dev \
  --template-body file://templates/main.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

Aguarde até o status da stack ser CREATE_COMPLETE:

```bash
aws cloudformation describe-stacks \
  --stack-name lambda-s3-automation-dev \
  --query "Stacks[0].StackStatus"
```

## ✅ 7. Testar a função Lambda

Após a criação bem-sucedida:

```bash
aws lambda invoke \
  --function-name my-lambda-task-dev \
  response.json
```

Verifique o resultado:

```bash
cat response.json
```

## 🧹 8. (Opcional) Limpar recursos

Para excluir todos os recursos criados:

```bash
aws cloudformation delete-stack --stack-name lambda-s3-automation-dev
```

## 📘 Notas

Este projeto é somente para testes e aprendizado de automação na AWS.

Se for expandir para produção, lembre-se de:
- Implementar logs detalhados (CloudWatch)
- Criar uma política IAM mínima para a Lambda
- Versionar artefatos do S3
- Implementar variáveis de ambiente seguras

## 🏁 Resultado esperado

Após seguir os passos acima, você terá:
- ✅ Uma função Lambda funcional
- ✅ Artefato empacotado e armazenado no S3
- ✅ Implantação automatizada via CloudFormation
- ✅ Pipeline pronto para futuras automações serverless

Autora: Blaine Silva
Tecnologias: AWS Lambda · AWS S3 · AWS CloudFormation · AWS CLI · Python
Região AWS usada: sa-east-1 (São Paulo)
