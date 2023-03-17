import React from 'react';
import { StyleSheet, Button, View } from 'react-native';

/**
 * A component for a continue button.
 * @param onPress The function to call when the button is pressed.
 * @returns The continue button component.
 */
export const ContinueButton: React.FC<{
  onPress: () => void;
}> = ({ onPress }) => {
  return (
    <View style={styles.continueButtonContainer}>
      <Button title="Continue" onPress={onPress} />
    </View>
  );
};

/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
  continueButtonContainer: {
    marginTop: 2,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
