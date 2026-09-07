import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, SafeAreaView, RefreshControl } from 'react-native';
import { recordService } from '../services/recordService';
import { authService } from '../services/authService';

const colorMap = {
  '透明': { color: '#FFF9C4', icon: '🫧' },
  '浅黄': { color: '#FFE082', icon: '💧' },
  '深黄': { color: '#FFD54F', icon: '🌊' },
  '琥珀色': { color: '#FFB300', icon: '🍯' },
  '棕色': { color: '#FF8F00', icon: '☕' },
};

const HomeScreen = ({ navigation }) => {
  const [stats, setStats] = useState({ todayCount: 0, healthScore: 0, dominantColor: '未知', weeklyByDay: [] });
  const [recentRecords, setRecentRecords] = useState([]);
  const [refreshing, setRefreshing] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const loadData = useCallback(async () => {
    try {
      const loggedIn = await authService.isLoggedIn();
      setIsLoggedIn(loggedIn);
      if (loggedIn) {
        const [statsData, recordsData] = await Promise.all([
          recordService.getStats(),
          recordService.getAll(1, 5),
        ]);
        setStats(statsData);
        setRecentRecords(recordsData.records || []);
      }
    } catch (err) {
      if (__DEV__) console.log('Load data error:', err.message);
    }
  }, []);

  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', loadData);
    return unsubscribe;
  }, [navigation, loadData]);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const formatTime = (dateStr) => {
    const d = new Date(dateStr);
    return `${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`;
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}>
        <View style={styles.header}>
          <View>
            <Text style={styles.greeting}>Hi! 今天嘘嘘了吗?</Text>
            <Text style={styles.subGreeting}>
              {isLoggedIn ? '关注健康,从每一次记录开始' : '登录后开始记录健康数据'}
            </Text>
          </View>
          <View style={styles.headerIcon}>
            <Text style={styles.headerEmoji}>👋</Text>
          </View>
        </View>

        <View style={styles.statsRow}>
          <View style={[styles.statCard, { backgroundColor: '#E3F2FD' }]}>
            <Text style={styles.statIcon}>💧</Text>
            <Text style={styles.statNumber}>{stats.todayCount}</Text>
            <Text style={styles.statLabel}>今日排尿</Text>
          </View>
          <View style={[styles.statCard, { backgroundColor: '#E8F5E9' }]}>
            <Text style={styles.statIcon}>✨</Text>
            <Text style={styles.statNumber}>{stats.healthScore}</Text>
            <Text style={styles.statLabel}>健康评分</Text>
          </View>
          <View style={[styles.statCard, { backgroundColor: '#FFF8E1' }]}>
            <Text style={styles.statIcon}>🎨</Text>
            <Text style={styles.statNumber}>{stats.dominantColor}</Text>
            <Text style={styles.statLabel}>主要颜色</Text>
          </View>
        </View>

        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>最近记录</Text>
            <TouchableOpacity onPress={() => navigation.navigate('记录')} style={styles.seeAllBtn}>
              <Text style={styles.seeAll}>查看全部</Text>
            </TouchableOpacity>
          </View>
          {recentRecords.length === 0 ? (
            <Text style={styles.emptyText}>暂无记录,快去记录一次吧</Text>
          ) : (
            recentRecords.map((record) => {
              const cm = colorMap[record.color] || { color: '#FFE082', icon: '💧' };
              return (
                <View key={record._id} style={styles.recordItem}>
                  <View style={[styles.recordIconWrap, { backgroundColor: cm.color + '40' }]}>
                    <Text style={styles.recordIcon}>{cm.icon}</Text>
                  </View>
                  <View style={styles.recordInfo}>
                    <Text style={styles.recordTime}>{formatTime(record.createdAt)}</Text>
                    <Text style={styles.recordDetail}>{record.volume || '未知'} · {record.color}</Text>
                  </View>
                </View>
              );
            })
          )}
        </View>

        <View style={styles.quickActions}>
          <Text style={styles.sectionTitle}>快捷操作</Text>
          <View style={styles.actionRow}>
            <TouchableOpacity style={styles.actionBtn} onPress={() => navigation.navigate('记录')}>
              <View style={[styles.actionIconWrap, { backgroundColor: '#E3F2FD' }]}>
                <Text style={styles.actionEmoji}>💧</Text>
              </View>
              <Text style={styles.actionText}>记录嘘嘘</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.actionBtn} onPress={() => navigation.navigate('地图')}>
              <View style={[styles.actionIconWrap, { backgroundColor: '#E8F5E9' }]}>
                <Text style={styles.actionEmoji}>🚻</Text>
              </View>
              <Text style={styles.actionText}>找厕所</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.actionBtn} onPress={() => navigation.navigate('分析')}>
              <View style={[styles.actionIconWrap, { backgroundColor: '#F3E5F5' }]}>
                <Text style={styles.actionEmoji}>🤖</Text>
              </View>
              <Text style={styles.actionText}>AI分析</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View style={styles.adCard}>
          <View style={styles.adBadge}><Text style={styles.adBadgeText}>AD</Text></View>
          <Text style={styles.adTitle}>成人纸尿裤 · 女性卫生用品</Text>
          <Text style={styles.adSub}>了解更多优惠</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFBFC' },
  scrollContent: { paddingBottom: 30 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 24, paddingBottom: 16 },
  greeting: { fontSize: 24, fontWeight: '700', color: '#1A1A2E' },
  subGreeting: { fontSize: 13, color: '#9E9E9E', marginTop: 4 },
  headerIcon: { width: 48, height: 48, borderRadius: 24, backgroundColor: '#FFF3E0', justifyContent: 'center', alignItems: 'center' },
  headerEmoji: { fontSize: 24 },
  statsRow: { flexDirection: 'row', paddingHorizontal: 20, gap: 12 },
  statCard: { flex: 1, padding: 16, borderRadius: 16, alignItems: 'center' },
  statIcon: { fontSize: 20, marginBottom: 4 },
  statNumber: { fontSize: 22, fontWeight: '700', color: '#1A1A2E' },
  statLabel: { fontSize: 11, color: '#666', marginTop: 2 },
  section: { backgroundColor: '#fff', marginHorizontal: 20, marginTop: 16, borderRadius: 16, padding: 18, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, elevation: 2 },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 12 },
  sectionTitle: { fontSize: 16, fontWeight: '600', color: '#1A1A2E' },
  seeAllBtn: { backgroundColor: '#E3F2FD', paddingHorizontal: 12, paddingVertical: 4, borderRadius: 12 },
  seeAll: { fontSize: 12, color: '#1976D2', fontWeight: '500' },
  emptyText: { textAlign: 'center', color: '#BDBDBD', paddingVertical: 20, fontSize: 14 },
  recordItem: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#F5F5F5' },
  recordIconWrap: { width: 40, height: 40, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginRight: 12 },
  recordIcon: { fontSize: 18 },
  recordInfo: { flex: 1 },
  recordTime: { fontSize: 15, fontWeight: '600', color: '#1A1A2E' },
  recordDetail: { fontSize: 12, color: '#9E9E9E', marginTop: 2 },
  quickActions: { backgroundColor: '#fff', marginHorizontal: 20, marginTop: 16, borderRadius: 16, padding: 18, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, elevation: 2 },
  actionRow: { flexDirection: 'row', justifyContent: 'space-around', marginTop: 12 },
  actionBtn: { alignItems: 'center' },
  actionIconWrap: { width: 56, height: 56, borderRadius: 16, justifyContent: 'center', alignItems: 'center', marginBottom: 8 },
  actionEmoji: { fontSize: 26 },
  actionText: { fontSize: 12, color: '#666', fontWeight: '500' },
  adCard: { marginHorizontal: 20, marginTop: 16, backgroundColor: '#F0F4FF', borderRadius: 16, padding: 16, alignItems: 'center', borderWidth: 1, borderColor: '#E3E8F0' },
  adBadge: { backgroundColor: '#C5CAE9', paddingHorizontal: 8, paddingVertical: 2, borderRadius: 6, marginBottom: 8 },
  adBadgeText: { fontSize: 10, color: '#5C6BC0', fontWeight: '700' },
  adTitle: { fontSize: 14, color: '#333', fontWeight: '500' },
  adSub: { fontSize: 12, color: '#9E9E9E', marginTop: 4 },
});

export default HomeScreen;
