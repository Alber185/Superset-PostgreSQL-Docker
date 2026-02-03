FROM apache/superset:5.0.0

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema para construir pymssql y mysqlclient
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential gcc g++ default-libmysqlclient-dev pkg-config \
      freetds-dev freetds-bin unixodbc-dev ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar FreeTDS para MSSQL (ajusta tds version si hace falta)
RUN printf "[global]\n\tds version = 7.4\n\tclient charset = UTF-8\n\ttext size = 4294967295\n" > /etc/freetds/freetds.conf

# Instalar pip (¡¡EN EL ENTORNO VIRTUAL!!) y luego los drivers de base de datos
RUN /app/.venv/bin/python -m ensurepip --upgrade && \
    /app/.venv/bin/python -m pip install --upgrade pip && \
    /app/.venv/bin/python -m pip install --no-cache-dir pymssql mysqlclient flask-cors

# Volver al usuario de la imagen base
USER superset


# Si en lugar de pymssql prefieres pyodbc + msodbcsql, descomenta y adapta:
# RUN apt-get update && apt-get install -y curl gnupg apt-transport-https && \
#     curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
#     curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
#     apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev && \
#     /bin/bash -lc "/app/.venv/bin/pip install --no-cache-dir pyodbc" && \
#     apt-get remove -y --purge curl gnupg apt-transport-https && apt-get autoremove -y