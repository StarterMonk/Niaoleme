import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, SafeAreaView, Alert, TextInput } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { authService } from '../services/authService';
import { recordService } from '../services/recordService';

const ProfileScreen = ({ navigation }) => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [user, setUser] = useState(null);
  const [stats, setStats] = useState({ totalRecords: 0 });
  const [showLogin, setShowLogin] = useState(false);
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [username, setUsername] = useState('');

  const loadProfile = useCallback(async () => {
    try {
      const loggedIn = await authService.isLoggedIn();
      setIsLoggedIn(loggedIn);
      if (loggedIn) {
        const profile = await authService.getProfile();
        setUser(profile);
        const [statsData, recordsData] = await Promise.all([
          recordService.getStats(),
          recordService.getAll(1, 1),
        ]);
        setStats({ ...statsData, totalRecords: recordsData.total || 0 });
      }
    } catch (err) {
      if (__DEV__) console.log('Load profile error:', err.message);
    }
  }, []);

  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', loadProfile);
    return unsubscribe;
  }, [navigation, loadProfile]);

  const handleAuth = async () => {
    try {
      if (isLogin) {
        await authService.login(email, password);
      } else {
        await authService.register(username, email, password);
      }
      Alert.alert('成功', isLogin ? '登录成功' : '注册成功');
      setShowLogin(false);
      setEmail('');
      setPassword('');
      setUsername('');
      loadProfile();
    } catch (err) {
      const message = err.code ? err.message : '操作失败';
      Alert.alert('失败', message);
    }
  };

  const handleLogout = async () => {
    await authService.logout();
    setIsLoggedIn(false);
    setUser(null);
    setStats({ totalRecords: 0 });
    Alert.alert('已退出', '您已成功退出登录');
  };

  const realStats = {
    totalRecords: stats.totalRecords || 0,
    totalDays: stats.totalRecords > 0 ? Math.max(1, Math.ceil(stats.totalRecords / (stats.todayCount || 1))) : 0,
    avgDaily: stats.todayCount || 0,
    healthScore: stats.healthScore || 0,
  };

  const menuItems = [
    { icon: '📊', title: '历史记录', subtitle: '查看所有嘘嘘记录' },
    { icon: '🏆', title: '健康成就', subtitle: '连续打卡 7 天' },
    { icon: '⚙️', title: '设置', subtitle: '通知、隐私、账号' },
    { icon: '💬', title: '意见反馈', subtitle: '帮助我们改进' },
    { icon: 'ℹ️', title: '关于我们', subtitle: '尿了没 v1.0.0' },
  ];

  if (showLogin) {
    return (
      <SafeAreaView style={styles.container}>
        <ScrollView contentContainerStyle={styles.loginContainer}>
          <Text style={styles.loginTitle}>{isLogin ? '登录' : '注册'}</Text>
          {!isLogin && (
            <TextInput style={styles.input} placeholder="用户名" placeholderTextColor="#BDBDBD" value={username} onChangeText={setUsername} />
          )}
          <TextInput style={styles.input} placeholder="邮箱" placeholderTextColor="#BDBDBD" value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" />
          <TextInput style={styles.input} placeholder="密码" placeholderTextColor="#BDBDBD" value={password} onChangeText={setPassword} secureTextEntry />
          <TouchableOpacity style={styles.authBtn} onPress={handleAuth}>
            <Text style={styles.authBtnText}>{isLogin ? '登录' : '注册'}</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => setIsLogin(!isLogin)}>
            <Text style={styles.switchAuth}>{isLogin ? '没有账号? 去注册' : '已有账号? 去登录'}</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => setShowLogin(false)}>
            <Text style={styles.cancelAuth}>返回</Text>
          </TouchableOpacity>
        </ScrollView>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{isLoggedIn ? (user?.username?.[0] || 'U') : '?'}</Text>
          </View>
          <Text style={styles.userName}>{isLoggedIn ? user?.username : '未登录'}</Text>
          <Text style={styles.userEmail}>{isLoggedIn ? user?.email : '点击登录开始使用'}</Text>
        </View>

        <View style={styles.statsContainer}>
          <View style={styles.statItem}><Text style={styles.statNumber}>{realStats.totalRecords}</Text><Text style={styles.statLabel}>总记录</Text></View>
          <View style={styles.statDivider} />
          <View style={styles.statItem}><Text style={styles.statNumber}>{realStats.totalDays}</Text><Text style={styles.statLabel}>使用天数</Text></View>
          <View style={styles.statDivider} />
          <View style={styles.statItem}><Text style={styles.statNumber}>{realStats.avgDaily}</Text><Text style={styles.statLabel}>日均次数</Text></View>
          <View style={styles.statDivider} />
          <View style={styles.statItem}><Text style={styles.statNumber}>{realStats.healthScore}</Text><Text style={styles.statLabel}>健康分</Text></View>
        </View>

        <View style={styles.menuContainer}>
          {menuItems.map((item, index) => (
            <TouchableOpacity key={index} style={styles.menuItem}>
              <Text style={styles.menuIcon}>{item.icon}</Text>
              <View style={styles.menuText}>
                <Text style={styles.menuTitle}>{item.title}</Text>
                <Text style={styles.menuSubtitle}>{item.subtitle}</Text>
              </View>
              <Text style={styles.menuArrow}>›</Text>
            </TouchableOpacity>
          ))}
        </View>

        <View style={styles.adCard}>
          <View style={styles.adBadge}><Text style={styles.adBadgeText}>AD</Text></View>
          <Text style={styles.adTitle}>女性卫生用品 · 健康生活</Text>
        </View>

        {isLoggedIn ? (
          <TouchableOpacity style={styles.logoutBtn} onPress={handleLogout}>
            <Text style={styles.logoutText}>退出登录</Text>
          </TouchableOpacity>
        ) : (
          <TouchableOpacity style={styles.loginBtn} onPress={() => setShowLogin(true)}>
            <Text style={styles.loginBtnText}>登录/注册</Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFBFC' },
  header: { backgroundColor: '#fff', padding: 24, alignItems: 'center', paddingTop: 20 },
  avatar: { width: 72, height: 72, borderRadius: 36, backgroundColor: '#1976D2', justifyContent: 'center', alignItems: 'center', marginBottom: 10 },
  avatarText: { fontSize: 28, color: '#fff', fontWeight: '700' },
  userName: { fontSize: 18, fontWeight: '700', color: '#1A1A2E' },
  userEmail: { fontSize: 13, color: '#9E9E9E', marginTop: 3 },
  statsContainer: { flexDirection: 'row', backgroundColor: '#fff', margin: 20, borderRadius: 16, padding: 18, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, elevation: 2 },
  statItem: { flex: 1, alignItems: 'center' },
  statNumber: { fontSize: 20, fontWeight: '700', color: '#1976D2' },
  statLabel: { fontSize: 10, color: '#999', marginTop: 3 },
  statDivider: { width: 1, backgroundColor: '#F0F0F0' },
  menuContainer: { backgroundColor: '#fff', marginHorizontal: 20, borderRadius: 16, overflow: 'hidden', shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, elevation: 2 },
  menuItem: { flexDirection: 'row', alignItems: 'center', padding: 16, borderBottomWidth: 1, borderBottomColor: '#F5F5F5' },
  menuIcon: { fontSize: 22, marginRight: 14 },
  menuText: { flex: 1 },
  menuTitle: { fontSize: 15, fontWeight: '500', color: '#1A1A2E' },
  menuSubtitle: { fontSize: 11, color: '#9E9E9E', marginTop: 2 },
  menuArrow: { fontSize: 22, color: '#E0E0E0' },
  adCard: { marginHorizontal: 20, marginTop: 16, backgroundColor: '#FCE4EC', borderRadius: 16, padding: 16, alignItems: 'center', borderWidth: 1, borderColor: '#F8BBD0' },
  adBadge: { backgroundColor: '#F48FB1', paddingHorizontal: 8, paddingVertical: 2, borderRadius: 6, marginBottom: 6 },
  adBadgeText: { fontSize: 10, color: '#fff', fontWeight: '700' },
  adTitle: { fontSize: 14, color: '#333', fontWeight: '500' },
  logoutBtn: { margin: 20, marginTop: 16, padding: 15, backgroundColor: '#fff', borderRadius: 14, alignItems: 'center', borderWidth: 1.5, borderColor: '#E57373' },
  logoutText: { color: '#E57373', fontSize: 15, fontWeight: '600' },
  loginBtn: { margin: 20, marginTop: 16, padding: 15, backgroundColor: '#1976D2', borderRadius: 14, alignItems: 'center' },
  loginBtnText: { color: '#fff', fontSize: 15, fontWeight: '600' },
  loginContainer: { padding: 24, paddingTop: 40, alignItems: 'center' },
  loginTitle: { fontSize: 26, fontWeight: '700', color: '#1A1A2E', marginBottom: 30 },
  input: { width: '100%', borderWidth: 1, borderColor: '#E0E0E0', padding: 14, borderRadius: 12, marginBottom: 14, backgroundColor: '#FAFAFA', fontSize: 15, color: '#333' },
  authBtn: { width: '100%', backgroundColor: '#1976D2', padding: 16, borderRadius: 12, alignItems: 'center', marginTop: 8 },
  authBtnText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  switchAuth: { marginTop: 16, color: '#1976D2', fontSize: 14 },
  cancelAuth: { marginTop: 12, color: '#999', fontSize: 14 },
});

export default ProfileScreen;
