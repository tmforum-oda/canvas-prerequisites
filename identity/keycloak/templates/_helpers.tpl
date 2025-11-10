{{- define "keycloak-helm.labels" -}}
app: {{ .Chart.Name }}
{{- end }}

{{- define "keycloak-helm.selectorLabels" -}}
app: {{ .Chart.Name }}
{{- end }}

{{- define "keycloak-helm.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
