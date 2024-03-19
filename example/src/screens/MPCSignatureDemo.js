import { computeMPCOperation, createSignatureFromTx, getAddress, getSignedTransaction, initMPCKeyService, initMPCSdk, initMPCWalletService, pollForPendingSignatures, waitPendingSignature, } from '@coinbase/waas-sdk-react-native';
import * as React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import AppContext from '../components/AppContext';
import { ContinueButton } from '../components/ContinueButton';
import { CopyButton } from '../components/CopyButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { LargeInputText } from '../components/LargeInputText';
import { Note } from '../components/Note';
import { PageTitle } from '../components/PageTitle';
import { MonospaceText } from '../components/MonospaceText';
import { ModeContext } from '../utils/ModeProvider';
import { directMode, proxyMode } from '../constants';
export const MPCSignatureDemo = () => {
    // The initial transaction text.
    const initialTx = `{
      "ChainID": "0x5",
      "Nonce": 0,
      "MaxPriorityFeePerGas": "0x400",
      "MaxFeePerGas": "0x400",
      "Gas": 63000,
      "To": "0xd8ddbfd00b958e94a024fb8c116ae89c70c60257",
      "Value": "0x1000",
      "Data": ""
    }`;
    const [deviceGroupName, setDeviceGroupName] = React.useState('');
    const [deviceGroupEditable, setDeviceGroupEditable] = React.useState(true);
    const [addressName, setAddressName] = React.useState('');
    const [addressNameEditable, setAddressNameEditable] = React.useState(true);
    const [tx, setTx] = React.useState(initialTx);
    const [pendingSignature, setPendingSignature] = React.useState();
    const [signature, setSignature] = React.useState();
    const [signedTx, setSignedTx] = React.useState();
    const [resultError, setResultError] = React.useState();
    const [showStep2, setShowStep2] = React.useState();
    const [showStep3, setShowStep3] = React.useState();
    const [showStep4, setShowStep4] = React.useState();
    const [showStep5, setShowStep5] = React.useState();
    const [showStep6, setShowStep6] = React.useState();
    const [showStep7, setShowStep7] = React.useState();
    const [showStep8, setShowStep8] = React.useState();
    const [showStep9, setShowStep9] = React.useState();
    const [showError, setShowError] = React.useState();
    const { selectedMode } = React.useContext(ModeContext);
    const { apiKeyName: apiKeyName, privateKey: privateKey, proxyUrl: proxyUrl, } = React.useContext(AppContext);
    // Runs the Signature demo.
    React.useEffect(() => {
        let demoFn = async function () {
            if (addressName === '' || deviceGroupName === '' || !showStep3) {
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
                const retrievedAddress = await getAddress(addressName);
                const keyName = retrievedAddress.MPCKeys[0];
                // Initiate the operation to create a signature.
                const resultTx = JSON.parse(tx);
                const operationName = await createSignatureFromTx(keyName, resultTx);
                setShowStep4(true);
                // Poll for pending signatures.
                setShowStep5(true);
                const pendingSignatures = await pollForPendingSignatures(deviceGroupName);
                let pendingSignatureOp;
                for (let i = 0; i < pendingSignatures.length; i++) {
                    if (pendingSignatures[i]?.Operation === operationName) {
                        pendingSignatureOp = pendingSignatures[i];
                    }
                }
                if (!pendingSignatureOp) {
                    throw new Error(`could not find operation with name ${operationName}`);
                }
                setPendingSignature(pendingSignatureOp);
                setShowStep6(true);
                // Process the pending signature.
                setShowStep7(true);
                await computeMPCOperation(pendingSignatureOp.MPCData);
                // Get Signature from MPCKeyService.
                let signatureResult = await waitPendingSignature(pendingSignatureOp.Operation);
                setSignature(signatureResult);
                setShowStep8(true);
                const signedTxResult = await getSignedTransaction(resultTx, signatureResult);
                setSignedTx(signedTxResult);
                setShowStep9(true);
            }
            catch (error) {
                setResultError(error);
                setShowError(true);
            }
        };
        demoFn();
    }, [
        addressName,
        deviceGroupName,
        apiKeyName,
        privateKey,
        proxyUrl,
        tx,
        initialTx,
        showStep3,
        selectedMode,
    ]);
    const requiredDemos = [
        'Pool Creation',
        'Device Registration',
        'Address Generation',
    ];
    return (React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: styles.container },
        React.createElement(PageTitle, { title: "Transaction Signing" }),
        React.createElement(Note, { items: requiredDemos }, "Note: Ensure you have run the following demos before this one:"),
        React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "1. Input your Address resource name below:"),
            React.createElement(InputText, { onTextChange: setAddressName, editable: addressNameEditable, placeholderText: "networks/{network_id}/addresses/{address_id}" }),
            React.createElement(DemoText, null, "Input your DeviceGroup resource name below:"),
            React.createElement(InputText, { onTextChange: setDeviceGroupName, editable: deviceGroupEditable, placeholderText: "pools/{pool_id}/deviceGroups/{device_group_id}" }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep2(true);
                    setAddressNameEditable(false);
                    setDeviceGroupEditable(false);
                } })),
        showStep2 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "2. Input your Transaction information below. The default values should suffice for the Goerli Network."),
            React.createElement(LargeInputText, { onTextChange: setTx, initialText: initialTx }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep3(true);
                } }))),
        showStep3 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "3. Initiating Signature creation..."))),
        showStep4 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "4. Successfully initiated Signature creation."))),
        showStep5 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "5. Polling for pending Signatures..."))),
        showStep6 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "6. Found pending Signature with resource name:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, pendingSignature?.MPCOperation),
            React.createElement(DemoText, null, "with hexadecimal payload:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, pendingSignature?.Payload))),
        showStep7 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "7. Processing pending Signature..."))),
        showStep8 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "8. Got Signature with signed hexadecimal payload:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, signature?.SignedPayload),
            React.createElement(CopyButton, { text: signature?.SignedPayload }))),
        showStep9 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "9. Got signed transaction:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, signedTx?.RawTransaction),
            React.createElement(CopyButton, { text: signedTx?.RawTransaction }),
            React.createElement(DemoText, null, "You can broadcast this value on-chain if it is a valid transaction."),
            React.createElement(Note, null, "You will need to fund your address with the native currency (e.g. ETH) for the broadcast to be successful."))),
        showError && (React.createElement(DemoStep, null,
            React.createElement(ErrorText, null, resultError?.message)))));
};
/**
 * The styles for the App container.
 */
const styles = StyleSheet.create({
    container: {
        backgroundColor: 'white',
    },
});
