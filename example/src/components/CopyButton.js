import React from 'react';
import { StyleSheet, Button, View } from 'react-native';
import Clipboard from '@react-native-clipboard/clipboard';
/**
 * A component for a copy button.
 * @param text The text to copy.
 * @returns The copy button component.
 */
export const CopyButton = ({ text }) => {
    return (React.createElement(View, { style: styles.copyButtonContainer },
        React.createElement(Button, { title: "Copy", onPress: () => Clipboard.setString(text) })));
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    copyButtonContainer: {
        marginTop: 2,
        justifyContent: 'center',
        alignItems: 'center',
    },
});
