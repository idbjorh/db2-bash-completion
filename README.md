# Db2 Bash Completion

db2-completion.sh defines a set of shell functions to provide command-line completion 
for CLP _commands_ of the IBM Db2 Command Line Processor.


## Installation

To enable the completions, either:

- place db2-completion.sh in /etc/bash_completion.d

or

- copy db2-completion.sh to ~/.db2-completion.sh (for example) and add the line below
  to your `.bashrc` after bash completion features are loaded
   
        . ~/.db2-completion.sh


## Db2 Command Support

Currently, db2-completion.sh supports the following Db2 CLP Commands:

- ACTIVATE DATABASE
- ARCHIVE LOG
- CATALOG DATABASE
- CATALOG DCS DATABASE
- CATALOG LDAP DATABASE
- CATALOG LDAP NODE
- CATALOG LOCAL NODE
- CATALOG TCPIP NODE
- CONNECT
- DEACTIVATE DATABASE
- DESCRIBE
- LIST ACTIVE DATABASES
- LIST APPLICATIONS
- LIST COMMAND OPTIONS
- LIST DATABASE DIRECTORY
- LIST DATABASE PARTITION GROUPS
- LIST DBPARTITIONNUMS
- LIST DCS APPLICATIONS
- LIST DCS DIRECTORY
- LIST DRDA INDOUBT TRANSACTIONS
- LIST HISTORY
- LIST INDOUBT TRANSACTIONS
- LIST INSTANCE
- LIST NODE DIRECTORY
- LIST PACKAGES/TABLES
- LIST TABLESPACE CONTAINERS
- LIST TABLESPACES
- LIST UTILITIES
- RUNSTATS
- TERMINATE


## Usage Notes

- Not all options are available for all supported CLP Commands; completion is 
  supported for typical sets of options.

- Table name completion is not supported (for performance reasons).

- Command completion will not work if commands are enclosed in quotes, i.e.:

        db2 "con<TAB>"


