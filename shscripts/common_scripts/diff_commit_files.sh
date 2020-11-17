#!/bin/bash
set -u

# Desc:
# 1. get go src files for diff commits;
# 2. diff these go src files by func;

project_root="${HOME}/Workspaces/shopee_repos/airpay_push_server"
branch='master'
hash_new='28a644' #'0e0b2c'
hash_old='c87001' #'5169a8'
tmp_new_dir='/tmp/test/new'
tmp_old_dir='/tmp/test/old'
out_diff_dir='/tmp/test/diff'
diff_bin='/tmp/test/funcdiff'

function before_diff {
    set +e
    for dir in ${tmp_old_dir} ${tmp_new_dir} ${out_diff_dir}; do
        rm -rf ${dir}
        mkdir -p ${dir}
    done
    set -e
}

function code_init {
    git checkout ${branch} > /dev/null
    git pull origin ${branch} > /dev/null
}

function get_go_files_between_commits {
    cd ${project_root}
    # git clone

    code_init
    # 排除文件 pb.go _test.go vendor
    # 文件重命名修改不算在内
    local go_files=$(git diff ${hash_new} ${hash_old} --stat \
      | grep -v -E "\.pb\.go|vendor" | grep '\.go' | grep -E "\+|-" \
      | awk -F '|' '{print $1}' | awk -F '/' '{print $NF}')

    git reset ${hash_new} --hard > /dev/null
    for file in ${go_files}; do
        f_path=$(find . -name ${file} -type f)
        cp ${f_path} ${tmp_new_dir}
    done

    code_init
    git reset ${hash_old} --hard > /dev/null
    for file in ${go_files}; do
        f_path=$(find . -name ${file} -type f)
        if [[ -f ${f_path} ]]; then
            cp ${f_path} ${tmp_old_dir}
        fi
    done
    code_init
    echo -e "\nDiff go files for OldCommit:[${hash_old}] - NewCommit:[${hash_new}]:\n${go_files}"
}

function diff_go_file_by_func {
    local files=$(ls ${tmp_old_dir} ${tmp_new_dir} | grep "\.go" | sort | uniq)
    echo -e "\nOldCommit:[${hash_old}] NewCommit:[${hash_new}] Diff" | awk '{printf "%-60s%-60s%-60s\n", $1, $2, $3}'

    for file in ${files}; do
        old_file="${tmp_old_dir}/${file}"
        if [[ ! -f ${old_file} ]]; then
            old_file="null"
        fi
        new_file="${tmp_new_dir}/${file}"
        if [[ ! -f ${new_file} ]]; then
            new_file="null"
        fi

        if [[ ${old_file} != "null" && ${new_file} != "null" ]]; then
            cmd="${diff_bin} -s ${new_file} -t ${old_file}"
            diff_file=${out_diff_dir}/${file}.diff
            # wc 返回结果要去掉空格
            diff_count=$(${cmd} | tee ${diff_file} | awk -F ':' '{print $2}' | grep diff | wc -l | sed 's/ //g')
            if [[ ${diff_count} -gt 0 ]]; then
                echo "${old_file} ${new_file} DiffFuncCount:${diff_count}" | awk '{printf "%-60s%-60s%-60s\n", $1, $2, $3}'
            fi
        else
            echo "${old_file} ${new_file}" | awk '{printf "%-60s%-60s\n", $1, $2}'
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

before_diff
get_go_files_between_commits
diff_go_file_by_func

# update_git_config_in_batch

echo "Diff Done"