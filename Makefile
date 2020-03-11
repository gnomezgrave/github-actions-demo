BASE_STACK_NAME=ppeiris
BUCKET ?=ppeiris-test
STACK_NAME_SUFFIX ?= $(USER)

REGION=eu-west-2


ifdef ENV
	OWNER=$(TEAM)
	STACK_NAME_SUFFIX=$(ENV)
else
	ENV=development
	OWNER=$(USER)
endif

ifdef TARGET
	TPL=cloudformation/$(TARGET).yaml
endif


# CloudFormation stacks do not allow underscores but support dashes. Python package names support underscores
# but not dashes. The Stackname contains the component name (or TARGET) which is often the same as the package name.
# To prevent clashes we replace underscores with dashes.
TARGET_TPL=$(subst _,-,$(TARGET))
PACKAGED_TPL=$(TARGET_TPL)-packaged-cloudformation-template.yaml

sync:
	mkdir -p _build/
	cp -R src/* _build/

build:
	rm -rf _build && mkdir -p _build
	pip install --upgrade pip
	$(MAKE) sync

package:
	@mkdir -p _build
	@echo "Preparing and uploading AWS package for $(TPL) for $(TARGET_TPL)."
	aws cloudformation package \
		--template-file $(TPL) \
		--s3-bucket $(BUCKET) \
		--s3-prefix packages \
		--output-template-file _build/$(PACKAGED_TPL)


deploy:
	@echo "Deploying template for $(TPL) for $(TARGET_TPL)."
	aws cloudformation deploy \
		--template-file _build/$(PACKAGED_TPL) \
		--stack-name $(BASE_STACK_NAME)--$(TARGET_TPL)--$(STACK_NAME_SUFFIX) \
		--capabilities CAPABILITY_IAM

release:
	@$(MAKE) build && $(MAKE) package && $(MAKE) deploy || echo "No changes to be deployed."

clean:
	find . -name "*.pyc" -exec rm -f {} \;
	rm -rf _build

test-coverage:
	PYTHONPATH=./src pytest tests/ --cov=src --full-trace

test:
	PYTHONPATH=./src pytest tests/

notify-failure:
	@echo $(NOTIFICATION_SUBJECT)
	@echo $(NOTIFICATION_MESSAGE)