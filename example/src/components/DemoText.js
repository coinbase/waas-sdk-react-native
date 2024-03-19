import React from 'react';
import { StyleSheet, Text } from 'react-native';
/**
 * A component for demo text.
 * @param children The text representing the step.
 * @returns The demo text component.
 */
export const DemoText = ({ children }) => {
    return React.createElement(Text, { style: styles.demoText }, children);
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    demoText: {
        fontSize: 14,
        fontWeight: '600',
        marginVertical: 10,
    },
});
