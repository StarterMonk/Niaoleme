package com.niaolemo.core.dto.request;

import com.niaolemo.core.entity.User;
import jakarta.validation.constraints.*;
import lombok.Data;

/**
 * 用户注册请求DTO
 * 
 * @author niaolemo-team
 */
@Data
public class RegisterRequest {

    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度必须在3-20位之间")
    @Pattern(regexp = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]+$", message = "用户名只能包含字母、数字、下划线和中文")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度必须在6-20位之间")
    private String password;

    @NotBlank(message = "确认密码不能为空")
    private String confirmPassword;

    @Email(message = "邮箱格式不正确")
    private String email;

    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    private String nickname;

    private User.Gender gender;

    @NotNull(message = "注册方式不能为空")
    private User.RegisterType registerType = User.RegisterType.USERNAME;

    // 第三方注册相关字段
    private String thirdPartyId;
    private String thirdPartyAccessToken;

    // 验证码相关
    private String smsCode;
    private String emailCode;

    /**
     * 验证密码一致性
     */
    public boolean isPasswordMatch() {
        return password != null && password.equals(confirmPassword);
    }

    /**
     * 根据注册方式验证必填字段
     */
    public boolean validateRequiredFields() {
        switch (registerType) {
            case USERNAME:
                return username != null && password != null;
            case PHONE:
                return phone != null && password != null && smsCode != null;
            case EMAIL:
                return email != null && password != null && emailCode != null;
            case WECHAT:
            case QQ:
            case ALIPAY:
                return thirdPartyId != null && thirdPartyAccessToken != null;
            default:
                return false;
        }
    }
}