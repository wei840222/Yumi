{{ if .local.gitea.default_login -}}
- `tea` defaults to the `{{ .local.gitea.default_login }}` login, which is {{ .local.gitea.default_login_owner }}'s account, not Baby's. Always pass `--login {{ .local.gitea.login }}` (and `--repo <owner>/<repo>` outside a git directory); never act as {{ .local.gitea.default_login_owner }}.
{{- else -}}
- Always pass `--login {{ .local.gitea.login }}` (and `--repo <owner>/<repo>` outside a git directory).
{{- end }}
- This overrides the `gitea` skill's examples, which omit `--login`. Write actions such as `tea pr create`, `tea pr merge`, and `tea comments add` still follow the Authorization section.