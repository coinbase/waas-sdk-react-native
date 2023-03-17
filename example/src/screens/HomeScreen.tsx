import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  useColorScheme,
  View,
} from 'react-native';

import { Colors } from 'react-native/Libraries/NewAppScreen';

import { PageTitle } from '../components/PageTitle';

import { Section } from '../components/Section';

/**
 * The home screen.
 */
export const HomeScreen = () => {
  const isDarkMode = useColorScheme() === 'dark';
  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}
      >
        <View
          style={{
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          }}
        >
          <PageTitle title="WaaS SDK Demo" />
          <Section title="Pool Demo" runDestination="PoolServiceDemo">
            Creates a WaaS Pool resource.
          </Section>
          <Section title="MPCKeyService Demo" runDestination="MPCKeyServiceDemo">
            Generates Registration Data for the Device, registers the Device on MPCKeyService.
          </Section>
          <Section title="MPCWalletService Demo" runDestination="MPCWalletServiceDemo">
            Creates an MPCWallet, computes DeviceGroup associated with the MPCWallet, generates an Ethereum Address in the MPCWallet.
          </Section>
          <Section title="MPCSignature Demo" runDestination="MPCSignatureDemo">
            Creates an Ethereum transaction with Address in MPCWallet, computes an MPC Signature for it and returns the Signed Transaction.
          </Section>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};
