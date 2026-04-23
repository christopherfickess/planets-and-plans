{{/*
==============================================================================
  Shared template helpers for the flux-addons chart.

  Each helper accepts a dict of parameters.  Call them with include, e.g.:
    {{- include "flux-addons.namespace"       (dict "name" .Values.nginx.namespace) }}
    {{- include "flux-addons.helmrepository"  (dict "repo" .Values.nginx.chart.repo "global" .Values.global) }}
    {{- include "flux-addons.configmap"       (dict "name" "nginx" "namespace" .Values.nginx.namespace "values" $builtValues) }}
    {{- include "flux-addons.helmrelease"     (dict "name" "nginx" "releaseName" "nginx" "namespace" .Values.nginx.namespace "chart" .Values.nginx.chart "configmapName" "nginx" "global" .Values.global) }}
==============================================================================
*/}}

{{/*
  flux-addons.namespace — renders a v1/Namespace.
  Params: name (string)
*/}}
{{- define "flux-addons.namespace" -}}
---
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .name }}
{{- end }}

{{/*
  flux-addons.helmrepository — renders a Flux HelmRepository in flux-system.
  Params: repo (dict with name/url/type), global (dict)
*/}}
{{- define "flux-addons.helmrepository" -}}
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: {{ .repo.name }}
  namespace: flux-system
spec:
  {{- if eq (.repo.type | default "default") "oci" }}
  type: oci
  {{- end }}
  interval: {{ .global.helmRepoInterval | default "5m" }}
  url: {{ .repo.url }}
{{- end }}

{{/*
  flux-addons.configmap — renders the values ConfigMap consumed by the HelmRelease.
  Params: name (string), namespace (string), values (dict)
*/}}
{{- define "flux-addons.configmap" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .name }}-values
  namespace: {{ .namespace }}
data:
  values.yaml: |
{{ toYaml .values | indent 4 }}
{{- end }}

{{/*
  flux-addons.helmrelease — renders a Flux HelmRelease wired to a values ConfigMap.
  Params:
    name         string   — used for ConfigMap reference and default releaseName
    releaseName  string   — override releaseName (e.g. "kube-prometheus-stack")
    namespace    string
    chart        dict     — releaseName/name/version/repo
    configmapName string  — ConfigMap name (usually same as name)
    global       dict
    dependsOn    []dict   — optional Flux dependsOn entries
*/}}
{{- define "flux-addons.helmrelease" -}}
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: {{ .releaseName | default .name }}
  namespace: {{ .namespace }}
spec:
  interval: {{ .global.helmReleaseInterval | default "10m" }}
  chart:
    spec:
      chart: {{ .chart.name }}
      version: {{ .chart.version | quote }}
      sourceRef:
        kind: HelmRepository
        name: {{ .chart.repo.name }}
        namespace: flux-system
      # How often Flux re-checks for a new chart version (and retries on download
      # failure). 1h is fine for pinned versions in prod; lower to 5-10m for dev
      # or whenever you need faster recovery from transient HelmRepository errors.
      interval: {{ .global.chartInterval | default "10m" }}
  install:
    createNamespace: true
    remediation:
      retries: {{ .global.upgradeRetries | default 3 }}
  upgrade:
    cleanupOnFail: true
    timeout: {{ .global.upgradeTimeout | default "5m" }}
    remediation:
      retries: {{ .global.upgradeRetries | default 3 }}
      # Roll back to the last successful release on upgrade failure rather than
      # leaving the release in a broken state and stopping all future reconciles.
      strategy: rollback
  {{- if .dependsOn }}
  dependsOn:
    {{- toYaml .dependsOn | nindent 4 }}
  {{- end }}
  valuesFrom:
    - kind: ConfigMap
      name: {{ .configmapName | default .name }}-values
      valuesKey: values.yaml
{{- end }}
