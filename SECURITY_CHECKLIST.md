# 尿了么项目网络安全检查清单

## 🔐 安全检查总览

### 安全等级分类
- 🔴 **关键安全** - 必须实现，影响系统安全
- 🟡 **重要安全** - 建议实现，提升安全性
- 🟢 **一般安全** - 可选实现，增强防护

---

## 📋 开发阶段安全检查

### 1. 认证与授权安全 🔴

#### 用户认证
- [ ] **密码安全策略** 🔴
  - 最小长度8位
  - 必须包含数字、字母、特殊字符
  - 禁用常见弱密码
  - 密码历史记录（不能重复最近5次）

- [ ] **登录安全** 🔴
  - 登录失败5次后锁定15分钟
  - 异地登录提醒
  - 可疑登录行为检测
  - 登录日志记录

- [ ] **会话管理** 🔴
  - JWT短期有效期（15分钟）
  - 刷新令牌机制
  - 会话并发控制
  - 安全登出清理

#### 权限控制
- [ ] **访问控制** 🔴
  - 基于角色的权限控制(RBAC)
  - 最小权限原则
  - 权限继承和委派
  - 敏感操作二次验证

- [ ] **API权限** 🔴
  - 接口级权限控制
  - 数据级权限隔离
  - 跨域访问控制
  - API密钥管理

### 2. 输入验证与数据安全 🔴

#### 输入验证
- [ ] **参数验证** 🔴
  ```java
  // 示例：严格的输入验证
  @Valid
  public class RegisterRequest {
      @NotBlank(message = "用户名不能为空")
      @Pattern(regexp = "^[a-zA-Z0-9_]{3,20}$", message = "用户名格式不正确")
      private String username;
      
      @Email(message = "邮箱格式不正确")
      @NotBlank(message = "邮箱不能为空")
      private String email;
      
      @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$", 
               message = "密码必须包含大小写字母、数字和特殊字符，长度至少8位")
      private String password;
  }
  ```

- [ ] **XSS防护** 🔴
  - 输出HTML编码
  - CSP内容安全策略
  - 输入内容过滤
  - 富文本编辑器安全配置

- [ ] **SQL注入防护** 🔴
  - 参数化查询
  - 输入特殊字符过滤
  - ORM框架安全配置
  - 数据库权限最小化

#### 文件上传安全
- [ ] **文件验证** 🔴
  ```java
  // 示例：安全的文件上传验证
  @Component
  public class FileUploadValidator {
      private static final List<String> ALLOWED_TYPES = 
          Arrays.asList("image/jpeg", "image/png", "image/bmp");
      private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
      
      public boolean validateFile(MultipartFile file) {
          // 1. 文件类型验证
          if (!ALLOWED_TYPES.contains(file.getContentType())) {
              return false;
          }
          
          // 2. 文件大小验证
          if (file.getSize() > MAX_FILE_SIZE) {
              return false;
          }
          
          // 3. 文件内容验证
          return validateFileContent(file);
      }
      
      private boolean validateFileContent(MultipartFile file) {
          // 检查文件头部魔数
          // 扫描恶意代码
          // 清理EXIF信息
          return true;
      }
  }
  ```

- [ ] **文件存储安全** 🔴
  - 文件路径遍历防护
  - 文件名安全处理
  - 病毒扫描集成
  - 文件访问权限控制

### 3. 数据保护 🔴

#### 敏感数据加密
- [ ] **数据库加密** 🔴
  ```java
  // 示例：敏感字段加密
  @Entity
  public class User {
      @Convert(converter = EncryptionConverter.class)
      private String phone;
      
      @Convert(converter = EncryptionConverter.class)
      private String idCard;
      
      @JsonIgnore
      private String passwordHash;
  }
  
  @Converter
  public class EncryptionConverter implements AttributeConverter<String, String> {
      @Override
      public String convertToDatabaseColumn(String attribute) {
          return encryptionService.encrypt(attribute);
      }
      
      @Override
      public String convertToEntityAttribute(String dbData) {
          return encryptionService.decrypt(dbData);
      }
  }
  ```

- [ ] **传输加密** 🔴
  - 强制HTTPS
  - TLS 1.3配置
  - 证书管理
  - HSTS头部设置

#### 数据脱敏
- [ ] **输出脱敏** 🟡
  ```java
  // 示例：敏感数据脱敏
  @JsonSerialize(using = PhoneDesensitizer.class)
  private String phone;
  
  public class PhoneDesensitizer extends JsonSerializer<String> {
      @Override
      public void serialize(String phone, JsonGenerator gen, SerializerProvider serializers) 
          throws IOException {
          if (phone != null && phone.length() >= 11) {
              String masked = phone.substring(0, 3) + "****" + phone.substring(7);
              gen.writeString(masked);
          }
      }
  }
  ```

