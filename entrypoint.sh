#!/bin/bash

# Wait until Consul can be contacted
until consul members; do
  echo "Waiting for Consul to start"
  sleep 1
done

# If we do not need to register a service just run the command
if [ ! -z "$SERVICE_CONFIG" ]; then
  # register the service with consul
  echo "Registering service with consul $SERVICE_CONFIG"
  consul services register ${SERVICE_CONFIG}
  
  if [ $? != 0 ]; then
    echo "Registering config for file:"
    cat ${file}
  fi
  
  # make sure the service deregisters when exit
  trap "consul services deregister ${SERVICE_CONFIG}" SIGINT SIGTERM EXIT
fi

# register any central config from individual files
if [ ! -z "$CENTRAL_CONFIG" ]; then
  IFS=';' read -r -a configs <<< ${CENTRAL_CONFIG}

  for i in "${configs[@]}"; do
    echo "Register central config $i"
    consul config write $i
      
    if [ $? != 0 ]; then
      echo "Registering config for file:"
      cat ${file}
    fi
  done
fi

# register any central config from a folder
if [ ! -z "$CENTRAL_CONFIG_DIR" ]; then
  for file in $CENTRAL_CONFIG_DIR/*; do 
    echo "Register central config $file"

    if [[ "${file#*.}" == "hcl" ]]; then
      consul config write $file

      if [ $? != 0 ]; then
        echo "Registering config for file:"
        cat ${file}
      fi
    fi
    
    if [[ "${file#*.}" == "json" ]]; then
	    curl -s -XPUT -d @$file ${CONSUL_HTTP_ADDR}/v1/config 
  
      if [ $? != 0 ]; then
        echo "Registering config for file:"
        cat ${file}
      fi
    fi
  done
fi

# Run the command if specified
echo "Command: $@"
if [ "$#" -ne 0 ]; then
  exec "$@" &

  # Block using tail so the trap will fire
  tail -f /dev/null &
  PID=$!
  wait $PID
fi
