#! /bin/bash

set -exuo pipefail

function configure_system {
  apt-get update
}

function install_awscli {
  apt-get install -y python3-pip
  pip3 install awscli

  apt-get remove -y python3-pip
}

function cleanup {
  apt-get autoremove -y
}

function complete_lifecycle_action {
  echo "Completing lifecycle action"

  INSTANCE_ID=$( curl -s http://169.254.169.254/latest/meta-data/instance-id )

  aws autoscaling --region eu-west-1 complete-lifecycle-action \
    --lifecycle-hook-name ${lifecycle_hook_name} \
    --auto-scaling-group-name ${autoscaling_group_name} \
    --lifecycle-action-result CONTINUE \
    --instance-id $${INSTANCE_ID}
}

function abandon_lifecycle_action {
  echo "Abandoning lifecycle action"

  INSTANCE_ID=$( curl -s http://169.254.169.254/latest/meta-data/instance-id )

  aws autoscaling --region eu-west-1 complete-lifecycle-action \
    --lifecycle-hook-name ${lifecycle_hook_name} \
    --auto-scaling-group-name ${autoscaling_group_name} \
    --lifecycle-action-result ABANDON \
    --instance-id $${INSTANCE_ID}
}

configure_system
install_awscli
cleanup
complete_lifecycle_action

trap abandon_lifecycle_action ERR
