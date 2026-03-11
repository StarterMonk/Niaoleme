-- ==========================================
-- 方案一：单体架构数据库设计
-- 适用场景：初期开发，用户量 < 10万
-- ==========================================

-- 1. 用户管理表
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL COMMENT '用户唯一标识',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    email VARCHAR(100) UNIQUE NOT NULL COMMENT '邮箱',
    phone VARCHAR(20) UNIQUE COMMENT '手机号',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    salt VARCHAR(32) NOT NULL COMMENT '密码盐值',
    
    -- 个人信息
    nickname VARCHAR(50) COMMENT '昵称',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    gender ENUM('M', 'F', 'Other') COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    height DECIMAL(5,2) COMMENT '身高(cm)',
    weight DECIMAL(5,2) COMMENT '体重(kg)',
    
    -- 健康档案
    medical_history JSON COMMENT '病史记录',
    allergies JSON COMMENT '过敏史',
    medications JSON COMMENT '用药记录',
    
    -- 系统字段
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL COMMENT '软删除时间',
    
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_uuid (uuid),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户基础信息表';

-- 2. 设备管理表
CREATE TABLE user_devices (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    device_uuid VARCHAR(36) UNIQUE NOT NULL COMMENT '设备唯一标识',
    device_name VARCHAR(100) COMMENT '设备名称',
    device_type ENUM('android', 'ios', 'web') NOT NULL,
    device_model VARCHAR(100) COMMENT '设备型号',
    os_version VARCHAR(50) COMMENT '系统版本',
    app_version VARCHAR(20) COMMENT '应用版本',
    
    -- 设备状态
    is_primary BOOLEAN DEFAULT FALSE COMMENT '是否主设备',
    push_token VARCHAR(500) COMMENT '推送令牌',
    last_active_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_device_uuid (device_uuid),
    INDEX idx_device_type (device_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户设备表';

-- 3. 尿液检测记录表
CREATE TABLE urine_tests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL COMMENT '检测唯一标识',
    user_id BIGINT NOT NULL,
    device_id BIGINT COMMENT '检测设备ID',
    
    -- 检测基本信息
    test_type ENUM('routine', 'protein', 'glucose', 'comprehensive') DEFAULT 'routine',
    test_date DATETIME NOT NULL COMMENT '检测时间',
    sample_collection_time DATETIME COMMENT '样本采集时间',
    
    -- 图像信息
    original_image_url VARCHAR(500) COMMENT '原始图片URL',
    processed_image_url VARCHAR(500) COMMENT '处理后图片URL',
    image_quality_score DECIMAL(3,2) COMMENT '图像质量评分(0-1)',
    
    -- 检测状态
    status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    processing_start_at TIMESTAMP NULL,
    processing_end_at TIMESTAMP NULL,
    
    -- AI分析信息
    ai_model_version VARCHAR(20) COMMENT 'AI模型版本',
    confidence_score DECIMAL(3,2) COMMENT '置信度(0-1)',
    processing_time_ms INT COMMENT '处理耗时(毫秒)',
    
    -- 环境信息
    location_latitude DECIMAL(10, 8) COMMENT '检测位置纬度',
    location_longitude DECIMAL(11, 8) COMMENT '检测位置经度',
    location_name VARCHAR(200) COMMENT '检测位置名称',
    
    -- 备注信息
    user_notes TEXT COMMENT '用户备注',
    symptoms JSON COMMENT '症状记录',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES user_devices(id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_test_date (test_date),
    INDEX idx_status (status),
    INDEX idx_uuid (uuid),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='尿液检测记录表';

-- 4. 检测结果详情表
CREATE TABLE test_results (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    test_id BIGINT NOT NULL,
    
    -- 检测项目
    parameter_name VARCHAR(50) NOT NULL COMMENT '检测参数名称',
    parameter_code VARCHAR(20) NOT NULL COMMENT '参数代码',
    
    -- 检测结果
    result_value DECIMAL(10, 4) COMMENT '数值结果',
    result_text VARCHAR(100) COMMENT '文本结果',
    result_unit VARCHAR(20) COMMENT '单位',
    
    -- 参考范围
    reference_min DECIMAL(10, 4) COMMENT '参考值下限',
    reference_max DECIMAL(10, 4) COMMENT '参考值上限',
    reference_text VARCHAR(100) COMMENT '参考值文本',
    
    -- 结果判断
    status ENUM('normal', 'low', 'high', 'abnormal', 'critical') NOT NULL,
    abnormal_flag BOOLEAN DEFAULT FALSE COMMENT '异常标记',
    
    -- 质量控制
    detection_confidence DECIMAL(3,2) COMMENT '检测置信度',
    quality_flag ENUM('good', 'acceptable', 'poor') DEFAULT 'good',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (test_id) REFERENCES urine_tests(id) ON DELETE CASCADE,
    
    INDEX idx_test_id (test_id),
    INDEX idx_parameter_code (parameter_code),
    INDEX idx_status (status),
    INDEX idx_abnormal_flag (abnormal_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='检测结果详情表';

-- 5. AI分析报告表
CREATE TABLE analysis_reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    test_id BIGINT NOT NULL,
    
    -- 报告内容
    summary TEXT COMMENT '检测总结',
    detailed_analysis TEXT COMMENT '详细分析',
    health_suggestions TEXT COMMENT '健康建议',
    lifestyle_recommendations TEXT COMMENT '生活方式建议',
    
    -- 风险评估
    overall_risk_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
    risk_factors JSON COMMENT '风险因素列表',
    
    -- 趋势分析
    trend_analysis JSON COMMENT '趋势分析数据',
    comparison_with_previous JSON COMMENT '与历史数据对比',
    
    -- 就医建议
    medical_advice TEXT COMMENT '就医建议',
    urgency_level ENUM('routine', 'soon', 'urgent', 'emergency') DEFAULT 'routine',
    recommended_specialists JSON COMMENT '推荐专科',
    
    -- 报告元数据
    report_version VARCHAR(10) DEFAULT '1.0',
    generated_by VARCHAR(50) DEFAULT 'AI_SYSTEM',
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_by VARCHAR(50) COMMENT '审核医生',
    reviewed_at TIMESTAMP NULL,
    
    FOREIGN KEY (test_id) REFERENCES urine_tests(id) ON DELETE CASCADE,
    
    INDEX idx_test_id (test_id),
    INDEX idx_risk_level (overall_risk_level),
    INDEX idx_urgency_level (urgency_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI分析报告表';

-- 6. 厕所位置信息表
CREATE TABLE toilet_locations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    
    -- 基本信息
    name VARCHAR(100) NOT NULL COMMENT '厕所名称',
    description TEXT COMMENT '描述信息',
    category ENUM('public', 'commercial', 'hospital', 'school', 'other') DEFAULT 'public',
    
    -- 地理位置
    latitude DECIMAL(10, 8) NOT NULL COMMENT '纬度',
    longitude DECIMAL(11, 8) NOT NULL COMMENT '经度',
    address VARCHAR(500) COMMENT '详细地址',
    city VARCHAR(50) COMMENT '城市',
    district VARCHAR(50) COMMENT '区域',
    
    -- 设施信息
    facilities JSON COMMENT '设施信息(无障碍、母婴室等)',
    opening_hours JSON COMMENT '开放时间',
    is_free BOOLEAN DEFAULT TRUE COMMENT '是否免费',
    price DECIMAL(5,2) COMMENT '收费价格',
    
    -- 评价信息
    rating DECIMAL(3,2) DEFAULT 0.0 COMMENT '平均评分',
    review_count INT DEFAULT 0 COMMENT '评价数量',
    cleanliness_score DECIMAL(3,2) DEFAULT 0.0 COMMENT '清洁度评分',
    
    -- 状态信息
    status ENUM('active', 'inactive', 'maintenance', 'closed') DEFAULT 'active',
    verified BOOLEAN DEFAULT FALSE COMMENT '是否已验证',
    
    -- 数据来源
    data_source VARCHAR(50) COMMENT '数据来源',
    contributor_id BIGINT COMMENT '贡献者ID',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (contributor_id) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_location (latitude, longitude),
    INDEX idx_city_district (city, district),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='厕所位置信息表';

-- 7. 用户评价表
CREATE TABLE toilet_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    toilet_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    
    -- 评价内容
    rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    cleanliness_rating TINYINT CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
    accessibility_rating TINYINT CHECK (accessibility_rating >= 1 AND accessibility_rating <= 5),
    
    review_text TEXT COMMENT '评价内容',
    photos JSON COMMENT '评价图片',
    
    -- 标签
    tags JSON COMMENT '标签(干净、拥挤、设施好等)',
    
    -- 状态
    status ENUM('active', 'hidden', 'reported') DEFAULT 'active',
    helpful_count INT DEFAULT 0 COMMENT '有用数',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (toilet_id) REFERENCES toilet_locations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE KEY uk_user_toilet (user_id, toilet_id),
    INDEX idx_toilet_id (toilet_id),
    INDEX idx_rating (rating),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='厕所评价表';

-- 8. 成就系统表
CREATE TABLE achievements (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL COMMENT '成就代码',
    name VARCHAR(100) NOT NULL COMMENT '成就名称',
    description TEXT COMMENT '成就描述',
    category VARCHAR(50) COMMENT '成就分类',
    
    -- 成就条件
    conditions JSON COMMENT '达成条件',
    points INT DEFAULT 0 COMMENT '积分奖励',
    badge_icon VARCHAR(200) COMMENT '徽章图标',
    
    -- 稀有度
    rarity ENUM('common', 'rare', 'epic', 'legendary') DEFAULT 'common',
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_rarity (rarity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='成就定义表';

-- 9. 用户成就记录表
CREATE TABLE user_achievements (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    achievement_id BIGINT NOT NULL,
    
    -- 获得信息
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress JSON COMMENT '进度信息',
    
    -- 奖励信息
    points_earned INT DEFAULT 0,
    is_claimed BOOLEAN DEFAULT FALSE COMMENT '是否已领取奖励',
    claimed_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE,
    
    UNIQUE KEY uk_user_achievement (user_id, achievement_id),
    INDEX idx_user_id (user_id),
    INDEX idx_earned_at (earned_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户成就记录表';

-- 10. 系统配置表
CREATE TABLE system_configs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    config_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否对客户端公开',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_config_key (config_key),
    INDEX idx_is_public (is_public)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 11. 操作日志表
CREATE TABLE operation_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT,
    
    -- 操作信息
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型',
    operation_desc VARCHAR(200) COMMENT '操作描述',
    
    -- 请求信息
    request_method VARCHAR(10) COMMENT 'HTTP方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_params JSON COMMENT '请求参数',
    
    -- 响应信息
    response_status INT COMMENT '响应状态码',
    response_time_ms INT COMMENT '响应时间(毫秒)',
    
    -- 客户端信息
    client_ip VARCHAR(45) COMMENT '客户端IP',
    user_agent TEXT COMMENT '用户代理',
    device_info JSON COMMENT '设备信息',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_created_at (created_at),
    INDEX idx_client_ip (client_ip)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';