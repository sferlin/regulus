#
# vi should "set expandtab&". Makefile cmds require tab
# Valid job targets are:
# 	init-jobs:	init the jobs in the $JOBS var found in  jobs.config
# 	run-jobs:   run the jobs list 
# 	clean-jobs: clean all artifacts generated by init-jobs and run-jobs, but not run dirs
# 	init-all:   init ALL dirs under REGULUS
# 	run-all:    run all dirs 
# 	clean-all:  clean all artifacts generated by init-all and run-all, but not run dirs
#
# Valid lab targets are: (Job targets make "init-lab" as necessary. No need to make it explicitly)
#	init-lab:	discover and verify the cluster specified in lab.config. Save results in ./.LAB
#	clean-lab	remove all state knowledge about this cluster.
#
include ./jobs.config
SHELL := /bin/bash
.PHONY: confirm_execute

init-jobs: init-lab
	echo JOBS=$JOBS
	@for dir in $(JOBS); do \
		echo "Executing script in $$dir"; \
		$(MAKE) -C $$dir init; \
	done

clean-jobs: 
	echo JOBS=$JOBS
	@for dir in $(JOBS); do \
		echo "Executing script in $$dir"; \
		$(MAKE) -C $$dir clean; \
	done

run-jobs: init-lab
	echo JOBS=$JOBS
	@for dir in $(JOBS); do \
		echo "Executing script in $$dir"; \
		$(MAKE) -C $$dir run; \
	done

# Also can be done with setting jobs.config.DRY_RUN=1; make run-jobs
dry-run-jobs: init-lab
	echo JOBS=$JOBS
	@for dir in $(JOBS); do \
		echo "Executing script in $$dir"; \
		$(MAKE) -C $$dir dry-run; \
	done

confirm_execute:
	@echo "Are you sure you want to execute the target? [y/N] " && read ans && [ $${ans:-N} = y ]

init-all: confirm_execute $(LAB_TARGET)
	@dirs=$$(find . -type f -name reg_expand.sh -exec dirname {} \;); \
	for dir in $$dirs; do \
		echo "Entering directory $$dir"; \
		$(MAKE) -C $$dir init; \
	done

run-all: confirm_execute init-lab
	@dirs=$$(find . -type f -name reg_expand.sh -exec dirname {} \;); \
	for dir in $$dirs; do \
		echo "Entering directory $$dir"; \
		$(MAKE) -C $$dir run; \
	done

# Also can be done with setting jobs.config.DRY_RUN=1; make run-all
dry-run-all: confirm_execute $(LAB_TARGET)
	@dirs=$$(find . -type f -name reg_expand.sh -exec dirname {} \;); \
	for dir in $$dirs; do \
		echo "Entering directory $$dir"; \
		$(MAKE) -C $$dir dry-run; \
	done

clean-all: confirm_execute
	@dirs=$$(find . -type f -name reg_expand.sh -exec dirname {} \;); \
	for dir in $$dirs; do \
		echo "Entering directory $$dir"; \
		$(MAKE) -C $$dir clean; \
	done

# Lab targets
.PHONY: clean-lab


LAB_TARGET := ${GEN_LAB_JSON}
LAB_TARGET_ENV := ${GEN_LAB_ENV}

LAB_SOURCE := ${REG_ROOT}/lab.config

$(LAB_TARGET): $(LAB_SOURCE) ./bin/lab-analyzer
	@output=$$(./bin/lab-analyzer); \
	if [ $$? -ne 0 ]; then \
		echo "Error: lab-analyzer failed"; \
		exit 1; \
	fi; \
	echo "$$output" > $@; \
	jq -r 'to_entries | .[] | "\(.key)=\(.value)"' $@ > ${LAB_TARGET_ENV};


# Init LAB info if lab.config changes
init-lab: $(LAB_TARGET) 
	@echo Analyze testbed

.SECONDARY: $(LAB_SOURCE)

clean-lab:
	@ rm -f $(LAB_TARGET) $(LAB_TARGET_ENV)

