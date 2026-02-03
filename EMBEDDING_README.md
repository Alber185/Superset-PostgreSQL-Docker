# Guía de Embedding de Superset con Detección de Descargas

## 📋 Resumen

Esta configuración te permite:
1. ✅ Embeber dashboards de Superset en tu aplicación
2. ✅ Detectar cuando un usuario descarga Excel/CSV
3. ✅ Interceptar y manipular las descargas desde JavaScript
4. ✅ Registrar eventos de descarga en tu backend

## 🚀 Pasos de Configuración

### 1. Reiniciar Superset con nueva configuración

```powershell
# Detener contenedores
docker-compose down

# Levantar con nueva configuración
docker-compose up -d

# Esperar 30 segundos
Start-Sleep -Seconds 30

# Crear admin (si es primera vez)
docker-compose exec -T superset superset fab create-admin --username admin --firstname Admin --lastname User --email admin@superset.com --password admin

# Inicializar
docker-compose exec -T superset superset db upgrade
docker-compose exec -T superset superset init
```

### 2. Configurar un Dashboard para Embedding

1. Accede a Superset: http://localhost:8088
2. Login: `admin` / `admin`
3. Crea o selecciona un dashboard
4. Ve a Settings → Dashboards
5. Edita el dashboard y anota su ID (está en la URL: `/superset/dashboard/{ID}/`)

### 3. Opción A: Usar ejemplo HTML simple

```powershell
# Abrir el archivo HTML en tu navegador
start embedded-dashboard-example.html
```

**Configuración:**
- Edita `embedded-dashboard-example.html`
- Cambia la línea del iframe `src` con el ID de tu dashboard:
  ```javascript
  src="http://localhost:8088/superset/dashboard/TU_DASHBOARD_ID/?standalone=true"
  ```

### 4. Opción B: Usar servidor Python con SDK (Recomendado)

```powershell
# Instalar dependencias
pip install flask pyjwt requests

# Editar guest_token_server.py y configurar:
# - SUPERSET_URL
# - SUPERSET_USERNAME
# - SUPERSET_PASSWORD
# - GUEST_TOKEN_SECRET (debe coincidir con superset_config.py)

# Ejecutar servidor
python guest_token_server.py

# Acceder a:
# http://localhost:5000/dashboard/1  (cambia 1 por tu dashboard ID)
```

## 🎯 Métodos de Detección de Descargas

### Método 1: PostMessage API
```javascript
window.addEventListener('message', function(event) {
    if (event.data.type === 'DOWNLOAD') {
        console.log('Descarga detectada:', event.data);
        // Tu lógica aquí
    }
});
```

### Método 2: Superset Embedded SDK (Recomendado)
```javascript
supersetEmbeddedSdk.embedDashboard({
    // ...configuración...
    eventHandlers: {
        DOWNLOAD_STARTED: (payload) => {
            console.log('Download iniciado:', payload);
            // Registrar en backend
            fetch('/api/log-download', {
                method: 'POST',
                body: JSON.stringify(payload)
            });
        }
    }
});
```

### Método 3: Interceptar Fetch en iframe
```javascript
iframe.addEventListener('load', function() {
    const iframeWindow = iframe.contentWindow;
    const originalFetch = iframeWindow.fetch;
    
    iframeWindow.fetch = function(...args) {
        const url = args[0];
        if (url.includes('export') || url.includes('download')) {
            console.log('Export detectado:', url);
        }
        return originalFetch.apply(this, args);
    };
});
```

## 📊 Ejemplo de Manipulación de Descarga

```javascript
function handleDownload(downloadData) {
    // 1. Registrar en tu base de datos
    await logDownloadToDatabase({
        user: getCurrentUser(),
        dashboard_id: downloadData.dashboard_id,
        format: downloadData.format,
        timestamp: new Date()
    });
    
    // 2. Mostrar notificación personalizada
    showCustomNotification('Exportando a Excel...');
    
    // 3. Agregar marca de agua o metadatos
    // (requiere procesar el archivo descargado)
    
    // 4. Bloquear descarga si no tiene permisos
    if (!userHasExportPermission()) {
        event.preventDefault();
        alert('No tienes permisos para exportar');
        return false;
    }
    
    // 5. Enviar webhook a sistema externo
    fetch('https://tu-sistema.com/webhook/download', {
        method: 'POST',
        body: JSON.stringify(downloadData)
    });
}
```

## 🔧 Troubleshooting

### Error: CORS bloqueando iframe
**Solución:** Verifica que `superset_config.py` tenga:
```python
ENABLE_CORS = True
CORS_OPTIONS = {
    'origins': ['*']  # O tu dominio específico
}
```

### Error: No se detectan eventos
**Solución:** 
1. Asegúrate de que `EMBEDDED_SUPERSET` está en `True` en `FEATURE_FLAGS`
2. Usa el SDK oficial de Superset
3. Verifica que el dashboard tenga permisos públicos o uses guest tokens

### Error: Guest token inválido
**Solución:**
1. Verifica que `GUEST_TOKEN_JWT_SECRET` sea igual en `superset_config.py` y `guest_token_server.py`
2. Asegúrate de que el dashboard existe y es accesible
3. Verifica que el usuario admin tenga permisos

## 📝 Logs de Descargas

El servidor guarda logs en `downloads.log`:
```
2025-12-04T10:30:15.123Z - user@example.com - xlsx
2025-12-04T10:31:22.456Z - admin - csv
```

## 🔐 Seguridad

1. **Cambiar secretos en producción:**
   ```python
   SECRET_KEY = "tu-secret-key-seguro"
   GUEST_TOKEN_JWT_SECRET = "otro-secret-diferente"
   ```

2. **Configurar CORS específico:**
   ```python
   CORS_OPTIONS = {
       'origins': ['https://tuapp.com']  # Solo tu dominio
   }
   ```

3. **Habilitar HTTPS en producción:**
   ```python
   TALISMAN_ENABLED = True
   ```

## 📚 Referencias

- [Superset Embedding Docs](https://superset.apache.org/docs/installation/embedding-dashboards)
- [Superset Embedded SDK](https://github.com/apache/superset/tree/master/superset-embedded-sdk)
- [Guest Token API](https://superset.apache.org/docs/security#guest-token)

## 🆘 Soporte

Si tienes problemas:
1. Revisa los logs: `docker-compose logs superset`
2. Verifica configuración CORS en DevTools del navegador
3. Comprueba que el dashboard sea accesible directamente
