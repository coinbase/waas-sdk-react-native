import * as React from 'react';
import { ScrollView, StyleSheet, Button, View, Text } from 'react-native';
import { PageTitle } from '../components/PageTitle';
import { DemoStep } from '../components/DemoStep';
import { ModeContext } from '../utils/ModeProvider';
import { useNavigation } from '@react-navigation/native';
/**
 * Prompts users to choose between 'Direct Mode' and 'Proxy Mode'.
 * Navigates to the 'Home' screen after a mode is selected.
 */
export const ModeSelectionScreen = () => {
    const { setSelectedMode } = React.useContext(ModeContext);
    const navigation = useNavigation();
    const handleModeSelection = (mode) => {
        setSelectedMode(mode);
        navigation.navigate('Home');
    };
    return (React.createElement(ScrollView, { contentInsetAdjustmentBehavior: "automatic", style: styles.container },
        React.createElement(PageTitle, { title: "Mode Selection." }),
        React.createElement(DemoStep, null,
            React.createElement(View, { style: styles.buttonContainer },
                React.createElement(Button, { title: "Direct Mode", onPress: () => handleModeSelection('direct-mode') }),
                React.createElement(Text, { style: styles.modeDescription }, "API credentials are required.")),
            React.createElement(Button, { title: "Proxy Mode", onPress: () => handleModeSelection('proxy-mode') }),
            React.createElement(Text, { style: styles.modeDescription }, "No API credentials. Assumes that API keys are stored in the proxy server."))));
};
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'white',
        paddingHorizontal: 90,
        paddingTop: 0,
    },
    buttonContainer: {
        marginVertical: 15,
        alignItems: 'center',
    },
    modeDescription: {
        marginVertical: 10,
        textAlign: 'center',
        color: '#555',
    },
});
