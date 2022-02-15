lowbatt
=======

Synopsis
--------

**lowbatt** [*options*] [*command*]...

Description
-----------

:program:`lowbatt` is a program to automatically notify the user of battery status at set thresholds.

Options
-------

-h, --help
        Show help message and exit

Commands
--------

get
        Display current configuration

set
        Set a value in the configuration file

invoke
        Internal command for service to call

Installation
------------

The makefile is configured with an `install` target, to install use: `sudo make install`.

Examples
--------

Check current configuration.

        :program:`lowbatt get`

Set configuration.

        :program:`lowbatt set lower.threshold`

License
-------

Apache License 2.0, see LICENSE.
