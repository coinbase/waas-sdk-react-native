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
import { MonospaceText } from '../components/MonospaceText';

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
      <PageTitle title="Device Registration" />
      <DemoStep>
        <DemoText>
          1. Enter a passcode of at least 6 digits. This passcode will be used
          to encrypt your device archive and backup materials. Remember your
          passcode!
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
          <DemoText>2. Generating Device registration data...</DemoText>
        </DemoStep>
      )}
      {showStep3 && (
        <DemoStep>
          <DemoText>
            3. Your base64-encoded Device registration data is below:
          </DemoText>
          <MonospaceText verticalMargin={5}>{registrationData}</MonospaceText>
          <DemoText>
            Typically, you would use this data to call RegisterDevice from your
            proxy server; however, for convenience, we'll do that directly here.
          </DemoText>
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
            5. Successfully registered Device with resource name:
          </DemoText>
          <MonospaceText verticalMargin={10}>{device?.Name}</MonospaceText>
          <DemoText>
            Copy your Device resource name and paste it into a notepad before
            proceeding to the next demo.
          </DemoText>
          <CopyButton text={device?.Name!} />
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
