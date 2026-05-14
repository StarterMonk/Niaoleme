import { registerRootComponent } from 'expo';
import React from 'react';
import { View, Text } from 'react-native';

const App = () => (
  <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
    <Text>Welcome to Niaoleme App</Text>
  </View>
);

registerRootComponent(App);
