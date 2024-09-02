.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Welcome to Skeleton example. Please use \`make <target>\` where <target> is one of"
	@echo " "
	@echo "  Next commands are only for dev environment with nextcloud-docker-dev!"
	@echo "  They should run from the host you are developing on(with activated venv) and not in the container with Nextcloud!"
	@echo "  "
	@echo "  build-push        build image and upload to ghcr.io"
	@echo "  "
	@echo "  run28             install Skeleton for Nextcloud 28"
	@echo "  run29             install Skeleton for Nextcloud 29"
	@echo "  run30             install Skeleton for Nextcloud 30"
	@echo "  run               install Skeleton for Nextcloud Last"
	@echo "  "
	@echo "  For development of this example use PyCharm run configurations. Development is always set for last Nextcloud."
	@echo "  First run 'Skeleton' and then 'make registerXX', after that you can use/debug/develop it and easy test."
	@echo "  "
	@echo "  register28        perform registration of running Skeleton into the 'manual_install' deploy daemon."
	@echo "  register29        perform registration of running Skeleton into the 'manual_install' deploy daemon."
	@echo "  register30        perform registration of running Skeleton into the 'manual_install' deploy daemon."
	@echo "  register          perform registration of running Skeleton into the 'manual_install' deploy daemon."

.PHONY: build-push
build-push:
	docker login ghcr.io
	docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag ghcr.io/cloud-py-api/skeleton:latest .

.PHONY: run28
run28:
	docker exec master-stable28-1 sudo -u www-data php occ app_api:app:unregister skeleton --silent --force || true
	docker exec master-stable28-1 sudo -u www-data php occ app_api:app:register skeleton --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/app-skeleton-python/main/appinfo/info.xml

.PHONY: run29
run29:
	docker exec master-stable29-1 sudo -u www-data php occ app_api:app:unregister skeleton --silent --force || true
	docker exec master-stable29-1 sudo -u www-data php occ app_api:app:register skeleton --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/app-skeleton-python/main/appinfo/info.xml

.PHONY: run30
run30:
	docker exec master-stable30-1 sudo -u www-data php occ app_api:app:unregister skeleton --silent --force || true
	docker exec master-stable30-1 sudo -u www-data php occ app_api:app:register skeleton --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/app-skeleton-python/main/appinfo/info.xml

.PHONY: run
run:
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:unregister skeleton --silent --force || true
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:register skeleton --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/app-skeleton-python/main/appinfo/info.xml

.PHONY: register28
register28:
	docker exec master-stable28-1 sudo -u www-data php occ app_api:app:unregister skeleton --silent --force || true
	docker exec master-stable28-1 sudo -u www-data php occ app_api:app:register skeleton manual_install --json-info \
  "{\"id\":\"skeleton\",\"name\":\"App Skeleton\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9030,\"scopes\":[]}" \
  --force-scopes --wait-finish

.PHONY: register29
register29:
	docker exec master-stable29-1 sudo -u www-data php occ app_api:app:unregister skeleton --silent --force || true
	docker exec master-stable29-1 sudo -u www-data php occ app_api:app:register skeleton manual_install --json-info \
  "{\"id\":\"skeleton\",\"name\":\"App Skeleton\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9030,\"scopes\":[]}" \
  --force-scopes --wait-finish

.PHONY: register30
register30:
	docker exec master-stable30-1 sudo -u www-data php occ app_api:app:unregister skeleton --silent --force || true
	docker exec master-stable30-1 sudo -u www-data php occ app_api:app:register skeleton manual_install --json-info \
  "{\"id\":\"skeleton\",\"name\":\"App Skeleton\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9030,\"scopes\":[]}" \
  --force-scopes --wait-finish

.PHONY: register
register:
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:unregister skeleton --silent --force || true
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:register skeleton manual_install --json-info \
  "{\"id\":\"skeleton\",\"name\":\"App Skeleton\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9030,\"scopes\":[]}" \
  --force-scopes --wait-finish
