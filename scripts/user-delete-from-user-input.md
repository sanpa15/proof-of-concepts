## user-delete-from-user-input.md

```bash
#!/usr/bin/env bash
set -x
USERNAME="jino dodo"

for NAME in $USERNAME; do
    USER=$(cat /etc/passwd | grep ${NAME} | awk -F: '{print $1}')
    if [ "${USER}" == "${NAME}" ]; then
        echo "${USER} user is available in the system"
        echo "${NAME} user is going to be delete"
        sudo killall -u "${NAME}"
        sudo userdel -r "${NAME}"
    else
        echo "${NAME} user is not available in the system"
    fi
    echo ""
done
```

_validation_

```bash
#!/usr/bin/env bash
USERNAME="jino ubuntu"
for NAME in $USERNAME; do
    USER=$(cat /etc/passwd | grep "${NAME}" | awk -F: '{print $1}')
    echo "${USER}"
done
```
