# S3 to Slack Notification System

### Objective
Design an AWS event-driven workflow where uploading a new file to an **S3 bucket** triggers an **AWS Lambda function** that sends a message to a **Slack channel**.

---

## Architecture Overview
The solution is based on the following components,

- **Amazon S3** – Stores uploaded objects and triggers an event notification.  
- **AWS Lambda** – Executes Python code to send formatted messages to Slack.  
- **Slack Incoming Webhook** – Receives POST requests from Lambda and posts to a selected channel.  
- **Terraform (`main.tf`)** – Used to *describe* the full infrastructure but was not deployed, to avoid additional AWS costs.

**Workflow Summary**
1. User uploads an object to S3.  
2. S3 triggers an event → Lambda function executes.  
3. Lambda uses Slack Webhook to send a notification to `#notifications` channel.

---

## Implementation Breakdown

### Lambda Function (`s3-slack-notifier.py`)
- **Language** Python 3.13 
- **Role** Processes S3 event payload and sends a formatted Slack message using the Webhook URL.  
- **Test** Manually invoked using a sample event JSON.  
- **Result** Slack notification successfully appeared in the channel.

**Proof #1 – Slack notification**  
![Alt Text](./screenshots/Slack%20notiofication.png)


---

### Terraform Configuration (`main.tf`)
The `main.tf` file defines how the AWS infrastructure would be deployed in a real-world setup.  
This code was not executed, but represents Infrastructure-as-Code best practices.

### Key Resources Defined
| Resource | Purpose |
|-----------|----------|
| `aws_s3_bucket` | Stores uploaded files and triggers Lambda events |
| `aws_iam_role` | Grants Lambda permissions to access S3 |
| `aws_lambda_function` | Executes Python code on file upload |
| `aws_s3_bucket_notification` | Links S3 events to the Lambda trigger |



