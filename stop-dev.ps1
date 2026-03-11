# 重庆黑客松项目开发环境停止脚本 (PowerShell版本)
# 作者: hackthon-team

param(
    [switch]$RemoveData,
    [switch]$Help
)

# 显示帮助信息
if ($Help) {
    Write-Host "重庆黑客松项目开发环境停止脚本" -ForegroundColor Blue
    Write-Host "用法: .\stop-dev.ps1 [选项]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "选项:" -ForegroundColor Yellow
    Write-Host "  -RemoveData    同时删除数据卷（谨慎使用）"
    Write-Host "  -Help          显示此帮助信息"
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Yellow
    Write-Host "  .\stop-dev.ps1              # 停止服务但保留数据"
    Write-Host "  .\stop-dev.ps1 -RemoveData  # 停止服务并删除所有数据"
    exit 0
}

Write-Host "🛑 停止重庆黑客松项目开发环境..." -ForegroundColor Red

# 检查Docker是否运行
function Test-Docker {
    try {
        $null = Get-Command docker -ErrorAction Stop
        $null = Get-Command docker-compose -ErrorAction Stop
        Write-Host "✅ Docker环境检查通过" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Docker未安装或未运行" -ForegroundColor Red
        exit 1
    }
}

# 停止服务
function Stop-Services {
    Write-Host "🔧 停止所有服务..." -ForegroundColor Blue
    
    try {
        & docker-compose down
        Write-Host "✅ 服务停止成功" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ 停止服务时发生错误: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# 删除数据卷
function Remove-DataVolumes {
    if ($RemoveData) {
        Write-Host ""
        Write-Host "⚠️  警告：即将删除所有数据卷！" -ForegroundColor Yellow
        Write-Host "   这将永久删除数据库数据、缓存数据等所有持久化数据" -ForegroundColor Yellow
        
        $confirm = Read-Host "确定要删除所有数据吗？请输入 'DELETE' 确认"
        
        if ($confirm -eq "DELETE") {
            Write-Host "🗑️  删除数据卷..." -ForegroundColor Red
            
            try {
                & docker-compose down -v
                & docker volume prune -f
                Write-Host "✅ 数据卷删除完成" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ 删除数据卷时发生错误: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "❌ 确认失败，取消删除数据卷" -ForegroundColor Yellow
        }
    }
}

# 清理未使用的Docker资源
function Clean-DockerResources {
    Write-Host "🧹 清理未使用的Docker资源..." -ForegroundColor Blue
    
    try {
        # 清理未使用的网络
        & docker network prune -f
        
        # 清理未使用的镜像（可选）
        $cleanImages = Read-Host "是否清理未使用的Docker镜像？(y/N)"
        if ($cleanImages -match '^[Yy]$') {
            & docker image prune -f
            Write-Host "✅ Docker镜像清理完成" -ForegroundColor Green
        }
        
        Write-Host "✅ Docker资源清理完成" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  清理Docker资源时发生错误，但不影响服务停止" -ForegroundColor Yellow
    }
}

# 显示停止后信息
function Show-StopInfo {
    Write-Host ""
    Write-Host "✅ 开发环境已停止" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📋 后续操作:" -ForegroundColor Blue
    Write-Host "   重新启动环境:     .\start-dev.ps1" -ForegroundColor White
    Write-Host "   查看Docker状态:   docker-compose ps" -ForegroundColor White
    Write-Host "   完全清理环境:     .\stop-dev.ps1 -RemoveData" -ForegroundColor White
    
    if (-not $RemoveData) {
        Write-Host ""
        Write-Host "💡 提示:" -ForegroundColor Yellow
        Write-Host "   - 数据已保留，下次启动时会恢复之前的数据" -ForegroundColor White
        Write-Host "   - 如需完全重置环境，请使用 -RemoveData 参数" -ForegroundColor White
    }
    else {
        Write-Host ""
        Write-Host "⚠️  注意:" -ForegroundColor Yellow
        Write-Host "   - 所有数据已删除，下次启动将是全新环境" -ForegroundColor White
        Write-Host "   - 数据库需要重新初始化" -ForegroundColor White
    }
}

# 主函数
function Main {
    Write-Host "重庆黑客松项目 - 开发环境停止" -ForegroundColor Blue
    Write-Host "==============================" -ForegroundColor Blue
    Write-Host ""
    
    try {
        Test-Docker
        Stop-Services
        Remove-DataVolumes
        Clean-DockerResources
        Show-StopInfo
        
        Write-Host ""
        Write-Host "👋 开发环境已安全停止！" -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Host "❌ 停止过程中发生错误: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "请检查错误信息并重试" -ForegroundColor Yellow
        exit 1
    }
}

# 执行主函数
Main