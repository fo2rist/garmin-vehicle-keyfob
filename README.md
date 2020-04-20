# Garmin Vehicle Keyfob
Garmin app that allow to Lock/Unlock a car from watch


![Main screen](docs/keyfob_main_screen.png?raw=true)
![Lock screen](docs/keyfob_lock_screen.png?raw=true)

## Requirements
- App uses [Garmin Connect-IQ SDK](https://developer.garmin.com/connect-iq/overview/) it needs to be installed prior build
- App uses [Smartcar API](https://smartcar.com/docs/api) to connect to vehicle.

To build a working app add one more file to `/source` that contains following constants for Smartcar API
```
const CLIENT_ID = "UUID HERE";
const BASIC_AUTH_CREDENTIALS = "CREDENTIAL FOR YOU APP HER";
```
(to obtain the keys sign up and register an app on smartcar.com)
and generate a signing certificate according to _Generating a Developer Key_ [instruction](https://developer.garmin.com/connect-iq/programmers-guide/getting-started) (I place it in '~/.garmin/developer_key.der' for convinience)

## How to build
To build the executable
```
monkeyc -o build/app.prg -f monkey.jungle -y ~/.garmin/developer_key.der
```

To run
```
monkeydo build/app.prg %DEVICE_TYPE%
```
where %DEVICE_TYPE% is a watch model for simulator, e.g. `vivoactive3`

To install on real device
- comment `"mode" => "test"` line in code
- build
- connect watch to computer and copy executable to apps folder on device
