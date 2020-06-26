# office-forge-install

This script will install and configure a suitable environment for running the Office Forge application (or other LAMP/Laravel application).

It is designed and tested to run effectively on a standard Digital Ocean Ubuntu 20.04 installation. For other environments/operating systems/hosts/etc, your mileage may vary.

Aside from taking the opinionated actions of

- disabling the default 000-default and default-ssl Apache vhosts
- creating an officeforge database and mysql user

this script should be suitable to execute on an existing environment, though this hasn't been tested.

More details will follow as the Office Forge installation process is refined.
