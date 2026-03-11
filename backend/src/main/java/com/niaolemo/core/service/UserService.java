package com.niaolemo.core.service;

import com.niaolemo.core.dto.request.LoginRequest;
import com.niaolemo.core.dto.request.RegisterRequest;
import com.niaolemo.core.dto.response.LoginResponse;
import com.niaolemo.core.entity.User;
import org.springframework.security.core.userdetails.UserDetailsService;

import java.util.Optional;

/**
 * 用户服务接口
 * 
 * @author niaolemo-team
 */
public interface UserService extends UserDetailsService {

    /**
     * 用户注册
     */
    User register(RegisterRequest request);

    /**
     * 用户登录
     */
    LoginResponse login(LoginRequest request);

    /**
     * 根据用户名查找用户
     */
    Optional<User> findByUsername(String username);

    /**
     * 根据邮箱查找用户
     */
    Optional<User> findByEmail(String email);

    /**
     * 根据手机号查找用户
     */
    Optional<User> findByPhone(String phone);

    /**
     * 根据UUID查找用户
     */
    Optional<User> findByUuid(String uuid);

    /**
     * 根据第三方ID查找用户
     */
    Optional<User> findByThirdPartyId(String thirdPartyId, User.RegisterType registerType);

    /**
     * 验证密码
     */
    boolean validatePassword(String rawPassword, String encodedPassword);

    /**
     * 编码密码
     */
    String encodePassword(String rawPassword);

    /**
     * 检查用户名是否存在
     */
    boolean existsByUsername(String username);

    /**
     * 检查邮箱是否存在
     */
    boolean existsByEmail(String email);

    /**
     * 检查手机号是否存在
     */
    boolean existsByPhone(String phone);

    /**
     * 更新最后登录时间
     */
    void updateLastLoginInfo(Long userId, String loginIp);

    /**
     * 处理登录失败
     */
    void handleLoginFailure(String identifier);

    /**
     * 检查用户是否被锁定
     */
    boolean isUserLocked(String identifier);

    /**
     * 解锁用户
     */
    void unlockUser(Long userId);

    /**
     * 验证邮箱
     */
    void verifyEmail(Long userId);

    /**
     * 验证手机号
     */
    void verifyPhone(Long userId);

    /**
     * 验证用户名是否包含敏感词
     */
    boolean containsSensitiveWords(String username);
}