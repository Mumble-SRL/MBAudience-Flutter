# MBAudience

MBAudienceSwift is a plugin libary for [MBurger](https://mburger.cloud), that lets you track user data and behavior inside your and to target messages only to specific users or groups of users. This plugin is often used with the [MBMessages](https://github.com/Mumble-SRL/MBMessages-Flutter) plugin to being able to send push and messages only to targeted users.

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

```
MBManager.shared.apiToken = 'YOUR_API_TOKEN';
MBManager.shared.plugins = [MBAudience()];
```
