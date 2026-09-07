import React, { useState, useEffect, useCallback, useRef } from 'react';
import { View, Text, TouchableOpacity, FlatList, StyleSheet, SafeAreaView, ActivityIndicator, RefreshControl } from 'react-native';
import { recordService } from '../services/recordService';
import { authService } from '../services/authService';

const AnalysisScreen = ({ navigation }) => {
  const [stats, setStats] = useState({ todayCount: 0, healthScore: 0, dominantColor: '未知', weeklyByDay: [] });
  const [messages, setMessages] = useState([
    { id: '0', text: '你好!我是你的嘘嘘健康小助手。\n\n请选择一项服务:', type: 'bot' }
  ]);
  const [isLoading, setIsLoading] = useState(false);
  const [showChart, setShowChart] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const flatListRef = useRef(null);

  const loadData = useCallback(async () => {
    try {
      const loggedIn = await authService.isLoggedIn();
      if (loggedIn) {
        const data = await recordService.getStats();
        setStats(data);
      }
    } catch (err) {
      if (__DEV__) console.log('Load stats error:', err.message);
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

  const addMessage = (text, type = 'user') => {
    setMessages(prev => [...prev, { id: Date.now().toString(), text, type }]);
    setTimeout(() => flatListRef.current?.scrollToEnd({ animated: true }), 100);
  };

  const maxCount = Math.max(...(stats.weeklyByDay || []).map(d => d.count), 1);

  const handleOption = async (option) => {
    if (isLoading) return;
    setIsLoading(true);

    if (option === 1) {
      addMessage('分析最近一周记录', 'user');
      await new Promise(r => setTimeout(r, 1500));
      addMessage(`本周分析报告:\n\n记录次数: ${stats.todayCount * 7 || 0}次\n健康评分: ${stats.healthScore}/100\n主要颜色: ${stats.dominantColor}\n\n建议: 继续保持良好饮水习惯!`, 'bot');
    } else if (option === 2) {
      addMessage('AI 深度分析', 'user');
      await new Promise(r => setTimeout(r, 2000));
      const score = stats.healthScore;
      let advice = '综合评估: 您的泌尿系统健康状况良好!';
      if (score < 60) advice = '建议: 请多喝水,注意饮食健康!';
      else if (score < 80) advice = '建议: 保持良好饮水习惯,适当运动.';
      addMessage(`AI深度分析结果:\n\n健康评分: ${score}/100\n主要颜色: ${stats.dominantColor}\n\n${advice}`, 'bot');
    } else if (option === 3) {
      addMessage('查看健康趋势', 'user');
      setShowChart(true);
      await new Promise(r => setTimeout(r, 1000));
      addMessage('已为您展示本周趋势图表。', 'bot');
    }
    setIsLoading(false);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>智能分析</Text>
      </View>

      {showChart && stats.weeklyByDay?.length > 0 && (
        <View style={styles.chartCard}>
          <View style={styles.chartHeader}>
            <Text style={styles.chartTitle}>本周健康趋势</Text>
            <TouchableOpacity onPress={() => setShowChart(false)}><Text style={styles.hideBtn}>收起</Text></TouchableOpacity>
          </View>
          <View style={styles.scoreRow}>
            <View style={styles.scoreCircle}>
              <Text style={styles.scoreNumber}>{stats.healthScore}</Text>
              <Text style={styles.scoreLabel}>健康评分</Text>
            </View>
            <View style={styles.scoreInfo}>
              <View style={styles.scoreItem}><Text style={styles.scoreDot}>●</Text><Text style={styles.scoreText}>排尿频率: 今日{stats.todayCount}次</Text></View>
              <View style={styles.scoreItem}><Text style={[styles.scoreDot, { color: '#66BB6A' }]}>●</Text><Text style={styles.scoreText}>尿液颜色: {stats.dominantColor}</Text></View>
            </View>
          </View>
          <View style={styles.chart}>
            {stats.weeklyByDay.map((item, index) => (
              <View key={index} style={styles.barContainer}>
                <Text style={styles.barValue}>{item.count}</Text>
                <View style={[styles.bar, { height: Math.max((item.count / maxCount) * 70, 4) }]} />
                <Text style={styles.barLabel}>{item.day}</Text>
              </View>
            ))}
          </View>
        </View>
      )}

      <FlatList ref={flatListRef} data={messages} keyExtractor={item => item.id} style={styles.chatContainer} contentContainerStyle={{ paddingBottom: 20 }}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        renderItem={({ item }) => (
          <View style={[styles.msgBubble, item.type === 'user' ? styles.userMsg : styles.botMsg]}>
            <Text style={item.type === 'user' ? styles.userText : styles.botText}>{item.text}</Text>
          </View>
        )}
      />

      {isLoading && (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="small" color="#1976D2" />
          <Text style={styles.loadingText}>分析中...</Text>
        </View>
      )}

      <View style={styles.optionsContainer}>
        <TouchableOpacity style={styles.optionBtn} onPress={() => handleOption(1)}><Text style={styles.optionText}>一周分析</Text></TouchableOpacity>
        <TouchableOpacity style={[styles.optionBtn, styles.aiBtn]} onPress={() => handleOption(2)}><Text style={[styles.optionText, styles.aiBtnText]}>AI 分析</Text></TouchableOpacity>
        <TouchableOpacity style={styles.optionBtn} onPress={() => handleOption(3)}><Text style={styles.optionText}>健康趋势</Text></TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFBFC' },
  header: { padding: 20, backgroundColor: '#fff', borderBottomWidth: 1, borderBottomColor: '#F0F0F0', alignItems: 'center' },
  headerTitle: { fontSize: 18, fontWeight: '700', color: '#1A1A2E' },
  chartCard: { backgroundColor: '#fff', margin: 20, borderRadius: 16, padding: 18, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, elevation: 2 },
  chartHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 },
  chartTitle: { fontSize: 15, fontWeight: '600', color: '#1A1A2E' },
  hideBtn: { fontSize: 12, color: '#1976D2' },
  scoreRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 16 },
  scoreCircle: { width: 72, height: 72, borderRadius: 36, backgroundColor: '#E3F2FD', justifyContent: 'center', alignItems: 'center', marginRight: 18 },
  scoreNumber: { fontSize: 24, fontWeight: '700', color: '#1976D2' },
  scoreLabel: { fontSize: 9, color: '#64B5F6', marginTop: 2 },
  scoreInfo: { flex: 1 },
  scoreItem: { flexDirection: 'row', alignItems: 'center', marginBottom: 5 },
  scoreDot: { fontSize: 8, color: '#1976D2', marginRight: 6 },
  scoreText: { fontSize: 13, color: '#333' },
  chart: { flexDirection: 'row', justifyContent: 'space-around', alignItems: 'flex-end', height: 110, paddingTop: 8 },
  barContainer: { alignItems: 'center' },
  barValue: { fontSize: 10, color: '#999', marginBottom: 4 },
  bar: { width: 22, backgroundColor: '#42A5F5', borderRadius: 6 },
  barLabel: { fontSize: 10, color: '#999', marginTop: 4 },
  chatContainer: { flex: 1, padding: 16 },
  msgBubble: { padding: 14, borderRadius: 18, maxWidth: '80%', marginBottom: 10 },
  userMsg: { alignSelf: 'flex-end', backgroundColor: '#1976D2', borderBottomRightRadius: 4 },
  botMsg: { alignSelf: 'flex-start', backgroundColor: '#fff', borderBottomLeftRadius: 4, borderWidth: 1, borderColor: '#F0F0F0' },
  userText: { color: '#fff', fontSize: 14, lineHeight: 21 },
  botText: { color: '#333', fontSize: 14, lineHeight: 21 },
  loadingContainer: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', padding: 8 },
  loadingText: { marginLeft: 6, color: '#999', fontSize: 13 },
  optionsContainer: { padding: 14, backgroundColor: '#fff', borderTopWidth: 1, borderTopColor: '#F0F0F0', flexDirection: 'row', justifyContent: 'space-between' },
  optionBtn: { paddingVertical: 10, paddingHorizontal: 16, borderWidth: 1.5, borderColor: '#1976D2', borderRadius: 20, backgroundColor: '#fff' },
  aiBtn: { backgroundColor: '#1976D2' },
  optionText: { color: '#1976D2', fontWeight: '600', fontSize: 13 },
  aiBtnText: { color: '#fff' },
});

export default AnalysisScreen;
