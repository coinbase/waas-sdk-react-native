import React from 'react';
import { Button, StyleSheet, Text, useColorScheme, View } from 'react-native';
import { Colors } from 'react-native/Libraries/NewAppScreen';
import { useNavigation } from '@react-navigation/native';
/**
 * A component for a section.
 * @param title The title of the section.
 * @param children The child nodes of the component.
 * @param runDestination The screen to navigate to when the run button is clicked.
 */
export const Section = ({ children, title, runDestination, disabled }) => {
    const isDarkMode = useColorScheme() === 'dark';
    const navigation = useNavigation();
    const stylesToApply = [styles.sectionContainer];
    if (disabled) {
        stylesToApply.push(styles.disabled);
    }
    return (React.createElement(View, { style: stylesToApply },
        React.createElement(Text, { style: [
                styles.sectionTitle,
                {
                    color: isDarkMode ? Colors.white : Colors.black,
                },
            ] }, title),
        React.createElement(Text, { style: [
                styles.sectionDescription,
                {
                    color: isDarkMode ? Colors.light : Colors.dark,
                },
            ] }, children),
        runDestination !== undefined && (React.createElement(View, { style: styles.runButton },
            React.createElement(Button, { title: "Run", onPress: () => navigation.navigate(runDestination) })))));
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    sectionContainer: {
        borderColor: 'gray',
        borderWidth: 2,
        marginHorizontal: 12,
        marginTop: 32,
        paddingBottom: 16,
        paddingHorizontal: 24,
        paddingTop: 12,
    },
    sectionTitle: {
        fontSize: 24,
        fontWeight: '600',
    },
    sectionDescription: {
        marginTop: 8,
        fontSize: 18,
        fontWeight: '400',
    },
    runButton: {
        marginTop: 8,
    },
    disabled: {
        backgroundColor: '#bebebe',
    },
});
