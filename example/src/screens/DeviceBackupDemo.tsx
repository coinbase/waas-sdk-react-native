import * as React from 'react';

import { ScrollView, StyleSheet } from 'react-native';
import {
  computePrepareDeviceBackupMPCOperation,
  exportDeviceBackup,
  initMPCKeyService,
  initMPCSdk,
  initMPCWalletService,
  pollForPendingDeviceBackups,
  prepareDeviceBackup,
  PrepareDeviceBackupOperation,
} from '@coinbase/waas-sdk-react-native';
import { ContinueButton } from '../components/ContinueButton';
import { DemoStep } from '../components/DemoStep';
import { DemoText } from '../components/DemoText';
import { ErrorText } from '../components/ErrorText';
import { InputText } from '../components/InputText';
import { PageTitle } from '../components/PageTitle';
import AppContext from '../components/AppContext';
import { CopyButton } from '../components/CopyButton';
import { Note } from '../components/Note';

export const DeviceBackupDemo = () => {
  const [deviceGroupName, setDeviceGroupName] = React.useState<string>('');
  const [deviceGroupEditable, setDeviceGroupEditable] =
    React.useState<boolean>(true);
  const [deviceEditable, setDeviceEditable] = React.useState<boolean>(true);
  const [passcodeEditable, setPasscodeEditable] = React.useState<boolean>(true);
  const [resultError, setResultError] = React.useState<Error>();
  const [deviceName, setDeviceName] = React.useState<string>('');
  const [passcode, setPasscode] = React.useState<string>('');
  const [deviceBackup, setDeviceBackup] = React.useState<string>('');

  const [showStep4, setShowStep4] = React.useState<boolean>();
  const [showStep5, setShowStep5] = React.useState<boolean>();
  const [showStep6, setShowStep6] = React.useState<boolean>();
  const [showError, setShowError] = React.useState<boolean>();

  const credentials = React.useContext(AppContext);
  const apiKeyName = credentials.apiKeyName as string;
  const privateKey = credentials.privateKey as string;

  //  Runs the DeviceBackupDemo.
  React.useEffect(() => {
    let demoFn = async function () {
      if (
        deviceGroupName === '' ||
        deviceName === '' ||
        passcode === '' ||
        apiKeyName === '' ||
        privateKey === '' ||
        !showStep4 ||
        showStep5
      ) {
        return;
      }

      try {
        // Initialize the MPCKeyService and MPCSdk.
        await initMPCSdk(true);
        await initMPCKeyService(apiKeyName, privateKey);
        await initMPCWalletService(apiKeyName, privateKey);
        let operationName = await prepareDeviceBackup(
          deviceGroupName,
          deviceName
        );

        // Process operation.
        const pendingDeviceBackupOperations = await pollForPendingDeviceBackups(
          deviceGroupName
        );

        let pendingOperation!: PrepareDeviceBackupOperation;
        for (let i = pendingDeviceBackupOperations.length - 1; i >= 0; i--) {
          if (pendingDeviceBackupOperations[i]?.Operation === operationName) {
            pendingOperation = pendingDeviceBackupOperations[
              i
            ] as PrepareDeviceBackupOperation;
          }
        }

        if (!pendingOperation) {
          throw new Error(
            `could not find operation with name ${operationName}`
          );
        }

        await computePrepareDeviceBackupMPCOperation(
          pendingOperation!.MPCData,
          passcode
        );
        setShowStep5(true);
      } catch (error) {
        setResultError(error as Error);
        setShowError(true);
      }
    };
    demoFn();

    let waitForBackupExport = async function () {
      if (!showStep5) {
        return;
      }

      let result = await exportDeviceBackup();
      setDeviceBackup(result as string);
      setShowStep6(true);
    };
    waitForBackupExport();
  }, [
    deviceGroupName,
    apiKeyName,
    privateKey,
    showStep4,
    showStep5,
    deviceName,
    passcode,
  ]);

  const requiredDemos = [
    'Pool Creation',
    'Device Registration',
    'Address Generation',
  ];

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="automatic"
      style={styles.container}
    >
      <PageTitle title="Device Backup" />
      <Note items={requiredDemos}>
        Note: Ensure you have run the following demos before this one:
      </Note>
      <DemoStep>
        <DemoText>1. Input your DeviceGroup resource name below:</DemoText>
        <InputText
          onTextChange={setDeviceGroupName}
          editable={deviceGroupEditable}
          placeholderText="pools/{pool_id}/deviceGroups/{device_group_id}"
        />
        <DemoText>2. Input your Device resource name below:</DemoText>
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
        <ContinueButton
          onPress={() => {
            setShowStep4(true);
            setDeviceGroupEditable(false);
            setDeviceEditable(false);
            setPasscodeEditable(false);
          }}
        />
      </DemoStep>
      {showStep4 && (
        <DemoStep>
          <DemoText>
            4. Preparing your Device backup. This may take some time...
          </DemoText>
        </DemoStep>
      )}
      {showStep5 && (
        <DemoStep>
          <DemoText>
            5. Successfully created the backup for this Device and DeviceGroup.
          </DemoText>
        </DemoStep>
      )}
      {showStep6 && (
        <DemoStep>
          <DemoText>
            6. Retrieved the Device backup. It is a long hexadecimal string we
            do not render here.
          </DemoText>
          <DemoText>
            Copy the Device backup and paste it into a notepad before proceeding
            to the next demo.
          </DemoText>
          <CopyButton text={deviceBackup} />
          <Note>This data is sensitive, do not share!</Note>
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
