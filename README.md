# React Native WaaS SDK

This is the repository for the mobile React Native SDK for Wallet-as-a-Service APIs.
It exposes a subset of the WaaS APIs to the mobile developer and, in particular, is
required for the completion of MPC operations such as Seed generation and Transaction signing.

### Prerequisites:

- [node 18+](https://nodejs.org/en/download/)
- [yarn 1.22+](https://yarnpkg.com/getting-started/install)

For iOS development:
- [Xcode 14.0+](https://developer.apple.com/xcode/)
  - iOS15.2+ simulator (iPhone 14 recommended)
- [CocoaPods](https://guides.cocoapods.org/using/getting-started.html)

For Android development:
- [Android Studio](https://developer.android.com/studio)
  - x86_64 Android emulator running Android 30+ (Pixel 5 running S recommended)
  - [Android NDK](https://developer.android.com/ndk)
- [Java 8](https://www.java.com/en/download)
  - [Java JDK 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) (JDK 19 will not work with React Native)

## Installation

With `npm`:

```
npm install --save @coinbase/waas-sdk-react-native
```

With `yarn`:

```
yarn add @coinbase/waas-sdk-react-native
```

## Usage

See [index.tsx](./src/index.tsx) for the list of supported APIs.

## Example App

This repository provides an example app that demonstrates how the APIs should be used.

> NOTE: An example Cloud API Key json file is at `example/src/.coinbase_cloud_api_key.json`
> To run the example app, populate, or replace, this file with the Cloud API Key file provided to you
> by Coinbase.

### iOS
Ensure you have XCode open and run the following from the root directory of the repository:

```bash
yarn bootstrap # Install packages for the root and /example directories
yarn example start # Start the Metro server
yarn example ios --simulator "iPhone 14" # Build and start the app on iOS simulator
```
### Android
Ensure you have the following [Android environment variables](https://developer.android.com/studio/command-line/variables) set correctly:

-  `ANDROID_HOME`
-  `ANDROID_SDK_ROOT="${ANDROID_HOME}"`
-  `ANDROID_NDK_HOME="${ANDROID_HOME}/ndk/<insert ndk version>"`
-  `ANDROID_NDK_ROOT="${ANDROID_NDK_HOME}"`

And then export the following to your `PATH`:

`export PATH="${ANDROID_HOME}/emulator:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}"`


Run the following from the root directory of the repository:

```bash
yarn install # Install packages for the root directory
emulator -avd Pixel_5_API_31 # Use any x86_64 emulator with min SDK version: 30.
yarn example start # Start the Metro server
yarn example android # Build and start the app on Android emulator
```

## Recommended Architecture

Broadly speaking, there are two possible approaches to using the WaaS SDK:

1. Use the WaaS backends directly for all calls.
2. Use the WaaS backends directly only for MPC operations; proxy all other calls through an intermediate server.

Of these two approaches, we recommend approach #2, as outlined in the following diagram:

![Recommended Set-up](./assets/diagram.png)

The motivation for placing a proxy server in between your application and the WaaS backends are as
follows:

1. Your proxy server can log API calls and collect metrics.
2. Your proxy server can filter results as it sees fit (e.g. policy enforcement).
3. Your proxy server can perform end user authentication.
4. Your proxy server can store the Coinbase API Key / Secret, rather than it being exposed to the client.
5. Your proxy server can throttle traffic.

In short, having a proxy server that you control in between your application and the WaaS backends will
afford you significantly more control than using the WaaS backends directly in most cases.

The methods from the WaaS SDK which are _required_ to be used for participation in MPC are:
1. `initMPCSdk`
2. `bootstrapDevice`
3. `getRegistrationData`
4. `computeMPCOperation`