### 4. API安全 🔴

#### 接口安全
- [ ] **API限流** 🔴
  ```java
  // 示例：API限流实现
  @Component
  public class RateLimitInterceptor implements HandlerInterceptor {
      @Override
      public boolean preHandle(HttpServletRequest request, 
                              HttpServletResponse response, 
                              Object handler) throws Exception {
          String clientIp = getClientIp(request);
          String apiPath = request.getRequestURI();
          
          // 基于IP的限流
          if (!rateLimitService.isAllowed(clientIp, apiPath)) {
              response.setStatus(429);
              response.getWriter().write("Too Many Requests");
              return false;
          }
          
          return true;
      }
  }
  ```

- [ ] **CSRF防护** 🔴
  - CSRF令牌验证
  - SameSite Cookie设置
  - Referer头部检查
  - 双重提交Cookie

#### API监控
- [ ] **异常监控** 🟡
  - 异常请求检测
  - 攻击模式识别
  - 实时告警机制
  - 自动封禁功能

### 5. 系统安全 🟡

#### 配置安全
- [ ] **配置管理** 🟡
  ```yaml
  # 示例：安全配置
  server:
    # 隐藏服务器信息
    server-header: ""
    # 错误页面配置
    error:
      include-stacktrace: never
      include-message: never
  
  spring:
    # 安全头部配置
    security:
      headers:
        frame-options: DENY
        content-type-options: nosniff
        xss-protection: "1; mode=block"
        referrer-policy: strict-origin-when-cross-origin
  ```

- [ ] **环境隔离** 🟡
  - 开发/测试/生产环境分离
  - 敏感配置加密存储
  - 配置文件权限控制
  - 密钥轮换机制

#### 日志安全
- [ ] **审计日志** 🟡
  ```java
  // 示例：安全审计日志
  @Component
  public class SecurityAuditLogger {
      public void logSecurityEvent(SecurityEvent event) {
          AuditLog log = AuditLog.builder()
              .eventType(event.getType())
              .userId(event.getUserId())
              .clientIp(event.getClientIp())
              .userAgent(event.getUserAgent())
              .timestamp(LocalDateTime.now())
              .details(event.getDetails())
              .riskLevel(event.getRiskLevel())
              .build();
          
          auditLogRepository.save(log);
          
          // 高风险事件实时告警
          if (event.getRiskLevel() == RiskLevel.HIGH) {
              alertService.sendSecurityAlert(log);
          }
      }
  }
  ```

---

## 🧪 安全测试检查

### 1. 自动化安全测试 🔴

#### 静态代码分析
- [ ] **代码扫描** 🔴
  ```bash
  # SonarQube安全扫描
  mvn sonar:sonar -Dsonar.projectKey=niaolemo \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login=your-token
  
  # OWASP依赖检查
  mvn org.owasp:dependency-check-maven:check
  
  # SpotBugs安全检查
  mvn com.github.spotbugs:spotbugs-maven-plugin:check
  ```

#### 动态安全测试
- [ ] **渗透测试** 🔴
  ```bash
  # OWASP ZAP自动扫描
  zap-baseline.py -t http://localhost:8080 -r zap-report.html
  
  # Nikto Web扫描
  nikto -h http://localhost:8080 -output nikto-report.txt
  
  # SQLMap注入测试
  sqlmap -u "http://localhost:8080/api/v1/users" --batch --risk=3
  ```

### 2. 手动安全测试 🟡

#### 认证测试
- [ ] **登录安全测试**
  - 暴力破解测试
  - 会话固定攻击测试
  - 权限提升测试
  - 会话劫持测试

#### 输入验证测试
- [ ] **注入攻击测试**
  - SQL注入测试
  - NoSQL注入测试
  - LDAP注入测试
  - 命令注入测试

- [ ] **XSS攻击测试**
  - 反射型XSS测试
  - 存储型XSS测试
  - DOM型XSS测试
  - CSP绕过测试

#### 业务逻辑测试
- [ ] **业务流程测试**
  - 支付流程安全测试
  - 文件上传安全测试
  - 数据导出安全测试
  - 批量操作安全测试

---

## 🚨 安全事件响应

### 1. 监控告警 🔴

#### 实时监控
- [ ] **安全事件监控**
  ```java
  // 示例：安全事件监控
  @Component
  public class SecurityMonitor {
      @EventListener
      public void handleLoginFailure(LoginFailureEvent event) {
          // 记录失败次数
          int failureCount = loginAttemptService.incrementFailureCount(event.getClientIp());
          
          // 超过阈值告警
          if (failureCount >= 5) {
              alertService.sendAlert(
                  AlertType.BRUTE_FORCE_ATTACK,
                  "IP: " + event.getClientIp() + " 疑似暴力破解攻击"
              );
          }
      }
      
      @EventListener
      public void handleSqlInjectionAttempt(SqlInjectionEvent event) {
          // 立即告警
          alertService.sendUrgentAlert(
              AlertType.SQL_INJECTION,
              "检测到SQL注入攻击尝试: " + event.getPayload()
          );
          
          // 自动封禁IP
          securityService.blockIp(event.getClientIp(), Duration.ofHours(24));
      }
  }
  ```

