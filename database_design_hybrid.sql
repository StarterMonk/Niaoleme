-- ==========================================
-- 方案三：混合架构数据库设计
-- 适用场景：渐进式演进，风险可控
-- ==========================================

-- ==========================================
-- 第一阶段：核心功能单库设计
-- 数据库名：app_core_db
-- ==========================================

-- 用户核心表（增强版）
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL COMMENT '用户唯一标识',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    email VARCHAR(100) UNIQUE COMMENT '邮箱',
    phone VARCHAR(20) UNIQUE COMMENT '手机号',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    salt VARCHAR(32) NOT NULL COMMENT '密码盐值',
    
    -- 基础信息
    nickname VARCHAR(50) COMMENT '昵称',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    gender ENUM('M', 'F', 'Other') COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    
    -- 健康基础信息（第一阶段内嵌）
    height DECIMAL(5,2) COMMENT '身高(cm)',
    weight DECIMAL(5,2) COMMENT '体重(kg)',
    medical_notes JSON COMMENT '简化的医疗信息',
    
    -- 注册方式
    register_type ENUM('USERNAME', 'PHONE', 'EMAIL', 'WECHAT', 'QQ', 'ALIPAY') DEFAULT 'USERNAME' COMMENT '注册方式',
    third_party_id VARCHAR(100) COMMENT '第三方平台用户ID',
    
    -- 状态管理
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'LOCKED') DEFAULT 'ACTIVE' COMMENT '用户状态',
    email_verified BOOLEAN DEFAULT FALSE COMMENT '邮箱是否验证',
    phone_verified BOOLEAN DEFAULT FALSE COMMENT '手机号是否验证',
    
    -- 安全相关
    login_failure_count INT DEFAULT 0 COMMENT '登录失败次数',
    locked_until TIMESTAMP NULL COMMENT '锁定到期时间',
    last_login_at TIMESTAMP NULL COMMENT '最后登录时间',
    last_login_ip VARCHAR(45) COMMENT '最后登录IP',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at TIMESTAMP NULL COMMENT '软删除时间',
    
    INDEX idx_uuid (uuid),
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_username (username),
    INDEX idx_status (status),
    INDEX idx_register_type (register_type),
    INDEX idx_third_party_id (third_party_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户核心信息表';

-- 检测记录表（核心功能）
CREATE TABLE health_tests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,
    
    -- 检测基础信息
    test_type ENUM('urine_routine', 'urine_protein', 'comprehensive') DEFAULT 'urine_routine',
    test_date DATETIME NOT NULL,
    
    -- 图像信息
    original_image_url VARCHAR(500),
    processed_image_url VARCHAR(500),
    image_quality_score DECIMAL(3,2),
    
    -- 处理状态
    status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
    ai_model_version VARCHAR(20),
    confidence_score DECIMAL(3,2),
    
    -- 简化的位置信息
    location_name VARCHAR(200),
    location_coordinates JSON,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_test_date (test_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康检测记录表';

-- 检测结果表
CREATE TABLE test_results (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    test_id BIGINT NOT NULL,
    
    parameter_code VARCHAR(20) NOT NULL,
    parameter_name VARCHAR(50) NOT NULL,
    result_value DECIMAL(10, 4),
    result_unit VARCHAR(20),
    
    -- 参考范围
    normal_min DECIMAL(10, 4),
    normal_max DECIMAL(10, 4),
    
    -- 结果状态
    status ENUM('normal', 'abnormal', 'critical') NOT NULL,
    confidence DECIMAL(3,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (test_id) REFERENCES health_tests(id) ON DELETE CASCADE,
    INDEX idx_test_id (test_id),
    INDEX idx_parameter_code (parameter_code),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='检测结果详情表';

-- 简化的分析报告表
CREATE TABLE analysis_reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    test_id BIGINT NOT NULL,
    
    summary TEXT,
    recommendations TEXT,
    risk_level ENUM('low', 'medium', 'high') DEFAULT 'low',
    
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (test_id) REFERENCES health_tests(id) ON DELETE CASCADE,
    INDEX idx_test_id (test_id),
    INDEX idx_risk_level (risk_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI分析报告表';

-- 基础厕所位置表
CREATE TABLE toilet_locations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    
    name VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address VARCHAR(500),
    
    -- 基础信息
    category ENUM('public', 'commercial', 'other') DEFAULT 'public',
    is_free BOOLEAN DEFAULT TRUE,
    
    -- 简化评价
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INT DEFAULT 0,
    
    status ENUM('active', 'inactive') DEFAULT 'active',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_location (latitude, longitude),
    INDEX idx_category (category),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='厕所位置基础表';

-- 用户评价表（简化版）
CREATE TABLE toilet_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    toilet_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    
    rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (toilet_id) REFERENCES toilet_locations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE KEY uk_user_toilet (user_id, toilet_id),
    INDEX idx_toilet_id (toilet_id),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='厕所评价表';

-- 系统配置表
CREATE TABLE system_configs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    config_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- ==========================================
-- 第二阶段：业务拆分设计
-- 新增地理位置服务数据库：location_service_db
-- ==========================================

-- 迁移并扩展厕所位置表
CREATE TABLE enhanced_toilet_locations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    
    -- 从核心库迁移的基础字段
    name VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address VARCHAR(500),
    category ENUM('public', 'commercial', 'hospital', 'school', 'mall', 'other') DEFAULT 'public',
    
    -- 新增的详细信息
    description TEXT,
    facilities JSON COMMENT '设施详情',
    opening_hours JSON COMMENT '营业时间',
    contact_info JSON COMMENT '联系方式',
    
    -- 增强的评价系统
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INT DEFAULT 0,
    cleanliness_score DECIMAL(3,2) DEFAULT 0.0,
    accessibility_score DECIMAL(3,2) DEFAULT 0.0,
    
    -- 运营信息
    is_free BOOLEAN DEFAULT TRUE,
    pricing_info JSON,
    verification_status ENUM('unverified', 'verified') DEFAULT 'unverified',
    
    -- 数据来源追踪
    migrated_from_core BOOLEAN DEFAULT FALSE COMMENT '是否从核心库迁移',
    core_db_id BIGINT COMMENT '核心库中的原始ID',
    
    status ENUM('active', 'inactive', 'maintenance') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    SPATIAL INDEX idx_location (POINT(longitude, latitude)),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_core_db_id (core_db_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='增强版厕所位置表';

-- 详细评价表（地理服务）
CREATE TABLE detailed_toilet_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    toilet_uuid VARCHAR(36) NOT NULL,
    user_uuid VARCHAR(36) NOT NULL COMMENT '关联核心库用户UUID',
    
    -- 多维度评分
    overall_rating TINYINT NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    cleanliness_rating TINYINT CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
    accessibility_rating TINYINT CHECK (accessibility_rating >= 1 AND accessibility_rating <= 5),
    facilities_rating TINYINT CHECK (facilities_rating >= 1 AND facilities_rating <= 5),
    
    -- 详细内容
    review_title VARCHAR(200),
    review_content TEXT,
    photos JSON COMMENT '评价图片',
    tags JSON COMMENT '标签',
    
    -- 互动统计
    helpful_count INT DEFAULT 0,
    reply_count INT DEFAULT 0,
    
    -- 数据迁移标记
    migrated_from_core BOOLEAN DEFAULT FALSE,
    core_db_id BIGINT,
    
    status ENUM('active', 'hidden', 'reported') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_toilet_uuid (toilet_uuid),
    INDEX idx_user_uuid (user_uuid),
    INDEX idx_overall_rating (overall_rating),
    INDEX idx_core_db_id (core_db_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='详细厕所评价表';

-- ==========================================
-- 第三阶段：完全微服务架构
-- 健康服务独立：health_service_db
-- ==========================================

-- 独立的用户健康档案表
CREATE TABLE user_health_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_uuid VARCHAR(36) UNIQUE NOT NULL COMMENT '关联核心用户UUID',
    
    -- 详细健康信息
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    bmi DECIMAL(4,2) GENERATED ALWAYS AS (weight / ((height/100) * (height/100))) STORED,
    blood_type ENUM('A', 'B', 'AB', 'O', 'Unknown'),
    
    -- 详细医疗历史
    chronic_conditions JSON,
    allergies JSON,
    current_medications JSON,
    family_medical_history JSON,
    
    -- 生活方式
    smoking_status ENUM('never', 'former', 'current'),
    alcohol_consumption ENUM('never', 'occasional', 'moderate', 'heavy'),
    exercise_frequency ENUM('sedentary', 'light', 'moderate', 'active', 'very_active'),
    diet_preferences JSON,
    
    -- 数据迁移信息
    migrated_from_core BOOLEAN DEFAULT FALSE,
    core_basic_info JSON COMMENT '从核心库迁移的基础信息',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_uuid (user_uuid),
    INDEX idx_bmi (bmi)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户健康档案表';

-- 增强的检测记录表
CREATE TABLE enhanced_health_tests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    user_uuid VARCHAR(36) NOT NULL,
    
    -- 检测信息
    test_type ENUM('urine_routine', 'urine_protein', 'urine_glucose', 'comprehensive', 'custom') NOT NULL,
    test_subtype VARCHAR(50) COMMENT '检测子类型',
    test_date DATETIME NOT NULL,
    sample_collection_time DATETIME,
    
    -- 图像处理
    original_image_url VARCHAR(500),
    processed_image_url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    image_metadata JSON,
    
    -- AI处理信息
    ai_pipeline_version VARCHAR(20),
    processing_stages JSON COMMENT '处理阶段信息',
    quality_metrics JSON COMMENT '质量指标',
    
    -- 环境和上下文
    environmental_conditions JSON COMMENT '环境条件',
    user_reported_symptoms JSON COMMENT '用户报告症状',
    pre_test_conditions JSON COMMENT '检测前条件',
    
    -- 状态管理
    status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'requires_review') DEFAULT 'pending',
    processing_start_at TIMESTAMP NULL,
    processing_end_at TIMESTAMP NULL,
    
    -- 数据迁移
    migrated_from_core BOOLEAN DEFAULT FALSE,
    core_db_id BIGINT,
    migration_notes JSON,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_user_uuid (user_uuid),
    INDEX idx_test_type (test_type),
    INDEX idx_status (status),
    INDEX idx_test_date (test_date),
    INDEX idx_core_db_id (core_db_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='增强版健康检测记录表';

-- 高精度检测结果表
CREATE TABLE enhanced_test_results (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    test_uuid VARCHAR(36) NOT NULL,
    
    -- 检测参数
    parameter_code VARCHAR(20) NOT NULL,
    parameter_name VARCHAR(50) NOT NULL,
    parameter_category VARCHAR(30),
    parameter_subcategory VARCHAR(30),
    
    -- 多类型结果值
    numeric_value DECIMAL(15, 6),
    text_value VARCHAR(200),
    boolean_value BOOLEAN,
    json_value JSON COMMENT '复杂结果数据',
    unit VARCHAR(20),
    
    -- 动态参考范围
    reference_ranges JSON COMMENT '基于年龄性别的参考范围',
    personalized_range JSON COMMENT '个性化参考范围',
    
    -- 结果分析
    result_interpretation ENUM('normal', 'borderline_low', 'low', 'borderline_high', 'high', 'critical_low', 'critical_high', 'abnormal') NOT NULL,
    clinical_significance TEXT,
    
    -- 质量和置信度
    detection_confidence DECIMAL(5,4),
    measurement_precision DECIMAL(5,4),
    quality_indicators JSON,
    
    -- 趋势信息
    trend_direction ENUM('stable', 'improving', 'worsening', 'fluctuating'),
    change_from_previous DECIMAL(10, 4),
    change_percentage DECIMAL(6, 2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_test_uuid (test_uuid),
    INDEX idx_parameter_code (parameter_code),
    INDEX idx_result_interpretation (result_interpretation),
    INDEX idx_parameter_category (parameter_category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='高精度检测结果表';

-- 智能分析报告表
CREATE TABLE intelligent_analysis_reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    test_uuid VARCHAR(36) NOT NULL,
    
    -- 多层次分析
    executive_summary TEXT COMMENT '执行摘要',
    detailed_findings TEXT COMMENT '详细发现',
    clinical_interpretation TEXT COMMENT '临床解读',
    
    -- 个性化建议
    immediate_actions JSON COMMENT '立即行动建议',
    short_term_recommendations JSON COMMENT '短期建议',
    long_term_lifestyle_changes JSON COMMENT '长期生活方式改变',
    
    -- 风险评估
    risk_stratification JSON COMMENT '风险分层',
    risk_factors JSON COMMENT '风险因素',
    protective_factors JSON COMMENT '保护因素',
    
    -- 趋势和预测
    historical_trend_analysis JSON COMMENT '历史趋势分析',
    predictive_insights JSON COMMENT '预测性洞察',
    
    -- 就医指导
    medical_consultation_advice TEXT,
    specialist_referral_suggestions JSON,
    urgency_assessment ENUM('routine', 'within_week', 'within_days', 'urgent', 'emergency') DEFAULT 'routine',
    
    -- 报告元数据
    analysis_model_versions JSON COMMENT '分析模型版本',
    confidence_scores JSON COMMENT '各部分置信度',
    generation_metadata JSON COMMENT '生成元数据',
    
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_test_uuid (test_uuid),
    INDEX idx_urgency_assessment (urgency_assessment),
    INDEX idx_generated_at (generated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='智能分析报告表';

-- ==========================================
-- 数据迁移和同步表
-- ==========================================

-- 迁移任务记录表
CREATE TABLE migration_tasks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    task_name VARCHAR(100) NOT NULL,
    source_database VARCHAR(50) NOT NULL,
    target_database VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    
    -- 迁移状态
    status ENUM('pending', 'running', 'completed', 'failed', 'rollback') DEFAULT 'pending',
    
    -- 迁移统计
    total_records INT DEFAULT 0,
    migrated_records INT DEFAULT 0,
    failed_records INT DEFAULT 0,
    
    -- 时间信息
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    estimated_duration INT COMMENT '预估耗时(秒)',
    
    -- 错误信息
    error_message TEXT,
    error_details JSON,
    
    -- 迁移配置
    migration_config JSON COMMENT '迁移配置参数',
    rollback_plan JSON COMMENT '回滚计划',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_status (status),
    INDEX idx_table_name (table_name),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据迁移任务表';

-- 数据同步状态表
CREATE TABLE data_sync_status (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sync_type ENUM('user_profile', 'health_data', 'location_data', 'review_data') NOT NULL,
    source_service VARCHAR(50) NOT NULL,
    target_service VARCHAR(50) NOT NULL,
    
    -- 同步状态
    last_sync_at TIMESTAMP NULL,
    next_sync_at TIMESTAMP NULL,
    sync_frequency INT COMMENT '同步频率(秒)',
    
    -- 同步统计
    total_synced_records BIGINT DEFAULT 0,
    last_batch_size INT DEFAULT 0,
    sync_success_rate DECIMAL(5,2) DEFAULT 100.0,
    
    -- 错误处理
    consecutive_failures INT DEFAULT 0,
    last_error_message TEXT,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_sync_route (sync_type, source_service, target_service),
    INDEX idx_sync_type (sync_type),
    INDEX idx_next_sync_at (next_sync_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据同步状态表';