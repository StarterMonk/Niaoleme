import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Text, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

import ErrorBoundary from './src/components/ErrorBoundary';
import HomeScreen from './src/screens/HomeScreen';
import RecordScreen from './src/screens/RecordScreen';
import MapScreen from './src/screens/MapScreen';
import AnalysisScreen from './src/screens/AnalysisScreen';
import ProfileScreen from './src/screens/ProfileScreen';

const Tab = createBottomTabNavigator();

const TabIcon = ({ emoji, focused }) => (
  <View style={{ alignItems: 'center', justifyContent: 'center', width: 48 }}>
    <Text style={{ fontSize: 22 }}>{emoji}</Text>
    {focused && <View style={{ width: 4, height: 4, borderRadius: 2, backgroundColor: '#1976D2', marginTop: 2 }} />}
  </View>
);

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <ErrorBoundary>
        <NavigationContainer>
          <Tab.Navigator
            screenOptions={({ route }) => ({
              tabBarIcon: ({ focused }) => {
                const icons = {
                  '首页': focused ? '🏠' : '🏡',
                  '记录': focused ? '📝' : '📋',
                  '地图': focused ? '🗺️' : '📍',
                  '分析': focused ? '🤖' : '📊',
                  '我的': focused ? '👤' : '👥',
                };
                return <TabIcon emoji={icons[route.name]} focused={focused} />;
              },
              tabBarActiveTintColor: '#1976D2',
              tabBarInactiveTintColor: '#BDBDBD',
              headerShown: false,
              tabBarStyle: {
                backgroundColor: '#fff',
                borderTopWidth: 0,
                elevation: 8,
                shadowColor: '#000',
                shadowOffset: { width: 0, height: -2 },
                shadowOpacity: 0.08,
                height: 60,
                paddingBottom: 8,
                paddingTop: 6,
              },
              tabBarLabelStyle: { fontSize: 10, fontWeight: '500' },
            })}
          >
            <Tab.Screen name="首页" component={HomeScreen} />
            <Tab.Screen name="记录" component={RecordScreen} />
            <Tab.Screen name="地图" component={MapScreen} />
            <Tab.Screen name="分析" component={AnalysisScreen} />
            <Tab.Screen name="我的" component={ProfileScreen} />
          </Tab.Navigator>
        </NavigationContainer>
      </ErrorBoundary>
    </GestureHandlerRootView>
  );
}