#### 告警机制
- [ ] **多渠道告警**
  - 邮件告警
  - 短信告警
  - 钉钉/企业微信告警
  - 电话告警（紧急情况）

### 2. 应急响应 🔴

#### 响应流程
- [ ] **事件分级响应**
  - P0: 数据泄露、系统被攻破 (15分钟内响应)
  - P1: 重要功能异常、安全漏洞 (1小时内响应)
  - P2: 一般安全事件 (4小时内响应)
  - P3: 安全建议、优化建议 (24小时内响应)

#### 应急措施
- [ ] **自动防护措施**
  ```java
  // 示例：自动防护机制
  @Service
  public class AutoDefenseService {
      public void handleSecurityThreat(SecurityThreat threat) {
          switch (threat.getLevel()) {
              case CRITICAL:
                  // 立即封禁攻击源
                  firewallService.blockIp(threat.getSourceIp());
                  // 启用紧急模式
                  systemService.enableEmergencyMode();
                  // 通知安全团队
                  notificationService.notifySecurityTeam(threat);
                  break;
              case HIGH:
                  // 限制访问频率
                  rateLimitService.restrictIp(threat.getSourceIp());
                  // 增强监控
                  monitoringService.enhanceMonitoring(threat.getSourceIp());
                  break;
              case MEDIUM:
                  // 记录日志
                  auditLogger.logSecurityEvent(threat);
                  // 发送告警
                  alertService.sendAlert(threat);
                  break;
          }
      }
  }
  ```

---

## 📊 安全合规检查

### 1. 数据保护合规 🔴

#### 个人信息保护法合规
- [ ] **数据收集合规**
  - 明确告知数据收集目的
  - 获得用户明确同意
  - 最小化数据收集原则
  - 数据收集合法性审查

- [ ] **数据处理合规**
  - 数据处理目的限制
  - 数据保留期限管理
  - 数据跨境传输合规
  - 数据处理活动记录

#### 医疗数据特殊保护
- [ ] **医疗数据安全**
  - 医疗数据分类分级
  - 特殊加密保护措施
  - 访问权限严格控制
  - 数据匿名化处理

### 2. 行业标准合规 🟡

#### 等保合规
- [ ] **等保2.0要求**
  - 安全管理制度
  - 安全技术措施
  - 安全运维管理
  - 定期安全评估

#### ISO27001合规
- [ ] **信息安全管理**
  - 信息安全政策
  - 风险评估管理
  - 安全意识培训
  - 持续改进机制

---

## ✅ 安全检查清单总结

### 开发阶段必检项 (每次提交前)
- [ ] 代码安全扫描通过
- [ ] 输入验证完整
- [ ] 敏感数据加密
- [ ] 权限控制正确
- [ ] 日志记录完整

### 测试阶段必检项 (每次发布前)
- [ ] 自动化安全测试通过
- [ ] 手动渗透测试通过
- [ ] 性能压力测试通过
- [ ] 安全配置检查通过
- [ ] 应急响应机制测试通过

### 生产环境必检项 (每月检查)
- [ ] 安全漏洞扫描
- [ ] 访问日志审计
- [ ] 权限配置审查
- [ ] 安全事件回顾
- [ ] 应急预案演练

### 合规检查项 (每季度检查)
- [ ] 数据保护合规审查
- [ ] 隐私政策更新
- [ ] 安全培训完成
- [ ] 第三方安全评估
- [ ] 合规文档更新

---

## 🔧 安全工具推荐

### 开发阶段工具
- **SonarQube**: 代码质量和安全扫描
- **OWASP Dependency Check**: 依赖漏洞检查
- **SpotBugs**: Java代码安全检查
- **Checkmarx**: 静态应用安全测试

### 测试阶段工具
- **OWASP ZAP**: Web应用安全扫描
- **Burp Suite**: 专业渗透测试工具
- **Nikto**: Web服务器扫描
- **SQLMap**: SQL注入检测工具

### 运维阶段工具
- **Nessus**: 漏洞扫描
- **Splunk**: 日志分析和监控
- **Fail2Ban**: 入侵防护
- **ModSecurity**: Web应用防火墙

这个安全检查清单确保了"尿了么"项目在整个开发生命周期中的安全性，特别关注了医疗健康数据的特殊保护要求。