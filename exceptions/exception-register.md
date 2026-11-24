# Platform Security Exception Register (Cutover Disposition)

**Target Namespace:** `secure-apps`  
**Security Baseline:** Pod Security Standards (`restricted:latest`), LimitRange CPU/Memory quotas  
**Reviewer:** Platform Lead & Triage SRE  

---

### Exception 01: `legacy-pdf-generator`
- **Workload Name:** `legacy-pdf-generator`
- **Triage Decision:** **EXEMPT** (Segregated Namespace Exemption)
- **Root Cause / Technical Constraint:** 
  The workload bundles an unmodifiable commercial off-the-shelf (COTS) binary (`cots-document-solutions`) that contains an explicit kernel-level check requiring UID 0 to bind into the legacy print/spooler subsystem. Applying `runAsNonRoot: true` passes admission but triggers a fatal process termination on startup.
- **Why It Cannot Be Fixed Immediately:** 
  Source code is vendor-managed. The vendor roadmap delivers an unprivileged container release in Q2 2027.
- **Compensating Security Controls:**
  1. Migrate workload to a segregated, non-default namespace (`legacy-exempt-workloads`) configured with `pod-security.kubernetes.io/enforce: baseline`.
  2. Implement strict Kubernetes `NetworkPolicy` restricting ingress exclusively to internal RPC calls from `api-gateway` and denying all external egress.
  3. Enforce read-only root filesystem with isolated tmpfs mounts to mitigate privilege abuse.
- **Sunset Date / Review Cycle:** 90-day temporary exception ticket `SEC-4091`.

---

### Exception 02: `mesh-telemetry-agent`
- **Workload Name:** `mesh-telemetry-agent`
- **Triage Decision:** **EXEMPT** (Architectural Platform Reclassification)
- **Root Cause / Technical Constraint:** 
  The service is a cluster node-level monitoring agent that requires `hostNetwork: true` and Linux capabilities `NET_ADMIN` and `NET_RAW` to capture interface socket metrics. Both configurations are explicitly forbidden under application `restricted` PSS.
- **Why It Cannot Be Fixed Immediately:** 
  Network interface metric collection inherently requires host network visibility. Stripping these capabilities renders the agent non-functional.
- **Compensating Security Controls:**
  1. Reclassify workload from an application Deployment into a cluster infrastructure `DaemonSet`.
  2. Move to `platform-system` or `kube-system` namespace.
  3. Restrict host path mounts and enforce strict RBAC limiting its service account to read-only metrics endpoints.
- **Disposition:** Permanent exemption as a platform-tier component.
