# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

#  "git.mk" variables
GIT_MAKEFILE = git.mk
GIT_ACCOUNT = zahapat
GIT_EMAIL ?= zahalka.patrik@gmail.com
GIT_TEMPLATE ?= fpga-tools-qc
GIT_TEMPLATE_HTTPS ?= https://github.com/$(GIT_ACCOUNT)/$(GIT_TEMPLATE).git
GIT_PROJECT_HTTPS ?= https://github.com/$(GIT_ACCOUNT)/$(PROJ_NAME).git
GIT_BRANCH ?= main



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:

# [Project repo]
# Update local repo with changes made on GitHub online (own) repository
# WARNING: There must be NO MODIFIED files in the project directory
# What it does:
# 	A: If there are modified files (ON CURRENTLY CHECKED OUT BRANCH) 
# 			-> no update will performed. A Warning message will be displayed.
# 	B: If there are no modified files (ON CURRENTLY CHECKED OUT BRANCH)
#  			-> update will be performed.
gupdate_ownrepo:
	@echo "INFO: Actual checked out branch: $$(git rev-parse --abbrev-ref HEAD) ($$(git rev-parse --symbolic-full-name HEAD))"
	@current_checked_out_branch=$$(git rev-parse --abbrev-ref HEAD)
	@modified_files=$$(git diff --name-only $${current_checked_out_branch})
	@if [ -z "$${modified_files}" ]; then \
		echo "INFO: No local changes @$${current_checked_out_branch} branch have been detected. Hence, loading changes from own online repo can be performed safely."; \
		git pull origin $${current_checked_out_branch}; \
	fi
	@if [ ! -z "$${modified_files}" ]; then \
		echo "WARNING: Unable to load changes from own online repo @$${current_checked_out_branch} branch because files:"; \
		echo $${modified_files}; \
		echo "... were modified."; \
		echo "INFO: Make sure the repository is in a clean state without any modifications."; \
		echo "INFO: This will alow the HEAD pointer to be updated successfully."; \
		echo "INFO: make gacp MSG="..." before git pull."; \
	fi

# [Project repo]
# Push changes to Github.com
# To do only once: git push -u origin main (and then, use git push only without the further arguments)
gp:
	git switch $(GIT_BRANCH)
	git remote set-url origin $(GIT_PROJECT_HTTPS)
	git push origin $(GIT_BRANCH) -f

# [Project repo]
# Git Add all changes -> Commit all changes
# In Nano editor: Ctrl+X -> Y -> Enter
# In CLI: make gac MSG="fix: Enable commit msg from cli"
gac:
	git remote set-url origin $(GIT_PROJECT_HTTPS)
	git switch $(GIT_BRANCH)
	git add --all && git commit -m "$(MSG)"
	git log --name-status HEAD^..HEAD

# [Project repo]
# Git Add all changes -> Commit all changes -> Push
# In Nano editor: Ctrl+X -> Y -> Enter
# In CLI: make gacp MSG="feat: Enable commit msg from cli"
# gacp = Git Add Commit Push
# example: make gacp MSG="feat: Create new make command gacp"
gacp: 
	make git_new_remote_origin_https
	git remote set-url origin $(GIT_PROJECT_HTTPS)
	git switch $(GIT_BRANCH)
	git reset
	git add --all
	git commit -m "$(MSG)"
	make gp
	git log --name-status HEAD^..HEAD


