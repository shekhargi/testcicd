#!/bin/sh

export TEST_ENV_VAR=value has come from env

java  -Xms512m -Xmx950m -XX:+ExitOnOutOfMemoryError -jar app.jar