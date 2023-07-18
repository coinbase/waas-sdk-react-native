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
          <PageTitle title="WaaS SDK Demos" />
          <Section title="Pool Creation" runDestination="PoolServiceDemo">
            Create a Pool resource.
          </Section>
          <Section
            title="Device Registration"
            runDestination="MPCKeyServiceDemo"
          >
            Generate registration data for the Device and register the Device
            with WaaS.
          </Section>
          <Section
            title="Address Generation"
            runDestination="MPCWalletServiceDemo"
          >
            Create an MPCWallet with an associated DeviceGroup and generate an
            Ethereum Address in the MPCWallet.
          </Section>
          <Section
            title="Transaction Signing"
            runDestination="MPCSignatureDemo"
          >
            Compute a signed transaction for the Ethereum Address.
          </Section>
          <Section title="Key Export" runDestination="MPCKeyExportDemo">
            Export the private keys corresponding to the MPCKeys in the
            DeviceGroup.
          </Section>
          <Section title="Device Backup" runDestination="DeviceBackupDemo">
            Export a Device backup that can be used to restore a Device within a
            DeviceGroup.
          </Section>
          <Section title="Device Restore" runDestination="DeviceAdditionDemo">
            Restore an old Device by adding a new Device to an existing
            DeviceGroup using the backup prepared by the old Device.
          </Section>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};
