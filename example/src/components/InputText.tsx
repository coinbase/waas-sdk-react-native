import React from 'react';
import { StyleSheet, TextInput } from 'react-native';

/**
 * A component for input text.
 * @param onTextChange The function to call when the text changes.
 * @param editable Whether the input text is editable.
 * @param secret Whether the input text should be considered secret.
 * @returns The input text component.
 */
export const InputText: React.FC<{
  onTextChange: (text: string) => void;
  editable: boolean;
  secret?: boolean;
}> = ({ onTextChange, editable, secret }) => {
  return (
    <TextInput
      style={styles.inputText}
      autoCapitalize="none"
      onChangeText={onTextChange}
      secureTextEntry={!!secret}
      editable={!!editable}
    />
  );
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
