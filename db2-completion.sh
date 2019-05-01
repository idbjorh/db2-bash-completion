#!/usr/bin/env bash
#
# bash completion file for Db2 CLP.  
#
#  Credit to Docker for many code patterns / ideas
#   https://github.com/docker/docker-ce/tree/master/components/cli/contrib/completion/bash
#
#
# To enable the completions, either:
#  - place this file in /etc/bash_completion.d
#  or
#  - copy this file to e.g. ~/.db2-completion.sh and add the line
#    below to your .bashrc after bash completion features are loaded
#    . ~/.db2-completion.sh
#

__db2_previous_extglob_setting=$(shopt -p extglob)
shopt -s extglob


#
# __db2_databases returns a list of Db2 databases.
#
__db2_databases() {

    # Use the cache file only if it's less than 60 minutes old.
    #    note this depends on find having a -mmin option, which probably breaks
    #    this on AIX, Solaris
    if [[ -f $(find $HOME -maxdepth 1 -name .db2completion-dbs -mmin -60) ]] ; then
        cat $HOME/.db2completion-dbs
    else 
        db2 list db directory | awk '{ if (/Database alias/) {print $4}}' | tee $HOME/.db2completion-dbs
    fi
}

__db2_complete_databases() 
{
    local current="$cur"
    if [ "$1" = "--cur" ] ; then
        current="$2"
        shift 2
    fi
    COMPREPLY=( $(compgen -W "$(__db2_databases "$@")" -- "$current") )
    
    return 0
}


__db2_nodes()
{
    db2 list node directory | awk '{if (/Node name/) { print $4 }}'
}

__db2_complete_nodes()
{
    local current="$cur"
    if [ "$1" = "--cur" ] ; then
        current="$2"
        shift 2
    fi
    COMPREPLY=( $(compgen -W "$(__db2_nodes "$@")" -- "$current") )
    
    return 0
}    

# return name of currently-connected database
__db2_connection() {
    local connection=$(db2 connect | awk '{ if (/alias/) { print $NF } }')
    echo $connection
}



_db2_db2() {
    # top level commands
    case "$cur" in
	*)
	    COMPREPLY=( $( compgen -W "${commands[*]}" -- "$cur" ) )
	    ;;
    esac
}

# __db2_to_alternatives transforms a multiline list of strings into a single line
# string with the words separated by `|`.
# This is used to prepare arguments to __docker_pos_first_nonflag().
__db2_to_alternatives() {
	local parts=( $1 )
	local IFS='|'
	echo "${parts[*]}"
}

# __db2_to_extglob transforms a multiline list of options into an extglob pattern
# suitable for use in case statements.
__db2_to_extglob() {
	local extglob=$( __db2_to_alternatives "$1" )
	echo "@($extglob)"
}

# __db2_subcommands processes subcommands
# Locates the first occurrence of any of the subcommands contained in the
# first argument. In case of a match, calls the corresponding completion
# function and returns 0.
# If no match is found, 1 is returned. The calling function can then
# continue processing its completion.
#
# TODO if the preceding command has options that accept arguments and an
# argument is equal ot one of the subcommands, this is falsely detected as
# a match.
__db2_subcommands() {
    local subcommands="$1"
    
   	local counter=$((command_pos + 1))
	while [ "$counter" -lt "$cword" ]; do
		case "${words[$counter]}" in
			$(__db2_to_extglob "$subcommands") )
				subcommand_pos=$counter
				local subcommand=${words[$counter]}
				local completions_func=_db2_${command}_${subcommand//-/_}
				declare -F "$completions_func" >/dev/null && "$completions_func"
				return 0
				;;
		esac
		(( counter++ ))
	done
	return 1
}

