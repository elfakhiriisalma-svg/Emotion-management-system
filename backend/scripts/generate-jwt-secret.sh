#!/bin/bash
# Script to generate a secure JWT secret

echo "Generating JWT Secret..."
echo ""
echo "JWT_SECRET=$(openssl rand -base64 64)"
echo ""
echo "Copy the JWT_SECRET value above and set it as an environment variable in your deployment platform."

