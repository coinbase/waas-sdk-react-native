import * as React from 'react';

import { ScrollView, StyleSheet } from 'react-native';
import {
  Address,
  computeMPCOperation,
  createMPCWallet,
  generateAddress,
  initMPCKeyService, initMPCSdk,
  initMPCWalletService,
  MPCWallet,
  pollForPendingDeviceGroup,
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

export const MPCWalletServiceDemo = () => {
  const [deviceName, setDeviceName] = React.useState<string>('');
  const [poolName, setPoolName] = React.useState<string>('');
  const [deviceGroupName, setDeviceGroupName] = React.useState<string>('');
  const [deviceEditable, setDeviceEditable] =
    React.useState<boolean>(true);
const [poolEditable, setPoolEditable] =
    React.useState<boolean>(true);
  const [wallet, setWallet] = React.useState<MPCWallet>();
  const [address, setAddress] = React.useState<Address>();
  const [resultError, setResultError] = React.useState<Error>();

  const [showStep2, setShowStep2] = React.useState<boolean>();
  const [showStep3, setShowStep3] = React.useState<boolean>();
  const [showStep4, setShowStep4] = React.useState<boolean>();
  const [showStep5, setShowStep5] = React.useState<boolean>();
  const [showError, setShowError] = React.useState<boolean>();

  const credentials = React.useContext(AppContext);
  const apiKeyName = credentials.apiKeyName as string;
  const privateKey = credentials.privateKey as string;

  //  Runs the WalletService demo.
  React.useEffect(() => {
    let demoFn = async function () {
      if (
        poolName === '' ||
        deviceName === '' ||
        apiKeyName === '' ||
        privateKey === '' ||
        !showStep2
      ) {
        return;
      }

      try {
            // Initialize the MPCSdk, MPCKeyService and MPCWalletService.
            await initMPCSdk(true);
            await initMPCKeyService(apiKeyName, privateKey);
            await initMPCWalletService(apiKeyName, privateKey);

            // Create MPCWallet if Device Group is not set.
            if(deviceGroupName == ""){
                const createMpcWalletResponse = await createMPCWallet(poolName, deviceName);
                setDeviceGroupName(createMpcWalletResponse.DeviceGroup);
                setShowStep3(true);

                const pendingDeviceGroup = await pollForPendingDeviceGroup(createMpcWalletResponse.DeviceGroup);

                for (let i = pendingDeviceGroup.length - 1; i >= 0; i--) {
                    const deviceGroupOperation = pendingDeviceGroup[i];
                    await computeMPCOperation(deviceGroupOperation?.MPCData as string);
                }

                const wallet = await waitPendingMPCWallet(createMpcWalletResponse.Operation as string)
                setWallet(wallet)

                setShowStep4(true);

                const address = await generateAddress(
                    wallet?.Name as string,
                    'networks/ethereum-goerli',
                    );
                setAddress(address);
                setShowStep5(true);
        }
      } catch (error) {
        setResultError(error as Error);
        setShowError(true);
      }
    };
    demoFn();
  }, [deviceName, apiKeyName, privateKey, showStep2]);

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="automatic"
      style={styles.container}
    >
      <PageTitle title="GenerateAddress Demo" />
      <DemoStep>
        <DemoText>
          1. Ensure you have run the KeyService demo. Input the name of your Pool resource below:
        </DemoText>
        <InputText
          onTextChange={setPoolName}
          editable={poolEditable}
        />
        <DemoText> 2. Input the name of registered Device from MPCKeyServiceDemo below</DemoText>
        <InputText
          onTextChange={setDeviceName}
          editable={deviceEditable}
        />
        <ContinueButton
          onPress={() => {
            setShowStep2(true);
            setDeviceEditable(false);
            setPoolEditable(false)
          }}
        />
      </DemoStep>
      {showStep2 && (
        <DemoStep>
          <DemoText>2. Creating your MPCWallet...</DemoText>
        </DemoStep>
      )}
      {showStep3 && (
        <DemoStep>
          <DemoText>3. Press the button below to copy your DeviceGroup that will be required for MPCSignatureDemo.</DemoText>
          <CopyButton text={deviceGroupName} />
          <DemoText>4. Processing MPCOperation to create DeviceGroup {deviceGroupName}...</DemoText>
        </DemoStep>
      )}
      {showStep4 && (
        <DemoStep>
          <DemoText>5. Created MPCWallet {wallet?.Name} </DemoText>
          <DemoText>Press the button below to copy the name of your MPCWallet.</DemoText>
          <CopyButton text={wallet?.Name!} />
        </DemoStep>
      )}
      {showStep5 && (
        <DemoStep>
          <DemoText>
            5. Generated Ethereum address {address?.Name} in MPC Wallet
          </DemoText>
          <DemoText>Press the button below to copy your address.</DemoText>
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
