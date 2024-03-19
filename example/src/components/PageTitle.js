import React from 'react';
import { StyleSheet, Text, useColorScheme, View } from 'react-native';
import { Colors } from 'react-native/Libraries/NewAppScreen';
/**
 * A component for a page title.
 * @param title The page title.
 * @returns The page title component.
 */
export const PageTitle = ({ title }) => {
    const isDarkMode = useColorScheme() === 'dark';
    return (React.createElement(View, { style: styles.pageTitleContainer },
        React.createElement(Text, { style: [
                styles.pageTitle,
                {
                    color: isDarkMode ? Colors.white : Colors.black,
                },
            ] }, title)));
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    pageTitleContainer: {
        marginVertical: 20,
    },
    pageTitle: {
        fontSize: 32,
        fontWeight: '600',
        textAlign: 'center',
    },
});
