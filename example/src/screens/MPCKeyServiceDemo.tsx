import * as React from 'react';

import { ScrollView, StyleSheet } from 'react-native';
import {
  getRegistrationData,
  bootstrapDevice,
  registerDevice,
  Device,
  initMPCKeyService,
  initMPCSdk,
} from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { PageTitle } from '../components/PageTitle';
import { CopyButton } from '../components/CopyButton';
import { InputText } from '../components/InputText';
import AppContext from '../components/AppContext';

export const MPCKeyServiceDemo = () => {
  const [registrationData, setRegistrationData] = React.useState<string>('');
  const [passcode, setPasscode] = React.useState<string>('');
  const [resultError, setResultError] = React.useState<Error>();

  const [passcodeEditable, setPasscodeEditable] = React.useState<boolean>(true);
  const [device, setDevice] = React.useState<Device>();
  const [showStep2, setShowStep2] = React.useState<boolean>();
  const [showStep3, setShowStep3] = React.useState<boolean>();
  const [showStep4, setShowStep4] = React.useState<boolean>();
  const [showStep5, setShowStep5] = React.useState<boolean>();
  const [showError, setShowError] = React.useState<boolean>();

  const credentials = React.useContext(AppContext);
  const apiKeyName = credentials.apiKeyName as string;
  const privateKey = credentials.privateKey as string;

  // Runs the MPCKeyService demo.
  React.useEffect(() => {
    let demoFn = async function () {
      if (apiKeyName === '' || privateKey === '' || !showStep2) {
        return;
      }

      try {
        // Initialize the MPCKeyService and MPCSdk.
        await initMPCSdk(true);
        await initMPCKeyService(apiKeyName, privateKey);

        await bootstrapDevice(passcode);

        const regData = await getRegistrationData();
        setRegistrationData(regData as string);
        setShowStep3(true);
        setShowStep4(true);

        const registeredDevice = await registerDevice();
        setDevice(registeredDevice);

        setShowStep5(true);
      } catch (error) {
        setResultError(error as Error);
        setShowError(true);
      }
    };

    demoFn();
  }, [showStep2, apiKeyName, passcode, privateKey]);

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="automatic"
      style={styles.container}
    >
      <PageTitle title="MPC Keys Demo" />
      <DemoStep>
        <DemoText>
          1. To generate registration Data for device, enter a passcode with
          at-least 6 characters
        </DemoText>
        <InputText
          onTextChange={setPasscode}
          editable={passcodeEditable}
          secret={true}
        />
        <ContinueButton
          onPress={() => {
            setShowStep2(true);
            setPasscodeEditable(false);
          }}
        />
      </DemoStep>
      {showStep2 && (
        <DemoStep>
          <DemoText>2. Generating Registration Data...</DemoText>
        </DemoStep>
      )}
      {showStep3 && (
        <DemoStep>
          <DemoText>
            3. Copy Registration Data {registrationData} to invoke
            RegisterDevice API in MPCKeyService
          </DemoText>
          <CopyButton text={registrationData} />
        </DemoStep>
      )}
      {showStep4 && (
        <DemoStep>
          <DemoText>4. Registering Device...</DemoText>
        </DemoStep>
      )}
      {showStep5 && (
        <DemoStep>
          <DemoText>
            5. Registered device {device?.Name}. Copy the name of your Device to
            use in MPCWalletServiceDemo.
          </DemoText>
          <CopyButton text={device?.Name as string} />
        </DemoStep>
      )}
      {showError && (
        <DemoStep>
          <ErrorText>ERROR: {resultError?.message}</ErrorText>
        </DemoStep>
      )}
    </ScrollView>
  );
};

/**
 * The styles for the App container.
 */
const styles = StyleSheet.create({
  container: {
    backgroundColor: 'white',
  },
});
