#!/bin/bash

# sleep for $SLEEP seconds to a maxium of 10 tries
SLEEP=1

db_not_ready() {
    echo ERROR: failed to connect to db
    echo " "
    echo "postgresql server was not initialised in time or correctly. Try running 'docker-compose up' again."
    echo If the problem persists, consider inspecting the postgresql container for logs or waiting longer for
    echo DB to initialise by increasing the SLEEP var in web/api-start.sh to a higher value and rebuilding
    echo the containers
    echo " "
    exit 1
}

wait_db() {
    while true; do
        echo -e "\033[1mAttempt to connect to db.. try #$i\033[0m"
        sudo -u postgres psql -h ${POSTGRES_HOST} --command 'select 1;' && return 0
        sleep $SLEEP
    done
    return 1
}

if [[ -n ${POSTGRES_PASSWORD+x} && -n ${LEMUR_PASSWORD+x} ]]
then
  PG_HOME=$(awk -F: -v v="postgres" '{if ($1==v) print $6}' /etc/passwd)
  touch ${PG_HOME}/.pgpass
  chown postgres:postgres ${PG_HOME}/.pgpass
  chmod 0600 ${PG_HOME}/.pgpass
  echo "${POSTGRES_HOST}:5432:*:postgres:${POSTGRES_PASSWORD}" > ${PG_HOME}/.pgpass

  echo "Waiting for db to become available"
  wait_db
  [ "x$?" == "x0" ] && printf "db ready!\n\n" || db_not_ready

  echo "Creating lemurdb..."
  sudo -u postgres psql -h ${POSTGRES_HOST} --command "CREATE DATABASE lemur;"
  echo "Creating the lemur user..."
  sudo -u postgres psql -h ${POSTGRES_HOST} --command "CREATE USER lemur WITH PASSWORD '${LEMUR_DB_PASSWORD}';"
  echo "Changing postgres password..."
  sudo -u postgres psql -h ${POSTGRES_HOST} --command "GRANT ALL PRIVILEGES ON DATABASE lemur to lemur;"
  echo "Done changing postgres password..."
  echo "DONE CREATING lemurdb..."
fi

cd /usr/local/src/lemur/lemur

export PATH=/usr/local/src/lemur/venv/bin:${PATH}

if [[ -n ${POSTGRES_PASSWORD+x} && -n ${LEMUR_PASSWORD+x} ]]
then
  python manage.py init -p ${LEMUR_PASSWORD}
fi
python manage.py start -w 6 -b 0.0.0.0:8000
