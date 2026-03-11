# 重庆黑客松项目开发环境启动脚本 (PowerShell版本)
# 作者: hackthon-team

param(
    [switch]$SkipApp,
    [switch]$Help
)

# 显示帮助信息
if ($Help) {
    Write-Host "重庆黑客松项目开发环境启动脚本" -ForegroundColor Blue
    Write-Host "用法: .\start-dev.ps1 [选项]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "选项:" -ForegroundColor Yellow
    Write-Host "  -SkipApp    跳过应用启动，只启动基础服务"
    Write-Host "  -Help       显示此帮助信息"
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Yellow
    Write-Host "  .\start-dev.ps1              # 启动所有服务"
    Write-Host "  .\start-dev.ps1 -SkipApp     # 只启动基础服务"
    exit 0
}

# 设置错误处理
$ErrorActionPreference = "Stop"

Write-Host "🚀 启动重庆黑客松项目开发环境..." -ForegroundColor Green

# 检查Docker是否安装
function Test-Docker {
    Write-Host "🔍 检查Docker环境..." -ForegroundColor Blue
    
    try {
        $null = Get-Command docker -ErrorAction Stop
        $null = Get-Command docker-compose -ErrorAction Stop
        Write-Host "✅ Docker环境检查通过" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Docker未安装，请先安装Docker Desktop" -ForegroundColor Red
        Write-Host "   下载地址: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        exit 1
    }
}

# 检查端口占用
function Test-Ports {
    $ports = @(3306, 6379, 5672, 9000, 9090, 3000, 8080)
    $occupiedPorts = @()
    
    foreach ($port in $ports) {
        $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($connection) {
            $occupiedPorts += $port
        }
    }
    
    if ($occupiedPorts.Count -gt 0) {
        Write-Host "⚠️  以下端口被占用: $($occupiedPorts -join ', ')" -ForegroundColor Yellow
        Write-Host "   如果是其他实例，请先停止相关服务" -ForegroundColor Yellow
        
        $continue = Read-Host "是否继续启动？(y/N)"
        if ($continue -notmatch '^[Yy]$') {
            exit 1
        }
    }
}

# 创建必要的目录
function New-ProjectDirectories {
    Write-Host "📁 创建必要的目录..." -ForegroundColor Blue
    
    $directories = @("logs", "data\mysql", "data\redis", "data\minio", "monitoring")
    
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    Write-Host "✅ 目录创建完成" -ForegroundColor Green
}

