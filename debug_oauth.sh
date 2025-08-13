#!/bin/bash

# 设置测试环境的OAuth配置
TEST_CLIENT_ID="test_client_id.apps.googleusercontent.com"
TEST_CLIENT_SECRET="test_client_secret"

echo "设置的测试配置："
echo "GOOGLE_CLIENT_ID=$TEST_CLIENT_ID"
echo "GOOGLE_CLIENT_SECRET=$TEST_CLIENT_SECRET"

# 启动Flutter应用 (使用--dart-define传递编译时常量)
echo "启动Flutter应用..."
flutter run -d macos --debug \
  --dart-define=GOOGLE_CLIENT_ID="$TEST_CLIENT_ID" \
  --dart-define=GOOGLE_CLIENT_SECRET="$TEST_CLIENT_SECRET"