_db2() {
    local previous_extglob_setting=$(shopt -p extglob)
    shopt -s extglob

    local commands=(
        activate
        archive
        catalog
        connect
        deactivate
        describe
        list
        terminate
    )


    COMPREPLY=()
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    (( i = $cword - 2 ))
    prevprev=${COMP_WORDS[$i]}
    
    local command='db2' command_pos=0 subcommand_pos 
    local counter=1
    while [ "$counter" -lt "$cword" ] ; do
	case "${words[$counter]}" in
	    db2)
		return 0
		;;
	    -*)
		;;
	    =)
                (( counter++ ))
                ;;
	    *)
		command="${words[$counter]}"
		command_pos=$counter
		break
		;;
	esac
	(( counter++ ))
    done

    
    local completions_func=_db2_${command//-/_}

    
    declare -F $completions_func >/dev/null && $completions_func

    eval "$previous_extglob_setting"
    return 0
}





eval "$__db2_previous_extglob_setting"
unset __db2_previous_extglob_setting

complete -F _db2 db2


_db2_activate() 
{

    if [[ ${prev} = "database" ]] ; then
        __db2_complete_databases $@ && return
    else
        COMPREPLY=( $( compgen -W "database" -- "$cur" ) )
    fi
    
}

_db2_archive()
{
    if [[ ${prev} = "archive" ]] ; then
        COMPREPLY="log for database"
    elif [[ ${prev} = "database" ]] ; then
        __db2_complete_databases $@ && return
    elif [[ ${prev} = "on" ]] ; then
        COMPREPLY="all dbpartitionnums"
    fi
    
    if [[ ${prevprev} = "database" ]] ; then
        COMPREPLY=( $(compgen -W "user on" -- "$cur") )
    elif [[ ${prevprev} = "user" ]] ; then
        COMPREPLY="using"
    fi
        
} 



_db2_catalog()
{
    if [[ ${prev} = "catalog" ]] ; then
        COMPREPLY=( $(compgen -W "database dcs ldap local tcpip" -- "$cur") )
    elif [[ ${prev} = "dcs" ]] ; then
        COMPREPLY="database"
    elif [[ ${prev} = "ldap" ]] ; then
        COMPREPLY=( $(compgen -W "database node" -- "$cur") )
    elif [[ ${prev} = "local" || ${prev} = "tcpip" ]] ; then
        COMPREPLY="node"
    fi
    
    if [[ ${prevprev} = "database" ]] ; then
        COMPREPLY="at node"
    elif [[ ${prevprev} = "at" && ${prev} = "node" ]] ; then
        __db2_complete_nodes $@ && return
    fi
        
}


_db2_connect()
{
    if [[ "$prev" = "connect" ]] ; then
        COMPREPLY=( $( compgen -W "to" -- "$cur") )
    elif [[ "$prev" = "to" ]] ; then
        __db2_complete_databases $@
    elif [[ "$prevprev" = "to" ]] ; then
	    COMPREPLY=( $(compgen -W "user" -- "$cur") )
    elif [[ "$prevprev" = "user" ]] ; then
        COMPREPLY=( $(compgen -W "using" -- "$cur") )
    fi
        
	return 0
}

_db2_deactivate()
{
    if [[ ${prev} = "database" ]] ; then
	    __db2_complete_databases $@ && return
    else
        COMPREPLY=( $( compgen -W "database" -- "$cur" ) )
    fi

    return 0
}

_db2_describe()
{
    if [[ ${prev} = "describe" ]] ; then
        COMPREPLY=( $(compgen -W "table indexes" -- "$cur") )
    elif [[ ${prev} = "indexes" ]] ; then
        COMPREPLY="for table"
    fi
    
    if [[ ${prevprev} = "table" ]] ; then
        COMPREPLY="show detail"
    fi
       
}

_db2_list()
{
    local subcommands="
        active
        applications
        command
        database
        dbpartitionnums
        dcs
        drda
        history
        indoubt
        instance
        node
        packages
        tables
        tablespace
        tablespaces
        utilities
    "


    __db2_subcommands "$subcommands" && return
    COMPREPLY=( $(compgen -W "$subcommands" -- "$cur") )
   
}

_db2_list_active()
{
    if [[ ${prev} != "databases" ]] ; then
        COMPREPLY=( $(compgen -W "databases" -- "$cur") )
    fi
        
    return 0
}


