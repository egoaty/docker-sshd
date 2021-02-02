#!/bin/sh
##
## Run the daemon (sshd)
##
## Environment Variables:
## LOGIN_USER_FILE ... file containing list of unprivileged users.
##                     Default: /login_users
##                     Format (per line):
##                     <username>:[<password hash (crypt)>]:[<UID>]:[<GUID>]:[<comment>]:[<home directory>]:[shell]:[<SSH public key>]
##

user_file="${LOGIN_USER_FILE:-/login_users}"

if ! [ -f /users_created ]; then
	if ! [ -f "${user_file}" ]; then
		echo "ERROR: Need to mount user file to '${user_file}'." >&2
		echo "Format (per line):" >&2
		echo "<username>:[<password hash (crypt)>]:[<UID>]:[<GID>]:[<comment>]:[<home directory>]:[shell]:[<SSH public key>]" >&2
		exit 2
	fi
	
	set -e   # Exit on error
	
	cat "${user_file}" | \
	while read -r line; do
		
		# Ignore empty lines and lines starting with #
		[ -z "${line}" ] && continue
		[ "${line#\#}" != "${line}" ] && continue
	
		OLDIFS="${IFS}"
		IFS=':'
		set ${line}
		IFS="${OLDIFS}"
		user="$1"
		password="$2"
		uid="$3"
		gid="$4"
		gecos="$5"
		home="${6:-/home/${user}}"
		shell="${7:-/bin/bash}"
		ssh_key="$8"
	
		if [ -z "${user}" ]; then
			echo "ERROR: Username must not be empty." >&2
			exit 2
		fi
	
		if [ -n "${home}" ] && [ "${home#/home/}" == "${home}" ]; then
			echo "ERROR: HOME directory of user '${user}' has to be under /home. '${home}'" >&2
			exit 2
		fi
		
		if [ -n "${gid}" ]; then
			if [ "${gid}" -lt 1000 ]; then
				echo "ERROR: GID must be >=1000" >&2
				exit 2
			fi
			echo "Creating group '${user}' with GID '${gid}'."
			groupadd -g "${gid}" "${user}"
		fi
	
		if [ -n "${uid}" ] && [ "${uid}" -lt 1000 ]; then
			echo "ERROR: UID must be >=1000" >&2
			exit 2
		fi
	
		[ -n "${password}" ] && OPTS="${OPTS} -p ${password}"
		[ -n "${uid}" ] && OPTS="${OPTS} -u ${uid}"
		[ -n "${gid}" ] && OPTS="${OPTS} -g ${gid}"
		[ -n "${gecos}" ] && OPTS="${OPTS} -c ${gecos}"
		[ -n "${home}" ] && OPTS="${OPTS} -d ${home}"
		[ -n "${shell}" ] && OPTS="${OPTS} -s ${shell}"
		echo "Creating user '${user}'."
		useradd -m ${OPTS} "${user}"
	
		if [ -n "${ssh_key}" ]; then
			mkdir -p "${home}/.ssh/"
			chown "${user}" "${home}/.ssh/"
			chmod 700 "${home}/.ssh/"
			touch "${home}/.ssh/authorized_keys"
			chown "${user}" "${home}/.ssh/authorized_keys"
			chmod 600 "${home}/.ssh/authorized_keys"
			grep "${ssh_key}" "${home}/.ssh/authorized_keys" >/dev/null ||
		  	echo "${ssh_key}" >> "${home}/.ssh/authorized_keys"
		fi
	
	done
	set +e 

	touch /users_created
fi

# Genereate host keys if they don't exist
ssh-keygen -A -f /local

touch /var/log/sshd.log

# Print sshd log messages to stdout (in background)
tail -F /var/log/sshd.log &

# Run sshd
exec /usr/sbin/sshd -D -E /var/log/sshd.log

