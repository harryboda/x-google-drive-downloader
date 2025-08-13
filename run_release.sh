#!/bin/bash

# 设置生产环境的OAuth配置  
# 请替换为您的真实OAuth凭据
PROD_CLIENT_ID="your_real_client_id.apps.googleusercontent.com"
PROD_CLIENT_SECRET="your_real_client_secret"
# PROD_CLIENT_ID=your_actual_client_id_here
# PROD_CLIENT_SECRET=your_actual_client_secret_here

echo "启动 Release 模式应用..."
echo "客户端ID: ${PROD_CLIENT_ID:0:20}..."

# 启动Flutter应用 Release模式 (使用--dart-define传递编译时常量)
echo "正在构建和启动Release版本..."
flutter run -d macos --release \
  --dart-define=GOOGLE_CLIENT_ID="$PROD_CLIENT_ID" \
  --dart-define=GOOGLE_CLIENT_SECRET="$PROD_CLIENT_SECRET"
