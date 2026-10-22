{{ if .local.gitea.default_login -}}
- `tea` defaults to the `{{ .local.gitea.default_login }}` login, which is {{ .local.gitea.default_login_owner }}'s account. Always pass `--login {{ .local.gitea.login }}` and, outside a Git directory, `--repo <owner>/<repo>`; never act as {{ .local.gitea.default_login_owner }}.
{{- else -}}
- Always pass `--login {{ .local.gitea.login }}` and, outside a Git directory, `--repo <owner>/<repo>`.
{{- end }}
- This overrides examples that omit `--login`. Write actions retain the Authorization rules.