# 启动基础服务
function Start-Infrastructure {
    Write-Host "🔧 启动基础服务 (MySQL, Redis, RabbitMQ, MinIO)..." -ForegroundColor Blue
    
    try {
        & docker-compose up -d mysql redis rabbitmq minio
        
        Write-Host "⏳ 等待服务启动..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        # 检查服务状态
        $services = & docker-compose ps --format json | ConvertFrom-Json
        $runningServices = $services | Where-Object { $_.State -eq "running" }
        
        if ($runningServices.Count -gt 0) {
            Write-Host "✅ 基础服务启动成功" -ForegroundColor Green
        }
        else {
            Write-Host "❌ 基础服务启动失败" -ForegroundColor Red
            & docker-compose logs
            exit 1
        }
    }
    catch {
        Write-Host "❌ 启动基础服务时发生错误: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# 启动监控服务
function Start-Monitoring {
    Write-Host "📊 启动监控服务 (Prometheus, Grafana)..." -ForegroundColor Blue
    
    try {
        & docker-compose up -d prometheus grafana
        Write-Host "✅ 监控服务启动成功" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  监控服务启动失败，但不影响核心功能" -ForegroundColor Yellow
    }
}

# 等待数据库就绪
function Wait-ForDatabase {
    Write-Host "⏳ 等待数据库就绪..." -ForegroundColor Blue
    
    $maxAttempts = 30
    $attempt = 1
    
    while ($attempt -le $maxAttempts) {
        try {
            $result = & docker-compose exec -T mysql mysql -u root -proot123 -e "SELECT 1" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ 数据库已就绪" -ForegroundColor Green
                return
            }
        }
        catch {
            # 继续尝试
        }
        
        Write-Host "   尝试 $attempt/$maxAttempts..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        $attempt++
    }
    
    Write-Host "❌ 数据库启动超时" -ForegroundColor Red
    exit 1
}

# 初始化数据库
function Initialize-Database {
    Write-Host "🗄️  初始化数据库..." -ForegroundColor Blue
    
    try {
        # 检查数据库是否已初始化
        $tables = & docker-compose exec -T mysql mysql -u hackthon_user -phackthon_pass hackthon_core_dev -e "SHOW TABLES" 2>$null
        if ($tables -match "users") {
            Write-Host "⚠️  数据库已初始化，跳过初始化步骤" -ForegroundColor Yellow
            return
        }
    }
    catch {
        # 数据库可能还未创建，继续初始化
    }
    
    # 执行数据库初始化脚本
    if (Test-Path "database_design_hybrid.sql") {
        try {
            Get-Content "database_design_hybrid.sql" | & docker-compose exec -T mysql mysql -u hackthon_user -phackthon_pass hackthon_core_dev
            Write-Host "✅ 数据库初始化完成" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️  数据库初始化失败，请手动执行初始化脚本" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "⚠️  数据库初始化脚本不存在，请手动初始化" -ForegroundColor Yellow
    }
}

# 启动应用
function Start-Application {
    if ($SkipApp) {
        Write-Host "⏭️  跳过应用启动" -ForegroundColor Yellow
        return
    }
    
    $startApp = Read-Host "是否启动Spring Boot应用？(y/N)"
    
    if ($startApp -match '^[Yy]$') {
        Write-Host "🚀 启动Spring Boot应用..." -ForegroundColor Blue
        
        if (Test-Path "stage1-core") {
            Push-Location "stage1-core"
            
            try {
                if (Test-Path "mvnw.cmd") {
                    Start-Process -FilePath "cmd" -ArgumentList "/c", "mvnw.cmd spring-boot:run" -NoNewWindow
                }
                elseif (Get-Command mvn -ErrorAction SilentlyContinue) {
                    Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run" -NoNewWindow
                }
                else {
                    Write-Host "❌ Maven未安装，请手动启动应用" -ForegroundColor Red
                    Pop-Location
                    return
                }
                
                Write-Host "✅ 应用启动中..." -ForegroundColor Green
            }
            catch {
                Write-Host "❌ 应用启动失败: $($_.Exception.Message)" -ForegroundColor Red
            }
            finally {
                Pop-Location
            }
        }
        else {
            Write-Host "❌ stage1-core目录不存在" -ForegroundColor Red
        }
    }
    else {
        Write-Host "💡 你可以稍后手动启动应用:" -ForegroundColor Yellow
        Write-Host "   cd stage1-core && .\mvnw.cmd spring-boot:run" -ForegroundColor Yellow
    }
}

# 显示服务信息
function Show-ServicesInfo {
    Write-Host ""
    Write-Host "🎉 开发环境启动完成！" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📋 服务访问地址:" -ForegroundColor Blue
    Write-Host "   🌐 API文档:        http://localhost:8080/doc.html" -ForegroundColor White
    Write-Host "   🔧 应用监控:       http://localhost:8081/actuator" -ForegroundColor White
    Write-Host "   🗄️  数据库管理:     http://localhost:8080/druid (admin/admin123)" -ForegroundColor White
    Write-Host "   🐰 RabbitMQ管理:   http://localhost:15672 (guest/guest)" -ForegroundColor White
    Write-Host "   📦 MinIO控制台:    http://localhost:9001 (minioadmin/minioadmin)" -ForegroundColor White
    Write-Host "   📊 Prometheus:     http://localhost:9090" -ForegroundColor White
    Write-Host "   📈 Grafana:        http://localhost:3000 (admin/admin123)" -ForegroundColor White
    
    Write-Host ""
    Write-Host "🔧 常用命令:" -ForegroundColor Blue
    Write-Host "   查看服务状态:      docker-compose ps" -ForegroundColor White
    Write-Host "   查看应用日志:      docker-compose logs -f app-core" -ForegroundColor White
    Write-Host "   停止所有服务:      docker-compose down" -ForegroundColor White
    Write-Host "   重启服务:          docker-compose restart <service-name>" -ForegroundColor White
    
    Write-Host ""
    Write-Host "📚 开发文档:" -ForegroundColor Blue
    Write-Host "   项目README:        .\README.md" -ForegroundColor White
    Write-Host "   数据库设计:        .\database_design_hybrid.sql" -ForegroundColor White
    Write-Host "   API接口文档:       启动应用后访问 http://localhost:8080/doc.html" -ForegroundColor White
    
    Write-Host ""
    Write-Host "💡 提示:" -ForegroundColor Yellow
    Write-Host "   - 首次启动可能需要下载Docker镜像，请耐心等待" -ForegroundColor White
    Write-Host "   - 如遇到问题，请查看 docker-compose logs 获取详细日志" -ForegroundColor White
    Write-Host "   - 生产环境部署请参考 README.md 中的部署指南" -ForegroundColor White
}

# 主函数
function Main {
    Write-Host "重庆黑客松项目 - 智能健康检测应用" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
    
    try {
        Test-Docker
        Test-Ports
        New-ProjectDirectories
        Start-Infrastructure
        Wait-ForDatabase
        Initialize-Database
        Start-Monitoring
        Start-Application
        Show-ServicesInfo
        
        Write-Host ""
        Write-Host "🚀 开发环境已就绪，开始你的开发之旅吧！" -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Host "❌ 启动过程中发生错误: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "请检查错误信息并重试" -ForegroundColor Yellow
        exit 1
    }
}

# 执行主函数
Main