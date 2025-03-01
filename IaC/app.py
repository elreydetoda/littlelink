#!/usr/bin/env python3
from os import getenv
import aws_cdk as cdk
from github_oidc.github_oidc_stack import GitHubOIDCStack

app = cdk.App()
GitHubOIDCStack(
    app,
    "GitHubOIDCStack",
    env=cdk.Environment(
        account=getenv("AWS_ACCOUNT_ID"),  # Replace with your AWS account ID
        region=getenv("AWS_ACCOUNT_REGION"),  # Replace with your desired region
    ),
)

app.synth()
