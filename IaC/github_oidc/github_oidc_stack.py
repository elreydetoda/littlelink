from os import getenv
from aws_cdk import Stack, aws_iam as iam, CfnOutput, Duration
from constructs import Construct


class GitHubOIDCStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Create the OIDC Provider
        github_provider = iam.OpenIdConnectProvider(
            self,
            "GitHubProvider",
            url="https://token.actions.githubusercontent.com",
            client_ids=["sts.amazonaws.com"],
            thumbprints=[
                "6938fd4d98bab03faadb97b34396831e3780aea1"
            ],  # GitHub's thumbprint
        )

        # Create the IAM role for GitHub Actions
        github_role = iam.Role(
            self,
            getenv("AWS_ROLE_NAME"),
            assumed_by=iam.OpenIdConnectPrincipal(github_provider).with_conditions(
                {
                    "StringLike": {
                        "token.actions.githubusercontent.com:sub": "repo:elreydetoda/littlelink:*"
                    },
                    "StringEquals": {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                    },
                }
            ),
            description="Role for GitHub Actions OIDC",
            role_name="GitHubActionsOIDCRole",
            max_session_duration=Duration.hours(1),
        )

        # Add necessary permissions for the role
        github_role.add_managed_policy(
            iam.ManagedPolicy.from_managed_policy_name(
                self,
                "ll-upload",
                "personal-littlelink-upload",
            )
        )

        # Output the role ARN
        CfnOutput(
            self,
            "GitHubOIDCRoleARN",
            value=github_role.role_arn,
            description="ARN of the IAM role for GitHub Actions",
            export_name="GitHubOIDCRoleARN",
        )
