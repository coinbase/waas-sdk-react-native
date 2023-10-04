import * as React from 'react';

import { ScrollView, StyleSheet } from 'react-native';
import {
  Address,
  createMPCWallet,
  generateAddress,
  initMPCKeyService,
  initMPCSdk,
  initMPCWalletService,
  MPCWallet,
  computeMPCWallet,
  pollForPendingDeviceGroup,
  computeMPCOperation,
  waitPendingMPCWallet,
} from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { PageTitle } from '../components/PageTitle';
import AppContext from '../components/AppContext';
import { CopyButton } from '../components/CopyButton';
import { MonospaceText } from '../components/MonospaceText';
import { Note } from '../components/Note';
import { ModeContext } from '../utils/ModeProvider';
import { directMode, proxyMode } from '../constants';

export const MPCWalletServiceDemo = () => {
  const [deviceName, setDeviceName] = React.useState<string>('');
  const [poolName, setPoolName] = React.useState<string>('');
  const [deviceGroupName, setDeviceGroupName] = React.useState<string>('');
  const [deviceEditable, setDeviceEditable] = React.useState<boolean>(true);
  const [poolEditable, setPoolEditable] = React.useState<boolean>(true);
  const [wallet, setWallet] = React.useState<MPCWallet>();
  const [address, setAddress] = React.useState<Address>();
  const [resultError, setResultError] = React.useState<Error>();

  const [passcode, setPasscode] = React.useState<string>('');
  const [passcodeEditable, setPasscodeEditable] = React.useState<boolean>(true);
  const [showStep4, setShowStep4] = React.useState<boolean>();
  const [showStep5, setShowStep5] = React.useState<boolean>();
  const [showStep6, setShowStep6] = React.useState<boolean>();
  const [showStep7, setShowStep7] = React.useState<boolean>();
  const [showError, setShowError] = React.useState<boolean>();

  const {
    apiKeyName: apiKeyName,
    privateKey: privateKey,
    proxyUrl: proxyUrl,
  } = React.useContext(AppContext) as {
    apiKeyName: string;
    privateKey: string;
    proxyUrl: string;
  };

  const { selectedMode } = React.useContext(ModeContext);

  const prepareDeviceArchiveEnforced = true;

  //  Runs the WalletService demo.
  React.useEffect(() => {
    let demoFn = async function () {
      if (poolName === '' || deviceName === '' || !showStep4) {
        return;
      }

      if (
        selectedMode === directMode &&
        (apiKeyName === '' || privateKey === '')
      ) {
        return;
      }

      try {
        const apiKey = selectedMode === proxyMode ? '' : apiKeyName;
        const privKey = selectedMode === proxyMode ? '' : privateKey;

        // Initialize the MPCSdk, MPCKeyService and MPCWalletService.
        await initMPCSdk(true);
        await initMPCKeyService(apiKey, privKey, proxyUrl);
        await initMPCWalletService(apiKey, privKey, proxyUrl);

        // Create MPCWallet if Device Group is not set.
        if (deviceGroupName === '') {
          const createMpcWalletResponse = await createMPCWallet(
            poolName,
            deviceName
          );
          setDeviceGroupName(createMpcWalletResponse.DeviceGroup);
          setShowStep5(true);

          if (prepareDeviceArchiveEnforced) {
            await computeMPCWallet(
              createMpcWalletResponse.DeviceGroup,
              passcode
            );
          } else {
            const pendingDeviceGroup = await pollForPendingDeviceGroup(
              createMpcWalletResponse.DeviceGroup
            );
            for (let i = pendingDeviceGroup.length - 1; i >= 0; i--) {
              const deviceGroupOperation = pendingDeviceGroup[i];
              await computeMPCOperation(
                deviceGroupOperation?.MPCData as string
              );
            }
          }
          setShowStep4(true);

          const walletCreated = await waitPendingMPCWallet(
            createMpcWalletResponse.Operation as string
          );
          setWallet(walletCreated);
          setShowStep6(true);
          const addressCreated = await generateAddress(
            walletCreated.Name,
            'networks/ethereum-goerli'
          );
          setAddress(addressCreated);

          setShowStep7(true);
        }
      } catch (error) {
        console.error(error);
        setResultError(error as Error);
        setShowError(true);
      }
    };
    demoFn();
  }, [
    deviceName,
    apiKeyName,
    privateKey,
    proxyUrl,
    showStep4,
    deviceGroupName,
    passcode,
    poolName,
    prepareDeviceArchiveEnforced,
    selectedMode,
  ]);

  const requiredDemos = ['Pool Creation', 'Device Registration'];

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="automatic"
      style={styles.container}
    >
      <PageTitle title="Address Generation" />
      <Note items={requiredDemos}>
        Note: Ensure you have run the following demos before this one:
      </Note>
      <DemoStep>
        <DemoText>1. Input your Pool resource name below:</DemoText>
        <InputText
          onTextChange={setPoolName}
          editable={poolEditable}
          placeholderText="pools/{pool_id}"
        />
        <DemoText>2. Input your Device resource name below:</DemoText>
        <InputText
          onTextChange={setDeviceName}
          editable={deviceEditable}
          placeholderText="devices/{device_id}"
        />
        <DemoText>
          3. Input the passcode of the registered Device below:
        </DemoText>
        <InputText
          onTextChange={setPasscode}
          editable={passcodeEditable}
          secret={true}
        />
        <ContinueButton
          onPress={() => {
            setShowStep4(true);
            setDeviceEditable(false);
            setPoolEditable(false);
            setPasscodeEditable(false);
          }}
        />
      </DemoStep>
      {showStep4 && (
        <DemoStep>
          <DemoText>4. Creating your MPCWallet...</DemoText>
        </DemoStep>
      )}
      {showStep5 && (
        <DemoStep>
          <DemoText>
            5. Initiated DeviceGroup creation with resource name:
          </DemoText>
          <MonospaceText verticalMargin={10}>{deviceGroupName}</MonospaceText>
          <DemoText>
            Copy your DeviceGroup resource name and paste it into a notepad
            before proceeding to the next step.
          </DemoText>
          <CopyButton text={deviceGroupName!} />
          <DemoText>
            Creating MPCWallet. This may take some time (1 min)...
          </DemoText>
        </DemoStep>
      )}
      {showStep6 && (
        <DemoStep>
          <DemoText>6. Created MPCWallet with resource name:</DemoText>
          <MonospaceText verticalMargin={10}>{wallet?.Name}</MonospaceText>
          <DemoText>
            Copy your MPCWallet resource name and paste it into a notepad before
            proceeding to the next step.
          </DemoText>
          <CopyButton text={wallet?.Name!} />
        </DemoStep>
      )}
      {showStep7 && (
        <DemoStep>
          <DemoText>7. Generated Ethereum Address with resource name:</DemoText>
          <MonospaceText verticalMargin={10}>{address?.Name}</MonospaceText>
          <DemoText>
            Copy your Address resource name and paste it into a notepad before
            proceeding to the next demo.
          </DemoText>
          <CopyButton text={address?.Name!} />
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
