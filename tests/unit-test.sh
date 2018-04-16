#!/bin/bash
set -x

image_name=${1:? $(basename $0) IMAGE_NAME VERSION needed}
VERSION=${2:-latest}
namespace=fluentd
fluentd=fluentd
export VERSION

ret=0
echo "Check tests/docker-compose.yml config"
docker-compose -p ${namespace} config
test_result=$?
if [ "$test_result" -eq 0 ] ; then
  echo "[PASSED] docker-compose -p ${namespace} config"
else
  echo "[FAILED] docker-compose -p ${namespace} config"
  ret=1
fi
echo "Check fluentd installed"
docker-compose -p ${namespace} run --name "test-fluentd" --rm $fluentd find /fluentd/
test_result=$?
if [ "$test_result" -eq 0 ] ; then
  echo "[PASSED] fluentd installed"
else
  echo "[FAILED] fluentd installed"
  ret=1
fi

exit $ret
# test a small nginx config
echo "Check fluentd running"

# setup test
echo "# setup env test:"
test_compose=docker-compose.yml
fluentd=fluentd
test_config=fluentd-test.sh
docker-compose -p ${namespace} -f $test_compose up -d --no-build $fluentd
docker-compose -p ${namespace} -f $test_compose ps $fluentd
container=$(docker-compose -p ${namespace}  -f $test_compose ps -q $fluentd)
echo docker cp $test_config ${container}:/opt/
docker cp $test_config ${container}:/opt/

# run test
echo "# run test:"
docker-compose -p ${namespace}  -f $test_compose exec -T $fluentd /bin/bash -c "/opt/$test_config"
test_result=$?

# teardown
echo "# teardown:"
docker-compose -p ${namespace}  -f $test_compose stop
docker-compose -p ${namespace}  -f $test_compose rm -fv

if [ "$test_result" -eq 0 ] ; then
  echo "[PASSED] fluentd url check [$test_config]"
else
  echo "[FAILED] fluentd url check [$test_config]"
  ret=1
fi

exit $ret
