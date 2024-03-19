import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
/**
 * A component for displaying text in monospace font.
 * @param verticalMargin The amount of margin to apply above and below the text.
 * @returns The text component.
 */
export const MonospaceText = ({ children, verticalMargin = 0, }) => {
    return (React.createElement(View, { style: styles.container },
        React.createElement(Text, { style: [styles.monospaceText, { marginVertical: verticalMargin }] }, children)));
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#f5f5f5',
    },
    monospaceText: {
        fontFamily: 'Courier',
        fontSize: 12,
        lineHeight: 24,
        backgroundColor: '#f5f5f5',
    },
});
