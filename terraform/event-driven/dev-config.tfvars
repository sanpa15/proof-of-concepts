region           = "ap-south-1"
alertSqsQueueURL = "https://sqs.ap-south-1.amazonaws.com/xxx/sqs-final-trigger-queue-to-application"
stageOneBucket = "op-a1-bucket-s3"
stageTwoBucket = "op-b1-bucket-s3"
stageThreeBucket = "op-abc1-bucket-s3"


successBucket = "op-d1-bucket-s3-final-success"
failureBucket = "op-d2-bucket-s3-final-failure"

stageOneSns = "op-a3-sns.fifo"
stageTwoSns = "op-b3-sns.fifo"
stageThreeSns = "op-c3-sns.fifo"

stageOneSqs = "op-a4-sqs.fifo"
stageTwoSqs = "op-b4-sqs.fifo"
stageThreeSqs =  "op-c4-sqs.fifo"

stageOneLambdaOne = "op-a2-lambda"
stageOneLambdaTwo = "op-a5-lambda"
stageTwoLambdaOne = "op-b2-lambda"
stageTwoLambdaTwo = "op-b5-lambda"
stageThreeLambdaOne = "op-c2-lambda"
stageThreeLambdaTwo = "op-c6-lambda"
