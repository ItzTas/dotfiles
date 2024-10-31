@echo off

set /p JVM_OPENS=<"%_PRG_DIR%java-opens.txt"
set JAVA_OPTS=%JVM_OPENS% %JAVA_OPTS%
