import * as React from 'react';

import { ScrollView, StyleSheet } from 'react-native';
import {
  addDevice,
  computeAddDeviceMPCOperation,
  initMPCKeyService,
  initMPCSdk,
  initMPCWalletService,
  pollForPendingDevices,
} from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { PageTitle } from '../components/PageTitle';
import AppContext from '../components/AppContext';
import { Note } from '../components/Note';

export const DeviceAdditionDemo = () => {
  const [deviceGroupName, setDeviceGroupName] = React.useState<string>('');
  const [deviceGroupEditable, setDeviceGroupEditable] =
    React.useState<boolean>(true);
  const [deviceName, setDeviceName] = React.useState<string>('');
  const [deviceEditable, setDeviceEditable] = React.useState<boolean>(true);
  const [passcode, setPasscode] = React.useState<string>('');
  const [passcodeEditable, setPasscodeEditable] = React.useState<boolean>(true);
  const [deviceBackup, setDeviceBackup] = React.useState<string>('');
  const [deviceBackupEditable, setDeviceBackupEditable] =
    React.useState<boolean>(true);
  const [resultError, setResultError] = React.useState<Error>();

  const [showStep2, setShowStep2] = React.useState<boolean>();
  const [showStep5, setShowStep5] = React.useState<boolean>();
  const [showStep6, setShowStep6] = React.useState<boolean>();
  const [showError, setShowError] = React.useState<boolean>();

  const credentials = React.useContext(AppContext);
  const apiKeyName = credentials.apiKeyName as string;
  const privateKey = credentials.privateKey as string;

  //  Runs the DeviceAdditionDemo.
  React.useEffect(
    () => {
      let demoFn = async function () {
        if (
          deviceGroupName === '' ||
          apiKeyName === '' ||
          privateKey === '' ||
          !showStep2 ||
          showStep6
        ) {
          return;
        }

        try {
          // Initialize the MPCKeyService and MPCSdk.
          await initMPCSdk(true);
          await initMPCKeyService(apiKeyName, privateKey);
          await initMPCWalletService(apiKeyName, privateKey);

          if (!showStep5) {
            const operationName = await addDevice(deviceGroupName, deviceName);
            setShowStep5(true);

            // Process operation.
            const pendingDeviceOperations = await pollForPendingDevices(
              deviceGroupName
            );

            for (let i = pendingDeviceOperations.length - 1; i >= 0; i--) {
              const pendingOperation = pendingDeviceOperations[i];

              if (pendingOperation?.Operation === operationName) {
                await computeAddDeviceMPCOperation(
                  pendingOperation!.MPCData,
                  passcode,
                  deviceBackup
                );
                setShowStep6(true);

                return;
              }
            }

            throw new Error(
              `could not find operation with name ${operationName}`
            );
          }
        } catch (error) {
          setResultError(error as Error);
          setShowError(true);
        }
      };
      demoFn();
    }, // eslint-disable-next-line react-hooks/exhaustive-deps
    [
      deviceGroupName,
      apiKeyName,
      privateKey,
      showStep2,
      deviceName,
      deviceBackup,
      passcode,
    ]
  );

  const requiredDemos = [
    'Pool Creation',
    'Device Registration',
    'Address Generation',
    'Device Backup',
  ];

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="automatic"
      style={styles.container}
    >
      <PageTitle title="Device Restore" />
      <Note items={requiredDemos}>
        Note: This demo requires that you initialize a new Device (i.e.
        simulator), and run the Device Registration demo with it, before you run
        this Demo with the new Device. The old Device should have run the
        following demos already:
      </Note>
      <DemoStep>
        <DemoText>1. Input your DeviceGroup resource name below:</DemoText>
        <InputText
          onTextChange={setDeviceGroupName}
          editable={deviceGroupEditable}
          placeholderText="pools/{pool_id}/deviceGroups/{device_group_id}"
        />
        <DemoText>
          2. Input the resource name of your newly registered Device (i.e. not
          your old Device) below:
        </DemoText>
        <InputText
          onTextChange={setDeviceName}
          editable={deviceEditable}
          placeholderText="devices/{device_id}"
        />
        <DemoText>3. Input your passcode below:</DemoText>
        <InputText
          onTextChange={setPasscode}
          editable={passcodeEditable}
          secret={true}
        />
        <DemoText>
          4. Input the Device backup created from an existing Device using the
          Device Backup demo. This will be a long hexadecimal string:
        </DemoText>
        <InputText
          onTextChange={setDeviceBackup}
          editable={deviceBackupEditable}
        />
        <ContinueButton
          onPress={() => {
            setShowStep2(true);
            setDeviceGroupEditable(false);
            setDeviceEditable(false);
            setPasscodeEditable(false);
            setDeviceBackupEditable(false);
          }}
        />
      </DemoStep>
      {showStep5 && (
        <DemoStep>
          <DemoText>
            5. Initiated the Device Restore operation. Processing MPC Operation
            - this may take a while...
          </DemoText>
        </DemoStep>
      )}
      {showStep6 && (
        <DemoStep>
          <DemoText>
            6. Successfully added the new Device to the DeviceGroup, and thereby
            restored the access of the old Device. Now, run the Transaction
            Signing demo with the new Device to confirm access.
          </DemoText>
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
