# Validación independiente del fallo de PowerShell — 2026-10-23

Objetivo autorizado: resolver el fallo final de `upgrade` por cuota anónima de GitHub, sin repetir la actualización completa.

Durante el diagnóstico se detectaron cambios concurrentes en `UpdateAppsHelper.ps1` y la aparición de `tests/PowerShellRuntime.Tests.ps1`. Esta sesión no aplicó la corrección: una propuesta de parche no se aplicó porque el archivo ya había cambiado. Se preservaron todos los cambios y se solicitó coordinación al usuario.

Estado validado: SHA256 de `Core/Apps/UpdateAppsHelper.ps1` `0EE7CC6B2A3EA0553AEBC8666299AFD4351A71DE81AB5F339E6E26036D69DEFD`.

- El código consulta por HEAD el redirect oficial `/PowerShell/PowerShell/releases/latest`, con límite de 30 segundos, sin API REST. Rechaza otros hosts y versiones preview. Mantiene la validación Authenticode de Microsoft antes de instalar.
- `Get-PowerShellPublishedVersion` consultado en vivo: 7.6.8.
- Ejecutable nuevo `C:/Program Files/PowerShell/7/pwsh.exe -NoProfile`: 7.6.8.
- `Invoke-Pester -Path ./tests/PowerShellRuntime.Tests.ps1`: 8 pruebas aprobadas, 0 fallidas.
- `Invoke-Pester -Path ./tests`: 77 aprobadas, 0 fallidas, 0 omitidas.
- `Invoke-ScriptAnalyzer -Path Core/Apps/UpdateAppsHelper.ps1 -Settings .psscriptanalyzersettings.psd1`: sin hallazgos.
- `Update-PowerShellRuntime -WhatIf`: no ejecuta la actualización.
- `Update-PowerShellRuntime` real: `[OK] PowerShell is already current (7.6.8)`; no descargó ni reinstaló.

Límites: no se repitió `upgrade` completo ni se verificaron CI o los demás gestores. Esta versión del código aún compara con la sesión abierta; abrir una terminal nueva evita repetir una instalación que Windows Update haya realizado durante la sesión antigua. El aviso Landlock ABI 7/10 es independiente y no queda resuelto por esta corrección.
