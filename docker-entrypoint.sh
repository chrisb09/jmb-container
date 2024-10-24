#!/bin/sh
#set -e


# Check if the config directory is empty
if [ -z "$(ls -A /jmb/config)" ]; then
    echo "Config directory is empty. Copying default config..."
    cp /jmb/reference/config.txt /jmb/config/config.txt
fi

chmod -R 755 /jmb/config && chown -R 10000:10001 /jmb/config

exec su-exec appuser java -jar -Dnogui=true /jmb/JMusicBot.jar
