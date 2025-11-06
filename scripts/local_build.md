
开发阶段

# 快速测试，只要 .app
./scripts/local_build.sh kpi_drojian.json apple

# 测试运行
open kpi-drojian.app

发布阶段

# 本地测试打包
./scripts/local_build.sh kpi_drojian.json apple dmg

# 测试 DMG 安装
open kpi-drojian_apple.dmg

# 确认无误后，推送 tag 自动构建所有平台
git tag kpi-drojian-v0.0.1 -m "Release v0.0.1"
git push origin kpi-drojian-v0.0.1

🚀 一键打包命令

# 一步到位：ARM64 + 自动 DMG
./scripts/local_build.sh kpi_drojian.json apple dmg

# 一步到位：Universal + 自动 DMG
./scripts/local_build.sh kpi_drojian.json universal dmg