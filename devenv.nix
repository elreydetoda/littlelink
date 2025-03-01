{ pkgs, lib, config, inputs, ... }:                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                                              
{                                                                                                                                                                                                                                                                                                                                                                                             
  # https://devenv.sh/basics/                                                                                                                                                                                                                                                                                                                                                                 
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    curl
    awscli2
    jq
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;
  languages = {
    python = {
      enable = true;
      uv = {
        enable = true;
      };
    };
    # for CDK deployments
    javascript = {
      enable = true;
      package = pkgs.nodejs_20;
      npm = {
        enable = true;
      };
    };
  };

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts = {
    # aws_profile_prep = {
    #   exec = ''
    #     set -euxo pipefail
    #     mkdir -p ~/.aws
    #     for profilez in infra dev-infra ; do
    #       echo "[profile \"$profilez\"]"
    #       echo "region = $AWS_REGION"
    #       echo "output = json"
    #     done >  ~/.aws/config
    #   '';
    # };
    # aws_profile_prod_prep = {
    #   exec = ''
    #     set -euo pipefail
    #     aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile infra
    #     aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile infra
    #     aws configure set aws_session_token $AWS_SESSION_TOKEN --profile infra
    #     ## for debugging
    #     # aws --profile infra sts get-caller-identity
    #   '';
    # };
    # aws_profile_dev_prep = {
    #   exec = ''
    #     set -euo pipefail
    #     aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile dev-infra
    #     aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile dev-infra
    #     aws configure set aws_session_token $AWS_SESSION_TOKEN --profile dev-infra
    #     ## for debugging
    #     # aws --profile dev-infra sts get-caller-identity
    #   '';
    # };
    aws_sync_ll_folder = {
      exec = ''
        set -euxo pipefail
        aws s3 cp --acl public-read index.html s3://$BUCKET_NAME/links
        aws s3 sync --acl public-read ./ll/ s3://$BUCKET_NAME/ll/
      '';
    };
    cdk_prep = {
      exec = ''
        set -euxo pipefail
        npm install || npm install aws-cdk@^2
      '';
    };
    cdk_wrap = {
      exec = ''
        set -euxo pipefail
        ${config.languages.python.uv.package}/bin/uv run npx cdk "$@"
      '';
    };
  };

  # enterShell = ''
  #   git --version
  # '';

  # https://devenv.sh/tasks/
  # tasks = {
  # #   "myproj:setup".exec = "mytool build";
  # #   "devenv:enterShell".after = [ "myproj:setup" ];
  # #   before = [ "devenv:enterShell" "devenv:enterTest" ];
  #   };
  # };

  # https://devenv.sh/tests/
  # enterTest = ''
  #   echo "Running tests"
  #   git --version | grep --color=auto "${pkgs.git.version}"
  # '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}