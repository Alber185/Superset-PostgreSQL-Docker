import os

SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "cámbiame-por-favor")

PREVENT_UNSAFE_DB_CONNECTIONS = False

# ============================================================================
# IDIOMA
# ============================================================================
# Idioma por defecto
BABEL_DEFAULT_LOCALE = "es"

# Idiomas disponibles
LANGUAGES = {
    "es": {"flag": "es", "name": "Spanish"},
    "en": {"flag": "us", "name": "English"},
    # "fr": {"flag": "fr", "name": "French"},
    # "it": {"flag": "it", "name": "Italian"},
    # "zh": {"flag": "cn", "name": "Chinese"},
    # "ja": {"flag": "jp", "name": "Japanese"},
    # "de": {"flag": "de", "name": "German"},
    # "pt": {"flag": "pt", "name": "Portuguese"},
    # "pt_BR": {"flag": "br", "name": "Brazilian Portuguese"},
    # "ru": {"flag": "ru", "name": "Russian"},
    # "ko": {"flag": "kr", "name": "Korean"},
}

# ============================================================================
# CSRF
# ============================================================================
WTF_CSRF_ENABLED = False  # Desabilitado porque Superset 6 tiene problemas con exemptiones

# ============================================================================
# EMBEDDING
# ============================================================================

FEATURE_FLAGS = {
    "ALLOW_ADHOC_SUBQUERY": True, # Nuevo
    "EMBEDDED_SUPERSET": True,
    "DASHBOARD_NATIVE_FILTERS": True,
    "DASHBOARD_CROSS_FILTERS": True,
    "ENABLE_TEMPLATE_PROCESSING": True, #Jinja
    "ENABLE_ROW_LEVEL_SECURITY": False,
    
    "DASHBOARD_FILTERS_EXPERIMENTAL": True,
    "NATIVE_FILTERS": True,
    "ENABLE_FILTER_BOX_MIGRATION": True,
}

# Clave JWT para embedding
GUEST_ROLE_NAME = "Public"
GUEST_TOKEN_JWT_SECRET = os.environ.get("EMBED_SECRET", "super-secret-key")
GUEST_TOKEN_JWT_ALGO = "HS256"
GUEST_TOKEN_JWT_EXP_SECONDS = 300

# Asignar permisos de Gamma al rol Public para guest users
PUBLIC_ROLE_LIKE = "Gamma"

# ============================================================================
# CORS
# ============================================================================

ENABLE_CORS = True
CORS_OPTIONS = {
    "supports_credentials": True,
    "origins": [
        "https://localhost:44301",
        "http://localhost:8089",
    ],
}

# ============================================================================
# IFRAME / CSP
# ============================================================================

TALISMAN_ENABLED = True
TALISMAN_CONFIG = {
    "content_security_policy": {
        "frame-ancestors": ["'self'", "https://localhost:44301"],
    },
    "force_https": False,
}

HTTP_HEADERS = {
    "X-Frame-Options": "ALLOWALL"
}

##############################################################
# NUEVOS CAMBIOS PARA INFORMES ACEDHA
# Timeouts
SQLLAB_TIMEOUT = 900
SUPERSET_WEBSERVER_TIMEOUT = 900
WEB_SERVER_TIMEOUT = 900

# Configuraciones para resultados de consultas
ROW_LIMIT = 500000
SQL_MAX_ROW = 500000
ALLOW_FULL_CSV_DOWNLOAD = True

