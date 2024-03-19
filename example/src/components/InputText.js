import React from 'react';
import { StyleSheet, TextInput } from 'react-native';
/**
 * A component for input text.
 * @param onTextChange The function to call when the text changes.
 * @param editable Whether the input text is editable.
 * @param secret Whether the input text should be considered secret.
 * @param placeholderText The placeholder text to display in the input field.
 * @returns The input text component.
 */
export const InputText = ({ onTextChange, editable, secret, placeholderText }) => {
    return (React.createElement(TextInput, { style: styles.inputText, autoCapitalize: "none", onChangeText: onTextChange, secureTextEntry: !!secret, editable: !!editable, placeholder: placeholderText, placeholderTextColor: "#999" }));
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    inputText: {
        height: 40,
        margin: 12,
        borderWidth: 1,
        padding: 10,
    },
});
