#!/bin/bash

# 重庆黑客松项目开发环境启动脚本
# 作者: hackthon-team

set -e

echo "🚀 启动重庆黑客松项目开发环境..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安装，请先安装Docker${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose未安装，请先安装Docker Compose${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker环境检查通过${NC}"
}

# 检查端口占用
check_ports() {
    local ports=(3306 6379 5672 9000 9090 3000 8080)
    local occupied_ports=()
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            occupied_ports+=($port)
        fi
    done
    
    if [ ${#occupied_ports[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  以下端口被占用: ${occupied_ports[*]}${NC}"
        echo -e "${YELLOW}   如果是其他实例，请先停止相关服务${NC}"
        read -p "是否继续启动？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 创建必要的目录
create_directories() {
    echo -e "${BLUE}📁 创建必要的目录...${NC}"
    
    mkdir -p logs
    mkdir -p data/mysql
    mkdir -p data/redis
    mkdir -p data/minio
    mkdir -p monitoring
    
    echo -e "${GREEN}✅ 目录创建完成${NC}"
}

# 启动基础服务
start_infrastructure() {
    echo -e "${BLUE}🔧 启动基础服务 (MySQL, Redis, RabbitMQ, MinIO)...${NC}"
    
    docker-compose up -d mysql redis rabbitmq minio
    
    echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
    sleep 10
    
    # 检查服务状态
    if docker-compose ps | grep -q "Up"; then
        echo -e "${GREEN}✅ 基础服务启动成功${NC}"
    else
        echo -e "${RED}❌ 基础服务启动失败${NC}"
        docker-compose logs
        exit 1
    fi
}

# 启动监控服务
start_monitoring() {
    echo -e "${BLUE}📊 启动监控服务 (Prometheus, Grafana)...${NC}"
    
    docker-compose up -d prometheus grafana
    
    echo -e "${GREEN}✅ 监控服务启动成功${NC}"
}

# 等待数据库就绪
wait_for_database() {
    echo -e "${BLUE}⏳ 等待数据库就绪...${NC}"
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose exec -T mysql mysql -u root -proot123 -e "SELECT 1" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ 数据库已就绪${NC}"
            return 0
        fi
        
        echo -e "${YELLOW}   尝试 $attempt/$max_attempts...${NC}"
        sleep 2
        ((attempt++))
    done
    
    echo -e "${RED}❌ 数据库启动超时${NC}"
    exit 1
}

# 初始化数据库
init_database() {
    echo -e "${BLUE}🗄️  初始化数据库...${NC}"
    
    # 检查数据库是否已初始化
    if docker-compose exec -T mysql mysql -u hackthon_user -phackthon_pass hackthon_core_dev -e "SHOW TABLES" 2>/dev/null | grep -q "users"; then
        echo -e "${YELLOW}⚠️  数据库已初始化，跳过初始化步骤${NC}"
        return 0
    fi
    
    # 执行数据库初始化脚本
    if [ -f "database_design_hybrid.sql" ]; then
        docker-compose exec -T mysql mysql -u hackthon_user -phackthon_pass hackthon_core_dev < database_design_hybrid.sql
        echo -e "${GREEN}✅ 数据库初始化完成${NC}"
    else
        echo -e "${YELLOW}⚠️  数据库初始化脚本不存在，请手动初始化${NC}"
    fi
}

# 启动应用（可选）
start_application() {
    read -p "是否启动Spring Boot应用？(y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🚀 启动Spring Boot应用...${NC}"
        
        cd stage1-core
        
        # 检查Maven是否安装
        if command -v ./mvnw &> /dev/null; then
            ./mvnw spring-boot:run &
        elif command -v mvn &> /dev/null; then
            mvn spring-boot:run &
        else
            echo -e "${RED}❌ Maven未安装，请手动启动应用${NC}"
            return 1
        fi
        
        cd ..
        echo -e "${GREEN}✅ 应用启动中...${NC}"
    else
        echo -e "${YELLOW}💡 你可以稍后手动启动应用:${NC}"
        echo -e "${YELLOW}   cd stage1-core && ./mvnw spring-boot:run${NC}"
    fi
}

# 显示服务信息
show_services_info() {
    echo -e "\n${GREEN}🎉 开发环境启动完成！${NC}\n"
    
    echo -e "${BLUE}📋 服务访问地址:${NC}"
    echo -e "   🌐 API文档:        http://localhost:8080/doc.html"
    echo -e "   🔧 应用监控:       http://localhost:8081/actuator"
    echo -e "   🗄️  数据库管理:     http://localhost:8080/druid (admin/admin123)"
    echo -e "   🐰 RabbitMQ管理:   http://localhost:15672 (guest/guest)"
    echo -e "   📦 MinIO控制台:    http://localhost:9001 (minioadmin/minioadmin)"
    echo -e "   📊 Prometheus:     http://localhost:9090"
    echo -e "   📈 Grafana:        http://localhost:3000 (admin/admin123)"
    
    echo -e "\n${BLUE}🔧 常用命令:${NC}"
    echo -e "   查看服务状态:      docker-compose ps"
    echo -e "   查看应用日志:      docker-compose logs -f app-core"
    echo -e "   停止所有服务:      docker-compose down"
    echo -e "   重启服务:          docker-compose restart <service-name>"
    
    echo -e "\n${BLUE}📚 开发文档:${NC}"
    echo -e "   项目README:        ./README.md"
    echo -e "   数据库设计:        ./database_design_hybrid.sql"
    echo -e "   API接口文档:       启动应用后访问 http://localhost:8080/doc.html"
    
    echo -e "\n${YELLOW}💡 提示:${NC}"
    echo -e "   - 首次启动可能需要下载Docker镜像，请耐心等待"
    echo -e "   - 如遇到问题，请查看 docker-compose logs 获取详细日志"
    echo -e "   - 生产环境部署请参考 README.md 中的部署指南"
}

# 主函数
main() {
    echo -e "${BLUE}重庆黑客松项目 - 智能健康检测应用${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    
    check_docker
    check_ports
    create_directories
    start_infrastructure
    wait_for_database
    init_database
    start_monitoring
    start_application
    show_services_info
    
    echo -e "\n${GREEN}🚀 开发环境已就绪，开始你的开发之旅吧！${NC}"
}

# 错误处理
trap 'echo -e "\n${RED}❌ 启动过程中发生错误${NC}"; exit 1' ERR

# 执行主函数
main "$@"