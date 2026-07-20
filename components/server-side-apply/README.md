# server-side-apply

Common annotations for Server-Side Apply via Argo CD.

```yaml
argocd.argoproj.io/sync-options: ServerSideApply=true,RespectIgnoreDifferences=true
```

```yaml
components:
  - ../../../components/server-side-apply
```

Prefer field ownership over full-object replace for CNO / MCO–owned cluster config.
