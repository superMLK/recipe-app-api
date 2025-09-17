# 使用python3.9的alpine版本作為基底映像檔
FROM python:3.9-alpine3.13

# 維護者資訊
LABEL maintainer="WEI-SHENG-LI"

# 設定環境變數，確保Python輸出不會被緩衝
ENV PYTHONUNBUFFERED 1

# 將本地的requirements.txt複製到映像檔的/tmp目錄下，方便後續安裝依賴
COPY ./requirements.txt /tmp/requirements.txt
# 也複製開發環境的依賴檔案
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# 將本地的app資料夾複製到映像檔的/app目錄，這是應用程式的主程式碼
COPY ./app /app
# 設定工作目錄為/app，之後的指令都會在這個目錄下執行
WORKDIR /app
# 宣告容器會使用8000埠，通常用於Web應用程式
EXPOSE 8000

# 建立一個建置參數，預設值為false，用來區分是否為開發環境
ARG DEV=false

# 安裝系統依賴，建立Python虛擬環境，安裝Python套件，並建立一個非root使用者來執行應用程式
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# 將虛擬環境的bin目錄加入PATH環境變數，確保使用虛擬環境中的Python和pip
ENV PATH="/py/bin:$PATH"

# 切換到非root使用者，提升安全性
USER django-user