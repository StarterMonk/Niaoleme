-- ==========================================
-- 方案二：微服务架构数据库设计
-- 适用场景：中长期发展，多团队协作
-- ==========================================

-- ==========================================
-- 用户服务数据库 (user_service_db)
-- ==========================================

-- 用户基础信息表
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL COMMENT '全局用户标识',
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(32) NOT NULL,
    
    -- 基础信息
    nickname VARCHAR(50),
    avatar_url VARCHAR(500),
    gender ENUM('M', 'F', 'Other'),
    birth_date DATE,
    
    -- 账户状态
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    
    -- 时间戳
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_uuid (uuid),
    INDEX idx_email (email),
    INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户认证表
CREATE TABLE user_auth (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    auth_type ENUM('password', 'oauth', 'sms', 'email') NOT NULL,
    auth_provider VARCHAR(50) COMMENT 'OAuth提供商',
    provider_user_id VARCHAR(100) COMMENT '第三方用户ID',
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMP NULL,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_auth_type (auth_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户权限表
CREATE TABLE user_permissions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    permission_code VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_permission (user_id, permission_code, resource_type, resource_id),
    INDEX idx_permission_code (permission_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户会话表
CREATE TABLE user_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    device_uuid VARCHAR(36),
    device_info JSON,
    
    ip_address VARCHAR(45),
    user_agent TEXT,
    location_info JSON,
    
    is_active BOOLEAN DEFAULT TRUE,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session_token (session_token),
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 健康检测服务数据库 (health_service_db)
-- ==========================================

-- 用户健康档案表
CREATE TABLE user_health_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_uuid VARCHAR(36) UNIQUE NOT NULL COMMENT '关联用户服务的UUID',
    
    -- 基础健康信息
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    blood_type ENUM('A', 'B', 'AB', 'O', 'Unknown'),
    
    -- 医疗历史
    medical_history JSON,
    allergies JSON,
    current_medications JSON,
    chronic_conditions JSON,
    
    -- 生活习惯
    smoking_status ENUM('never', 'former', 'current'),
    drinking_status ENUM('never', 'occasional', 'regular', 'heavy'),
    exercise_frequency ENUM('never', 'rarely', 'sometimes', 'regularly', 'daily'),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_uuid (user_uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 检测任务表
CREATE TABLE health_tests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    user_uuid VARCHAR(36) NOT NULL,
    
    -- 检测信息
    test_type ENUM('urine_routine', 'urine_protein', 'urine_glucose', 'comprehensive') NOT NULL,
    test_date DATETIME NOT NULL,
    sample_collection_time DATETIME,
    
    -- 图像处理
    original_image_url VARCHAR(500),
    processed_image_url VARCHAR(500),
    image_metadata JSON,
    
    -- 处理状态
    status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    processing_pipeline JSON COMMENT '处理流水线信息',
    
    -- AI处理信息
    ai_model_version VARCHAR(20),
    processing_start_at TIMESTAMP NULL,
    processing_end_at TIMESTAMP NULL,
    processing_time_ms INT,
    
    -- 质量控制
    image_quality_score DECIMAL(3,2),
    confidence_score DECIMAL(3,2),
    quality_flags JSON,
    
    -- 环境信息
    location_data JSON,
    device_info JSON,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_user_uuid (user_uuid),
    INDEX idx_test_type (test_type),
    INDEX idx_status (status),
    INDEX idx_test_date (test_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 检测结果表
CREATE TABLE test_results (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    test_uuid VARCHAR(36) NOT NULL,
    
    -- 检测参数
    parameter_code VARCHAR(20) NOT NULL,
    parameter_name VARCHAR(50) NOT NULL,
    parameter_category VARCHAR(30),
    
    -- 结果值
    numeric_value DECIMAL(12, 4),
    text_value VARCHAR(100),
    unit VARCHAR(20),
    
    -- 参考范围
    reference_range JSON,
    normal_range_min DECIMAL(12, 4),
    normal_range_max DECIMAL(12, 4),
    
    -- 结果判断
    result_status ENUM('normal', 'low', 'high', 'abnormal', 'critical') NOT NULL,
    abnormal_flags JSON,
    
    -- 质量指标
    detection_confidence DECIMAL(3,2),
    measurement_quality ENUM('excellent', 'good', 'acceptable', 'poor'),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_test_uuid (test_uuid),
    INDEX idx_parameter_code (parameter_code),
    INDEX idx_result_status (result_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI分析结果表
CREATE TABLE ai_analysis (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    test_uuid VARCHAR(36) NOT NULL,
    
    -- 分析内容
    summary TEXT,
    detailed_analysis TEXT,
    risk_assessment JSON,
    
    -- 建议
    health_recommendations TEXT,
    lifestyle_suggestions TEXT,
    medical_advice TEXT,
    
    -- 风险等级
    overall_risk_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
    urgency_level ENUM('routine', 'soon', 'urgent', 'emergency') DEFAULT 'routine',
    
    -- 趋势分析
    trend_data JSON,
    historical_comparison JSON,
    
    -- 元数据
    analysis_model_version VARCHAR(20),
    analysis_confidence DECIMAL(3,2),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_test_uuid (test_uuid),
    INDEX idx_risk_level (overall_risk_level),
    INDEX idx_urgency_level (urgency_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 地理位置服务数据库 (location_service_db)
-- ==========================================

-- 厕所位置表
CREATE TABLE toilet_locations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    
    -- 基础信息
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category ENUM('public', 'commercial', 'hospital', 'school', 'mall', 'gas_station', 'other') DEFAULT 'public',
    
    -- 地理位置
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    altitude DECIMAL(8, 2),
    
    -- 地址信息
    country VARCHAR(50),
    province VARCHAR(50),
    city VARCHAR(50),
    district VARCHAR(50),
    street_address VARCHAR(500),
    postal_code VARCHAR(20),
    
    -- 设施信息
    facilities JSON COMMENT '设施详情',
    accessibility_features JSON COMMENT '无障碍设施',
    amenities JSON COMMENT '便民设施',
    
    -- 运营信息
    opening_hours JSON,
    is_24_hours BOOLEAN DEFAULT FALSE,
    is_free BOOLEAN DEFAULT TRUE,
    pricing_info JSON,
    contact_info JSON,
    
    -- 评价统计
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INT DEFAULT 0,
    rating_breakdown JSON COMMENT '各维度评分',
    
    -- 状态管理
    status ENUM('active', 'inactive', 'maintenance', 'permanently_closed') DEFAULT 'active',
    verification_status ENUM('unverified', 'pending', 'verified', 'rejected') DEFAULT 'unverified',
    
    -- 数据来源
    data_source VARCHAR(50),
    contributor_uuid VARCHAR(36),
    last_verified_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    SPATIAL INDEX idx_location (POINT(longitude, latitude)),
    INDEX idx_city_district (city, district),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 地理区域表
CREATE TABLE geographic_regions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    region_code VARCHAR(20) UNIQUE NOT NULL,
    region_name VARCHAR(100) NOT NULL,
    region_type ENUM('country', 'province', 'city', 'district', 'custom') NOT NULL,
    parent_region_code VARCHAR(20),
    
    -- 边界信息
    boundary_polygon GEOMETRY,
    center_latitude DECIMAL(10, 8),
    center_longitude DECIMAL(11, 8),
    
    -- 统计信息
    toilet_count INT DEFAULT 0,
    population BIGINT,
    area_km2 DECIMAL(10, 2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_parent_region (parent_region_code),
    INDEX idx_region_type (region_type),
    SPATIAL INDEX idx_boundary (boundary_polygon)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 社交互动服务数据库 (social_service_db)
-- ==========================================

-- 用户评价表
CREATE TABLE toilet_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    toilet_uuid VARCHAR(36) NOT NULL,
    user_uuid VARCHAR(36) NOT NULL,
    
    -- 评价内容
    overall_rating TINYINT NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    cleanliness_rating TINYINT CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
    accessibility_rating TINYINT CHECK (accessibility_rating >= 1 AND accessibility_rating <= 5),
    facilities_rating TINYINT CHECK (facilities_rating >= 1 AND facilities_rating <= 5),
    
    review_title VARCHAR(200),
    review_content TEXT,
    
    -- 媒体内容
    photos JSON,
    videos JSON,
    
    -- 标签和分类
    tags JSON,
    visit_purpose ENUM('routine', 'emergency', 'convenience', 'other'),
    visit_time DATETIME,
    
    -- 互动统计
    helpful_count INT DEFAULT 0,
    unhelpful_count INT DEFAULT 0,
    reply_count INT DEFAULT 0,
    
    -- 状态管理
    status ENUM('active', 'hidden', 'reported', 'deleted') DEFAULT 'active',
    moderation_status ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_toilet_uuid (toilet_uuid),
    INDEX idx_user_uuid (user_uuid),
    INDEX idx_overall_rating (overall_rating),
    INDEX idx_created_at (created_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 评价互动表
CREATE TABLE review_interactions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    review_uuid VARCHAR(36) NOT NULL,
    user_uuid VARCHAR(36) NOT NULL,
    interaction_type ENUM('helpful', 'unhelpful', 'report', 'share') NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_review_interaction (user_uuid, review_uuid, interaction_type),
    INDEX idx_review_uuid (review_uuid),
    INDEX idx_interaction_type (interaction_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 成就系统表
CREATE TABLE achievements (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    
    -- 成就条件
    trigger_conditions JSON,
    progress_tracking JSON,
    
    -- 奖励信息
    points_reward INT DEFAULT 0,
    badge_icon VARCHAR(200),
    badge_color VARCHAR(7),
    
    -- 稀有度和显示
    rarity ENUM('common', 'uncommon', 'rare', 'epic', 'legendary') DEFAULT 'common',
    display_order INT DEFAULT 0,
    
    -- 状态
    is_active BOOLEAN DEFAULT TRUE,
    is_hidden BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_rarity (rarity),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户成就记录表
CREATE TABLE user_achievements (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_uuid VARCHAR(36) NOT NULL,
    achievement_code VARCHAR(50) NOT NULL,
    
    -- 获得信息
    progress_data JSON,
    completion_percentage DECIMAL(5,2) DEFAULT 0.0,
    
    -- 状态
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    is_claimed BOOLEAN DEFAULT FALSE,
    claimed_at TIMESTAMP NULL,
    
    -- 奖励
    points_earned INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_achievement (user_uuid, achievement_code),
    INDEX idx_user_uuid (user_uuid),
    INDEX idx_is_completed (is_completed),
    INDEX idx_completed_at (completed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户积分表
CREATE TABLE user_points (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_uuid VARCHAR(36) UNIQUE NOT NULL,
    
    -- 积分统计
    total_points INT DEFAULT 0,
    available_points INT DEFAULT 0,
    used_points INT DEFAULT 0,
    
    -- 等级信息
    current_level INT DEFAULT 1,
    level_progress DECIMAL(5,2) DEFAULT 0.0,
    
    -- 统计信息
    points_earned_today INT DEFAULT 0,
    points_earned_this_week INT DEFAULT 0,
    points_earned_this_month INT DEFAULT 0,
    
    last_earned_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_total_points (total_points),
    INDEX idx_current_level (current_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 系统管理服务数据库 (system_service_db)
-- ==========================================

-- 系统配置表
CREATE TABLE system_configs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(50) NOT NULL,
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT,
    config_type ENUM('string', 'number', 'boolean', 'json', 'encrypted') DEFAULT 'string',
    
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    is_encrypted BOOLEAN DEFAULT FALSE,
    
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_service_config (service_name, config_key),
    INDEX idx_service_name (service_name),
    INDEX idx_is_public (is_public)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 服务间通信日志表
CREATE TABLE service_communication_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- 请求信息
    request_id VARCHAR(36) NOT NULL,
    source_service VARCHAR(50) NOT NULL,
    target_service VARCHAR(50) NOT NULL,
    
    -- API信息
    api_endpoint VARCHAR(200) NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    request_payload JSON,
    
    -- 响应信息
    response_status INT,
    response_payload JSON,
    response_time_ms INT,
    
    -- 错误信息
    error_code VARCHAR(50),
    error_message TEXT,
    
    -- 追踪信息
    trace_id VARCHAR(36),
    span_id VARCHAR(36),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_request_id (request_id),
    INDEX idx_source_service (source_service),
    INDEX idx_target_service (target_service),
    INDEX idx_trace_id (trace_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;