import boto3
import os
import datetime
from statistics import mean

cloudwatch = boto3.client('cloudwatch')
region = os.environ.get("AWS_REGION", "ap-south-1")

INSTANCE_ID = os.environ["INSTANCE_ID"]
NAMESPACE = os.environ["NAMESPACE"]
METRIC_NAME = os.environ["METRIC_NAME"]

def lambda_handler(event, context):
    end_time = datetime.datetime.utcnow()
    start_time = end_time - datetime.timedelta(minutes=30)

    response = cloudwatch.get_metric_statistics(
        Namespace="AWS/EC2",
        MetricName="CPUUtilization",
        Dimensions=[{"Name": "InstanceId", "Value": INSTANCE_ID}],
        StartTime=start_time,
        EndTime=end_time,
        Period=300,
        Statistics=["Average"]
    )

    datapoints = [dp["Average"] for dp in response["Datapoints"]]
    if not datapoints:
        print("No data found")
        return

    avg_cpu = mean(datapoints)
    print(f"Average CPU over 30 mins: {avg_cpu:.2f}")

    # Publish as custom metric
    cloudwatch.put_metric_data(
        Namespace=NAMESPACE,
        MetricData=[{
            "MetricName": METRIC_NAME,
            "Value": avg_cpu,
            "Unit": "Percent"
        }]
    )

    print(f"Published {METRIC_NAME} = {avg_cpu:.2f}% to {NAMESPACE}")
