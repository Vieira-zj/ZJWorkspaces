#!/bin/bash
set -u

# Desc:
# 1. get go src files for diff commits;
# 2. diff these go src files by func;

project_root="${HOME}/Workspaces/shopee_repos/airpay_push_server"
branch="master"
tmp_old_dir="/tmp/test/old"
tmp_new_dir="/tmp/test/new"
is_copy="1"
diff_bin="/tmp/test/funcdiff"

function before {
    set +e
    rm -rf ${tmp_old_dir}
    mkdir -p ${tmp_old_dir}
    rm -rf ${tmp_new_dir}
    mkdir -p ${tmp_new_dir}
    set -e
}

function code_init {
    git checkout ${branch}
    git pull origin ${branch}
}

function get_go_files_between_commits {
    local hash1=$1
    local hash2=$2

    cd ${project_root}
    code_init
    local files=$(git diff ${hash1} ${hash2} --stat | grep go | awk -F '|' '{print $1}' | awk -F '/' '{print $NF}')
    echo "[${hash1}]-[${hash2}] commit files:"
    echo "${files}"

    set -x
    if [[ ${is_copy} == "1" ]]; then
        git reset ${hash1} --hard
        for file in ${files}; do
            f_path=$(find . -name ${file} -type f)
            cp ${f_path} ${tmp_old_dir}
        done

        code_init
        git reset ${hash2} --hard
        for file in ${files}; do
            f_path=$(find . -name ${file} -type f)
            if [[ -f ${f_path} ]]; then
                cp ${f_path} ${tmp_new_dir}
            fi
        done
    fi
    code_init
}

function diff_go_file_by_func {
    local files=$(ls ${tmp_old_dir} ${tmp_new_dir} | grep go | uniq)
    for file in ${files}; do
        old_file="${tmp_old_dir}/${file}"
        if [[ ! -f ${old_file} ]]; then
            old_file="null"
        fi
        new_file="${tmp_new_dir}/${file}"
        if [[ ! -f ${new_file} ]]; then
            new_file="null"
        fi
        echo ""
        echo "old:${old_file}, new:${new_file}"

        if [[ ${old_file} != "null" && ${new_file} != "null" ]]; then
            cmd="${diff_bin} -s ${old_file} -t ${new_file}"
            ${cmd}
        fi
    done
}

function update_git_configs_in_batch {
    local email_addr='jin.zheng@xxxxx.com'
    local repo_root_dir=${HOME}/Workspaces/shopee_repos
    local repos=$(ls ${repo_root_dir})
    for repo in ${repos}; do
        repo_path=${repo_root_dir}/${repo}
        echo "Update user name and email info for repo ${repo_path}"
        cd ${repo_path}
        git config user.name 'jin.zheng'
        git config user.email ${email_addr}
        # show configs
        # git config --list
    done
}

update_git_config_in_batch

# before
# get_go_files_between_commits 25c381 f0c4e1a
# diff_go_file_by_func

echo "Diff Done"