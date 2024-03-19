import React from 'react';
import { StyleSheet, Text } from 'react-native';
/**
 * A component for error text.
 * @param children The text representing the error.
 * @returns The error text component.
 */
export const ErrorText = ({ children }) => {
    return React.createElement(Text, { style: styles.demoText }, children);
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    demoText: {
        color: 'red',
        fontSize: 14,
        fontWeight: '600',
    },
});
