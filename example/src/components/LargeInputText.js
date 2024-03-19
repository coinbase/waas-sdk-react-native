import React from 'react';
import { StyleSheet, TextInput } from 'react-native';
/**
 * A component for large input text.
 * @param onTextChange The function to call when the text changes.
 * @param initialText The initial text.
 * @returns The large input text component.
 */
export const LargeInputText = ({ onTextChange, initialText }) => {
    return (React.createElement(TextInput, { style: styles.inputText, multiline: true, numberOfLines: 15, autoCapitalize: "none", onChangeText: onTextChange, defaultValue: initialText }));
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    inputText: {
        fontFamily: 'Courier New',
        height: 200,
        margin: 12,
        borderWidth: 1,
        padding: 10,
    },
});
