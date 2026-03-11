package com.niaolemo.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.niaolemo.core.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * 用户数据访问层
 * 
 * @author niaolemo-team
 */
@Mapper
@Repository
public interface UserRepository extends BaseMapper<User> {

    /**
     * 根据用户名查找用户
     */
    @Select("SELECT * FROM users WHERE username = #{username} AND deleted_at IS NULL")
    Optional<User> findByUsername(@Param("username") String username);

    /**
     * 根据邮箱查找用户
     */
    @Select("SELECT * FROM users WHERE email = #{email} AND deleted_at IS NULL")
    Optional<User> findByEmail(@Param("email") String email);

    /**
     * 根据手机号查找用户
     */
    @Select("SELECT * FROM users WHERE phone = #{phone} AND deleted_at IS NULL")
    Optional<User> findByPhone(@Param("phone") String phone);

    /**
     * 根据UUID查找用户
     */
    @Select("SELECT * FROM users WHERE uuid = #{uuid} AND deleted_at IS NULL")
    Optional<User> findByUuid(@Param("uuid") String uuid);

    /**
     * 根据第三方ID查找用户
     */
    @Select("SELECT * FROM users WHERE third_party_id = #{thirdPartyId} AND register_type = #{registerType} AND deleted_at IS NULL")
    Optional<User> findByThirdPartyId(@Param("thirdPartyId") String thirdPartyId, 
                                     @Param("registerType") User.RegisterType registerType);

    /**
     * 检查用户名是否存在
     */
    @Select("SELECT COUNT(*) > 0 FROM users WHERE username = #{username} AND deleted_at IS NULL")
    boolean existsByUsername(@Param("username") String username);

    /**
     * 检查邮箱是否存在
     */
    @Select("SELECT COUNT(*) > 0 FROM users WHERE email = #{email} AND deleted_at IS NULL")
    boolean existsByEmail(@Param("email") String email);

    /**
     * 检查手机号是否存在
     */
    @Select("SELECT COUNT(*) > 0 FROM users WHERE phone = #{phone} AND deleted_at IS NULL")
    boolean existsByPhone(@Param("phone") String phone);

    /**
     * 更新登录失败次数
     */
    @Update("UPDATE users SET login_failure_count = #{count}, updated_at = NOW() WHERE id = #{userId}")
    int updateLoginFailureCount(@Param("userId") Long userId, @Param("count") Integer count);

    /**
     * 锁定用户
     */
    @Update("UPDATE users SET status = 'LOCKED', locked_until = #{lockedUntil}, updated_at = NOW() WHERE id = #{userId}")
    int lockUser(@Param("userId") Long userId, @Param("lockedUntil") LocalDateTime lockedUntil);

    /**
     * 解锁用户
     */
    @Update("UPDATE users SET status = 'ACTIVE', locked_until = NULL, login_failure_count = 0, updated_at = NOW() WHERE id = #{userId}")
    int unlockUser(@Param("userId") Long userId);

    /**
     * 更新最后登录信息
     */
    @Update("UPDATE users SET last_login_at = #{loginTime}, last_login_ip = #{loginIp}, login_failure_count = 0, updated_at = NOW() WHERE id = #{userId}")
    int updateLastLoginInfo(@Param("userId") Long userId, 
                           @Param("loginTime") LocalDateTime loginTime, 
                           @Param("loginIp") String loginIp);

    /**
     * 验证邮箱
     */
    @Update("UPDATE users SET email_verified = true, updated_at = NOW() WHERE id = #{userId}")
    int verifyEmail(@Param("userId") Long userId);

    /**
     * 验证手机号
     */
    @Update("UPDATE users SET phone_verified = true, updated_at = NOW() WHERE id = #{userId}")
    int verifyPhone(@Param("userId") Long userId);
}