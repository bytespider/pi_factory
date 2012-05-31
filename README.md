# The Pi Factory

A set of tools for playing with the Raspberry Pi

Released under the MIT. Please see LICENCE in the project root folder for more
information.


# SDFlash
## Usage

    ./sdflash.sh

### Prerequisites
You'll need one or more `.img` images unzipped and placed in the `pi_factory` directory.
You'll also need to take note of the volume name once the SD card has mounted.

During the process you'll be asked a series of questions, the first of which is about the drive you wish to flash. Make sure you
insert the SD card before running `./sdflash.sh`

Be sure to heed the warnings.


## To do

- Auto detect sd card insertion. This should make the script friendlier for beginers
- Download distributions


## Authors

  * Rob Griffiths (rob AT bytespider DOT eu) [@bytespider](https://twitter.com/bytespider)
