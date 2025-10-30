# criar o bucket s3 para armazenar os artefatos da lambda
aws s3 mb s3://my-lambda-artifacts-dev-final-project --region sa-east-1

# empacotar o código da lambda e enviar ao s3
zip -r ../lambda-code.zip .
aws s3 cp ../lambda-code.zip s3://my-lambda-artifacts-dev-final-project/lambda-code.zip

# criar a stack do cloudformation
aws cloudformation create-stack \
  --stack-name lambda-s3-automation-dev-final-project \
  --template-body file://templates/main.yaml \
  --capabilities CAPABILITY_NAMED_IAM

# verificar o status da stack
aws cloudformation describe-stacks \
  --stack-name lambda-s3-automation-dev-final-project \
  --query "Stacks[0].StackStatus"

# invocar a lambda criada
aws lambda invoke \
  --function-name my-lambda-task-dev-final-project \
  response.json

# ver o resultado da invocação
cat response.json