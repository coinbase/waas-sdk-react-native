# React Native WaaS SDK

This is the repository for the mobile React Native SDK for Wallet-as-a-Service APIs.
It exposes a subset of the WaaS APIs to the mobile developer and, in particular, is
required for the completion of MPC operations such as Seed generation and Transaction signing.

### Prerequisites:

- [node 18+](https://nodejs.org/en/download/)
- [yarn classic 1.22+](https://classic.yarnpkg.com/en/docs/install)

For iOS development:
- [Xcode 14.0+](https://developer.apple.com/xcode/)
  - iOS15.2+ simulator (iPhone 14 recommended)
- [CocoaPods](https://guides.cocoapods.org/using/getting-started.html)
- [make](https://www.gnu.org/software/make/)

For Android development:
- [Android Studio](https://developer.android.com/studio)
  - x86_64 Android emulator running Android 30+ (Pixel 5 running S recommended)
  - [Android NDK](https://developer.android.com/ndk)
- [Java 8](https://www.java.com/en/download)
  - [Java JDK 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) (JDK 19 will not work with React Native)

## Installation

### React Native

With `npm`:

```
npm install --save @coinbase/waas-sdk-react-native
```

With `yarn`:

```
yarn add @coinbase/waas-sdk-react-native
```

### Android

In your Android application's `settings.gradle` file, make sure to add the following:

```gradle

include ":android-native", ":android-native:go-internal-sdk", ":android-native:mpc-sdk" 

project(':android-native').projectDir = new File(rootProject.projectDir, '../node_modules/@coinbase/waas-sdk-react-native/android-native')
project(':android-native:mpc-sdk').projectDir = new File(rootProject.projectDir, '../node_modules/@coinbase/waas-sdk-react-native/android-native/mpc-sdk')
project(':android-native:go-internal-sdk').projectDir = new File(rootProject.projectDir, '../node_modules/@coinbase/waas-sdk-react-native/android-native/go-internal-sdk')
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

> *NOTE:* To build an app that depends on the WaaS SDK, you'll also need a compatible version of OpenSSL.
> You can build the OpenSSL framework by running the following on your Mac from the root of this repository:
> 
> `yarn ssl-ios`
> 
> You can alternatively depend on an open-compiled version of OpenSSL, like [OpenSSL-Universal](https://cocoapods.org/pods/OpenSSL-Universal), by adding the following to your app's Podfile:
> 
> `pod "OpenSSL-Universal"`

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

# Native Waas SDK (Beta)

## Android

We expose a Java 8+, `java.util.concurrent.Future`-based SDK for use with Java/Kotlin. An example
app is included in `android-native-example/` for more information.

### Requirements

- Java 8+
- Gradle 7.*
  - If using central gradle repositories, you may need to update your `settings.gradle` to not fail on project repos.
    - i.e (`repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)`)

### Installation
To begin, place the `android-native` directory relative to your project.

In your `settings.gradle`, include the following:

```
include ':android-native', ':android-native:mpc-sdk', ':android-native:go-internal-sdk'
project(':android-native').projectDir = new File(rootProject.projectDir, '../android-native')
project(':android-native:mpc-sdk').projectDir = new File(rootProject.projectDir, '../android-native/mpc-sdk')
project(':android-native:go-internal-sdk').projectDir = new File(rootProject.projectDir, '../android-native/go-internal-sdk')
```

Remember to specify the correct relative-location of `android-native`.

In your `build.gradle`, you should now take dependencies on

```
implementation project(":android-native")
implementation project(':android-native:mpc-sdk')
implementation project(':android-native:go-internal-sdk')
```

### Demo App
A demo app of the native SDK is included in `android-native/`. Opening this directory with Android Studio should be 
sufficient to build and run the app.

### Considerations

- The SDK should import cleanly into Kotlin as-is -- the sample app includes a demonstration of utilizing Waas's Futures
with Kotlin task-closures. Please reach out with any questions.

## iOS

Waas also supports Native iOS (iOS 13+), using Swift 5.5 futures. The react-native SDK wraps this into convenient
JS-exposed modules.

### Requirements

- iOS 13+
- Swift 5.5+ in Xcode (run `swift version` to check your compiler)

### Installation

You can rely upon the `WaasSdk` pod from this repository to use Waas directly in Swift.

In your `Podfile`:

```ruby
source "https://github.com/coinbase/waas-sdk-react-native"

target "MyApp" do
  pod "WaasSdk", '~>0.0.1'
end
```

Once you've added the `pod` and custom `source`, you can run `pod install` to begin using the SDK.

### Demo App

At the moment, no demo app is included for native iOS. We'll introduce this in a followup PR. For now, the API for Native iOS matches identically to the react-native API, so code should be logically identical.

Please open an issue or contact our cloud forums with any questions.
