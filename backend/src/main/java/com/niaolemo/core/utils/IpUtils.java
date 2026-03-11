package com.niaolemo.core.utils;

import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * IP工具类
 * 
 * @author niaolemo-team
 */
@Slf4j
public class IpUtils {

    private static final String UNKNOWN = "unknown";
    private static final String LOCALHOST_IPV4 = "127.0.0.1";
    private static final String LOCALHOST_IPV6 = "0:0:0:0:0:0:0:1";

    /**
     * 获取客户端真实IP地址
     */
    public static String getClientIp() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) {
                return LOCALHOST_IPV4;
            }
            
            HttpServletRequest request = attributes.getRequest();
            return getClientIp(request);
        } catch (Exception e) {
            log.warn("获取客户端IP失败", e);
            return LOCALHOST_IPV4;
        }
    }

    /**
     * 获取客户端真实IP地址
     */
    public static String getClientIp(HttpServletRequest request) {
        if (request == null) {
            return LOCALHOST_IPV4;
        }

        String ip = null;

        // 1. 检查X-Forwarded-For头部（代理服务器会添加）
        ip = request.getHeader("X-Forwarded-For");
        if (isValidIp(ip)) {
            // X-Forwarded-For可能包含多个IP，取第一个
            int index = ip.indexOf(',');
            if (index != -1) {
                ip = ip.substring(0, index);
            }
            return ip.trim();
        }

        // 2. 检查X-Real-IP头部（Nginx代理会添加）
        ip = request.getHeader("X-Real-IP");
        if (isValidIp(ip)) {
            return ip;
        }

        // 3. 检查Proxy-Client-IP头部（Apache代理会添加）
        ip = request.getHeader("Proxy-Client-IP");
        if (isValidIp(ip)) {
            return ip;
        }

        // 4. 检查WL-Proxy-Client-IP头部（WebLogic代理会添加）
        ip = request.getHeader("WL-Proxy-Client-IP");
        if (isValidIp(ip)) {
            return ip;
        }

        // 5. 检查HTTP_CLIENT_IP头部
        ip = request.getHeader("HTTP_CLIENT_IP");
        if (isValidIp(ip)) {
            return ip;
        }

        // 6. 检查HTTP_X_FORWARDED_FOR头部
        ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        if (isValidIp(ip)) {
            return ip;
        }

        // 7. 最后使用request.getRemoteAddr()
        ip = request.getRemoteAddr();
        
        // 处理IPv6本地地址
        if (LOCALHOST_IPV6.equals(ip)) {
            ip = LOCALHOST_IPV4;
        }

        return ip;
    }

    /**
     * 验证IP地址是否有效
     */
    private static boolean isValidIp(String ip) {
        return ip != null 
            && !ip.isEmpty() 
            && !UNKNOWN.equalsIgnoreCase(ip);
    }

    /**
     * 检查是否为内网IP
     */
    public static boolean isInternalIp(String ip) {
        if (ip == null || ip.isEmpty()) {
            return false;
        }

        // 本地回环地址
        if (LOCALHOST_IPV4.equals(ip) || LOCALHOST_IPV6.equals(ip) || "localhost".equals(ip)) {
            return true;
        }

        try {
            String[] parts = ip.split("\\.");
            if (parts.length != 4) {
                return false;
            }

            int firstOctet = Integer.parseInt(parts[0]);
            int secondOctet = Integer.parseInt(parts[1]);

            // A类私有地址：10.0.0.0 - 10.255.255.255
            if (firstOctet == 10) {
                return true;
            }

            // B类私有地址：172.16.0.0 - 172.31.255.255
            if (firstOctet == 172 && secondOctet >= 16 && secondOctet <= 31) {
                return true;
            }

            // C类私有地址：192.168.0.0 - 192.168.255.255
            if (firstOctet == 192 && secondOctet == 168) {
                return true;
            }

            // 链路本地地址：169.254.0.0 - 169.254.255.255
            if (firstOctet == 169 && secondOctet == 254) {
                return true;
            }

        } catch (NumberFormatException e) {
            return false;
        }

        return false;
    }

    /**
     * 获取IP地址的地理位置（简单版本）
     */
    public static String getIpLocation(String ip) {
        if (ip == null || ip.isEmpty()) {
            return "未知";
        }

        if (isInternalIp(ip)) {
            return "内网";
        }

        // 这里可以集成第三方IP地址库，如IP2Location、GeoIP等
        // 目前返回简单的分类
        return "外网";
    }

    /**
     * 脱敏IP地址（隐藏最后一段）
     */
    public static String maskIp(String ip) {
        if (ip == null || ip.isEmpty()) {
            return "未知";
        }

        try {
            String[] parts = ip.split("\\.");
            if (parts.length == 4) {
                return parts[0] + "." + parts[1] + "." + parts[2] + ".***";
            }
        } catch (Exception e) {
            log.warn("IP脱敏失败: {}", ip, e);
        }

        return ip;
    }
}