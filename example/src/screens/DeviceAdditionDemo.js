import * as React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { addDevice, computeAddDeviceMPCOperation, initMPCKeyService, initMPCSdk, initMPCWalletService, pollForPendingDevices, } from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { PageTitle } from '../components/PageTitle';
import AppContext from '../components/AppContext';
import { Note } from '../components/Note';
import { ModeContext } from '../utils/ModeProvider';
import { directMode, proxyMode } from '../constants';
export const DeviceAdditionDemo = () => {
    const [deviceGroupName, setDeviceGroupName] = React.useState('');
    const [deviceGroupEditable, setDeviceGroupEditable] = React.useState(true);
    const [deviceName, setDeviceName] = React.useState('');
    const [deviceEditable, setDeviceEditable] = React.useState(true);
    const [passcode, setPasscode] = React.useState('');
    const [passcodeEditable, setPasscodeEditable] = React.useState(true);
    const [deviceBackup, setDeviceBackup] = React.useState('');
    const [deviceBackupEditable, setDeviceBackupEditable] = React.useState(true);
    const [resultError, setResultError] = React.useState();
    const [showStep2, setShowStep2] = React.useState();
    const [showStep5, setShowStep5] = React.useState();
    const [showStep6, setShowStep6] = React.useState();
    const [showError, setShowError] = React.useState();
    const { selectedMode } = React.useContext(ModeContext);
    const { apiKeyName: apiKeyName, privateKey: privateKey, proxyUrl: proxyUrl, } = React.useContext(AppContext);
    //  Runs the DeviceAdditionDemo.
    React.useEffect(() => {
        let demoFn = async function () {
            if (!showStep2 || showStep6 || deviceGroupName) {
                return;
            }
            if (selectedMode === directMode &&
                (apiKeyName === '' || privateKey === '')) {
                return;
            }
            try {
                const apiKey = selectedMode === proxyMode ? '' : apiKeyName;
                const privKey = selectedMode === proxyMode ? '' : privateKey;
                // Initialize the MPCKeyService and MPCSdk.
                await initMPCSdk(true);
                await initMPCKeyService(apiKey, privKey, proxyUrl);
                await initMPCWalletService(apiKey, privKey, proxyUrl);
                if (!showStep5) {
                    const operationName = await addDevice(deviceGroupName, deviceName);
                    setShowStep5(true);
                    // Process operation.
                    const pendingDeviceOperations = await pollForPendingDevices(deviceGroupName);
                    for (let i = pendingDeviceOperations.length - 1; i >= 0; i--) {
                        const pendingOperation = pendingDeviceOperations[i];
                        if (pendingOperation?.Operation === operationName) {
                            await computeAddDeviceMPCOperation(pendingOperation.MPCData, passcode, deviceBackup);
                            setShowStep6(true);
                            return;
                        }
                    }
                    throw new Error(`could not find operation with name ${operationName}`);
                }
            }
            catch (error) {
                setResultError(error);
                setShowError(true);
            }
        };
        demoFn();
    }, // eslint-disable-next-line react-hooks/exhaustive-deps
    [
        deviceGroupName,
        apiKeyName,
        privateKey,
        proxyUrl,
        showStep2,
        deviceName,
        deviceBackup,
        passcode,
        selectedMode,
    ]);
    const requiredDemos = [
        'Pool Creation',
        'Device Registration',
        'Address Generation',
        'Device Backup',
    ];
    return (React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: styles.container },
        React.createElement(PageTitle, { title: "Device Restore" }),
        React.createElement(Note, { items: requiredDemos }, "Note: This demo requires that you initialize a new Device (i.e. simulator), and run the Device Registration demo with it, before you run this Demo with the new Device. The old Device should have run the following demos already:"),
        React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "1. Input your DeviceGroup resource name below:"),
            React.createElement(InputText, { onTextChange: setDeviceGroupName, editable: deviceGroupEditable, placeholderText: "pools/{pool_id}/deviceGroups/{device_group_id}" }),
            React.createElement(DemoText, null, "2. Input the resource name of your newly registered Device (i.e. not your old Device) below:"),
            React.createElement(InputText, { onTextChange: setDeviceName, editable: deviceEditable, placeholderText: "devices/{device_id}" }),
            React.createElement(DemoText, null, "3. Input your passcode below:"),
            React.createElement(InputText, { onTextChange: setPasscode, editable: passcodeEditable, secret: true }),
            React.createElement(DemoText, null, "4. Input the Device backup created from an existing Device using the Device Backup demo. This will be a long hexadecimal string:"),
            React.createElement(InputText, { onTextChange: setDeviceBackup, editable: deviceBackupEditable }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep2(true);
                    setDeviceGroupEditable(false);
                    setDeviceEditable(false);
                    setPasscodeEditable(false);
                    setDeviceBackupEditable(false);
                } })),
        showStep5 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "5. Initiated the Device Restore operation. Processing MPC Operation - this may take a while..."))),
        showStep6 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "6. Successfully added the new Device to the DeviceGroup, and thereby restored the access of the old Device. Now, run the Transaction Signing demo with the new Device to confirm access."))),
        showError && (React.createElement(DemoStep, null,
            React.createElement(ErrorText, null,
                "ERROR: ",
                resultError?.message)))));
};
/**
 * The styles for the App container.
 */
const styles = StyleSheet.create({
    container: {
        backgroundColor: 'white',
    },
});
