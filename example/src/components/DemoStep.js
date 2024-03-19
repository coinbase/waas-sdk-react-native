import React, { useState, useEffect } from 'react';
import { Animated, StyleSheet } from 'react-native';
/**
 * A component for a single step in a demo.
 * @param children The children of the demo step.
 * @returns The demo step component.
 */
export const DemoStep = ({ children }) => {
    const [fade] = useState(new Animated.Value(0));
    useEffect(() => {
        Animated.timing(fade, {
            toValue: 1,
            duration: 1000,
            useNativeDriver: true,
        }).start();
    }, [fade]);
    return (React.createElement(Animated.View, { style: [styles.demoStepContainer, { opacity: fade }] }, children));
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    demoStepContainer: {
        background: 'white',
        flexDirection: 'column',
        margin: 10,
    },
});
