#!/usr/bin/env bash

aws s3 cp s3://<S3 bucket name>/KxPlatformAWSStartScript.sh .
chmod 755 KxPlatformAWSStartScript.sh 
./KxPlatformAWSStartScript.sh <PackageName> # eg - PlatformKx-4.4.0-Linux
