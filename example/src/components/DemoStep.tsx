import React, { useState, useEffect } from 'react';
import { Animated, StyleSheet } from 'react-native';

/**
 * A component for a single step in a demo.
 * @param children The children of the demo step.
 * @returns The demo step component.
 */
export const DemoStep: React.FC<{
  children: React.ReactNode;
}> = ({ children }) => {
  const [fade] = useState(new Animated.Value(0));
  useEffect(() => {
    Animated.timing(fade, {
      toValue: 1,
      duration: 1000,
      useNativeDriver: true,
    }).start();
  }, [fade]);

  return (
    <Animated.View style={[styles.demoStepContainer, { opacity: fade }]}>
      {children}
    </Animated.View>
  );
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
