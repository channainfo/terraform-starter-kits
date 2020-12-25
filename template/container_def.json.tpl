[
  {
    "name": "${container_name}",
    "image": "${docker_image_url}",
    "cpu": ${container_cpu},
    "memory": ${container_memory},
    "portMappings": [
      {
        "containerPort": ${container_port},
        "protocol": "tcp"
      }
    ],
    "environment": [
      {"name": "APP_NAME", "value": "${app_name}"},
      {"name": "ASSET_HOST_URL", "value": "${asset_host_url}"},
      {"name": "AWS_BUCKET_NAME", "value": "${bucket_Name}"},
      {"name": "AWS_REGION", "value": "${region}"},
      {"name": "DEVISE_SECRET_KEY", "value": "${device_secret_key}"},
      {"name": "FIREBASE_PROJECT_ID", "value": "${firebase_project_id}"},
      {"name": "HOST", "value": "${host}"},
      {"name": "MODE_ENV", "value": "${app_mode}"},
      {"name": "RAILS_MASTER_KEY", "value": "${rails_master_key}"},
      {"name": "RAILS_MIN_INSTANCES", "value": "${rails_min_instances}"},
      {"name": "RAILS_MAX_INSTANCES", "value": "${rails_max_instance}"},
      {"name": "SMS_SENDER_ID", "value": "${sms_sender_id}"},
      {"name": "SMTP_SERVER", "value": "${smtp_server}"},
      {"name": "SMTP_USERNAME", "value": "${smtp_username}"},
      {"name": "SMTP_PASSWORD", "value": "${smtp_password}"},
      {"name": "VSHOP_DB_HOST", "value": "${rds_db_host}"},
      {"name": "VSHOP_DB_NAME", "value": "${rds_db_name}"},
      {"name": "VSHOP_DB_NAME_PRODUCTION", "value": "${rds_db_name}"},
      {"name": "VSHOP_DB_USER", "value": "${rds_db_user}"},
      {"name": "VSHOP_DB_PASSWORD", "value": "${rds_db_password}"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group": "true",
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
