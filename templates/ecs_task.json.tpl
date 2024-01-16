[
  {
    "name": "piano-lessons",
    "image": "${account_number}.dkr.ecr.eu-west-2.amazonaws.com/piano-lessons",
    "cpu": 0,
    "environment": [
      {
        "name": "GOOGLE_APPLICATION_CREDENTIALS",
        "value" : "/client-config.json"
      },
      {
        "name": "BASE_URL",
        "value": "https://app.clairepalmerpiano.co.uk"
      }
    ],
    "secrets": [
      {
        "name": "AUTH_URL",
        "valueFrom": "/mgmt/auth/url"
      },
      {
        "name": "AUTH_CLIENT_ID",
        "valueFrom": "/mgmt/auth/id"
      },
      {
        "name": "AUTH_SECRET",
        "valueFrom": "/mgmt/auth/secret"
      },
      {
        "name": "GOOGLE_CLIENT_ID",
        "valueFrom": "/mgmt/google/id"
      },
      {
        "name": "GOOGLE_CLIENT_SECRET",
        "valueFrom": "/mgmt/google/secret"
      },
      {
        "name": "SENDGRID_API_KEY",
        "valueFrom": "/mgmt/sendgrid/key"
      },
      {
        "name": "SENDGRID_TEMPLATE",
        "valueFrom": "/mgmt/sendgrid/template"
      },
      {
        "name": "APPLICATION_SECRET",
        "valueFrom": "/mgmt/play/secret"
      },
      {
        "name": "DB_HOST",
        "valueFrom": "/mgmt/db/host"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "/mgmt/db/password"
      },
      {
        "name": "STRIPE_PUBLIC",
        "valueFrom": "/mgmt/stripe/public"
      },
      {
        "name": "STRIPE_PRIVATE",
        "valueFrom": "/mgmt/stripe/private"
      },
      {
        "name": "CONTACT_PHONE",
        "valueFrom": "/mgmt/contact"
      }
    ],
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/piano-lessons",
        "awslogs-region": "eu-west-2",
        "awslogs-stream-prefix": "ecs",
        "awslogs-datetime-format": "%H:%M:%S%L"
      }
    },
    "portMappings": [
      {
        "containerPort": 9000,
        "hostPort": 9000
      }
    ]
  }
]
