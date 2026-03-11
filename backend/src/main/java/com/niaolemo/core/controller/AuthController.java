package com.niaolemo.core.controller;

import com.niaolemo.core.dto.request.LoginRequest;
import com.niaolemo.core.dto.request.RegisterRequest;
import com.niaolemo.core.dto.response.ApiResponse;
import com.niaolemo.core.dto.response.LoginResponse;
import com.niaolemo.core.entity.User;
import com.niaolemo.core.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 * 
 * @author niaolemo-team
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "认证管理", description = "用户注册、登录、登出等认证相关接口")
public class AuthController {

    private final UserService userService;

    /**
     * 用户注册
     */
    @PostMapping("/register")
    @Operation(summary = "用户注册", description = "支持用户名、邮箱、手机号等多种方式注册")
    public ApiResponse<User> register(@Valid @RequestBody RegisterRequest request) {
        log.info("用户注册请求: username={}, registerType={}", request.getUsername(), request.getRegisterType());
        
        User user = userService.register(request);
        
        // 清除敏感信息
        user.setPasswordHash(null);
        user.setSalt(null);
        
        return ApiResponse.success("注册成功", user);
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    @Operation(summary = "用户登录", description = "支持用户名、邮箱、手机号登录")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        log.info("用户登录请求: identifier={}, loginType={}", request.getIdentifier(), request.getLoginType());
        
        LoginResponse response = userService.login(request);
        
        return ApiResponse.success("登录成功", response);
    }

    /**
     * 检查用户名是否可用
     */
    @GetMapping("/check-username")
    @Operation(summary = "检查用户名", description = "检查用户名是否已被使用或包含敏感词")
    public ApiResponse<Boolean> checkUsername(@RequestParam String username) {
        log.debug("检查用户名: {}", username);
        
        // 检查敏感词
        if (userService.containsSensitiveWords(username)) {
            return ApiResponse.badRequest("用户名包含敏感词汇");
        }
        
        // 检查是否已存在
        boolean exists = userService.existsByUsername(username);
        if (exists) {
            return ApiResponse.badRequest("用户名已被使用");
        }
        
        return ApiResponse.success("用户名可用", true);
    }

    /**
     * 检查邮箱是否可用
     */
    @GetMapping("/check-email")
    @Operation(summary = "检查邮箱", description = "检查邮箱是否已被注册")
    public ApiResponse<Boolean> checkEmail(@RequestParam String email) {
        log.debug("检查邮箱: {}", email);
        
        boolean exists = userService.existsByEmail(email);
        if (exists) {
            return ApiResponse.badRequest("邮箱已被注册");
        }
        
        return ApiResponse.success("邮箱可用", true);
    }

    /**
     * 检查手机号是否可用
     */
    @GetMapping("/check-phone")
    @Operation(summary = "检查手机号", description = "检查手机号是否已被注册")
    public ApiResponse<Boolean> checkPhone(@RequestParam String phone) {
        log.debug("检查手机号: {}", phone);
        
        boolean exists = userService.existsByPhone(phone);
        if (exists) {
            return ApiResponse.badRequest("手机号已被注册");
        }
        
        return ApiResponse.success("手机号可用", true);
    }

    /**
     * 刷新令牌
     */
    @PostMapping("/refresh")
    @Operation(summary = "刷新令牌", description = "使用刷新令牌获取新的访问令牌")
    public ApiResponse<String> refreshToken(@RequestParam String refreshToken) {
        log.info("刷新令牌请求");
        
        // TODO: 实现刷新令牌逻辑
        
        return ApiResponse.success("令牌刷新成功", "new-access-token");
    }

    /**
     * 用户登出
     */
    @PostMapping("/logout")
    @Operation(summary = "用户登出", description = "用户登出，清除会话信息")
    public ApiResponse<Void> logout() {
        log.info("用户登出请求");
        
        // TODO: 实现登出逻辑，清除Redis中的令牌
        
        return ApiResponse.success("登出成功");
    }
}