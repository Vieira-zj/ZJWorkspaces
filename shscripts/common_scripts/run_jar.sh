#!/bin/bash
set -u

if [[ $1 == "jar" ]]; then
  mvn clean package -Dmaven.test.skip=true
fi

if [[ $1 == "run" ]]; then
  paths=""
  for jar_file in $(ls lib); do
    paths="${paths}:lib/${jar_file}"
  done

  paths="target/kp-0.0.1-SNAPSHOT-jar-with-dependencies.jar${paths}"
  main="com.yumc.kp.HiveWeakLoad"
  cmd="java -cp ${paths} ${main}"
  echo "run cmd: ${cmd}"
  ${cmd}
fi

echo "Run jar done."
