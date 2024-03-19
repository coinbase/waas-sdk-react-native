import React from 'react';
import { SafeAreaView, ScrollView, StatusBar, useColorScheme, View, } from 'react-native';
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
    return (React.createElement(SafeAreaView, { style: backgroundStyle },
        React.createElement(StatusBar, { barStyle: isDarkMode ? 'light-content' : 'dark-content' }),
        React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: backgroundStyle },
            React.createElement(View, { style: {
                    backgroundColor: isDarkMode ? Colors.black : Colors.white,
                } },
                React.createElement(PageTitle, { title: "WaaS SDK Demos" }),
                React.createElement(Section, { title: "Pool Creation", runDestination: "PoolServiceDemo" }, "Create a Pool resource."),
                React.createElement(Section, { title: "Device Registration", runDestination: "MPCKeyServiceDemo" }, "Generate registration data for the Device and register the Device with WaaS."),
                React.createElement(Section, { title: "Address Generation", runDestination: "MPCWalletServiceDemo" }, "Create an MPCWallet with an associated DeviceGroup and generate an Ethereum Address in the MPCWallet."),
                React.createElement(Section, { title: "Transaction Signing", runDestination: "MPCSignatureDemo" }, "Compute a signed transaction for the Ethereum Address."),
                React.createElement(Section, { title: "Key Export", runDestination: "MPCKeyExportDemo" }, "Export the private keys corresponding to the MPCKeys in the DeviceGroup."),
                React.createElement(Section, { title: "Device Backup", runDestination: "DeviceBackupDemo" }, "Export a Device backup that can be used to restore a Device within a DeviceGroup."),
                React.createElement(Section, { title: "Device Restore", runDestination: "DeviceAdditionDemo" }, "Restore an old Device by adding a new Device to an existing DeviceGroup using the backup prepared by the old Device.")))));
};
