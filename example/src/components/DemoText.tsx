import React from 'react';
import { StyleSheet, Text } from 'react-native';

/**
 * A component for demo text.
 * @param children The text representing the step.
 * @returns The demo text component.
 */
export const DemoText: React.FC<{
  children: React.ReactNode;
}> = ({ children }) => {
  return <Text style={styles.demoText}>{children}</Text>;
};

/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
  demoText: {
    fontSize: 14,
    fontWeight: '600',
  },
});
