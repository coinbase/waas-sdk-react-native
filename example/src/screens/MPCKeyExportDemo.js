import * as React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { initMPCWalletService, prepareDeviceArchive, exportPrivateKeys, initMPCKeyService, initMPCSdk, computePrepareDeviceArchiveMPCOperation, getDeviceGroup, pollForPendingDeviceArchives, } from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { PageTitle } from '../components/PageTitle';
import AppContext from '../components/AppContext';
import { CopyButton } from '../components/CopyButton';
import { Note } from '../components/Note';
import { MonospaceText } from '../components/MonospaceText';
import { ModeContext } from '../utils/ModeProvider';
import { directMode, proxyMode } from '../constants';
export const MPCKeyExportDemo = () => {
    const [deviceGroupName, setDeviceGroupName] = React.useState('');
    const [deviceGroupEditable, setDeviceGroupEditable] = React.useState(true);
    const [deviceEditable, setDeviceEditable] = React.useState(true);
    const [passcodeEditable, setPasscodeEditable] = React.useState(true);
    const [resultError, setResultError] = React.useState();
    const [deviceName, setDeviceName] = React.useState('');
    const [passcode, setPasscode] = React.useState('');
    const [mpcKeyExportMetadata, setMpcKeyExportMetadata] = React.useState('');
    const [mpcKeyExportMetadataInput, setMpcKeyExportMetadataInput] = React.useState('');
    const [mpcKeyExportMetadataInputEditable, setmpcKeyExportMetadataInputEditable,] = React.useState(true);
    const [exportedKeys, setExportedKeys] = React.useState('');
    const [showStep2, setShowStep2] = React.useState();
    const [showStep3, setShowStep3] = React.useState();
    const [showStep4, setShowStep4] = React.useState();
    const [showStep5, setShowStep5] = React.useState();
    const [showStep6, setShowStep6] = React.useState();
    const [showStep7, setShowStep7] = React.useState();
    const [showError, setShowError] = React.useState();
    const { selectedMode } = React.useContext(ModeContext);
    const { apiKeyName: apiKeyName, privateKey: privateKey, proxyUrl: proxyUrl, } = React.useContext(AppContext);
    //  Runs the MPCKeyExportDemo.
    React.useEffect(() => {
        let demoFn = async function () {
            if (deviceGroupName === '' || !showStep2 || showStep7) {
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
                if (!showStep3) {
                    const operationName = (await prepareDeviceArchive(deviceGroupName, deviceName));
                    setShowStep3(true);
                    const pendingDeviceArchiveOperations = await pollForPendingDeviceArchives(deviceGroupName);
                    let pendingOperation;
                    for (let i = pendingDeviceArchiveOperations.length - 1; i >= 0; i--) {
                        if (pendingDeviceArchiveOperations[i]?.Operation === operationName) {
                            pendingOperation = pendingDeviceArchiveOperations[i];
                            break;
                        }
                    }
                    if (!pendingOperation) {
                        throw new Error(`could not find operation with name ${operationName}`);
                    }
                    await computePrepareDeviceArchiveMPCOperation(pendingOperation.MPCData, passcode);
                    const retrievedDeviceGroup = await getDeviceGroup(deviceGroupName);
                    setMpcKeyExportMetadata(retrievedDeviceGroup.MPCKeyExportMetadata);
                    setShowStep4(true);
                }
            }
            catch (error) {
                setResultError(error);
                setShowError(true);
            }
        };
        demoFn();
        let waitForKeyExport = async function () {
            if (!showStep7) {
                return;
            }
            let result = await exportPrivateKeys(mpcKeyExportMetadataInput, passcode);
            setExportedKeys((result[0]?.Address +
                ' -> ' +
                result[0]?.PrivateKey));
            setShowStep7(true);
        };
        waitForKeyExport();
    }, [
        deviceGroupName,
        apiKeyName,
        privateKey,
        proxyUrl,
        showStep2,
        showStep3,
        showStep4,
        showStep7,
        deviceName,
        mpcKeyExportMetadata,
        passcode,
        mpcKeyExportMetadataInput,
        selectedMode,
    ]);
    const requiredDemos = [
        'Pool Creation',
        'Device Registration',
        'Address Generation',
    ];
    return (React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: styles.container },
        React.createElement(PageTitle, { title: "Key Export" }),
        React.createElement(Note, { items: requiredDemos }, "Note: Ensure you have run the following demos before this one:"),
        React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "1. Input your DeviceGroup resource name below:"),
            React.createElement(InputText, { onTextChange: setDeviceGroupName, editable: deviceGroupEditable, placeholderText: "pools/{pool_id}/deviceGroups/{device_group_id}" }),
            React.createElement(DemoText, null, "2. Input your Device resource name below:"),
            React.createElement(InputText, { onTextChange: setDeviceName, editable: deviceEditable, placeholderText: "devices/{device_id}" }),
            React.createElement(DemoText, null, "3. Input your passcode below:"),
            React.createElement(InputText, { onTextChange: setPasscode, editable: passcodeEditable, secret: true }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep2(true);
                    setDeviceGroupEditable(false);
                    setDeviceEditable(false);
                } })),
        showStep3 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "3. Preparing your Device archive..."))),
        showStep4 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "4. Successfully created a Device archive for this Device and DeviceGroup. The archive's base64-encoded key export metadata is:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, mpcKeyExportMetadata),
            React.createElement(DemoText, null, "Copy your archive's key export metadata and paste it into a notepad before proceeding to the next step."),
            React.createElement(CopyButton, { text: mpcKeyExportMetadata }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep5(true);
                } }))),
        showStep5 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "5. Input your passcode again to export the private keys in your MPCWallet:"),
            React.createElement(InputText, { onTextChange: setPasscode, editable: passcodeEditable, secret: true }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep6(true);
                    setPasscodeEditable(false);
                } }))),
        showStep6 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "6. Input the mpcKeyExportMetadata from Step 4:"),
            React.createElement(InputText, { onTextChange: setMpcKeyExportMetadataInput, editable: mpcKeyExportMetadataInputEditable }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep7(true);
                    setmpcKeyExportMetadataInputEditable(false);
                } }))),
        showStep7 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "7. Successfully exported your private keys. The list below maps your addresses to their corresponding private keys:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, exportedKeys),
            React.createElement(CopyButton, { text: exportedKeys }),
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
