# MBAudience

MBAudience is a plugin libary for [MBurger](https://mburger.cloud), that lets you track user data and behavior inside your and to target messages only to specific users or groups of users. This plugin is often used with the [MBMessages](https://github.com/Mumble-SRL/MBMessages-Flutter) plugin to being able to send push and messages only to targeted users.

MBAudience depends on the following packages:

 - [mburger](https://pub.dev/packages/mburger)
 - [package_info](https://pub.dev/packages/package_info)
 - [permission_handler](https://pub.dev/packages/permission_handler)

# Installation

You can install the MBAudience SDK using pub, add this to your pubspec.yaml file:

``` yaml
dependencies:
  mbaudience: ^0.0.1
```

And then install packages from the command line with:

``` bash
$ flutter pub get
```

# Initialization

To initialize the SDK you have to add `MBAudience` to the array of plugins of `MBurger`.

``` dart
MBManager.shared.apiToken = 'YOUR_API_TOKEN';
MBManager.shared.plugins = [MBAudience()];
```

# Tracked data

Below are described all the data that are tracked by the MBAudience SDK and that you will be able to use from the [MBurger](https://mburger.cloud) dashboard. Most of the data are tracked automatically, for a couples a little setup by the app is neccessary.

- **app_version**: The current version of the app, retrieved from the [package_info](https://pub.dev/packages/package_info) package (`packageInfo.version`).
- **locale**: The locale of the phone, the value returned by `Platform.localeName`.
- **sessions**: An incremental number indicating the number of time the user opens the app, this number is incremented at each startup.
- **sessions_time**: The total time the user has been on the app, this time is paused when the app goes in background (using `WidgetsBindingObserver` app lifecycle state) and it's resumed when the app re-become active.
- **last_session**: The start date of the last session.
- **push_enabled**: If push notifications are enabled or not; to determine this value the SDK uses the [permission_handler](https://pub.dev/packages/permission_handler) package: `Permission.notification.status`.
- **location_enabled**: If user has given permissions to use location data or not; to determine this value the SDK uses the [permission_handler](https://pub.dev/packages/permission_handler) package: `Permission.location.status`.
- **mobile_user_id**: The user id of the user curently logged in MBurger
- **custom_id**: A custom id that can be used to filter further.
- **tags**: An array of tags
- **latitude, longitude**: The latitude and longitude of the last place visited by this device

## Tags

You can set tags to assign to a user/device (e.g. if user has done an action set a tag), so you can target those users later:

To set a tag:

```dart
MBAudience.setTag(tag: 'TAG', value: 'VALUE');
```

To remove it:

```dart
MBAudience.removeTag('TAG');
```

## Custom Id

You can set a custom id in order to track/target users with id coming from different platforms. 

To set a custom id:

```dart
MBAudience.setCustomId('CUSTOM_ID');
```

To remove it:

```dart
MBAudience.removeCustomId();
```

To retrieve the current saved id:

```dart
String customId = await MBAudience.getCustomId();
```

## Mobile User Id

This is the id of the user currently logged in MBurger using MBAuth. At the moment the mobile user id is not sent automatically when a user log in/log out with MBAuth. It will be implemented in the future but at the moment you have to set and remove it manually when the user completes the login flow and when he logs out.

To set the mobile user id:

```dart
MBAudience.setMobileUserId(1);
```

To remove it, if the user logs out:

```dart
MBAudience.removeMobileUserId();
```

To get the currently saved mobile user id: 

```dart
int mobileUserId = await MBAudience.getMobileUserId();
```

## Location Data

MBAudience let you track and target user based on their location. Location is sent to MBurger only if it's distant at least 100m from the last location seen by the SDK.

To start monitoring for location changes call, it will continue monitoring until the stop method is called:

```dart
MBAudience.startLocationUpdates();
```

To stop monitoring location changes you have to call:

```dart
MBAudience.stopLocationUpdates();
```

If you want to implement your location logic yoou can always tell `MBAudience` location data with:

```dart
MBAudience.setCurrentLocation(latitude, longitude);
```

#### iOS
The framework uses the method [startMonitoringSignificantLocationChanges](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423531-startmonitoringsignificantlocati) of the CoreLocation manager with an accuracy of `kCLLocationAccuracyHundredMeters`. To start monitoring for location changes call, it will continue monitoring until the stop method is called:

#### Android
MBAudience let you track and target user based on their location, the framework uses a foreground `FusedLocationProviderClient` with priority `PRIORITY_BALANCED_POWER_ACCURACY` which is killed the moment the app goes in background. If you wish to track user position while app is in background you need to implement your own location service, then when you have a new location you can use this API to send it to the framework: `setCurrentLocation(latitude, longitude)`
