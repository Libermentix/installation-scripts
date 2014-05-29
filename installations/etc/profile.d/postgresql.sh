#!/bin/bash
LD_LIBRARY_PATH=/usr/local/pgsql/lib:/usr/local/lib
export LD_LIBRARY_PATH

PATH=/usr/local/pgsql/bin:$PATH
export PATH

MANPATH=/usr/local/pgsql/man:$MANPATH
export MANPATH

PGDATA=/usr/local/pgsql/data
export PGDATA

