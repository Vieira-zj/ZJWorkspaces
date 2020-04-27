#!/bin/bash
set -e

PWD=$(cd `dirname $0`; pwd)
CWD="$PWD/.."

source "${CWD}/bin/load_configs.sh"

script_dir=$(dirname $(dirname $0))
cd ${script_dir}

export JAVA_HOME=${script_dir}/jdk
export HADOOP_HOME=${script_dir}/hadoop
export HADOOP_CONF_DIR=${script_dir}/hadoop/etc/hadoop
export KERBEROS_KEYTAB=${kerberos_keytab}
export LC_ALL="en_US.UTF-8"
export TZ=""
export PATH=${script_dir}/jdk/bin:${script_dir}/hadoop/bin:$PATH

if [ 0"$hadoop_configs" = 0 ]; then
    hadoop_configs="primary,${hadoop_type},hadoop.tar.gz,${sage_distribution},valid,${hadoop_username}"
fi

for line in $hadoop_configs; do
    arr=(${line//,/ })
    hadoopUserName=${arr[5]}

    export HADOOP_USER_NAME=${hadoopUserName}
    export KERBEROS_USER=${hadoopUserName}
    HADOOP_TAR_GZ_PATH=${script_dir}/config/prophet/hadoop/${arr[2]}
    rm -rf ${HADOOP_CONF_DIR}/*
    tar xf ${HADOOP_TAR_GZ_PATH} -C ${HADOOP_CONF_DIR}
    CLASSPATH=$(${HADOOP_HOME}/bin/hadoop classpath)
    CLASSPATH=${script_dir}:$CLASSPATH
    kerberos_user=${KERBEROS_USER} kerberos_keytab=${kerberos_keytab} ${JAVA_HOME}/bin/java -cp ${CLASSPATH} FileSystemOperations mkdir ${hdfs_dir}
    kerberos_user=${KERBEROS_USER} kerberos_keytab=${kerberos_keytab} ${JAVA_HOME}/bin/java -cp ${CLASSPATH} FileSystemOperations mkdir ${hdfs_upload_files_dir_with_version}
    kerberos_user=${KERBEROS_USER} kerberos_keytab=${kerberos_keytab} ${JAVA_HOME}/bin/java -cp ${CLASSPATH} FileSystemOperations mkdir ${hdfs_dir}/workspace
    kerberos_user=${KERBEROS_USER} kerberos_keytab=${kerberos_keytab} ${JAVA_HOME}/bin/java -cp ${CLASSPATH} FileSystemOperations mkdir ${hdfs_dir}/platform-data
    kerberos_user=${KERBEROS_USER} kerberos_keytab=${kerberos_keytab} ${JAVA_HOME}/bin/java -cp ${CLASSPATH} FileSystemOperations mkdir ${hdfs_dir}/platform-data/operator
    kerberos_user=${KERBEROS_USER} kerberos_keytab=${kerberos_keytab} ${JAVA_HOME}/bin/java -cp ${CLASSPATH} FileSystemOperations mkdir ${hdfs_dir}/platform-data/linkoop

    if [ "${arr[1]}"x == "fix" ]; then
        if [ -d "${script_dir}/hadoop-client" ]; then
            rm -rfv "${script_dir}/hadoop_files/operators/yarn/Pico/hadoop-client/"
            mv "${script_dir}/hadoop-client" "${script_dir}/hadoop_files/operators/yarn/Pico/"
        fi
        # 是fusioninsight集群，PICO算子会使用到hadoop中的配置文件，需要将hadoop的配置文件覆盖到打包的ftp文件夹路径当中
        mkdir -p ${script_dir}/hadoop_files/operators/yarn/Pico/hadoop-client/etc/hadoop/
        tar xf ${script_dir}/config/prophet/hadoop/${arr[2]} -C ${script_dir}/hadoop_files/operators/yarn/Pico/hadoop-client/etc/hadoop/
    else
        # 不是fusioninsight集群，不需要上传额外的hadoop客户端，故将打包的hadoop-client目录清理掉
        if [ -d "${script_dir}/hadoop_files/operators/yarn/Pico/hadoop-client" ]; then
            rm -rfv "${script_dir}/hadoop-client"
            mv "${script_dir}/hadoop_files/operators/yarn/Pico/hadoop-client" "${script_dir}"
        fi
    fi
    hadoop_overwrite=${hadoop_overwrite} kerberos_user=${KERBEROS_USER} kerberos_keytab=${kerberos_keytab} ${JAVA_HOME}/bin/java -cp ${CLASSPATH} FileSystemOperations add hadoop_files ${hdfs_upload_files_dir_with_version}
    hadoop_overwrite=${hadoop_overwrite} kerberos_user=${KERBEROS_USER} kerberos_keytab=${kerberos_keytab} ${JAVA_HOME}/bin/java -cp ${CLASSPATH} FileSystemOperations check hadoop_files ${hdfs_upload_files_dir_with_version}
done

green_echo 'upload files to hadoop done'
