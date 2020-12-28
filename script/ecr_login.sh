# Login to ECR, optionally specifying a profile namd and region.

profile_name="vtenh"
region="ap-southeast-1"

args=()
if [ -n "$profile_name" ]; then
  args=("${args[@]}" "--profile=$profile_name")
fi
if [ -n "$region" ]; then
  args=("${args[@]}" "--region=$region")
fi
auth_result=$(aws "${args[@]}" ecr get-authorization-token --output text)
if [ -z "$auth_result" ]; then
  return
fi
token=$(echo "$auth_result" | cut -f2 | base64 --decode | cut -d: -f2)
url=$(echo "$auth_result" | cut -f4)
echo "$token" | docker login --password-stdin -u AWS "$url"
