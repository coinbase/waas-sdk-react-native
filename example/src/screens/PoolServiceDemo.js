import * as React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { initPoolService, createPool, } from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { PageTitle } from '../components/PageTitle';
import { CopyButton } from '../components/CopyButton';
import AppContext from '../components/AppContext';
import { MonospaceText } from '../components/MonospaceText';
import { ModeContext } from '../utils/ModeProvider';
import { directMode, proxyMode } from '../constants';
export const PoolServiceDemo = () => {
    const [poolDisplayName, setPoolDisplayName] = React.useState('');
    const [displayNameEditable, setDisplayNameEditable] = React.useState(true);
    const [resultPool, setResultPool] = React.useState();
    const [resultError, setResultError] = React.useState();
    const [showStep2, setShowStep2] = React.useState();
    const [showStep3, setShowStep3] = React.useState();
    const [showError, setShowError] = React.useState();
    const { selectedMode } = React.useContext(ModeContext);
    const { apiKeyName: apiKeyName, privateKey: privateKey, proxyUrl: proxyUrl, } = React.useContext(AppContext);
    // Creates a Pool once the API key, API secret, and Pool display name are defined.
    React.useEffect(() => {
        let createPoolFn = async function () {
            if (!showStep2 || poolDisplayName === '') {
                return;
            }
            if (selectedMode === directMode &&
                (apiKeyName === '' || privateKey === '')) {
                return;
            }
            try {
                const apiKey = selectedMode === proxyMode ? '' : apiKeyName;
                const privKey = selectedMode === proxyMode ? '' : privateKey;
                await initPoolService(apiKey, privKey, proxyUrl);
                const createdPool = await createPool(poolDisplayName);
                setResultPool(createdPool);
                setShowStep3(true);
            }
            catch (error) {
                setResultError(error);
                setShowError(true);
            }
        };
        createPoolFn();
    }, [
        apiKeyName,
        privateKey,
        poolDisplayName,
        proxyUrl,
        showStep2,
        selectedMode,
    ]);
    return (React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: styles.container },
        React.createElement(PageTitle, { title: "Pool Creation" }),
        React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "1. Input your Pool's desired display name:"),
            React.createElement(InputText, { onTextChange: setPoolDisplayName, editable: displayNameEditable }),
            React.createElement(ContinueButton, { onPress: () => {
                    setShowStep2(true);
                    setDisplayNameEditable(false);
                } })),
        showStep2 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null, "2. Creating your Pool..."))),
        showStep3 && (React.createElement(DemoStep, null,
            React.createElement(DemoText, null,
                "3. Successfully created and got Pool resource with display name \"",
                resultPool?.displayName,
                "\":"),
            React.createElement(MonospaceText, { verticalMargin: 10 }, resultPool?.name),
            React.createElement(DemoText, null, "Copy your Pool resource name and paste it into a notepad before proceeding to the next demo."),
            React.createElement(CopyButton, { text: resultPool?.name }))),
        showError && (React.createElement(DemoStep, null,
            React.createElement(ErrorText, null,
                "ERROR: ",
                resultError?.message)))));
};
const styles = StyleSheet.create({
    container: {
        backgroundColor: 'white',
    },
});
