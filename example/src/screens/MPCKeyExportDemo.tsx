import * as React from 'react';

import { ScrollView, StyleSheet } from 'react-native';
import {
  initMPCWalletService,
  prepareDeviceArchive,
  exportPrivateKeys,
  initMPCKeyService,
  initMPCSdk,
  computePrepareDeviceArchiveMPCOperation,
  getDeviceGroup,
  pollForPendingDeviceArchives,
  PrepareDeviceArchiveOperation,
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
import { MonospaceText } from '../components/MonospaceText';

export const MPCKeyExportDemo = () => {
  const [deviceGroupName, setDeviceGroupName] = React.useState<string>('');
  const [deviceGroupEditable, setDeviceGroupEditable] =
    React.useState<boolean>(true);
  const [deviceEditable, setDeviceEditable] = React.useState<boolean>(true);
  const [passcodeEditable, setPasscodeEditable] = React.useState<boolean>(true);
  const [resultError, setResultError] = React.useState<Error>();
  const [deviceName, setDeviceName] = React.useState<string>('');
  const [passcode, setPasscode] = React.useState<string>('');
  const [mpcKeyExportMetadata, setMpcKeyExportMetadata] =
    React.useState<string>('');
  const [mpcKeyExportMetadataInput, setMpcKeyExportMetadataInput] =
    React.useState<string>('');
  const [
    mpcKeyExportMetadataInputEditable,
    setmpcKeyExportMetadataInputEditable,
  ] = React.useState<boolean>(true);

  const [exportedKeys, setExportedKeys] = React.useState<string>('');

  const [showStep2, setShowStep2] = React.useState<boolean>();
  const [showStep3, setShowStep3] = React.useState<boolean>();
  const [showStep4, setShowStep4] = React.useState<boolean>();
  const [showStep5, setShowStep5] = React.useState<boolean>();
  const [showStep6, setShowStep6] = React.useState<boolean>();
  const [showStep7, setShowStep7] = React.useState<boolean>();
  const [showError, setShowError] = React.useState<boolean>();

  const credentials = React.useContext(AppContext);
  const apiKeyName = credentials.apiKeyName as string;
  const privateKey = credentials.privateKey as string;

  //  Runs the MPCKeyExportDemo.
  React.useEffect(() => {
    let demoFn = async function () {
      if (
        deviceGroupName === '' ||
        apiKeyName === '' ||
        privateKey === '' ||
        !showStep2 ||
        showStep7
      ) {
        return;
      }

      try {
        // Initialize the MPCKeyService and MPCSdk.
        await initMPCSdk(true);
        await initMPCKeyService(apiKeyName, privateKey);
        await initMPCWalletService(apiKeyName, privateKey);

        if (!showStep3) {
          const operationName = (await prepareDeviceArchive(
            deviceGroupName,
            deviceName
          )) as string;
          setShowStep3(true);

          const pendingDeviceArchiveOperations =
            await pollForPendingDeviceArchives(deviceGroupName);

          let pendingOperation!: PrepareDeviceArchiveOperation;

          for (let i = pendingDeviceArchiveOperations.length - 1; i >= 0; i--) {
            if (
              pendingDeviceArchiveOperations[i]?.Operation === operationName
            ) {
              pendingOperation = pendingDeviceArchiveOperations[
                i
              ] as PrepareDeviceArchiveOperation;

              break;
            }
          }

          if (!pendingOperation) {
            throw new Error(
              `could not find operation with name ${operationName}`
            );
          }
          await computePrepareDeviceArchiveMPCOperation(
            pendingOperation!.MPCData,
            passcode
          );

          const retrievedDeviceGroup = await getDeviceGroup(deviceGroupName);
          setMpcKeyExportMetadata(retrievedDeviceGroup.MPCKeyExportMetadata);
          setShowStep4(true);
        }
      } catch (error) {
        setResultError(error as Error);
        setShowError(true);
      }
    };
    demoFn();

    let waitForKeyExport = async function () {
      if (!showStep7) {
        return;
      }

      let result = await exportPrivateKeys(mpcKeyExportMetadataInput, passcode);
      setExportedKeys(
        ((result[0]?.Address as string) +
          ' -> ' +
          result[0]?.PrivateKey) as string
      );
      setShowStep7(true);
    };
    waitForKeyExport();
  }, [
    deviceGroupName,
    apiKeyName,
    privateKey,
    showStep2,
    showStep3,
    showStep4,
    showStep7,
    deviceName,
    mpcKeyExportMetadata,
    passcode,
    mpcKeyExportMetadataInput,
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
      <PageTitle title="Key Export" />
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
            setShowStep2(true);
            setDeviceGroupEditable(false);
            setDeviceEditable(false);
          }}
        />
      </DemoStep>
      {showStep3 && (
        <DemoStep>
          <DemoText>3. Preparing your Device archive...</DemoText>
        </DemoStep>
      )}
      {showStep4 && (
        <DemoStep>
          <DemoText>
            4. Successfully created a Device archive for this Device and
            DeviceGroup. The archive's base64-encoded key export metadata is:
          </DemoText>
          <MonospaceText verticalMargin={10}>
            {mpcKeyExportMetadata}
          </MonospaceText>
          <DemoText>
            Copy your archive's key export metadata and paste it into a notepad
            before proceeding to the next step.
          </DemoText>
          <CopyButton text={mpcKeyExportMetadata} />
          <ContinueButton
            onPress={() => {
              setShowStep5(true);
            }}
          />
        </DemoStep>
      )}
      {showStep5 && (
        <DemoStep>
          <DemoText>
            5. Input your passcode again to export the private keys in your
            MPCWallet:
          </DemoText>
          <InputText
            onTextChange={setPasscode}
            editable={passcodeEditable}
            secret={true}
          />
          <ContinueButton
            onPress={() => {
              setShowStep6(true);
              setPasscodeEditable(false);
            }}
          />
        </DemoStep>
      )}
      {showStep6 && (
        <DemoStep>
          <DemoText>6. Input the mpcKeyExportMetadata from Step 4:</DemoText>
          <InputText
            onTextChange={setMpcKeyExportMetadataInput}
            editable={mpcKeyExportMetadataInputEditable}
          />
          <ContinueButton
            onPress={() => {
              setShowStep7(true);
              setmpcKeyExportMetadataInputEditable(false);
            }}
          />
        </DemoStep>
      )}
      {showStep7 && (
        <DemoStep>
          <DemoText>
            7. Successfully exported your private keys. The list below maps your
            addresses to their corresponding private keys:
          </DemoText>
          <MonospaceText verticalMargin={10}>{exportedKeys}</MonospaceText>
          <CopyButton text={exportedKeys} />
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
