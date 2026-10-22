{{- define "keycloak.labels" -}}
app: {{ .Chart.Name }}
{{- end }}

{{- define "keycloak.selectorLabels" -}}
app: {{ .Chart.Name }}
{{- end }}

{{- define "keycloak.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
