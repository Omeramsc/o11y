PINT_VERSION = 0.42.2
PROMTOOL_VERSION = 2.42.0
YQ_VERSION = 4.31.2
EXTRACTED_RULE_FILE = test/promql/extracted-rules.yaml
RULE_FILE = prometheus/base/prometheus.rules.yaml

.PHONY: all
all: prepare lint test_rules pint_lint

.PHONY: prepare
prepare: pint promtool yq
	echo "Extract Prometheus rules"
	./yq ".spec" ${RULE_FILE} > ${EXTRACTED_RULE_FILE}

.PHONY: lint
lint:
	echo "Running Prometheus rules linter tests"
	./promtool check rules ${EXTRACTED_RULE_FILE}

.PHONY: test_rules
test_rules:
	echo "Running Prometheus rules unit tests"
	./promtool test rules test/promql/tests/*

pint:
	echo 'Installing pint...'
	curl -OJL 'https://github.com/cloudflare/pint/releases/download/v${PINT_VERSION}/pint-${PINT_VERSION}-linux-amd64.tar.gz'
	tar xvzf 'pint-${PINT_VERSION}-linux-amd64.tar.gz' pint-linux-amd64
	mv pint-linux-amd64 pint
	rm 'pint-${PINT_VERSION}-linux-amd64.tar.gz'	

promtool:
	echo "Installing promtool..."
	curl -OJL "https://github.com/prometheus/prometheus/releases/download/v${PROMTOOL_VERSION}/prometheus-${PROMTOOL_VERSION}.linux-amd64.tar.gz"
	tar xvzf "prometheus-${PROMTOOL_VERSION}.linux-amd64.tar.gz" "prometheus-${PROMTOOL_VERSION}.linux-amd64"/promtool --strip-components=1
	rm -f prometheus-${PROMTOOL_VERSION}.linux-amd64.tar.gz

yq:
	echo "Installing yq..."
	curl -OJL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64.tar.gz"
	tar xvzf yq_linux_amd64.tar.gz ./yq_linux_amd64
	rm -f yq_linux_amd64.tar.gz
	mv yq_linux_amd64 yq

.PHONY: pint_lint
pint_lint:
	echo "Linting Prometheus rules..."
	./pint --no-color lint ${EXTRACTED_RULE_FILE}
