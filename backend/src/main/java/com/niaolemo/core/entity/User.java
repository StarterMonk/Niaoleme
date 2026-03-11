package com.niaolemo.core.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Comment;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 用户实体类
 * 
 * @author niaolemo-team
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_uuid", columnList = "uuid"),
    @Index(name = "idx_email", columnList = "email"),
    @Index(name = "idx_phone", columnList = "phone"),
    @Index(name = "idx_username", columnList = "username"),
    @Index(name = "idx_status", columnList = "status")
})
@EntityListeners(AuditingEntityListener.class)
@Comment("用户基础信息表")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @TableId(type = IdType.AUTO)
    private Long id;

    @Column(name = "uuid", nullable = false, unique = true, length = 36)
    @Comment("用户唯一标识")
    private String uuid;

    @NotBlank(message = "用户名不能为空")
    @Pattern(regexp = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]{3,20}$", message = "用户名长度3-20位，只能包含字母、数字、下划线和中文")
    @Column(name = "username", nullable = false, unique = true, length = 50)
    @Comment("用户名")
    private String username;

    @Email(message = "邮箱格式不正确")
    @Column(name = "email", unique = true, length = 100)
    @Comment("邮箱")
    private String email;

    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    @Column(name = "phone", unique = true, length = 20)
    @Comment("手机号")
    private String phone;

    @JsonIgnore
    @Column(name = "password_hash", nullable = false)
    @Comment("密码哈希")
    private String passwordHash;

    @JsonIgnore
    @Column(name = "salt", nullable = false, length = 32)
    @Comment("密码盐值")
    private String salt;

    // 个人信息
    @Column(name = "nickname", length = 50)
    @Comment("昵称")
    private String nickname;

    @Column(name = "avatar_url", length = 500)
    @Comment("头像URL")
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender")
    @Comment("性别")
    private Gender gender;

    @Column(name = "birth_date")
    @Comment("出生日期")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate birthDate;

    // 健康基础信息（第一阶段内嵌）
    @Column(name = "height", precision = 5, scale = 2)
    @Comment("身高(cm)")
    private BigDecimal height;

    @Column(name = "weight", precision = 5, scale = 2)
    @Comment("体重(kg)")
    private BigDecimal weight;

    @Column(name = "medical_notes", columnDefinition = "JSON")
    @Comment("简化的医疗信息")
    private String medicalNotes;

    // 注册方式
    @Enumerated(EnumType.STRING)
    @Column(name = "register_type", nullable = false)
    @Comment("注册方式")
    private RegisterType registerType = RegisterType.USERNAME;

    @Column(name = "third_party_id", length = 100)
    @Comment("第三方平台用户ID")
    private String thirdPartyId;

    // 状态管理
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @Comment("用户状态")
    private UserStatus status = UserStatus.ACTIVE;

    @Column(name = "email_verified", nullable = false)
    @Comment("邮箱是否验证")
    private Boolean emailVerified = false;

    @Column(name = "phone_verified", nullable = false)
    @Comment("手机号是否验证")
    private Boolean phoneVerified = false;

    // 安全相关
    @Column(name = "login_failure_count", nullable = false)
    @Comment("登录失败次数")
    private Integer loginFailureCount = 0;

    @Column(name = "locked_until")
    @Comment("锁定到期时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lockedUntil;

    @Column(name = "last_login_at")
    @Comment("最后登录时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastLoginAt;

    @Column(name = "last_login_ip", length = 45)
    @Comment("最后登录IP")
    private String lastLoginIp;

    // 审计字段
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    @Comment("创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    @Comment("更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;

    @TableLogic
    @Column(name = "deleted_at")
    @Comment("软删除时间")
    @JsonIgnore
    private LocalDateTime deletedAt;

    /**
     * 性别枚举
     */
    public enum Gender {
        M("男性"),
        F("女性"),
        OTHER("其他");

        private final String description;

        Gender(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    /**
     * 用户状态枚举
     */
    public enum UserStatus {
        ACTIVE("正常"),
        INACTIVE("未激活"),
        SUSPENDED("已暂停"),
        LOCKED("已锁定");

        private final String description;

        UserStatus(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    /**
     * 注册方式枚举
     */
    public enum RegisterType {
        USERNAME("用户名注册"),
        PHONE("手机号注册"),
        EMAIL("邮箱注册"),
        WECHAT("微信注册"),
        QQ("QQ注册"),
        ALIPAY("支付宝注册");

        private final String description;

        RegisterType(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    /**
     * 计算年龄
     */
    public Integer getAge() {
        if (birthDate == null) {
            return null;
        }
        return LocalDate.now().getYear() - birthDate.getYear();
    }

    /**
     * 计算BMI
     */
    public BigDecimal getBmi() {
        if (height == null || weight == null || 
            height.compareTo(BigDecimal.ZERO) <= 0) {
            return null;
        }
        
        BigDecimal heightInMeters = height.divide(new BigDecimal("100"));
        return weight.divide(heightInMeters.multiply(heightInMeters), 2, BigDecimal.ROUND_HALF_UP);
    }

    /**
     * 获取BMI状态描述
     */
    public String getBmiStatus() {
        BigDecimal bmi = getBmi();
        if (bmi == null) {
            return "未知";
        }
        
        if (bmi.compareTo(new BigDecimal("18.5")) < 0) {
            return "偏瘦";
        } else if (bmi.compareTo(new BigDecimal("24")) < 0) {
            return "正常";
        } else if (bmi.compareTo(new BigDecimal("28")) < 0) {
            return "超重";
        } else {
            return "肥胖";
        }
    }

    /**
     * 检查用户是否被锁定
     */
    public boolean isLocked() {
        return lockedUntil != null && lockedUntil.isAfter(LocalDateTime.now());
    }

    /**
     * 检查用户是否激活
     */
    public boolean isActive() {
        return UserStatus.ACTIVE.equals(this.status) && !isLocked();
    }
}