_db2_list_applications()
{
    if [[ ${prev} = "applications" ]] ; then
        COMPREPLY=( $(compgen -W "for at global show" -- "$cur") )
    elif [[ ${prev} = "for" ]] ; then
        COMPREPLY=( $(compgen -W "database" -- "$cur") )
    elif [[ ${prev} = "at" ]] ; then
        COMPREPLY=( $(compgen -W "member" -- "$cur") )
    elif [[ ${prev} = "show" ]] ; then
        COMPREPLY=( $(compgen -W "detail" -- "$cur") )
    fi
    
}

_db2_list_command()
{
    if [[ ${prev} != "options" ]] ; then
        COMPREPLY=( $(compgen -W "options" -- "$cur") )
    fi
    return 0    
}

_db2_list_database()
{
    local subcommands="
        directory
        partition
    "
    
    if [[ ${prev} = "database" ]] ; then
        __db2_subcommands "$subcommands" && return
        COMPREPLY=( $(compgen -W "$subcommands" -- "$cur")) 
    elif [[ ${prev} = "partition" ]] ; then
        COMPREPLY=( $(compgen -W "groups" -- "$cur") )
        
    fi
    
}

_db2_list_dcs()
{
    if [[ ${prev} = "dcs" ]] ; then
        COMPREPLY=( $(compgen -W "applications directory" -- "$cur") )
    elif [[ ${prev} = "applications" ]] ; then
        COMPREPLY=( $(compgen -W "show extended" -- "$cur") )
    elif [[ ${prev} = "show" ]] ; then
        COMPREPLY=( $(compgen -W "detail" -- "$cur") )
    fi
    
}

_db2_list_drda()
{
    if [[ ${prev} = "drda" ]] ; then
        COMPREPLY="indoubt transactions"
    fi
}

_db2_list_history()
{
    local subcommands="
        backup
        rollforward
        dropped
        load
        create
        alter
        rename
        reorg
        archive
    "

    if [[ ${prev} = "history" ]] ; then
        __db2_subcommands "$subcommands" && return
        COMPREPLY=( $(compgen -W "$subcommands" -- "$cur")) 
    elif [[ ${prev} = "dropped" ]] ; then
        COMPREPLY=( $(compgen -W "table" -- "$cur") )
    elif [[ ${prev} = "create" || ${prev} = "alter" || ${prev} = "rename" ]] ; then
        COMPREPLY=( $(compgen -W "tablespace" -- "$cur") )
    elif [[ ${prev} = "archive" ]] ; then
        COMPREPLY=( $(compgen -W "log" -- "$cur") )
    else
        COMPREPLY=( $(compgen -W "all since containing" -- "$cur") )
    fi
}

_db2_list_indoubt()
{
    if [[ ${prev} = "indoubt" ]] ; then
        COMPREPLY="transactions"
    fi   
}

_db2_list_instance()
{
    if [[ ${prev} = "instance" ]] ; then
        COMPREPLY="show detail"
    fi
}


_db2_list_node()
{
    if [[ ${prev} = "node" ]] ; then
        COMPREPLY="directory"
    elif [[ ${prev} = "directory" ]] ; then
        COMPREPLY="show detail"
    fi
}

__db2_list_objects()
{
    if [[ ${prev} = "packages" || ${prev} = "tables" ]] ; then
        COMPREPLY="for"
    elif [[ ${prev} = "for" ]] ; then
        COMPREPLY=( $(compgen -W "user all schema system" -- "$cur") )
    fi      
}

_db2_list_packages()
{
    __db2_list_objects && return
}

_db2_list_tables()
{
    __db2_list_objects && return
}


_db2_list_tablespace() 
{
    if [[ ${prev} = "tablespace" ]] ; then
        COMPREPLY=( $(compgen -W "containers" -- "$cur") )
    elif [[ ${prev} = "containers" ]] ; then
        COMPREPLY=( $(compgen -W "for" -- "$cur") )
    fi
}


_db2_list_utilities()
{
    if [[ ${prev} = "utilities" ]] ; then
        COMPREPLY="show detail"
    fi
}




