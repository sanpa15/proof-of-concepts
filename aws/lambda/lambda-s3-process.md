_lambda-s3-process.md_

**layer 1**

```py
import json
import urllib
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3Client = boto3.client('s3')
sqsClient = boto3.client('sqs')

metadataBucket = "a2-s3-bucket-jn"
scanningBucket = "a2-s3-bucket-scan"
sqsUrl         = "https://sqs.ap-southeast-1.amazonaws.com/676487226531/a1-s3-sqs.fifo"

def deleteQueueMessage(sqsUrl, receiptHandle):
    return sqsClient.delete_message(QueueUrl=sqsUrl,ReceiptHandle=receiptHandle)
    
def findS3EventObject(event):
    listOfObjetcts = []
    checkEvent = 'Records' in event.keys()
    if checkEvent == True:
        for source in range(len(event['Records'])):
            reformedListRecord = event['Records'][source]
            reformedBody       = json.loads(reformedListRecord["body"])
            reformedMessageList= json.dumps(reformedBody)
            reformedMessage    = json.loads(reformedMessageList)
            receiptHandle      = reformedListRecord['receiptHandle']
            s3Event            = reformedMessage['detail']['requestParameters']
            object             = json.dumps({'s3': s3Event, "receiptHandle": receiptHandle})
            listOfObjetcts.append(object)
            
    return listOfObjetcts

def printLogging(sourceBucketName, fileName, state):
    return json.dumps({ 'Bucket': sourceBucketName, 'fileName': fileName, 'processState': state })
    
def getObjectDetails(buckeName, fileName):
    _results = s3Client.list_objects(Bucket=buckeName, Prefix=fileName)
    return 'Contents' in _results
    
def createNewTags(buckeName, fileName, tagName, tagValue):
    tagging = {'TagSet' : [{'Key': tagName, 'Value': tagValue }]}
    return s3Client.put_object_tagging(Bucket=buckeName, Key=fileName, Tagging=tagging)

def copyS3Object(sourceBucketName, DestinationBucketName, fileName):
    return s3Client.copy_object(CopySource={ 'Bucket': sourceBucketName, 'Key': fileName }, Bucket=DestinationBucketName, Key=fileName, TaggingDirective='COPY', ChecksumAlgorithm='SHA1',)

def deleteS3Object(bucketName, fileName):
    return s3Client.delete_object(Bucket=bucketName, Key=fileName)

def lambda_handler(event, context):
    json.dumps(event, indent=3)
    s3ObjectIdentifier = findS3EventObject(event)
    if s3ObjectIdentifier != []:
        for s3 in s3ObjectIdentifier:
            s3Data = json.loads(s3)
            sourceBucketName = urllib.parse.unquote_plus(s3Data['s3']['bucketName'])
            fileName = urllib.parse.unquote_plus(s3Data['s3']['key'])
            receiptHandle = s3Data['receiptHandle']
            
            getSourceBucketObjectAvailablility = getObjectDetails(sourceBucketName, fileName)
            if getSourceBucketObjectAvailablility == True:
                createNewTags(sourceBucketName, fileName, "zone", "internet")
                copyS3Object(sourceBucketName, metadataBucket, fileName)
                copyS3Object(sourceBucketName, scanningBucket, fileName)
                deleteS3Object(sourceBucketName, fileName)
                deleteQueueMessage(sqsUrl, receiptHandle)
                logger.info(printLogging(sourceBucketName, fileName, "Success"))
            else:
                deleteQueueMessage(sqsUrl, receiptHandle)
                logger.error(printLogging(sourceBucketName, fileName, "Failure"))
```

**Layer 2**

```py
import json
import urllib
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3Client = boto3.client('s3')
sqsClient = boto3.client('sqs')

destinationBucket = "a2-s3-bucket-jn"
sqsUrl            = "https://sqs.ap-southeast-1.amazonaws.com/676487226531/a2-s3-sqs.fifo"

def deleteQueueMessage(sqsUrl, receiptHandle):
    return sqsClient.delete_message(QueueUrl=sqsUrl,ReceiptHandle=receiptHandle)
    
def findS3EventObject(event):
    listOfObjetcts = []
    checkEvent = 'Records' in event.keys()
    if checkEvent == True:
        for source in range(len(event['Records'])):
            reformedListRecord = event['Records'][source]
            reformedBody       = json.loads(reformedListRecord["body"])
            reformedMessageList= json.dumps(reformedBody)
            reformedMessage    = json.loads(reformedMessageList)
            receiptHandle      = reformedListRecord['receiptHandle']
            s3Event            = reformedMessage['detail']['requestParameters']
            object             = json.dumps({'s3': s3Event, "receiptHandle": receiptHandle})
            listOfObjetcts.append(object)
            
    return listOfObjetcts

def printLogging(sourceBucketName, fileName, state):
    return json.dumps({ 'Bucket': sourceBucketName, 'fileName': fileName, 'tagUpdationSuccess': state })
    
def getObjectDetails(buckeName, fileName):
    _results = s3Client.list_objects(Bucket=buckeName, Prefix=fileName)
    return 'Contents' in _results
    
def updateTags(buckeName, fileName, updationTags):
    return s3Client.put_object_tagging(Bucket=buckeName, Key=fileName, Tagging={'TagSet': updationTags})

def deleteS3Object(bucketName, fileName):
    return s3Client.delete_object(Bucket=bucketName, Key=fileName)

def getTags(buckeName, fileName):
    tag = s3Client.get_object_tagging(Bucket=buckeName, Key=fileName)
    return tag['TagSet']
    
def lambda_handler(event, context):
    json.dumps(event, indent=3)
    s3ObjectIdentifier = findS3EventObject(event)
    if s3ObjectIdentifier != []:
        for s3 in s3ObjectIdentifier:
            s3Data = json.loads(s3)
            sourceBucketName = urllib.parse.unquote_plus(s3Data['s3']['bucketName'])
            fileName = urllib.parse.unquote_plus(s3Data['s3']['key'])
            receiptHandle = s3Data['receiptHandle']
            
            getSourceBucketObjectAvailablility = getObjectDetails(sourceBucketName, fileName)
            if getSourceBucketObjectAvailablility == True:
                updationTags = getTags(sourceBucketName, fileName)
                updateTags(destinationBucket, fileName, updationTags)
                deleteS3Object(sourceBucketName, fileName)
                deleteQueueMessage(sqsUrl, receiptHandle)
                logger.info(printLogging(sourceBucketName, fileName, "Success"))
            else:
                deleteQueueMessage(sqsUrl, receiptHandle)
                logger.error(printLogging(sourceBucketName, fileName, "Failure"))
```

