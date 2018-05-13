# Flashy
Flashy is a collection of helper scripts to make flashing routers faster and easier - especially when flashing routers in bulk.

Some of the scripts can do everything, but some will require a specific starting state. Be sure to read the usage before attempting to flash anything.

## Usage 

Find the directory for your router model and run the bare command:
```
./flasher.sh 
```

After reading the requirements and usage, run the script with the necessary arguments
```
./flasher.sh 192.168.31.1 715712a016753036f25e41f2d2a7642f
```

## Contributing

To add new routers, simply find or create a folder for the router manufacturer, and create a new ./flasher.sh that automates some or all of the flashing process for that router.

Patches to existing scripts to make them more error resistant or comprehensive are greatly appreciated.