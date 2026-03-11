-- 尿了么智能健康检测应用数据库初始化脚本
-- 混合架构设计 - 支持从单体向微服务演进

-- 创建数据库
CREATE DATABASE IF NOT EXISTS niaolemo_core_db 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE niaolemo_core_db;

-- 创建用户
CREATE USER IF NOT EXISTS 'niaolemo_user'@'%' IDENTIFIED BY 'niaolemo_pass';
GRANT ALL PRIVILEGES ON niaolemo_core_db.* TO 'niaolemo_user'@'%';
FLUSH PRIVILEGES;

-- ================================
-- 用户管理模块
-- ================================

-- 用户基础信息表
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    uuid VARCHAR(36) NOT NULL UNIQUE COMMENT '用户唯一标识',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) UNIQUE COMMENT '邮箱',
    phone VARCHAR(20) UNIQUE COMMENT '手机号',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    salt VARCHAR(32) NOT NULL COMMENT '密码盐值',
    
    -- 个人信息
    nickname VARCHAR(50) COMMENT '昵称',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    gender ENUM('M', 'F', 'OTHER') COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    
    -- 健康基础信息（第一阶段内嵌）
    height DECIMAL(5,2) COMMENT '身高(cm)',
    weight DECIMAL(5,2) COMMENT '体重(kg)',
    medical_notes JSON COMMENT '简化的医疗信息',
    
    -- 注册方式
    register_type ENUM('USERNAME', 'PHONE', 'EMAIL', 'WECHAT', 'QQ', 'ALIPAY') NOT NULL DEFAULT 'USERNAME' COMMENT '注册方式',
    third_party_id VARCHAR(100) COMMENT '第三方平台用户ID',
    
    -- 状态管理
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'LOCKED') NOT NULL DEFAULT 'ACTIVE' COMMENT '用户状态',
    email_verified BOOLEAN NOT NULL DEFAULT FALSE COMMENT '邮箱是否验证',
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE COMMENT '手机号是否验证',
    
    -- 安全相关
    login_failure_count INT NOT NULL DEFAULT 0 COMMENT '登录失败次数',
    locked_until DATETIME COMMENT '锁定到期时间',
    last_login_at DATETIME COMMENT '最后登录时间',
    last_login_ip VARCHAR(45) COMMENT '最后登录IP',
    
    -- 审计字段
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME COMMENT '软删除时间',
    
    INDEX idx_uuid (uuid),
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_username (username),
    INDEX idx_status (status),
    INDEX idx_register_type (register_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户基础信息表';

-- 用户会话表（JWT黑名单）
CREATE TABLE user_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会话ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    token_hash VARCHAR(64) NOT NULL COMMENT 'JWT令牌哈希',
    token_type ENUM('ACCESS', 'REFRESH') NOT NULL DEFAULT 'ACCESS' COMMENT '令牌类型',
    expires_at DATETIME NOT NULL COMMENT '过期时间',
    revoked_at DATETIME COMMENT '撤销时间',
    device_info JSON COMMENT '设备信息',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    user_agent TEXT COMMENT '用户代理',
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_revoked_at (revoked_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户会话表';

-- ================================
-- 健康检测模块
-- ================================

-- 健康检测记录表
CREATE TABLE health_tests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '检测ID',
    uuid VARCHAR(36) NOT NULL UNIQUE COMMENT '检测唯一标识',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    
    -- 检测基本信息
    test_type ENUM('URINE', 'BLOOD', 'OTHER') NOT NULL DEFAULT 'URINE' COMMENT '检测类型',
    test_date DATETIME NOT NULL COMMENT '检测时间',
    sample_image_url VARCHAR(500) COMMENT '样本图片URL',
    
    -- 检测状态
    status ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED') NOT NULL DEFAULT 'PENDING' COMMENT '检测状态',
    progress INT NOT NULL DEFAULT 0 COMMENT '处理进度(0-100)',
    
    -- AI分析结果
    ai_analysis JSON COMMENT 'AI分析结果',
    confidence_score DECIMAL(3,2) COMMENT '置信度分数(0-1)',
    processing_time INT COMMENT '处理时间(毫秒)',
    
    -- 地理位置信息
    location_latitude DECIMAL(10,8) COMMENT '纬度',
    location_longitude DECIMAL(11,8) COMMENT '经度',
    location_address VARCHAR(200) COMMENT '地址描述',
    
    -- 审计字段
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME COMMENT '软删除时间',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_uuid (uuid),
    INDEX idx_test_date (test_date),
    INDEX idx_status (status),
    INDEX idx_test_type (test_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康检测记录表';

-- 检测结果详情表
CREATE TABLE test_results (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '结果ID',
    test_id BIGINT NOT NULL COMMENT '检测ID',
    
    -- 检测指标
    indicator_name VARCHAR(50) NOT NULL COMMENT '指标名称',
    indicator_value VARCHAR(100) COMMENT '指标值',
    reference_range VARCHAR(100) COMMENT '参考范围',
    unit VARCHAR(20) COMMENT '单位',
    
    -- 结果评估
    result_level ENUM('NORMAL', 'ABNORMAL', 'CRITICAL') NOT NULL DEFAULT 'NORMAL' COMMENT '结果等级',
    health_suggestion TEXT COMMENT '健康建议',
    
    -- 审计字段
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    FOREIGN KEY (test_id) REFERENCES health_tests(id) ON DELETE CASCADE,
    INDEX idx_test_id (test_id),
    INDEX idx_indicator_name (indicator_name),
    INDEX idx_result_level (result_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='检测结果详情表';

-- 分析报告表
CREATE TABLE analysis_reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '报告ID',
    test_id BIGINT NOT NULL COMMENT '检测ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    
    -- 报告内容
    report_title VARCHAR(100) NOT NULL COMMENT '报告标题',
    summary TEXT COMMENT '总结',
    detailed_analysis TEXT COMMENT '详细分析',
    health_recommendations TEXT COMMENT '健康建议',
    
    -- 报告状态
    status ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED') NOT NULL DEFAULT 'DRAFT' COMMENT '报告状态',
    
    -- 审计字段
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    FOREIGN KEY (test_id) REFERENCES health_tests(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_test_id (test_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分析报告表';

-- ================================
-- 位置服务模块
-- ================================

-- 厕所位置表
CREATE TABLE toilet_locations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '位置ID',
    uuid VARCHAR(36) NOT NULL UNIQUE COMMENT '位置唯一标识',
    
    -- 基本信息
    name VARCHAR(100) NOT NULL COMMENT '厕所名称',
    description TEXT COMMENT '描述',
    category ENUM('PUBLIC', 'COMMERCIAL', 'HOSPITAL', 'SCHOOL', 'OTHER') NOT NULL DEFAULT 'PUBLIC' COMMENT '类别',
    
    -- 地理位置
    latitude DECIMAL(10,8) NOT NULL COMMENT '纬度',
    longitude DECIMAL(11,8) NOT NULL COMMENT '经度',
    address VARCHAR(200) COMMENT '地址',
    city VARCHAR(50) COMMENT '城市',
    district VARCHAR(50) COMMENT '区域',
    
    -- 设施信息
    facilities JSON COMMENT '设施信息',
    accessibility_features JSON COMMENT '无障碍设施',
    opening_hours JSON COMMENT '开放时间',
    
    -- 状态信息
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
    verified BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否已验证',
    
    -- 统计信息
    rating_average DECIMAL(2,1) DEFAULT 0.0 COMMENT '平均评分',
    rating_count INT DEFAULT 0 COMMENT '评分数量',
    visit_count INT DEFAULT 0 COMMENT '访问次数',
    
    -- 审计字段
    created_by BIGINT COMMENT '创建者ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME COMMENT '软删除时间',
    
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_uuid (uuid),
    INDEX idx_location (latitude, longitude),
    INDEX idx_city_district (city, district),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_rating (rating_average),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='厕所位置表';

-- 厕所评价表
CREATE TABLE toilet_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评价ID',
    toilet_id BIGINT NOT NULL COMMENT '厕所ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    
    -- 评价内容
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5) COMMENT '评分(1-5)',
    title VARCHAR(100) COMMENT '评价标题',
    content TEXT COMMENT '评价内容',
    
    -- 评价维度
    cleanliness_rating INT CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5) COMMENT '清洁度评分',
    facilities_rating INT CHECK (facilities_rating >= 1 AND facilities_rating <= 5) COMMENT '设施评分',
    accessibility_rating INT CHECK (accessibility_rating >= 1 AND accessibility_rating <= 5) COMMENT '便利性评分',
    
    -- 图片和标签
    images JSON COMMENT '评价图片',
    tags JSON COMMENT '标签',
    
    -- 状态管理
    status ENUM('ACTIVE', 'HIDDEN', 'REPORTED') NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
    helpful_count INT DEFAULT 0 COMMENT '有用数',
    
    -- 审计字段
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at DATETIME COMMENT '软删除时间',
    
    FOREIGN KEY (toilet_id) REFERENCES toilet_locations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_toilet (user_id, toilet_id),
    INDEX idx_toilet_id (toilet_id),
    INDEX idx_user_id (user_id),
    INDEX idx_rating (rating),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='厕所评价表';

-- ================================
-- 系统管理模块
-- ================================

-- 系统配置表
CREATE TABLE system_configs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '配置ID',
    config_key VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    config_type ENUM('STRING', 'NUMBER', 'BOOLEAN', 'JSON') NOT NULL DEFAULT 'STRING' COMMENT '配置类型',
    description VARCHAR(200) COMMENT '配置描述',
    category VARCHAR(50) COMMENT '配置分类',
    
    -- 状态管理
    is_active BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    is_system BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否系统配置',
    
    -- 审计字段
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX idx_config_key (config_key),
    INDEX idx_category (category),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 操作日志表
CREATE TABLE operation_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id BIGINT COMMENT '操作用户ID',
    
    -- 操作信息
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型',
    operation_desc VARCHAR(200) COMMENT '操作描述',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_params TEXT COMMENT '请求参数',
    
    -- 响应信息
    response_status INT COMMENT '响应状态码',
    response_time INT COMMENT '响应时间(毫秒)',
    
    -- 环境信息
    ip_address VARCHAR(45) COMMENT 'IP地址',
    user_agent TEXT COMMENT '用户代理',
    device_info JSON COMMENT '设备信息',
    
    -- 审计字段
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_ip_address (ip_address),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- ================================
-- 初始化数据
-- ================================

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, config_type, description, category, is_system) VALUES
('app.name', '尿了么', 'STRING', '应用名称', 'app', TRUE),
('app.version', '1.0.0', 'STRING', '应用版本', 'app', TRUE),
('ai.model.version', 'glm-4.1v-9b', 'STRING', 'AI模型版本', 'ai', TRUE),
('ai.confidence.threshold', '0.8', 'NUMBER', 'AI置信度阈值', 'ai', TRUE),
('security.max.login.attempts', '5', 'NUMBER', '最大登录尝试次数', 'security', TRUE),
('security.lockout.duration', '900', 'NUMBER', '账户锁定时长(秒)', 'security', TRUE),
('business.max.tests.per.day', '10', 'NUMBER', '每日最大检测次数', 'business', TRUE),
('business.test.result.retention.days', '365', 'NUMBER', '检测结果保留天数', 'business', TRUE);

-- 创建索引优化查询性能
CREATE INDEX idx_users_login_composite ON users(username, status, deleted_at);
CREATE INDEX idx_health_tests_user_date ON health_tests(user_id, test_date DESC);
CREATE INDEX idx_toilet_locations_geo ON toilet_locations(latitude, longitude, status);

-- 创建视图简化查询
CREATE VIEW v_user_stats AS
SELECT 
    u.id,
    u.username,
    u.status,
    COUNT(ht.id) as total_tests,
    MAX(ht.test_date) as last_test_date,
    COUNT(tr.id) as total_reviews
FROM users u
LEFT JOIN health_tests ht ON u.id = ht.user_id AND ht.deleted_at IS NULL
LEFT JOIN toilet_reviews tr ON u.id = tr.user_id AND tr.deleted_at IS NULL
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.username, u.status;

-- 设置数据库参数
SET GLOBAL innodb_buffer_pool_size = 268435456; -- 256MB
SET GLOBAL max_connections = 200;
SET GLOBAL query_cache_size = 67108864; -- 64MB

COMMIT;