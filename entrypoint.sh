#!/bin/bash
set -x

USERNAME=${USERNAME:=plex}
GROUP=${GROUP:=plex}

if ! id -u "${USERNAME}" >/dev/null 2>&1; then
  groupadd --gid ${USER_GID:=4000} ${GROUP}
  useradd --uid ${USER_UID:=4000} --gid ${USER_GID:=4000} --system -M --shell /usr/sbin/nologin ${USERNAME}
elif [ `id -u ${USERNAME}` != ${USER_UID:=4000} ]; then
  usermod -u ${USER_UID:=4000} ${USERNAME}
  groupmod -g ${USER_GID:=4000} ${GROUP}
  usermod -G ${USER_GID:=4000} ${USERNAME}
fi

if [ "${CHANGE_CONFIG_DIR_OWNERSHIP}" = true ]; then
  find ${HOME} ! -user ${USERNAME} -print0 | xargs -0 -I{} chown -R ${USERNAME}: {}
fi

# Will change all files in directory to be readable by group
if [ "${CHANGE_DIR_RIGHTS}" = true ]; then
  chgrp -R ${GROUP} /media
  chmod -R g+rX /media
fi

# Make sure old pid gets removed before starting
rm -rf /config/Library/Application\ Support/Plex\ Media\ Server/plexmediaserver.pid

# Current defaults to run as root while testing.
if [ "${RUN_AS_ROOT}" = true ]; then
  /usr/sbin/start_pms
else
  sudo -u ${USERNAME} -E sh -c "/usr/sbin/start_pms"
fi