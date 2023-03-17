import {
  computeMPCOperation,
  createSignatureFromTx, CreateSignatureOperation,
  getAddress, getSignedTransaction, initMPCKeyService, initMPCSdk, initMPCWalletService,
  pollForPendingSignatures, Signature, SignedTransaction,
  Transaction, waitPendingSignature
} from '@coinbase/waas-sdk-react-native';
  import * as React from 'react';

  import { ScrollView, StyleSheet } from 'react-native';
  import AppContext from '../components/AppContext';
  import { ContinueButton } from '../components/ContinueButton';
  import { CopyButton } from '../components/CopyButton';
  import { DemoStep } from '../components/DemoStep';
  import { DemoText } from '../components/DemoText';
  import { ErrorText } from '../components/ErrorText';
  import { InputText } from '../components/InputText';
  import { LargeInputText } from '../components/LargeInputText';
  import { PageTitle } from '../components/PageTitle';

  export const MPCSignatureDemo = () => {
    // The initial transaction text.
    const initialTx = `{
      "ChainID": "0x5",
      "Nonce": 0,
      "MaxPriorityFeePerGas": "0x400",
      "MaxFeePerGas": "0x400",
      "Gas": 63000,
      "To": "0xd8ddbfd00b958e94a024fb8c116ae89c70c60257",
      "Value": "0x1000",
      "Data": ""
    }`;

    const [deviceGroupName, setDeviceGroupName] = React.useState<string>('');
    const [deviceGroupEditable, setDeviceGroupEditable] =
      React.useState<boolean>(true);
    const [addressName, setAddressName] = React.useState<string>('');
    const [addressNameEditable, setAddressNameEditable] =
      React.useState<boolean>(true);
    const [tx, setTx] = React.useState<string>(initialTx);
    const [pendingSignature, setPendingSignature] =
      React.useState<CreateSignatureOperation>();
    const [signature, setSignature] = React.useState<Signature>();
    const [signedTx, setSignedTx] = React.useState<SignedTransaction>();
    const [resultError, setResultError] = React.useState<Error>();

    const [showStep2, setShowStep2] = React.useState<boolean>();
    const [showStep3, setShowStep3] = React.useState<boolean>();
    const [showStep4, setShowStep4] = React.useState<boolean>();
    const [showStep5, setShowStep5] = React.useState<boolean>();
    const [showStep6, setShowStep6] = React.useState<boolean>();
    const [showStep7, setShowStep7] = React.useState<boolean>();
    const [showStep8, setShowStep8] = React.useState<boolean>();
    const [showStep9, setShowStep9] = React.useState<boolean>();
    const [showError, setShowError] = React.useState<boolean>();

    const credentials = React.useContext(AppContext);
    const apiKeyName = credentials.apiKeyName as string;
    const privateKey = credentials.privateKey as string;

    // Runs the Signature demo.
    React.useEffect(() => {
      let demoFn = async function () {
        if (
          addressName === '' ||
          deviceGroupName === '' ||
          apiKeyName === '' ||
          privateKey === '' ||
          !showStep3
        ) {
          return;
        }

        try {
          // Initialize the MPCSdk, MPCKeyService and MPCWalletService.
          await initMPCSdk(true);
          await initMPCKeyService(apiKeyName, privateKey);
          await initMPCWalletService(apiKeyName, privateKey);
          const retrievedAddress = await getAddress(addressName);
          const keyName = retrievedAddress.MPCKeys[0]!;
          // Initiate the operation to create a signature.
          const resultTx = JSON.parse(tx) as Transaction;
          await createSignatureFromTx(
            keyName,
            resultTx
          );
          setShowStep4(true);

          // Poll for pending signatures.
          setShowStep5(true);
          const pendingSignatures = await pollForPendingSignatures(
            deviceGroupName
          );
          setPendingSignature(pendingSignatures[0]);
          setShowStep6(true);

          // Process the pending signature.
          setShowStep7(true);
          await computeMPCOperation(
            pendingSignatures[0]!.MPCData
          );

          // Get Signature from MPCKeyService.
          let signatureResult = await waitPendingSignature(pendingSignatures[0]!.Operation)

          setSignature(signatureResult);
          setShowStep8(true);

          const signedTxResult = await getSignedTransaction(
            resultTx,
            signatureResult
          );
          setSignedTx(signedTxResult);
          setShowStep9(true);
        } catch (error) {
          setResultError(error as Error);
          setShowError(true);
        }
      };

      demoFn();
    }, [
      addressName,
      deviceGroupName,
      apiKeyName,
      privateKey,
      tx,
      initialTx,
      showStep3,
    ]);

    return (
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={styles.container}
      >
        <PageTitle title="Tx Signing Demo" />
        <DemoStep>
          <DemoText>
            1. Ensure you have run the MPCWalletService demo and created an Address.
            Input your Address resource name below:
          </DemoText>
          <InputText
            onTextChange={setAddressName}
            editable={addressNameEditable}
          />
          <DemoText>Input your DeviceGroup resource name below:</DemoText>
          <InputText
            onTextChange={setDeviceGroupName}
            editable={deviceGroupEditable}
          />
          <ContinueButton
            onPress={() => {
              setShowStep2(true);
              setAddressNameEditable(false);
              setDeviceGroupEditable(false);
            }}
          />
        </DemoStep>
        {showStep2 && (
          <DemoStep>
            <DemoText>2. Input your transaction information below</DemoText>
            <LargeInputText onTextChange={setTx} initialText={initialTx} />
            <ContinueButton
              onPress={() => {
                setShowStep3(true);
              }}
            />
          </DemoStep>
        )}
        {showStep3 && (
          <DemoStep>
            <DemoText>3. Initiating Signature creation...</DemoText>
          </DemoStep>
        )}
        {showStep4 && (
          <DemoStep>
            <DemoText>4. Successfully initiated Signature creation.</DemoText>
          </DemoStep>
        )}
        {showStep5 && (
          <DemoStep>
            <DemoText>5. Polling for pending Signatures...</DemoText>
          </DemoStep>
        )}
        {showStep6 && (
          <DemoStep>
            <DemoText>
              6. Found pending Signature {pendingSignature?.MPCOperation} with
              payload {pendingSignature?.Payload}
            </DemoText>
          </DemoStep>
        )}
        {showStep7 && (
          <DemoStep>
            <DemoText>7. Processing pending Signature...</DemoText>
          </DemoStep>
        )}
        {showStep8 && (
          <DemoStep>
            <DemoText>8. Got Signature {signature?.SignedPayload}</DemoText>
            <CopyButton text={signature?.SignedPayload!} />
          </DemoStep>
        )}
        {showStep9 && (
          <DemoStep>
            <DemoText>
              9. Got signed transaction {signedTx?.RawTransaction}.
            </DemoText>
            <DemoText>
              You can broadcast this value on-chain if it is a valid transaction.
            </DemoText>
            <CopyButton text={signedTx?.RawTransaction!} />
          </DemoStep>
        )}
        {showError && (
          <DemoStep>
            <ErrorText>{resultError?.message}</ErrorText>
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
