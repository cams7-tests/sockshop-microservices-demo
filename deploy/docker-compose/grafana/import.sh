#!/usr/bin/env sh

sleep 3
# Import dashboards
for DASHBOARD in sock-shop-performance-dashboard; do
  echo "importing $DASHBOARD" &&
  curl --request POST http://admin:foobar@grafana:3000/api/dashboards/import \
    --header "Content-Type: application/json" \
    --header "Accept: application/json" \
    --data-binary "@${DASHBOARD}.json";
done;

for DASHBOARD in prometheus-dashboard; do
echo "Importing ${DASHBOARD}.json..." &&
curl -s -k -u "admin:foobar" -XPOST -H "Accept: application/json" -H "Content-Type: application/json" \
-d @- "http://grafana:3000/api/dashboards/import" <<CURL_DATA
{"dashboard":$(cat /opt/grafana-import-dashboards/${DASHBOARD}.json),"overwrite":false, "inputs":[{"name":"DS_PROMETHEUS","type":"datasource","pluginId":"prometheus","value":"prometheus"}]}
CURL_DATA
done

for DASHBOARD in 1860; do
REVISION="$(curl -s https://grafana.com/api/dashboards/${DASHBOARD}/revisions -s | jq ".items[-1].revision")"
curl -s https://grafana.com/api/dashboards/${DASHBOARD}/revisions/${REVISION}/download > /tmp/dashboard.json
echo "Importing $(cat /tmp/dashboard.json | jq -r '.title') (revision ${REVISION}, id ${DASHBOARD})..." &&
curl -s -k -o /dev/null -u "admin:foobar" -XPOST \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-d @- "http://grafana:3000/api/dashboards/import" <<CURL_DATA
{"dashboard":$(cat /tmp/dashboard.json),"overwrite":false, "inputs":[{"name":"DS_PROMETHEUS","type":"datasource","pluginId":"prometheus","value":"prometheus"}]}
CURL_DATA
done
