package com.niaolemo.core.dto.request;

import com.niaolemo.core.entity.User;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 用户登录请求DTO
 * 
 * @author niaolemo-team
 */
@Data
public class LoginRequest {

    @NotBlank(message = "登录标识不能为空")
    private String identifier; // 可以是用户名、邮箱或手机号

    @NotBlank(message = "密码不能为空")
    private String password;

    @NotNull(message = "登录方式不能为空")
    private LoginType loginType = LoginType.USERNAME;

    private String captcha; // 验证码
    private String captchaKey; // 验证码key

    // 第三方登录相关
    private String thirdPartyAccessToken;
    private String thirdPartyCode;

    /**
     * 登录方式枚举
     */
    public enum LoginType {
        USERNAME("用户名登录"),
        EMAIL("邮箱登录"),
        PHONE("手机号登录"),
        WECHAT("微信登录"),
        QQ("QQ登录"),
        ALIPAY("支付宝登录");

        private final String description;

        LoginType(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}