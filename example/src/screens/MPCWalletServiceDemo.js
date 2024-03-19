import * as React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { createMPCWallet, generateAddress, initMPCKeyService, initMPCSdk, initMPCWalletService, computeMPCWallet, pollForPendingDeviceGroup, computeMPCOperation, waitPendingMPCWallet, } from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { PageTitle } from '../components/PageTitle';
import AppContext from '../components/AppContext';
import { CopyButton } from '../components/CopyButton';
import { MonospaceText } from '../components/MonospaceText';
import { Note } from '../components/Note';
import { ModeContext } from '../utils/ModeProvider';
import { directMode, proxyMode } from '../constants';
export const MPCWalletServiceDemo = () => {
    const [deviceName, setDeviceName] = React.useState('');
    const [poolName, setPoolName] = React.useState('');
    const [deviceGroupName, setDeviceGroupName] = React.useState('');
    const [deviceEditable, setDeviceEditable] = React.useState(true);
    const [poolEditable, setPoolEditable] = React.useState(true);
    const [wallet, setWallet] = React.useState();
    const [address, setAddress] = React.useState();
    const [resultError, setResultError] = React.useState();
    const [passcode, setPasscode] = React.useState('');
    const [passcodeEditable, setPasscodeEditable] = React.useState(true);
    const [showStep4, setShowStep4] = React.useState();
    const [showStep5, setShowStep5] = React.useState();
    const [showStep6, setShowStep6] = React.useState();
    const [showStep7, setShowStep7] = React.useState();
    const [showError, setShowError] = React.useState();
    const { apiKeyName: apiKeyName, privateKey: privateKey, proxyUrl: proxyUrl, } = React.useContext(AppContext);
    const { selectedMode } = React.useContext(ModeContext);
    const prepareDeviceArchiveEnforced = true;
    //  Runs the WalletService demo.
    React.useEffect(() => {
        let demoFn = async function () {
            if (poolName === '' || deviceName === '' || !showStep4) {
                return;
            }
            if (selectedMode === directMode &&
                (apiKeyName === '' || privateKey === '')) {
                return;
            }
            try {
                const apiKey = selectedMode === proxyMode ? '' : apiKeyName;
                const privKey = selectedMode === proxyMode ? '' : privateKey;
                // Initialize the MPCSdk, MPCKeyService and MPCWalletService.
                await initMPCSdk(true);
                await initMPCKeyService(apiKey, privKey, proxyUrl);
                await initMPCWalletService(apiKey, privKey, proxyUrl);
                // Create MPCWallet if Device Group is not set.
                if (deviceGroupName === '') {
                    const createMpcWalletResponse = await createMPCWallet(poolName, deviceName);
                    setDeviceGroupName(createMpcWalletResponse.DeviceGroup);
                    setShowStep5(true);
                    if (prepareDeviceArchiveEnforced) {
                        await computeMPCWallet(createMpcWalletResponse.DeviceGroup, passcode);
                    }
                    else {
                        const pendingDeviceGroup = await pollForPendingDeviceGroup(createMpcWalletResponse.DeviceGroup);
                        for (let i = pendingDeviceGroup.length - 1; i >= 0; i--) {
                            const deviceGroupOperation = pendingDeviceGroup[i];
                            await computeMPCOperation(deviceGroupOperation?.MPCData);
                        }
                    }
                    setShowStep4(true);
                    const walletCreated = await waitPendingMPCWallet(createMpcWalletResponse.Operation);
                    setWallet(walletCreated);
                    setShowStep6(true);
                    const addressCreated = await generateAddress(walletCreated.Name, 'networks/ethereum-goerli');
                    setAddress(addressCreated);
                    setShowStep7(true);
                }
            }
            catch (error) {
                console.error(error);
                setResultError(error);
                setShowError(true);
            }
        };
        demoFn();
    }, [
        deviceName,
        apiKeyName,
        privateKey,
        proxyUrl,
        showStep4,
        deviceGroupName,
        passcode,
        poolName,
        prepareDeviceArchiveEnforced,
        selectedMode,
    ]);
    const requiredDemos = ['Pool Creation', 'Device Registration'];
    return (React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: styles.container },
        React.createElement(PageTitle, { title: "Address Generation" }),
        React.createElement(Note, { items: requiredDemos }, "Note: Ensure you have run the following demos before this one:"),
        React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "1. Input your Pool resource name below:"),
            React.createElement(InputText, { onTextChange: setPoolName, editable: poolEditable, placeholderText: "pools/{pool_id}" }),
            React.createElement(DemoText, null, "2. Input your Device resource name below:"),
            React.createElement(InputText, { onTextChange: setDeviceName, editable: deviceEditable, placeholderText: "devices/{device_id}" }),
            React.createElement(DemoText, null, "3. Input the passcode of the registered Device below:"),
            React.createElement(InputText, { onTextChange: setPasscode, editable: passcodeEditable, secret: true }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep4(true);
                    setDeviceEditable(false);
                    setPoolEditable(false);
                    setPasscodeEditable(false);
                } })),
        showStep4 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "4. Creating your MPCWallet..."))),
        showStep5 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "5. Initiated DeviceGroup creation with resource name:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, deviceGroupName),
            React.createElement(DemoText, null, "Copy your DeviceGroup resource name and paste it into a notepad before proceeding to the next step."),
            React.createElement(CopyButton, { text: deviceGroupName }),
            React.createElement(DemoText, null, "Creating MPCWallet. This may take some time (1 min)..."))),
        showStep6 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "6. Created MPCWallet with resource name:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, wallet?.Name),
            React.createElement(DemoText, null, "Copy your MPCWallet resource name and paste it into a notepad before proceeding to the next step."),
            React.createElement(CopyButton, { text: wallet?.Name }))),
        showStep7 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "7. Generated Ethereum Address with resource name:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, address?.Name),
            React.createElement(DemoText, null, "Copy your Address resource name and paste it into a notepad before proceeding to the next demo."),
            React.createElement(CopyButton, { text: address?.Name }))),
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
