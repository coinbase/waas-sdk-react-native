import React, { useState, useEffect, useContext } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { HomeScreen } from './screens/HomeScreen';
import { PoolServiceDemo } from './screens/PoolServiceDemo';
import { MPCKeyServiceDemo } from './screens/MPCKeyServiceDemo';
import { MPCWalletServiceDemo } from './screens/MPCWalletServiceDemo';
import { MPCSignatureDemo } from './screens/MPCSignatureDemo';
import { MPCKeyExportDemo } from './screens/MPCKeyExportDemo';
import AppContext from './components/AppContext';
import { DeviceBackupDemo } from './screens/DeviceBackupDemo';
import { DeviceAdditionDemo } from './screens/DeviceAdditionDemo';
import { ModeSelectionScreen } from './screens/ModeSelectionScreen';
import { ModeContext } from './utils/ModeProvider';
import { ModeProvider } from './utils/ModeProvider';

/** The navigation stack. */
const Stack = createNativeStackNavigator();

function SetupApp() {
  const [apiKeyData, setApiKeyData] = useState<any>({});
  const [proxyUrlData, setProxyUrlData] = useState<string>('');
  const { selectedMode } = useContext(ModeContext);

  useEffect(() => {
    if (selectedMode === 'direct-mode') {
      const cloudAPIKey = require('./.coinbase_cloud_api_key.json');

      setApiKeyData(cloudAPIKey);
    } else {
      const config = require('./config.json');

      setProxyUrlData(config.proxyUrl);
    }
  }, [selectedMode]);

  const apiKeyName = apiKeyData.name || '';
  const privateKey = apiKeyData.privateKey || '';
  const proxyUrl = proxyUrlData || '';

  return (
    <AppContext.Provider value={{ apiKeyName, privateKey, proxyUrl }}>
      <NavigationContainer>
        <Stack.Navigator initialRouteName="ModeSelectionScreen">
          <Stack.Screen
            name="ModeSelectionScreen"
            component={ModeSelectionScreen}
          />
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="PoolServiceDemo" component={PoolServiceDemo} />
          <Stack.Screen
            name="MPCKeyServiceDemo"
            component={MPCKeyServiceDemo}
          />
          <Stack.Screen
            name="MPCWalletServiceDemo"
            component={MPCWalletServiceDemo}
          />
          <Stack.Screen name="MPCSignatureDemo" component={MPCSignatureDemo} />
          <Stack.Screen name="MPCKeyExportDemo" component={MPCKeyExportDemo} />
          <Stack.Screen name="DeviceBackupDemo" component={DeviceBackupDemo} />
          <Stack.Screen
            name="DeviceAdditionDemo"
            component={DeviceAdditionDemo}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </AppContext.Provider>
  );
}

export default function App() {
  return (
    <ModeProvider>
      <SetupApp />
    </ModeProvider>
  );
}
