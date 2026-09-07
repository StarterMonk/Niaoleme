import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, StyleSheet, Alert, Switch } from 'react-native';
import * as Location from 'expo-location';
import { recordService } from '../services/recordService';
import { authService } from '../services/authService';

const RecordScreen = () => {
  const [selectedColor, setSelectedColor] = useState(null);
  const [selectedVolume, setSelectedVolume] = useState(null);
  const [locationName, setLocationName] = useState('');
  const [latitude, setLatitude] = useState(null);
  const [longitude, setLongitude] = useState(null);
  const [notes, setNotes] = useState('');
  const [shareLocation, setShareLocation] = useState(false);
  const [isPublicToilet, setIsPublicToilet] = useState(false);
  const [hygieneRating, setHygieneRating] = useState(0);
  const [facilityRating, setFacilityRating] = useState(0);
  const [saving, setSaving] = useState(false);

  const colors = [
    { color: '#FFF9C4', label: '透明', desc: '饮水过多' },
    { color: '#FFE082', label: '浅黄', desc: '健康状态' },
    { color: '#FFD54F', label: '深黄', desc: '轻度缺水' },
    { color: '#FFB300', label: '琥珀色', desc: '缺水' },
    { color: '#FF8F00', label: '棕色', desc: '严重缺水' },
  ];

  const volumes = [
    { label: '少量', ml: '<100ml' },
    { label: '正常', ml: '100-300ml' },
    { label: '大量', ml: '>300ml' },
  ];

  const getLocation = async () => {
    try {
      let { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('权限不足', '需要获取位置权限才能使用定位功能');
        return;
      }
      let location = await Location.getCurrentPositionAsync({});
      setLatitude(location.coords.latitude);
      setLongitude(location.coords.longitude);
      setLocationName(`${location.coords.latitude.toFixed(4)}, ${location.coords.longitude.toFixed(4)}`);
    } catch (error) {
      Alert.alert('定位失败', error.message);
    }
  };

  const handleSave = async () => {
    if (!selectedColor) {
      Alert.alert('提示', '请选择嘘嘘颜色');
      return;
    }

    const loggedIn = await authService.isLoggedIn();
    if (!loggedIn) {
      Alert.alert('提示', '请先登录后再记录');
      return;
    }

    setSaving(true);
    try {
      await recordService.create({
        color: selectedColor,
        volume: selectedVolume,
        latitude,
        longitude,
        locationName,
        isPublicToilet,
        hygieneRating: isPublicToilet ? hygieneRating : 0,
        facilityRating: isPublicToilet ? facilityRating : 0,
        notes,
      });
      Alert.alert('保存成功', '您的嘘嘘记录已保存!');
      setSelectedColor(null);
      setSelectedVolume(null);
      setLocationName('');
      setLatitude(null);
      setLongitude(null);
      setNotes('');
      setHygieneRating(0);
      setFacilityRating(0);
    } catch (err) {
      const message = err.code ? err.message : '请检查网络连接';
      Alert.alert('保存失败', message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
      <View style={styles.header}>
        <Text style={styles.title}>记录嘘嘘</Text>
        <Text style={styles.subtitle}>记录每一次,关注健康每一天</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>嘘嘘颜色</Text>
        <Text style={styles.cardHint}>选择最接近的颜色</Text>
        <View style={styles.colorsContainer}>
          {colors.map((item, index) => (
            <TouchableOpacity key={index} style={[styles.colorBtn, { backgroundColor: item.color }, selectedColor === item.label && styles.colorBtnActive]} onPress={() => setSelectedColor(item.label)}>
              <Text style={styles.colorLabel}>{item.label}</Text>
              <Text style={styles.colorDesc}>{item.desc}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>嘘嘘量</Text>
        <View style={styles.volumeContainer}>
          {volumes.map((item, index) => (
            <TouchableOpacity key={index} style={[styles.volumeBtn, selectedVolume === item.label && styles.volumeBtnActive]} onPress={() => setSelectedVolume(item.label)}>
              <Text style={styles.volumeLabel}>{item.label}</Text>
              <Text style={styles.volumeMl}>{item.ml}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>嘘嘘地点</Text>
        <View style={styles.locationRow}>
          <TextInput style={styles.input} placeholder="输入地址或点击定位" placeholderTextColor="#BDBDBD" value={locationName} onChangeText={setLocationName} />
          <TouchableOpacity style={styles.geoBtn} onPress={getLocation}>
            <Text style={styles.btnText}>定位</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.switchRow}>
          <Text style={styles.switchLabel}>分享位置给其他用户</Text>
          <Switch value={shareLocation} onValueChange={setShareLocation} trackColor={{ false: '#E0E0E0', true: '#90CAF9' }} thumbColor={shareLocation ? '#1976D2' : '#f4f3f4'} />
        </View>
        <View style={styles.switchRow}>
          <Text style={styles.switchLabel}>这是公共厕所</Text>
          <Switch value={isPublicToilet} onValueChange={setIsPublicToilet} trackColor={{ false: '#E0E0E0', true: '#90CAF9' }} thumbColor={isPublicToilet ? '#1976D2' : '#f4f3f4'} />
        </View>
        {isPublicToilet && (
          <View style={styles.ratingSection}>
            <View style={styles.ratingRow}>
              <Text style={styles.ratingLabel}>卫生条件</Text>
              <View style={styles.stars}>
                {[1,2,3,4,5].map(star => (
                  <TouchableOpacity key={star} onPress={() => setHygieneRating(star)}>
                    <Text style={[styles.star, hygieneRating >= star && styles.starActive]}>{hygieneRating >= star ? '★' : '☆'}</Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>
            <View style={styles.ratingRow}>
              <Text style={styles.ratingLabel}>硬件设施</Text>
              <View style={styles.stars}>
                {[1,2,3,4,5].map(star => (
                  <TouchableOpacity key={star} onPress={() => setFacilityRating(star)}>
                    <Text style={[styles.star, facilityRating >= star && styles.starActive]}>{facilityRating >= star ? '★' : '☆'}</Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>
          </View>
        )}
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>备注</Text>
        <TextInput style={styles.notesInput} placeholder="添加备注信息(可选)" placeholderTextColor="#BDBDBD" value={notes} onChangeText={setNotes} multiline numberOfLines={3} />
      </View>

      <TouchableOpacity style={[styles.saveBtn, saving && styles.saveBtnDisabled]} onPress={handleSave} disabled={saving}>
        <Text style={styles.saveBtnText}>{saving ? '保存中...' : '保存记录'}</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: { padding: 20, paddingBottom: 40, backgroundColor: '#FAFBFC' },
  header: { marginTop: 8, marginBottom: 20 },
  title: { fontSize: 26, fontWeight: '700', color: '#1A1A2E' },
  subtitle: { fontSize: 13, color: '#9E9E9E', marginTop: 4 },
  card: { backgroundColor: '#fff', borderRadius: 16, padding: 18, marginBottom: 14, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, elevation: 2 },
  cardTitle: { fontSize: 15, fontWeight: '600', color: '#1A1A2E', marginBottom: 4 },
  cardHint: { fontSize: 12, color: '#9E9E9E', marginBottom: 12 },
  colorsContainer: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between' },
  colorBtn: { width: '18%', aspectRatio: 1, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginBottom: 8 },
  colorBtnActive: { borderWidth: 3, borderColor: '#1976D2', transform: [{ scale: 1.08 }] },
  colorLabel: { fontSize: 10, fontWeight: '600', marginTop: 2, color: '#333' },
  colorDesc: { fontSize: 7, color: '#666', marginTop: 1 },
  volumeContainer: { flexDirection: 'row', gap: 10 },
  volumeBtn: { flex: 1, padding: 14, alignItems: 'center', backgroundColor: '#F5F5F5', borderRadius: 12 },
  volumeBtnActive: { backgroundColor: '#E3F2FD', borderWidth: 2, borderColor: '#1976D2' },
  volumeLabel: { fontSize: 14, fontWeight: '600', color: '#333' },
  volumeMl: { fontSize: 11, color: '#9E9E9E', marginTop: 2 },
  locationRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  input: { flex: 1, borderWidth: 1, borderColor: '#E0E0E0', padding: 12, borderRadius: 10, marginRight: 10, backgroundColor: '#FAFAFA', fontSize: 14, color: '#333' },
  geoBtn: { backgroundColor: '#1976D2', padding: 12, borderRadius: 10 },
  btnText: { color: '#fff', fontWeight: '600', fontSize: 14 },
  switchRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 10, borderTopWidth: 1, borderTopColor: '#F5F5F5' },
  switchLabel: { fontSize: 14, color: '#333' },
  ratingSection: { backgroundColor: '#FAFAFA', padding: 14, borderRadius: 10, marginTop: 10 },
  ratingRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
  ratingLabel: { fontSize: 13, color: '#666', width: 70 },
  stars: { flexDirection: 'row' },
  star: { fontSize: 22, color: '#E0E0E0', marginRight: 4 },
  starActive: { color: '#FFB300' },
  notesInput: { borderWidth: 1, borderColor: '#E0E0E0', padding: 12, borderRadius: 10, backgroundColor: '#FAFAFA', textAlignVertical: 'top', minHeight: 80, fontSize: 14, color: '#333' },
  saveBtn: { backgroundColor: '#1976D2', padding: 16, borderRadius: 14, alignItems: 'center', marginTop: 8, shadowColor: '#1976D2', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, elevation: 4 },
  saveBtnDisabled: { opacity: 0.6 },
  saveBtnText: { color: '#fff', fontSize: 16, fontWeight: '600' },
});

export default RecordScreen;
