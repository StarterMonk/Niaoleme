package com.niaolemo.core.service.impl;

import com.niaolemo.core.dto.request.LoginRequest;
import com.niaolemo.core.dto.request.RegisterRequest;
import com.niaolemo.core.dto.response.LoginResponse;
import com.niaolemo.core.entity.User;
import com.niaolemo.core.exception.BusinessException;
import com.niaolemo.core.repository.UserRepository;
import com.niaolemo.core.service.JwtService;
import com.niaolemo.core.service.UserService;
import com.niaolemo.core.utils.IpUtils;
import com.niaolemo.core.utils.SensitiveWordFilter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Optional;
import java.util.UUID;

/**
 * 用户服务实现类
 * 
 * @author niaolemo-team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final SensitiveWordFilter sensitiveWordFilter;

    private static final int MAX_LOGIN_ATTEMPTS = 5;
    private static final int LOCK_DURATION_MINUTES = 15;

    @Override
    @Transactional
    public User register(RegisterRequest request) {
        // 1. 验证请求参数
        validateRegisterRequest(request);

        // 2. 检查用户名敏感词
        if (containsSensitiveWords(request.getUsername())) {
            throw new BusinessException("用户名包含敏感词汇，请重新输入");
        }

        // 3. 检查用户名、邮箱、手机号是否已存在
        if (request.getUsername() != null && existsByUsername(request.getUsername())) {
            throw new BusinessException("用户名已存在");
        }
        if (request.getEmail() != null && existsByEmail(request.getEmail())) {
            throw new BusinessException("邮箱已被注册");
        }
        if (request.getPhone() != null && existsByPhone(request.getPhone())) {
            throw new BusinessException("手机号已被注册");
        }

        // 4. 创建用户对象
        User user = new User();
        user.setUuid(UUID.randomUUID().toString());
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setNickname(request.getNickname() != null ? request.getNickname() : request.getUsername());
        user.setGender(request.getGender());
        user.setRegisterType(request.getRegisterType());
        user.setThirdPartyId(request.getThirdPartyId());

        // 5. 密码加密
        if (request.getPassword() != null) {
            String salt = UUID.randomUUID().toString().substring(0, 8);
            user.setSalt(salt);
            user.setPasswordHash(passwordEncoder.encode(request.getPassword() + salt));
        }

        // 6. 设置默认状态
        user.setStatus(User.UserStatus.ACTIVE);
        user.setLoginFailureCount(0);

        // 7. 根据注册方式设置验证状态
        switch (request.getRegisterType()) {
            case EMAIL:
                user.setEmailVerified(true); // 邮箱注册默认已验证
                break;
            case PHONE:
                user.setPhoneVerified(true); // 手机注册默认已验证
                break;
            case WECHAT:
            case QQ:
            case ALIPAY:
                user.setEmailVerified(false);
                user.setPhoneVerified(false);
                break;
            default:
                user.setEmailVerified(false);
                user.setPhoneVerified(false);
        }

        // 8. 保存用户
        userRepository.insert(user);
        
        log.info("用户注册成功: username={}, registerType={}", user.getUsername(), user.getRegisterType());
        return user;
    }

    @Override
    @Transactional
    public LoginResponse login(LoginRequest request) {
        // 1. 查找用户
        User user = findUserByIdentifier(request.getIdentifier(), request.getLoginType());
        if (user == null) {
            handleLoginFailure(request.getIdentifier());
            throw new BusinessException("用户名或密码错误");
        }

        // 2. 检查用户状态
        if (!user.isActive()) {
            if (user.isLocked()) {
                throw new BusinessException("账户已被锁定，请稍后再试");
            }
            throw new BusinessException("账户已被禁用");
        }

        // 3. 验证密码
        if (!validatePassword(request.getPassword(), user.getPasswordHash(), user.getSalt())) {
            handleLoginFailure(request.getIdentifier());
            throw new BusinessException("用户名或密码错误");
        }

        // 4. 更新登录信息
        String clientIp = IpUtils.getClientIp();
        updateLastLoginInfo(user.getId(), clientIp);

        // 5. 生成JWT令牌
        UserDetails userDetails = loadUserByUsername(user.getUsername());
        String accessToken = jwtService.generateTokenWithUserId(userDetails, user.getId());
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        // 6. 构建响应
        LoginResponse.UserInfo userInfo = LoginResponse.UserInfo.builder()
                .uuid(user.getUuid())
                .username(user.getUsername())
                .nickname(user.getNickname())
                .email(user.getEmail())
                .phone(user.getPhone())
                .avatarUrl(user.getAvatarUrl())
                .gender(user.getGender() != null ? user.getGender().name() : null)
                .status(user.getStatus().name())
                .lastLoginAt(user.getLastLoginAt())
                .build();

        log.info("用户登录成功: username={}, ip={}", user.getUsername(), clientIp);

        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresAt(LocalDateTime.now().plusMinutes(15)) // 15分钟过期
                .userInfo(userInfo)
                .build();
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("用户不存在: " + username));

        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getUsername())
                .password(user.getPasswordHash())
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER")))
                .accountExpired(false)
                .accountLocked(user.isLocked())
                .credentialsExpired(false)
                .disabled(!user.isActive())
                .build();
    }

    @Override
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    public Optional<User> findByPhone(String phone) {
        return userRepository.findByPhone(phone);
    }

    @Override
    public Optional<User> findByUuid(String uuid) {
        return userRepository.findByUuid(uuid);
    }

    @Override
    public Optional<User> findByThirdPartyId(String thirdPartyId, User.RegisterType registerType) {
        return userRepository.findByThirdPartyId(thirdPartyId, registerType);
    }

    @Override
    public boolean validatePassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    @Override
    public String encodePassword(String rawPassword) {
        return passwordEncoder.encode(rawPassword);
    }

    @Override
    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public boolean existsByPhone(String phone) {
        return userRepository.existsByPhone(phone);
    }

    @Override
    @Transactional
    public void updateLastLoginInfo(Long userId, String loginIp) {
        userRepository.updateLastLoginInfo(userId, LocalDateTime.now(), loginIp);
    }

    @Override
    @Transactional
    public void handleLoginFailure(String identifier) {
        User user = findUserByIdentifier(identifier, null);
        if (user != null) {
            int failureCount = user.getLoginFailureCount() + 1;
            userRepository.updateLoginFailureCount(user.getId(), failureCount);

            // 达到最大失败次数，锁定用户
            if (failureCount >= MAX_LOGIN_ATTEMPTS) {
                LocalDateTime lockUntil = LocalDateTime.now().plusMinutes(LOCK_DURATION_MINUTES);
                userRepository.lockUser(user.getId(), lockUntil);
                log.warn("用户因登录失败次数过多被锁定: username={}, lockUntil={}", user.getUsername(), lockUntil);
            }
        }
    }

    @Override
    public boolean isUserLocked(String identifier) {
        User user = findUserByIdentifier(identifier, null);
        return user != null && user.isLocked();
    }

    @Override
    @Transactional
    public void unlockUser(Long userId) {
        userRepository.unlockUser(userId);
    }

    @Override
    @Transactional
    public void verifyEmail(Long userId) {
        userRepository.verifyEmail(userId);
    }

    @Override
    @Transactional
    public void verifyPhone(Long userId) {
        userRepository.verifyPhone(userId);
    }

    @Override
    public boolean containsSensitiveWords(String username) {
        return sensitiveWordFilter.containsSensitiveWord(username);
    }

    /**
     * 验证注册请求
     */
    private void validateRegisterRequest(RegisterRequest request) {
        if (!request.validateRequiredFields()) {
            throw new BusinessException("必填字段不完整");
        }

        if (request.getPassword() != null && !request.isPasswordMatch()) {
            throw new BusinessException("两次输入的密码不一致");
        }

        // 验证密码强度（6-20位）
        if (request.getPassword() != null) {
            String password = request.getPassword();
            if (password.length() < 6 || password.length() > 20) {
                throw new BusinessException("密码长度必须在6-20位之间");
            }
        }
    }

    /**
     * 根据标识符查找用户
     */
    private User findUserByIdentifier(String identifier, LoginRequest.LoginType loginType) {
        if (loginType == null) {
            // 自动判断标识符类型
            if (identifier.contains("@")) {
                return findByEmail(identifier).orElse(null);
            } else if (identifier.matches("^1[3-9]\\d{9}$")) {
                return findByPhone(identifier).orElse(null);
            } else {
                return findByUsername(identifier).orElse(null);
            }
        }

        switch (loginType) {
            case EMAIL:
                return findByEmail(identifier).orElse(null);
            case PHONE:
                return findByPhone(identifier).orElse(null);
            case USERNAME:
            default:
                return findByUsername(identifier).orElse(null);
        }
    }

    /**
     * 验证密码（包含盐值）
     */
    private boolean validatePassword(String rawPassword, String encodedPassword, String salt) {
        return passwordEncoder.matches(rawPassword + salt, encodedPassword);
    }
}