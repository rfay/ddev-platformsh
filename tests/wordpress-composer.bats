# Requires bats-assert and bats-support
# brew tap kaos/shell &&
# brew install bats-core bats-assert bats-support jq mkcert yq
setup() {
  load setup.sh
}

teardown() {
  load teardown.sh
}

@test "wordpress-composer" {
  load per_test.sh
  template="wordpress-composer"
  for source in $PROJECT_SOURCE platformsh/ddev-platformsh; do
    per_test_setup

    run ddev exec -s db 'echo ${DDEV_DATABASE}'
    assert_output "mariadb:10.4"
    run ddev exec 'echo $PLATFORM_RELATIONSHIPS | base64 -d | jq -r ".database[0].username"'
    assert_output "db"
    run ddev exec "php --version | awk 'NR==1 { sub(/\.[0-9]+$/, \"\", \$2); print \$2 }'"
    assert_output "8.1"
    run ddev exec ls wordpress/wp-config.php
    assert_output "wordpress/wp-config.php"
    ddev describe -j >describe.json
    run  jq -r .raw.docroot <describe.json
    assert_output "wordpress"
    per_test_teardown
  done
}
