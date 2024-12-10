# 使用官方的 Nginx 基礎映像
FROM nginx:latest

# 安裝所需依賴
RUN apt-get update && apt-get install -y \
    libmodsecurity3 libmodsecurity-dev git build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev curl unzip

# 安裝 ModSecurity
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity /opt/ModSecurity \
    && cd /opt/ModSecurity \
    && ./build.sh \
    && ./configure \
    && make \
    && make install

# 安裝 ModSecurity-nginx 模塊
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /opt/ModSecurity-nginx

# 編譯 Nginx 並集成 ModSecurity 模塊
RUN cd /usr/src/nginx \
    && ./configure --add-dynamic-module=/opt/ModSecurity-nginx \
    && make modules \
    && cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules/

# 配置 ModSecurity
COPY modsecurity.conf /etc/modsecurity/
COPY crs-setup.conf /etc/modsecurity/
COPY nginx.conf /etc/nginx/

# 安裝 OWASP CRS
RUN git clone --depth 1 https://github.com/coreruleset/coreruleset /etc/modsecurity-crs \
    && cp /etc/modsecurity-crs/crs-setup.conf.example /etc/modsecurity-crs/crs-setup.conf \
    && ln -s /etc/modsecurity-crs/rules /etc/modsecurity/rules
