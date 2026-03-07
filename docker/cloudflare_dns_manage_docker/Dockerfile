FROM python:3.10-slim
WORKDIR /app

RUN pip install --no-cache-dir \
    fastapi \
    uvicorn \
    requests \
    jinja2 \
    passlib \
    bcrypt==3.2.0 \
    python-multipart \
    itsdangerous

COPY . .
RUN mkdir -p /app/data
EXPOSE 8000

# 关键修改：直接在容器启动层级屏蔽 info 和访问日志
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--log-level", "error", "--no-access-log"]