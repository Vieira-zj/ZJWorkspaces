#!/bin/bash
set -eu

git_repos=(
	"gitlab@git.xxxxx.com:jin.zheng/zhengjin_worksapce.git"
	"gitlab@git.xxxxx.com:jin.zheng/test-deploy.git"
)

root_dir="/tmp/test/repos"
tag_name="v1.0.1-test"


function delete_root_dir() {
	if [[ -d $root_dir ]]; then
		rm -rf $root_dir
		mkdir $root_dir
	fi
}

function clone_repo() {
	local repo_url=$1
	echo "clone repo ${repo_url}"
	git clone ${repo}
}

function get_repo_dir_from_url() {
	local repo_url=$1
	echo $repo_url | awk -F '/' '{print $2}' | sed 's/.git//'
}

function create_release_tag() {
	local repo_url=$1
	local repo_dir=$(get_repo_dir_from_url ${repo_url})
	if [[ ! -d $root_dir/$repo_dir ]]; then
		echo "repo dir [${repo_dir}] is not found"
	else
		echo "create release tag for repo: $repo_url"
		cd $root_dir/$repo_dir
		git checkout release
		# git pull origin release
		git tag $tag_name
		# git push origin $tag_name
	fi
}

function create_release_branches() {
	local repo_url=$1
	local repo_dir=$(get_repo_dir_from_url ${repo_url})
	if [[ ! -d $root_dir/$repo_dir ]]; then
		echo "repo dir [${repo_dir}] is not found"
	else
		cd $root_dir/$repo_dir
		local branches=("master-backup" "staging" "release")
		for br in ${branches[*]}; do
			echo "create [${br}] branch"
			git checkout master && git pull origin master && git checkout -b $br
			# git push origin $br
		done
	fi
}

# handle for new git repo: 1) delete root dir; 2) clone git repo
function batch_job_for_new() {
	delete_root_dir
	for repo in ${git_repos[*]}; do
		cd $root_dir
		clone_repo $repo
		create_release_branches $repo
		create_release_tag $repo
	done
}

# handle for existing git repo
function batch_job_for_exist() {
	for repo in ${git_repos[*]}; do
		cd $root_dir
		create_release_branches $repo
		create_release_tag $repo
	done
}

# batch_job_for_new
batch_job_for_exist
echo "batch git job done."
