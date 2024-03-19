import * as React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { getRegistrationData, bootstrapDevice, registerDevice, initMPCKeyService, initMPCSdk, } from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { PageTitle } from '../components/PageTitle';
import { CopyButton } from '../components/CopyButton';
import { InputText } from '../components/InputText';
import AppContext from '../components/AppContext';
import { MonospaceText } from '../components/MonospaceText';
import { ModeContext } from '../utils/ModeProvider';
import { directMode, proxyMode } from '../constants';
export const MPCKeyServiceDemo = () => {
    const [registrationData, setRegistrationData] = React.useState('');
    const [passcode, setPasscode] = React.useState('');
    const [resultError, setResultError] = React.useState();
    const [passcodeEditable, setPasscodeEditable] = React.useState(true);
    const [device, setDevice] = React.useState();
    const [showStep2, setShowStep2] = React.useState();
    const [showStep3, setShowStep3] = React.useState();
    const [showStep4, setShowStep4] = React.useState();
    const [showStep5, setShowStep5] = React.useState();
    const [showError, setShowError] = React.useState();
    const { apiKeyName: apiKeyName, privateKey: privateKey, proxyUrl: proxyUrl, } = React.useContext(AppContext);
    const { selectedMode } = React.useContext(ModeContext);
    // Runs the MPCKeyService demo.
    React.useEffect(() => {
        let demoFn = async function () {
            if (!showStep2) {
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
                await bootstrapDevice(passcode);
                const regData = await getRegistrationData();
                setRegistrationData(regData);
                setShowStep3(true);
                setShowStep4(true);
                const registeredDevice = await registerDevice();
                setDevice(registeredDevice);
                setShowStep5(true);
            }
            catch (error) {
                setResultError(error);
                setShowError(true);
            }
        };
        demoFn();
    }, [showStep2, apiKeyName, passcode, privateKey, proxyUrl, selectedMode]);
    return (React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: styles.container },
        React.createElement(PageTitle, { title: "Device Registration" }),
        React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "1. Enter a passcode of at least 6 digits. This passcode will be used to encrypt your device archive and backup materials. Remember your passcode!"),
            React.createElement(InputText, { onTextChange: setPasscode, editable: passcodeEditable, secret: true }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep2(true);
                    setPasscodeEditable(false);
                } })),
        showStep2 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "2. Generating Device registration data..."))),
        showStep3 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "3. Your base64-encoded Device registration data is below:"),
            React.createElement(MonospaceText, { verticalMargin: 5 }, registrationData),
            React.createElement(DemoText, null, "Typically, you would use this data to call RegisterDevice from your proxy server; however, for convenience, we'll do that directly here."))),
        showStep4 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "4. Registering Device..."))),
        showStep5 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "5. Successfully registered Device with resource name:"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, device?.Name),
            React.createElement(DemoText, null, "Copy your Device resource name and paste it into a notepad before proceeding to the next demo."),
            React.createElement(CopyButton, { text: device?.Name }))),
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
