import * as React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { computePrepareDeviceBackupMPCOperation, exportDeviceBackup, initMPCKeyService, initMPCSdk, initMPCWalletService, pollForPendingDeviceBackups, prepareDeviceBackup, } from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { PageTitle } from '../components/PageTitle';
import AppContext from '../components/AppContext';
import { CopyButton } from '../components/CopyButton';
import { Note } from '../components/Note';
import { ModeContext } from '../utils/ModeProvider';
import { directMode, proxyMode } from '../constants';
export const DeviceBackupDemo = () => {
    const [deviceGroupName, setDeviceGroupName] = React.useState('');
    const [deviceGroupEditable, setDeviceGroupEditable] = React.useState(true);
    const [deviceEditable, setDeviceEditable] = React.useState(true);
    const [passcodeEditable, setPasscodeEditable] = React.useState(true);
    const [resultError, setResultError] = React.useState();
    const [deviceName, setDeviceName] = React.useState('');
    const [passcode, setPasscode] = React.useState('');
    const [deviceBackup, setDeviceBackup] = React.useState('');
    const [showStep4, setShowStep4] = React.useState();
    const [showStep5, setShowStep5] = React.useState();
    const [showStep6, setShowStep6] = React.useState();
    const [showError, setShowError] = React.useState();
    const { selectedMode } = React.useContext(ModeContext);
    const { apiKeyName: apiKeyName, privateKey: privateKey, proxyUrl: proxyUrl, } = React.useContext(AppContext);
    //  Runs the DeviceBackupDemo.
    React.useEffect(() => {
        let demoFn = async function () {
            if (deviceGroupName === '' ||
                deviceName === '' ||
                passcode === '' ||
                !showStep4 ||
                showStep5) {
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
                let operationName = await prepareDeviceBackup(deviceGroupName, deviceName);
                // Process operation.
                const pendingDeviceBackupOperations = await pollForPendingDeviceBackups(deviceGroupName);
                let pendingOperation;
                for (let i = pendingDeviceBackupOperations.length - 1; i >= 0; i--) {
                    if (pendingDeviceBackupOperations[i]?.Operation === operationName) {
                        pendingOperation = pendingDeviceBackupOperations[i];
                    }
                }
                if (!pendingOperation) {
                    throw new Error(`could not find operation with name ${operationName}`);
                }
                await computePrepareDeviceBackupMPCOperation(pendingOperation.MPCData, passcode);
                setShowStep5(true);
            }
            catch (error) {
                setResultError(error);
                setShowError(true);
            }
        };
        demoFn();
        let waitForBackupExport = async function () {
            if (!showStep5) {
                return;
            }
            let result = await exportDeviceBackup();
            setDeviceBackup(result);
            setShowStep6(true);
        };
        waitForBackupExport();
    }, [
        deviceGroupName,
        apiKeyName,
        privateKey,
        proxyUrl,
        showStep4,
        showStep5,
        deviceName,
        passcode,
        selectedMode,
    ]);
    const requiredDemos = [
        'Pool Creation',
        'Device Registration',
        'Address Generation',
    ];
    return (React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: styles.container },
        React.createElement(PageTitle, { title: "Device Backup" }),
        React.createElement(Note, { items: requiredDemos }, "Note: Ensure you have run the following demos before this one:"),
        React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "1. Input your DeviceGroup resource name below:"),
            React.createElement(InputText, { onTextChange: setDeviceGroupName, editable: deviceGroupEditable, placeholderText: "pools/{pool_id}/deviceGroups/{device_group_id}" }),
            React.createElement(DemoText, null, "2. Input your Device resource name below:"),
            React.createElement(InputText, { onTextChange: setDeviceName, editable: deviceEditable, placeholderText: "devices/{device_id}" }),
            React.createElement(DemoText, null, "3. Input your passcode below:"),
            React.createElement(InputText, { onTextChange: setPasscode, editable: passcodeEditable, secret: true }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep4(true);
                    setDeviceGroupEditable(false);
                    setDeviceEditable(false);
                    setPasscodeEditable(false);
                } })),
        showStep4 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "4. Preparing your Device backup. This may take some time..."))),
        showStep5 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "5. Successfully created the backup for this Device and DeviceGroup."))),
        showStep6 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "6. Retrieved the Device backup. It is a long hexadecimal string we do not render here."),
            React.createElement(DemoText, null, "Copy the Device backup and paste it into a notepad before proceeding to the next demo."),
            React.createElement(CopyButton, { text: deviceBackup }),
            React.createElement(Note, null, "This data is sensitive, do not share!"))),
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
