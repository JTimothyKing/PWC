#!/usr/bin/env bash
DIR=$( dirname "${BASH_SOURCE[0]}" )
perl -I"$DIR" "$DIR"/1-no-connection.pl
