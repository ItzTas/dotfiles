#!/bin/sh

JVM_OPENS=$(cat $PRGDIR/java-opens.txt)
JAVA_OPTS="$JVM_OPENS $JAVA_OPTS"
