#!/usr/bin/env bash
DIR=$( dirname "${BASH_SOURCE[0]}" )
dotnet run --project "$DIR"/1-no-connection/1-no-connection.csproj
