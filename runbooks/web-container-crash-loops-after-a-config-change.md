# Web container crash-loops after a config change

Application: spike-app · namespace spike
Observed: 2026-11-16T22:31:12.895Z

## Symptom

- Rollout spike-app: progressing, 1/1 updated, 1 available, 2 pods
- spike-app-5d96984bd-t4dxc/web: waiting CrashLoopBackOff, 4 restarts, last exit 1 (Error)

## Evidence

- Image sha256:fa02ff157ed2… → revision 219444def06c (ghcr.io/nazmur96/bastion-delivery-spike-8b7a1e revision label)
- Event BackOff on Pod/spike-app-5d96984bd-t4dxc ×8: Back-off restarting failed container web in pod spike-app-5d96984bd-t4dxc_spike(d2bfb21b-9db8-4787-af61-56e745985c15)
- Event Unhealthy on Pod/spike-app-5d96984bd-t4dxc ×5: Readiness probe failed: Get "http://10.244.0.13:8080/": dial tcp 10.244.0.13:8080: connect: connection refused
- Event Unhealthy on Pod/spike-app-66565496fd-fnbh6 ×1: Readiness probe failed: Get "http://10.244.0.12:8080/": dial tcp 10.244.0.12:8080: connect: connection refused

Previous log of spike-app-5d96984bd-t4dxc/web (last lines, redacted):

```text
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: can not modify /etc/nginx/conf.d/default.conf (read-only file system?)
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/11/16 22:30:40 [emerg] 1#1: unknown directive "gzip_type" in /etc/nginx/conf.d/default.conf:5
nginx: [emerg] unknown directive "gzip_type" in /etc/nginx/conf.d/default.conf:5
```

## Cause

nginx refuses to start: `gzip_type` is not a directive (it is `gzip_types`), in `app/default.conf` line 5, introduced by revision 219444d. CI passed because the checks never start nginx.

## Recovery

1. On the Delivery page, read the evidence for the last verified revision.
2. Pin its digest (rollback), then commit and push the change; the controller deploys it.
3. Run the journey check below and record the result as a drill.

Limits: rollback does not undo data or schema changes or external side effects.

## Correction

_The source change that fixes the cause, and the revision that carries it._

## Verification

Journey check: GET spike-app:8080/ through the cluster API, expecting "version:".
- 2026-11-16T22:30:42.911Z check failed · revision unknown · Response does not contain "version: 5"
