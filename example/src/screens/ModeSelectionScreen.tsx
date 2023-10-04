import * as React from 'react';
import { ScrollView, StyleSheet, Button, View, Text } from 'react-native';
import { PageTitle } from '../components/PageTitle';
import { DemoStep } from '../components/DemoStep';
import { ModeContext } from '../utils/ModeProvider';
import { useNavigation } from '@react-navigation/native';

/**
 * Prompts users to choose between 'Direct Mode' and 'Proxy Mode'.
 * Navigates to the 'Home' screen after a mode is selected.
 */
export const ModeSelectionScreen = () => {
  const { setSelectedMode } = React.useContext(ModeContext);
  const navigation = useNavigation<any>();

  const handleModeSelection = (mode: string) => {
    setSelectedMode(mode);
    navigation.navigate('Home');
  };

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="automatic"
      style={styles.container}
    >
      <PageTitle title="Mode Selection." />
      <DemoStep>
        <View style={styles.buttonContainer}>
          <Button
            title="Direct Mode"
            onPress={() => handleModeSelection('direct-mode')}
          />
          <Text style={styles.modeDescription}>
            API credentials are required.
          </Text>
        </View>
        <Button
          title="Proxy Mode"
          onPress={() => handleModeSelection('proxy-mode')}
        />
        <Text style={styles.modeDescription}>
          No API credentials. Assumes that API keys are stored in the proxy
          server.
        </Text>
      </DemoStep>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
    paddingHorizontal: 90,
    paddingTop: 0,
  },
  buttonContainer: {
    marginVertical: 15,
    alignItems: 'center',
  },
  modeDescription: {
    marginVertical: 10,
    textAlign: 'center',
    color: '#555',
  },
});
