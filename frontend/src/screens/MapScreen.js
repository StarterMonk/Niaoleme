import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, FlatList, TouchableOpacity, Modal, TextInput, StyleSheet, SafeAreaView, Alert, RefreshControl } from 'react-native';
import * as Location from 'expo-location';
import { toiletService } from '../services/toiletService';
import { authService } from '../services/authService';

const MapScreen = ({ navigation }) => {
  const [toilets, setToilets] = useState([]);
  const [selectedToilet, setSelectedToilet] = useState(null);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newToiletName, setNewToiletName] = useState('');
  const [newToiletComment, setNewToiletComment] = useState('');
  const [userLocation, setUserLocation] = useState(null);
  const [refreshing, setRefreshing] = useState(false);

  const loadToilets = useCallback(async () => {
    try {
      let { status } = await Location.requestForegroundPermissionsAsync();
      let loc = null;
      if (status === 'granted') {
        loc = await Location.getCurrentPositionAsync({});
        setUserLocation(loc.coords);
      }
      const lat = loc?.coords.latitude || 29.56;
      const lng = loc?.coords.longitude || 106.55;
      const data = await toiletService.getNearby(lat, lng);
      setToilets(data.toilets || []);
    } catch (err) {
      if (__DEV__) console.log('Load toilets error:', err.message);
    }
  }, []);

  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', loadToilets);
    loadToilets();
    return unsubscribe;
  }, [navigation, loadToilets]);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadToilets();
    setRefreshing(false);
  };

  const renderStars = (count) => {
    const num = parseFloat(count) || 0;
    return '\u2605'.repeat(Math.round(num)) + '\u2606'.repeat(5 - Math.round(num));
  };

  const handleAddToilet = async () => {
    const loggedIn = await authService.isLoggedIn();
    if (!loggedIn) {
      Alert.alert('提示', '请先登录后再添加');
      return;
    }
    if (!newToiletName.trim()) {
      Alert.alert('提示', '请输入厕所名称');
      return;
    }
    try {
      await toiletService.create({
        name: newToiletName,
        latitude: userLocation?.latitude || 29.56,
        longitude: userLocation?.longitude || 106.55,
        tags: [],
      });
      Alert.alert('添加成功', '感谢您的贡献!');
      setShowAddModal(false);
      setNewToiletName('');
      setNewToiletComment('');
      loadToilets();
    } catch (err) {
      Alert.alert('添加失败', err.response?.data?.error || '请检查网络');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <View>
          <Text style={styles.headerTitle}>附近厕所</Text>
          <Text style={styles.headerSubtitle}>找到最近的公共厕所</Text>
        </View>
        <TouchableOpacity style={styles.addBtn} onPress={() => setShowAddModal(true)}>
          <Text style={styles.addBtnText}>+ 添加</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.mapPlaceholder}>
        {toilets.slice(0, 4).map((toilet, index) => (
          <TouchableOpacity key={toilet.id} style={[styles.mapDot, { top: 20 + index * 40, left: 30 + index * 55 }]} onPress={() => setSelectedToilet(toilet)}>
            <Text style={styles.mapDotText}>📍</Text>
            <Text style={styles.mapDotLabel}>{toilet.distance || '?'}</Text>
          </TouchableOpacity>
        ))}
        <Text style={styles.mapHint}>点击标记查看详情</Text>
      </View>

      <Text style={styles.sectionTitle}>厕所评价</Text>
      <FlatList data={toilets} keyExtractor={item => item.id} contentContainerStyle={styles.listContent} showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        renderItem={({ item }) => (
          <TouchableOpacity style={styles.reviewCard} onPress={() => setSelectedToilet(item)}>
            <View style={styles.reviewHeader}>
              <Text style={styles.toiletName}>{item.name}</Text>
              {item.distance && <View style={styles.distanceBadge}><Text style={styles.distanceText}>{item.distance}</Text></View>}
            </View>
            <View style={styles.ratingRow}>
              <Text style={styles.ratingLabel}>卫生</Text><Text style={styles.ratingStars}>{renderStars(item.hygiene)}</Text>
              <Text style={styles.ratingLabel}>设施</Text><Text style={styles.ratingStars}>{renderStars(item.facility)}</Text>
            </View>
            {item.tags?.length > 0 && (
              <View style={styles.tagsRow}>
                {item.tags.map((tag, i) => <View key={i} style={styles.tag}><Text style={styles.tagText}>{tag}</Text></View>)}
              </View>
            )}
          </TouchableOpacity>
        )}
      />

      <Modal visible={!!selectedToilet} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>{selectedToilet?.name}</Text>
              <TouchableOpacity onPress={() => setSelectedToilet(null)}><Text style={styles.modalClose}>✕</Text></TouchableOpacity>
            </View>
            <View style={styles.modalDivider} />
            <View style={styles.modalRatingRow}>
              <Text style={styles.modalRatingLabel}>卫生条件</Text>
              <Text style={styles.modalRatingStars}>{renderStars(selectedToilet?.hygiene)}</Text>
            </View>
            <View style={styles.modalRatingRow}>
              <Text style={styles.modalRatingLabel}>硬件设施</Text>
              <Text style={styles.modalRatingStars}>{renderStars(selectedToilet?.facility)}</Text>
            </View>
            {selectedToilet?.distance && <Text style={styles.modalDistance}>距离: {selectedToilet.distance}</Text>}
            <TouchableOpacity style={styles.modalBtn} onPress={() => setSelectedToilet(null)}>
              <Text style={styles.modalBtnText}>确定</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      <Modal visible={showAddModal} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>添加新厕所</Text>
              <TouchableOpacity onPress={() => setShowAddModal(false)}><Text style={styles.modalClose}>✕</Text></TouchableOpacity>
            </View>
            <View style={styles.modalDivider} />
            <TextInput style={styles.input} placeholder="厕所名称" placeholderTextColor="#BDBDBD" value={newToiletName} onChangeText={setNewToiletName} />
            <TextInput style={[styles.input, styles.textArea]} placeholder="评价内容(可选)" placeholderTextColor="#BDBDBD" value={newToiletComment} onChangeText={setNewToiletComment} multiline />
            <TouchableOpacity style={styles.modalBtn} onPress={handleAddToilet}>
              <Text style={styles.modalBtnText}>提交</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFBFC' },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 20 },
  headerTitle: { fontSize: 24, fontWeight: '700', color: '#1A1A2E' },
  headerSubtitle: { fontSize: 13, color: '#9E9E9E', marginTop: 2 },
  addBtn: { backgroundColor: '#1976D2', paddingHorizontal: 14, paddingVertical: 8, borderRadius: 10 },
  addBtnText: { color: '#fff', fontWeight: '600', fontSize: 14 },
  mapPlaceholder: { height: 180, backgroundColor: '#E3F2FD', marginHorizontal: 20, borderRadius: 16, overflow: 'hidden', position: 'relative' },
  mapDot: { position: 'absolute', alignItems: 'center' },
  mapDotText: { fontSize: 24 },
  mapDotLabel: { fontSize: 10, color: '#1565C0', fontWeight: '600' },
  mapHint: { position: 'absolute', bottom: 12, alignSelf: 'center', color: '#666', fontSize: 12, backgroundColor: 'rgba(255,255,255,0.9)', paddingHorizontal: 10, paddingVertical: 5, borderRadius: 8 },
  sectionTitle: { fontSize: 16, fontWeight: '600', padding: 20, paddingBottom: 10, color: '#1A1A2E' },
  listContent: { paddingHorizontal: 20, paddingBottom: 20 },
  reviewCard: { backgroundColor: '#fff', borderRadius: 14, padding: 16, marginBottom: 10, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, elevation: 2 },
  reviewHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 },
  toiletName: { fontWeight: '600', fontSize: 15, color: '#1A1A2E', flex: 1 },
  distanceBadge: { backgroundColor: '#E3F2FD', paddingHorizontal: 10, paddingVertical: 4, borderRadius: 8 },
  distanceText: { fontSize: 12, color: '#1976D2', fontWeight: '600' },
  ratingRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 6 },
  ratingLabel: { fontSize: 12, color: '#9E9E9E', width: 36, marginRight: 4 },
  ratingStars: { fontSize: 13, color: '#FFB300', marginRight: 12 },
  tagsRow: { flexDirection: 'row', flexWrap: 'wrap', marginTop: 10 },
  tag: { backgroundColor: '#E8F5E9', paddingHorizontal: 10, paddingVertical: 4, borderRadius: 8, marginRight: 6 },
  tagText: { fontSize: 11, color: '#388E3C' },
  modalOverlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.4)', justifyContent: 'center', padding: 24 },
  modalContent: { backgroundColor: '#fff', borderRadius: 20, padding: 22 },
  modalHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  modalTitle: { fontSize: 18, fontWeight: '700', color: '#1A1A2E' },
  modalClose: { fontSize: 22, color: '#9E9E9E' },
  modalDivider: { height: 1, backgroundColor: '#F0F0F0', marginVertical: 14 },
  modalRatingRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8 },
  modalRatingLabel: { fontSize: 14, color: '#666' },
  modalRatingStars: { fontSize: 15, color: '#FFB300' },
  modalDistance: { fontSize: 14, color: '#1976D2', textAlign: 'center', marginTop: 10 },
  modalBtn: { backgroundColor: '#1976D2', padding: 14, borderRadius: 12, alignItems: 'center', marginTop: 18 },
  modalBtnText: { color: '#fff', fontWeight: '600', fontSize: 15 },
  input: { borderWidth: 1, borderColor: '#E0E0E0', padding: 12, borderRadius: 10, marginBottom: 12, backgroundColor: '#FAFAFA', fontSize: 14, color: '#333' },
  textArea: { minHeight: 80, textAlignVertical: 'top' },
});

export default MapScreen;