**Layer 3**

```py
import json
import urllib
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3Client = boto3.client('s3')
sqsClient = boto3.client('sqs')

successBucket = "a3-s3-bucket-success"
failureBucket = "a3-s3-bucket-failure"
sqsUrl         = "https://sqs.ap-southeast-1.amazonaws.com/676487226531/a3-s3-sqs.fifo"

def deleteQueueMessage(sqsUrl, receiptHandle):
    return sqsClient.delete_message(QueueUrl=sqsUrl,ReceiptHandle=receiptHandle)
    
def findS3EventObject(event):
    listOfObjetcts = []
    checkEvent = 'Records' in event.keys()
    if checkEvent == True:
        for source in range(len(event['Records'])):
            reformedListRecord = event['Records'][source]
            reformedBody       = json.loads(reformedListRecord["body"])
            reformedMessageList= json.dumps(reformedBody)
            reformedMessage    = json.loads(reformedMessageList)
            receiptHandle      = reformedListRecord['receiptHandle']
            s3Event            = reformedMessage['detail']['requestParameters']
            object             = json.dumps({'s3': s3Event, "receiptHandle": receiptHandle})
            listOfObjetcts.append(object)
            
    return listOfObjetcts

def printLogging(sourceBucketName, fileName, state):
    return json.dumps({ 'Bucket': sourceBucketName, 'fileName': fileName, 'processState': state })
    
def getObjectDetails(buckeName, fileName):
    _results = s3Client.list_objects(Bucket=buckeName, Prefix=fileName)
    return 'Contents' in _results
    
def copyS3Object(sourceBucketName, DestinationBucketName, fileName):
    return s3Client.copy_object(CopySource={ 'Bucket': sourceBucketName, 'Key': fileName }, Bucket=DestinationBucketName, Key=fileName, TaggingDirective='COPY', ChecksumAlgorithm='SHA1',)

def deleteS3Object(bucketName, fileName):
    return s3Client.delete_object(Bucket=bucketName, Key=fileName)

def getTagsDetails(sourceBucketName, fileName):
    tags = s3Client.get_object_tagging(Bucket=sourceBucketName, Key=fileName)
    data = tags['TagSet']
    outputResult = [ x for x in data if x['Key'] == 'fss-scan-result']
    return outputResult[0]['Value']        
    
def lambda_handler(event, context):
    json.dumps(event, indent=3)
    s3ObjectIdentifier = findS3EventObject(event)
    if s3ObjectIdentifier != []:
        for s3 in s3ObjectIdentifier:
            s3Data = json.loads(s3)
            sourceBucketName = urllib.parse.unquote_plus(s3Data['s3']['bucketName'])
            fileName = urllib.parse.unquote_plus(s3Data['s3']['key'])
            receiptHandle = s3Data['receiptHandle']
            
            getSourceBucketObjectAvailablility = getObjectDetails(sourceBucketName, fileName)
            
            if getSourceBucketObjectAvailablility == True:
                getTagValue = getTagsDetails(sourceBucketName, fileName)
                
                if 'no issues found' == getTagValue:
                    copyS3Object(sourceBucketName, successBucket, fileName)
                    deleteS3Object(sourceBucketName, fileName)
                    deleteQueueMessage(sqsUrl, receiptHandle)
                    logger.info(printLogging(sourceBucketName, fileName, "Success"))
                else:
                    copyS3Object(sourceBucketName, failureBucket, fileName)
                    deleteS3Object(sourceBucketName, fileName)
                    deleteQueueMessage(sqsUrl, receiptHandle)
                    logger.info(printLogging(sourceBucketName, fileName, "Failure"))
            else:
                deleteQueueMessage(sqsUrl, receiptHandle)
                logger.error(printLogging(sourceBucketName, fileName, "Failure"))
```