# [Template repo]
# Git Add all changes in "generic" folders -> Commit all changes -> Push
# gacpt = Git Add Commit Push [Template repo]
# example: make gacpt MSG="feat: Create new make command gacpt"
gacpt:
	make git_new_remote_origin_template_https
	git remote set-url origin $(GIT_TEMPLATE_HTTPS)
	git switch main
	git reset
	git add -f \
		    './boards/*' './boards/*/*' './boards/*/*/*' ':!./boards/*/*/*/*' \
			./do/*
			./scripts/*
			./*/generic/\* \
			./Makefile \
			./*.mk\
		-except


	git commit -m "$(MSG)"
	git push https://github.com/$(GIT_ACCOUNT)/$(GIT_TEMPLATE) -f
	git log --name-status HEAD^..HEAD
	make git_new_remote_origin_https
	git remote set-url origin $(GIT_PROJECT_HTTPS)


# [All repos]
# Update all changes to Template repo first!
# At last, update Project repo
glive:
	make gacpt
	make gacp


# Log in to Git for this directory
git_login_thisdir:
	git config user.name "$(GIT_ACCOUNT)"
	git config user.email "$(GIT_EMAIL)"

# Log in to Git for all directories
git_login:
	git config user.name "$(GIT_ACCOUNT)"
	git config --global user.email "$(GIT_EMAIL)"

git_cli_auth:
	gh auth login

# Configure git using this target
git_config:
	git config core.editor "nano"

# Initialize the file tracking system for the local directory
git_init:
	rm -rf .directory_name
	git init -b $(GIT_BRANCH)

# Set active branch
git_branch:
	git branch -m $(GIT_BRANCH)

# Add changes in all files to Git
git_add_all:
	git add --all

# Save all the added/staged changes, with a description (-a)
git_commit_all:
	git commit -a

# Save 1 added change, with a description
git_commit:
	git commit

# Rename any commit
# 1) replace pick -> r/reword where you want to make changes
# 2) save and then prompts will ask you to make the respective changes
# ... Use squash for merging commits
# --- Commands ---
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but [meld into previous commit]
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge commit was
# .       specified). Use -c <commit> to reword the commit message.
git_change_commit_after_push:
	rm -fr .git/REBASE_HEAD
	git switch $(GIT_BRANCH)
	GIT_EDITOR=nano git rebase -i --root
	git rebase --continue
	git switch $(GIT_BRANCH)
	make gp

git_change_last_commit_before_push:
	git switch $(GIT_BRANCH)
	git commit --amend
	git rebase --continue
	git switch $(GIT_BRANCH)

git_undo_last_commit_before_push:
	git reset HEAD~1

git_undo_last_commit_after_push:
	git reset HEAD~1
	make gp

# Add and verify new origin on Github
git_new_remote_origin_https:
	git remote add origin $(GIT_PROJECT_HTTPS)
	git remote -v


# Add and verify new origin on Github
git_new_remote_origin_template_https:
	git remote add origin $(GIT_TEMPLATE_HTTPS)
	git remote -v


# Show history of commits
# Press 'q' to leave the env
# --pretty=oneline
git_history:
	git log --pretty=oneline --max-count=10

git_goto_commit:
	git checkout $(COMMIT_HASH)


# Create new repo, name = this_folder
git_new_private_repo:
	make git_init
	make git_config
	make git_cli_auth
	make git_login
	gh repo create $(PROJ_NAME) --private --source=. --remote=upstream
	make git_new_remote_origin_https
	make git_new_remote_origin_template_https
	make gacp MSG="Initial commit"

git_new_public_repo:
	make git_init
	make git_config
	make git_cli_auth
	make git_login
	gh repo create $(PROJ_NAME) --public --source=. --remote=upstream
	make git_new_remote_origin_https
	make git_new_remote_origin_template_https
	make gacp MSG="Initial commit"


git_new_private_repo_from_template:
	make git_init
	make git_config
	make git_cli_auth
	make git_login
	gh repo create $(PROJ_NAME) --private --template $(GIT_ACCOUNT)/$(GIT_TEMPLATE)
	make git_new_remote_origin_https
	make git_new_remote_origin_template_https
	git clean -d -f .
	make git_update_changes_mainbranch_templrepo
	git checkout main
	make gacp MSG="build: Get history from template repository $(GIT_TEMPLATE)"
	
	
	
git_new_public_repo_from_template:
	make git_init
	make git_config
	make git_cli_auth
	make git_login
	gh repo create $(PROJ_NAME) --public --template $(GIT_ACCOUNT)/$(GIT_TEMPLATE)
	make git_new_remote_origin_https
	make git_new_remote_origin_template_https
	git clean -d -f .
	make git_update_changes_mainbranch_templrepo
	git checkout main
	make gacp MSG="build: Get history from template repository $(GIT_TEMPLATE)"


# Make this repository available as a template repository
git_make_this_repo_template:
	gh repo edit --template


# Works for https
git_clone_repo_https:
	git remote set-url origin $(GIT_PROJECT_HTTPS)
	git clone $(GIT_PROJECT_HTTPS)


# Check the status of repos you are connected to
git_connected_repos:
	git remote -v


# List git branches
git_list_branches:
	git branch


# Create a new git branch
# Use name convention for naming the new branch
# Example: feature-1-something
git_new_branch:
	git checkout -b $(GIT_BRANCH)


# Switch to another branch
git_switch_branch:
	git checkout $(GIT_BRANCH)


# Compare changes of <this> branch with the <main> branch
# Hit "Q" to leave the screen
git_compare_with_main_branch:
	git diff main


# Merge <this> branch to the <main> branch
git_merge_to_main_branch:
	git checkout main
	git merge $(GIT_BRANCH)


# Update your code with new changes form the specific remote repo's branch
git_update_changes_thisbranch_projrepo:
	git remote set-url origin $(GIT_PROJECT_HTTPS)
	git switch $(GIT_BRANCH)
	git status
	git fetch origin $(GIT_BRANCH)
	git merge origin/$(GIT_BRANCH)

git_update_changes_mainbranch_templrepo:
	git remote set-url origin $(GIT_TEMPLATE_HTTPS)
	git switch main
	git status
	git pull origin main --allow-unrelated-histories
	git merge origin/main
	git remote set-url origin $(GIT_PROJECT_HTTPS)
	git switch $(GIT_BRANCH)