docker run -d -p 4000:3000 grafana/grafana


docker run -d -p 4000:3000 --name grafana -e "GF_DEFAULT_INSTANCE_NAME=jingwu" -e "GF_SECURITY_ADMIN_USER=jingwu" -e "GF_AUTH_GOOGLE_CLIENT_SECRET=jingwu" -e "GF_PLUGIN_GRAFANA_IMAGE_RENDERER_RENDERING_IGNORE_HTTPS_ERRORS=true" grafana/grafana

docker run -d -p 3000:3000 --name grafana grafana/grafana:<version number>

插件
docker run -d -p 3000:3000 --name=grafana -e "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource" grafana/grafana

源码安装插件
docker run -d -p 3000:3000 --name=grafana -e "GF_INSTALL_PLUGINS=http://plugin-domain.com/my-custom-plugin.zip;custom-plugin,grafana-clock-panel" grafana/grafana