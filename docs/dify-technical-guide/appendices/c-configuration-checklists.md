# C. Configuration checklists

> **Version áp dụng:** Dify Community Edition `1.15.0`, commit `3aa26fb6374bbd47e5469f7d7cc25f3e0075a60c`  
> **Ngày kiểm chứng:** `2026-07-16`  
> **Trạng thái xác minh:** Catalog được tổng hợp từ source/config/design của Chương 11–16; mọi review theo môi trường mặc định `RUNTIME-PENDING` cho đến khi có evidence  
> **Reviewer:** Điền environment owner, technical reviewer và approver trong review record; không ghi secret vào phụ lục

## Cách sử dụng

Phụ lục này là **review sheet**, không phải runbook. Mỗi dòng là một control có ID ổn định; rationale, procedure, command, failure test và caveat nằm ở chương được ghi trong cột “Cơ sở/chương”. Khi hai tài liệu khác nhau, source đã pin và chương sở hữu nội dung là chuẩn; cập nhật checklist sau.

### Metadata của một lần review

Mỗi bản review phải ghi ở ticket hoặc evidence index:

| Trường | Giá trị cần điền |
|---|---|
| Review ID | ID duy nhất, liên kết change/release nếu có |
| Environment | `dev`, `staging` hoặc `prod` |
| Deployment model | `Docker Compose`, `Kubernetes/Helm nội bộ` hoặc phương án đã phê duyệt |
| Dify release | Tag, full source commit, image digest và release bundle ID |
| Config version | Commit/hash của base, overlay và rendered manifest đã redacted |
| Data classification | Classification, tenant/workspace scope và external-data policy |
| Reviewer/approver | Tên hoặc team; technical, Security, Data và Operations theo scope |
| Review time | UTC timestamp và thời hạn hiệu lực của evidence |
| Exceptions | Risk acceptance ID, owner, expiry và compensating control |

### Mã môi trường

| Mã | Ý nghĩa |
|---|---|
| `D/S/P` | Bắt buộc ở dev, staging và prod; assurance/evidence tăng dần theo môi trường. |
| `S/P` | Bắt buộc ở staging và prod; có thể áp dụng dev nếu dùng cùng topology. |
| `P` | Production gate; nên rehearsal ở staging. |
| `D/S/P (Compose)` | Áp dụng khi môi trường dùng Docker Compose. |
| `S/P (K8s)` | Áp dụng khi môi trường dùng Kubernetes/Helm. |
| `Conditional` | Chỉ được đánh `N/A` khi điều kiện không tồn tại và owner phê duyệt lý do. |

Dev không được dùng production credential hoặc production data chưa được phê duyệt. Staging phải đủ production-like để kiểm tra release, migration, network, provider, backup và failure path nhưng phải chặn side effect thật. Production chỉ nhận artifact đã qua staging.

### Cấp bằng chứng và trạng thái template

| Cấp | Dùng khi | Trạng thái ban đầu | Trạng thái đạt |
|---|---|---|---|
| `SOURCE` | Xác nhận provenance/version hoặc claim trực tiếp từ nguồn primary đã pin. | `SOURCE-PENDING` | `SOURCE-VALIDATED` |
| `CONFIG` | Xác nhận rendered config, manifest, image, port, route, env key hoặc policy tĩnh. | `CONFIG-PENDING` | `CONFIG-VALIDATED` |
| `DESIGN` | Xác nhận quyết định kiến trúc/ownership/risk trước runtime. | `DESIGN-PENDING` | `DESIGN-REVIEWED` |
| `RUNTIME` | Cần log, metric, test, restore, failure injection hoặc observed result. | `RUNTIME-PENDING` | `RUNTIME-VALIDATED` |
| `N/A` | Control thực sự không áp dụng. | Không được để trống | `N/A-APPROVED:<ID>` |

Không nâng một item từ `SOURCE/CONFIG/DESIGN` thành `RUNTIME-VALIDATED` chỉ vì container/Pod ở trạng thái `running`. Evidence phải có release/environment/test ID, expected/actual result, timestamp và reviewer. Evidence URI không được chứa `.env` đã resolve, secret value, token, private key, production prompt/response chưa redact hoặc signed URL dài hạn.

### Quy tắc hoàn tất

1. Copy trạng thái của từng item vào evidence index hoặc điền trực tiếp trên nhánh review.
2. Không xóa item. Dùng `N/A-APPROVED:<ID>` với lý do, approver và expiry nếu không áp dụng.
3. Một item `FAIL` hoặc `PENDING` ở production gate phải có blocker hoặc risk acceptance còn hiệu lực.
4. Evidence source/config có thể dùng lại giữa môi trường nếu artifact giống hệt; runtime evidence chỉ dùng lại khi topology, config, data profile và failure domain tương đương.
5. Không sao chép command từ phụ lục. Mở chương sở hữu nội dung và chạy procedure đúng version.

### Bản đồ ownership nội dung

| Chương | Nội dung chuẩn | Nhóm nguồn chính đã dùng lại |
|---|---|---|
| Chương 11 | Docker Compose, profile, image, env precedence, service/mount/route và smoke | [S-001][S-005][S-006][S-007][S-009][S-010][S-013][S-021][S-046][S-047] |
| Chương 12 | Kubernetes/Helm reference, HA, migration Job, HPA/PDB/probe/Ingress | [S-008][S-013][S-032][S-039][S-079]–[S-086] |
| Chương 13 | Identity, secret, edge, network/egress, sandbox/plugin/tool và data security | [S-005][S-006][S-010][S-016][S-017][S-031][S-073][S-078] |
| Chương 14 | Provider/model onboarding, compatible endpoints, capability, RAG model và observability | [S-038][S-050][S-060][S-065][S-066][S-069][S-071][S-072][S-087]–[S-094] |
| Chương 15 | Ownership/SLO, backup/restore, migration/rollback, incident, DR và evidence | [S-001][S-011][S-039][S-045][S-056][S-095]–[S-102] |
| Chương 16 | Baseline lock, digest/SBOM/provenance, CI/CD, IaC, promotion và drift | [S-001][S-045][S-046][S-103]–[S-105] |

## Baseline

### Provenance và scope

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-BASE-001 | Dify được khóa bằng tag `1.15.0` và full commit; không dùng `main` hoặc lookup “latest” động. | D/S/P | Release | Baseline lock + Git metadata | SOURCE · Ch.11/16 [S-001] | `SOURCE-PENDING` |
| CFG-BASE-002 | Docs baseline được khóa bằng immutable commit phù hợp release. | D/S/P | Docs/Release | Docs commit trong release bundle | SOURCE · Ch.16 | `SOURCE-PENDING` |
| CFG-BASE-003 | Plugin daemon được khóa bằng version, commit và image digest tương thích baseline. | D/S/P | Platform | Component lock + digest | SOURCE · Ch.12/16 [S-032] | `SOURCE-PENDING` |
| CFG-BASE-004 | Edition, entitlement, support boundary và deployment model được ghi rõ; Community chart không bị gọi là artifact chính thức. | S/P | Service owner | Architecture decision record | DESIGN · Ch.12 [S-008] | `DESIGN-PENDING` |
| CFG-BASE-005 | Mỗi môi trường có owner, purpose, data classification, tenant/workspace scope và lifecycle. | D/S/P | Service owner | Environment registry | DESIGN · Ch.13/16 | `DESIGN-PENDING` |
| CFG-BASE-006 | PostgreSQL, Redis, vector, storage, ingress, secret manager và observability backend/version được inventory. | D/S/P | Platform | Dependency manifest | CONFIG · Ch.11/12/15 | `CONFIG-PENDING` |
| CFG-BASE-007 | Docker/Compose hoặc Kubernetes/Helm/GitOps toolchain version được khóa. | D/S/P | Platform | Toolchain lock + version output | CONFIG · Ch.11/12/16 | `CONFIG-PENDING` |
| CFG-BASE-008 | Release/change ID liên kết source, artifact, rendered config, migration và evidence. | S/P | Release | Release manifest/evidence index | DESIGN · Ch.16 | `DESIGN-PENDING` |
| CFG-BASE-009 | App DSL có hash và dependency manifest cho model, plugin, knowledge và env; không được coi là full backup. | S/P | App owner | DSL hash + dependency manifest | CONFIG · Ch.16 [S-045] | `CONFIG-PENDING` |
| CFG-BASE-010 | Mọi deviation khỏi upstream baseline có owner, rationale, test, upgrade impact và expiry/review date. | D/S/P | Platform | Deviation register | DESIGN · Ch.11/16 | `DESIGN-PENDING` |
| CFG-BASE-011 | Production assumptions về SLO/RPO/RTO, data residency và external provider đã được phê duyệt. | P | Service owner | Signed service record | DESIGN · Ch.13–15 | `DESIGN-PENDING` |
| CFG-BASE-012 | Reviewer độc lập xác nhận scope review bao phủ đúng environment và release candidate. | S/P | Approver | Review sign-off + timestamp | DESIGN · Ch.16 | `DESIGN-PENDING` |

### Image và supply-chain baseline

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-IMG-001 | Mọi image có registry/repository, platform và immutable digest; tag chỉ là metadata. | S/P | Release | Image inventory + digests | CONFIG · Ch.11/16 [S-105] | `CONFIG-PENDING` |
| CFG-IMG-002 | Mutable image reference trong upstream manifest được thay hoặc khóa bằng internal immutable mapping trước production. | P | Platform | Rendered image list/diff | CONFIG · Ch.11 [S-005] | `CONFIG-PENDING` |
| CFG-IMG-003 | Image được lấy từ registry allowlist; mirror/cache và credential scope có owner. | S/P | Platform/Security | Registry policy + pull evidence | DESIGN · Ch.13/16 | `DESIGN-PENDING` |
| CFG-IMG-004 | Vulnerability/license/malware scan có policy, threshold, exception owner và expiry. | S/P | Security | Scan report + exception IDs | RUNTIME · Ch.13/16 | `RUNTIME-PENDING` |
| CFG-IMG-005 | SBOM, provenance/attestation và signature có issuer/workflow identity; deploy job verify thay vì chỉ lưu. | S/P | Release/Security | SBOM + verification log | RUNTIME · Ch.16 [S-103]–[S-105] | `RUNTIME-PENDING` |
| CFG-IMG-006 | Source-to-image mapping cho custom build hoặc upstream-to-mirror chain có thể truy nguyên. | S/P | Release | Provenance record | SOURCE · Ch.16 | `SOURCE-PENDING` |
| CFG-IMG-007 | Production không build lại hoặc resolve tag lại; dùng đúng digest đã test ở staging. | P | Release | Staging/prod digest comparison | RUNTIME · Ch.16 | `RUNTIME-PENDING` |
| CFG-IMG-008 | Rollback image/config bundle còn truy cập được từ failure domain dự kiến. | P | Release/SRE | Artifact availability drill | RUNTIME · Ch.15/16 | `RUNTIME-PENDING` |

## Docker Compose

### Compose render và host boundary

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-CMP-001 | Docker daemon và Compose version đáp ứng prerequisite của baseline. | D/S/P (Compose) | Platform | Client/server/version output | RUNTIME · Ch.11 [S-007] | `RUNTIME-PENDING` |
| CFG-CMP-002 | Checkout/source commit của thư mục deploy khớp baseline lock. | D/S/P (Compose) | Release | Full commit output | SOURCE · Ch.11 | `SOURCE-PENDING` |
| CFG-CMP-003 | File cấu hình được tạo từ template đúng release; optional env precedence được review. | D/S/P (Compose) | Platform | File inventory + redacted diff | CONFIG · Ch.11 [S-006][S-021] | `CONFIG-PENDING` |
| CFG-CMP-004 | Rendered model pass validation; profile, service và image list khớp lựa chọn DB/vector/collaboration. | D/S/P (Compose) | Platform | `config` gate output không chứa secret | CONFIG · Ch.11 [S-046] | `CONFIG-PENDING` |
| CFG-CMP-005 | Port, volume/bind mount, network và dependency diff được reviewer thứ hai xác nhận. | S/P (Compose) | Platform | Redacted rendered diff | CONFIG · Ch.11 [S-005] | `CONFIG-PENDING` |
| CFG-CMP-006 | Host CPU/RAM/disk/inode/IO và port availability có headroom theo workload và backup. | D/S/P (Compose) | SRE | Capacity/preflight evidence | RUNTIME · Ch.11/15 | `RUNTIME-PENDING` |
| CFG-CMP-007 | Chỉ intended edge port được public; plugin debug, DB, Redis, vector, sandbox và proxy không public. | D/S/P (Compose) | Security/Network | Listener/firewall scan | RUNTIME · Ch.11/13 | `RUNTIME-PENDING` |
| CFG-CMP-008 | State path/ownership của DB, app storage, plugin storage, Redis và vector được inventory. | D/S/P (Compose) | Platform | Mount inventory + owner/mode | CONFIG · Ch.11/15 [S-005] | `CONFIG-PENDING` |
| CFG-CMP-009 | `init_permissions` hoàn tất đúng kỳ vọng; không dùng privileged workaround tùy tiện. | D/S/P (Compose) | Platform | Task exit/log + filesystem check | RUNTIME · Ch.11 | `RUNTIME-PENDING` |
| CFG-CMP-010 | Start/smoke xác nhận API, web, worker, plugin, sandbox và dependency; không chỉ `running`. | D/S/P (Compose) | SRE | Ch.11 smoke test IDs | RUNTIME · Ch.11 | `RUNTIME-PENDING` |
| CFG-CMP-011 | Stop/down/cleanup procedure không xóa volume hoặc bind-mounted state ngoài change approval. | S/P (Compose) | SRE | Approved procedure/test | DESIGN · Ch.11/15 [S-047] | `DESIGN-PENDING` |
| CFG-CMP-012 | Compose single-host failure domain được ghi trong risk/SLO; không gắn nhãn HA. | P (Compose) | Service owner | Risk acceptance/architecture record | DESIGN · Ch.11/15 | `DESIGN-PENDING` |

### Environment, secret và config coupling

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-ENV-001 | Env schema xác định required/optional/type; missing và unknown key bị reject ở pipeline. | D/S/P | Platform/Release | Schema validation result | RUNTIME · Ch.16 | `RUNTIME-PENDING` |
| CFG-ENV-002 | Secret khác nhau giữa môi trường; bootstrap/default credential đã được thay mà không ghi giá trị vào evidence. | D/S/P | Security | Secret version/fingerprint đã redact | CONFIG · Ch.11/13 [S-006] | `CONFIG-PENDING` |
| CFG-ENV-003 | Secret value nằm trong secret manager/runtime scope, không ở Git, image, DSL, artifact hoặc resolved config log. | D/S/P | Security/Release | Secret scan + reference inventory | RUNTIME · Ch.13/16 | `RUNTIME-PENDING` |
| CFG-ENV-004 | DB server/client credential mapping nhất quán và rotation đổi cả hai phía. | D/S/P | DBA | Consumer map + rotation test | RUNTIME · Ch.11/13 | `RUNTIME-PENDING` |
| CFG-ENV-005 | Redis credential và Celery broker/backend URL nhất quán; password không lộ trong log. | D/S/P | Platform | Redacted connection test | RUNTIME · Ch.11/15 [S-011] | `RUNTIME-PENDING` |
| CFG-ENV-006 | Sandbox key và code-execution client key cùng secret version, scope tối thiểu. | D/S/P | Platform/Security | Secret reference map + test | RUNTIME · Ch.11/13 | `RUNTIME-PENDING` |
| CFG-ENV-007 | Plugin daemon key và Dify inner API key có consumer map, rotation và revoke procedure. | D/S/P | Platform/Security | Reference map + rotation evidence | RUNTIME · Ch.11/13 | `RUNTIME-PENDING` |
| CFG-ENV-008 | Vector/object storage credential có least privilege và không dùng chung giữa môi trường. | D/S/P | Data/Storage | IAM policy + access test | RUNTIME · Ch.13/15 | `RUNTIME-PENDING` |
| CFG-ENV-009 | `SECRET_KEY` ownership, version, backup/restore và rotation impact được ghi; không in key. | S/P | Security/Platform | Secret version ID + restore/rotation test | RUNTIME · Ch.11/15 | `RUNTIME-PENDING` |
| CFG-ENV-010 | Secret/certificate expiry có alert, owner, rotation window và break-glass. | S/P | Security/SRE | Alert test + lifecycle record | RUNTIME · Ch.13/15 | `RUNTIME-PENDING` |
| CFG-ENV-011 | Non-secret config được version hóa; environment overlay chỉ chứa khác biệt có chủ đích. | D/S/P | Platform | Base/overlay diff + hash | CONFIG · Ch.16 | `CONFIG-PENDING` |
| CFG-ENV-012 | Resolved config/support bundle/evidence có access control, retention và redaction. | S/P | Security/SRE | ACL/retention + redaction test | RUNTIME · Ch.13/16 | `RUNTIME-PENDING` |

### URL, DNS, TLS và edge routes

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-URL-001 | Public console, API, app, file và callback URLs dùng đúng scheme/domain của môi trường; không còn localhost/dev domain. | S/P | Platform/App | Redacted env + route smoke | RUNTIME · Ch.11 | `RUNTIME-PENDING` |
| CFG-URL-002 | Internal service URL dùng đúng service/network boundary, không hairpin qua public edge nếu không chủ đích. | D/S/P | Platform | Rendered endpoint map | CONFIG · Ch.11/12 | `CONFIG-PENDING` |
| CFG-URL-003 | Nginx/Ingress route UI, API/file/MCP/trigger, WebSocket và plugin hook đúng baseline. | D/S/P | Platform | Route table + positive/negative test | RUNTIME · Ch.11/12 [S-010] | `RUNTIME-PENDING` |
| CFG-URL-004 | Console/Web API CORS chỉ cho domain cần thiết; wildcard production không được chấp nhận nếu chưa có risk approval. | S/P | Security/App | CORS test + rendered config | RUNTIME · Ch.11/13 | `RUNTIME-PENDING` |
| CFG-URL-005 | TLS certificate, hostname, chain, protocol policy, redirect và expiry monitoring đạt. | S/P | Network/Security | TLS scan + alert test | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-URL-006 | WebSocket/SSE/streaming timeout, upgrade header, reconnect và drain đã test qua edge thật. | S/P | Platform/App | Streaming/WebSocket test IDs | RUNTIME · Ch.12/14 | `RUNTIME-PENDING` |
| CFG-URL-007 | Upload/request body limit, API/proxy timeout và rate limit khớp workload/risk. | S/P | Platform/Security | Boundary tests + config | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-URL-008 | DNS/LB cutover, TTL/cache và rollback target nằm trong RTO; certificate có sẵn ở DR target. | P | Network/SRE | DR DNS/TLS drill | RUNTIME · Ch.15 | `RUNTIME-PENDING` |

### Network và egress

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-NET-001 | Trust zones và inbound matrix chỉ cho edge/admin path gọi đúng service; stateful dependency không public. | D/S/P | Network/Security | Network diagram + scan | DESIGN · Ch.13 | `DESIGN-PENDING` |
| CFG-NET-002 | Egress inventory bao phủ model, tool, plugin/package, SMTP, webhook, data source, DNS/NTP và observability. | D/S/P | Network/App | Egress allowlist + owner map | DESIGN · Ch.13/14 | `DESIGN-PENDING` |
| CFG-NET-003 | Private, loopback, link-local, metadata và internal admin targets bị deny từ untrusted URL path. | S/P | Security | SSRF negative test | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-NET-004 | `ssrf_proxy` chỉ được credit cho traffic đã chứng minh đi qua; bypass path được inventory/test. | S/P | Security/Platform | Route capture + bypass tests | RUNTIME · Ch.13 [S-005][S-006] | `RUNTIME-PENDING` |
| CFG-NET-005 | Provider/plugin runtime resolve DNS, validate TLS/CA và dùng proxy theo policy từ đúng network namespace. | D/S/P | Network/AI Platform | Connectivity/TLS test | RUNTIME · Ch.14 | `RUNTIME-PENDING` |
| CFG-NET-006 | DB, Redis, vector và object endpoint có auth/TLS/segmentation theo backend support và policy. | S/P | Platform/Data | Connection/IAM/network evidence | RUNTIME · Ch.12/13 | `RUNTIME-PENDING` |
| CFG-NET-007 | Admin console/break-glass access được giới hạn theo IAM/network và được audit. | P | Security | Access test + audit event | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-NET-008 | Denied egress/inbound signal có log/alert nhưng không lộ secret/PII. | S/P | SRE/Security | Alert + redaction test | RUNTIME · Ch.13/15 | `RUNTIME-PENDING` |

### DB, Redis, vector và storage

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-DATA-001 | Main DB và plugin DB được inventory, có owner, database/version/endpoint và backup scope. | D/S/P | DBA | DB inventory đã redact | CONFIG · Ch.11/15 | `CONFIG-PENDING` |
| CFG-DATA-002 | PostgreSQL connection pool/budget, timeout, TLS và max connection phù hợp replica/worker/migration. | S/P | DBA/Platform | Capacity test + config | RUNTIME · Ch.12/15 | `RUNTIME-PENDING` |
| CFG-DATA-003 | Migration policy rõ: environment-exclusive atomic lock + one-shot Compose/Job; không để mọi replica hoặc hai pipeline cùng chạy migration. | S/P | DBA/Release | Lock contract + rendered env + migration evidence | CONFIG · Ch.11/12/15/16 [S-013] | `CONFIG-PENDING` |
| CFG-DATA-004 | Redis role được ghi: broker/backend/cache/event; topology và client mode khớp standalone/Sentinel/Cluster đã chọn. | D/S/P | Platform | Redis config + functional test | RUNTIME · Ch.12/15 [S-039] | `RUNTIME-PENDING` |
| CFG-DATA-005 | Redis memory/eviction/persistence/TLS và clean-restore hay RDB/AOF strategy có decision record. | S/P | Platform/App | Policy + failure/replay test | DESIGN · Ch.15 [S-100] | `DESIGN-PENDING` |
| CFG-DATA-006 | Vector backend/profile/endpoint/auth/version khớp rendered config và dataset hiện hữu. | D/S/P | Data/RAG | Backend inventory + retrieval test | RUNTIME · Ch.11/15 [S-056] | `RUNTIME-PENDING` |
| CFG-DATA-007 | Đổi `VECTOR_STORE` có migration/reindex/cutover/rollback plan; không coi env change là migration. | S/P | Data/RAG | Migration plan + test | DESIGN · Ch.12/15 [S-056] | `DESIGN-PENDING` |
| CFG-DATA-008 | Storage backend/path/bucket, encryption, versioning, retention và multi-replica semantics được xác nhận. | D/S/P | Storage | Storage config + read/write test | RUNTIME · Ch.11/12/15 | `RUNTIME-PENDING` |
| CFG-DATA-009 | App storage và plugin storage được tách đúng ownership và cùng nằm trong recovery inventory. | D/S/P | Platform | Mount/object inventory | CONFIG · Ch.11/15 [S-005] | `CONFIG-PENDING` |
| CFG-DATA-010 | Local filesystem chỉ dùng khi topology/risk chấp nhận; Kubernetes không phụ thuộc host-local writable state. | S/P | Platform | Architecture decision + manifest | DESIGN · Ch.11/12 | `DESIGN-PENDING` |
| CFG-DATA-011 | Data capacity, growth, inode/IO/quota và backup headroom có forecast/alert. | S/P | SRE/Data | Capacity model + alert test | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-DATA-012 | Restore/read/write/retrieval canary dùng dữ liệu synthetic đã phê duyệt, không làm side effect production. | S/P | App/Data | Canary IDs + result | RUNTIME · Ch.15 | `RUNTIME-PENDING` |

### API, worker, beat, plugin, sandbox và proxy

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-RUN-001 | API, WebSocket, worker và beat dùng đúng image/MODE và release-specific queue list. | D/S/P | Platform | Rendered service/env list | CONFIG · Ch.11/12 [S-013] | `CONFIG-PENDING` |
| CFG-RUN-002 | Worker functional health dùng synthetic queued task/queue age; không dựa vào healthcheck bị disable mặc định. | D/S/P | SRE | Task ID + completion/alert | RUNTIME · Ch.11/15 | `RUNTIME-PENDING` |
| CFG-RUN-003 | Worker concurrency/autoscale/pool/queue routing khớp workload, DB connection và provider quota. | S/P | Platform/AI Platform | Load/queue evidence | RUNTIME · Ch.12/14 | `RUNTIME-PENDING` |
| CFG-RUN-004 | Beat là singleton; duplicate/missed schedule và failover behavior đã test. | S/P | Platform/App | Scheduler failure test | RUNTIME · Ch.12/15 | `RUNTIME-PENDING` |
| CFG-RUN-005 | Plugin daemon là critical path; API/worker → daemon invocation và daemon → Dify inner API callback có Service/port/key owner, positive/negative auth test; inner API không public. | D/S/P | Platform/AI Platform | Hai chiều connectivity/auth + plugin/model synthetic IDs | RUNTIME · Ch.11–14 | `RUNTIME-PENDING` |
| CFG-RUN-006 | Plugin provenance/signature/update policy đạt; debug/inner API không public. | D/S/P | Security/Platform | Plugin inventory + network scan | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-RUN-007 | Sandbox image/key/network/resource/time limit và code-execution policy được review. | D/S/P | Security/Platform | Config + positive/negative test | RUNTIME · Ch.11/13 | `RUNTIME-PENDING` |
| CFG-RUN-008 | SSRF proxy config/version/allow-deny path được version hóa và negative-test. | S/P | Security/Platform | Config hash + test IDs | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-RUN-009 | Graceful shutdown/drain xử lý streaming, WebSocket và task đang chạy; timeout không cắt mù. | S/P | Platform/App | Rollout/drain test | RUNTIME · Ch.12/14 | `RUNTIME-PENDING` |
| CFG-RUN-010 | Staging/DR mặc định chặn mail, webhook, trigger, schedule và external side effect thật. | S/P | App/Security | Negative side-effect evidence | RUNTIME · Ch.15/16 | `RUNTIME-PENDING` |

## Kubernetes/Helm

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-K8S-001 | Distribution/version, CNI, CSI/StorageClass, Ingress/Gateway, metrics adapter, secret driver và renderer được khóa. | S/P (K8s) | Platform | Cluster/toolchain baseline | CONFIG · Ch.12 | `CONFIG-PENDING` |
| CFG-K8S-002 | Internal chart/manifest có owner, version, schema, CI và support boundary; provenance không bị gán nhầm cho Dify. | S/P (K8s) | Platform | Chart metadata + ADR | DESIGN · Ch.12 [S-008] | `DESIGN-PENDING` |
| CFG-K8S-003 | Helm/template render, lint, policy và server-side dry-run pass trên API version của cluster mục tiêu. | S/P (K8s) | Platform/Release | CI logs + rendered hash | RUNTIME · Ch.12/16 | `RUNTIME-PENDING` |
| CFG-K8S-004 | API/web/WebSocket/sandbox/proxy workload type, Service và replica strategy khớp reference/risk. | S/P (K8s) | Platform | Rendered workload inventory | CONFIG · Ch.12 [S-079] | `CONFIG-PENDING` |
| CFG-K8S-005 | Migration/backfill chạy trong environment-exclusive lock và singleton Job; long-lived API/worker/beat đặt migration disabled. | S/P (K8s) | Release/DBA | Lease/fencing + Job/Deployment env + run log | RUNTIME · Ch.12 [S-013][S-086] | `RUNTIME-PENDING` |
| CFG-K8S-006 | Worker được tách/routing theo queue khi cần; chỉ một autoscaling control loop chính và có connection/quota budget. | S/P (K8s) | Platform | HPA/queue config + load test | RUNTIME · Ch.12 [S-081] | `RUNTIME-PENDING` |
| CFG-K8S-007 | Beat singleton, không HPA; plugin daemon CE singleton/SPOF/no-overlap requirement được risk-accept hoặc thay bằng supported option. | P (K8s) | Service owner | Risk decision + failure test | DESIGN · Ch.12 [S-032] | `DESIGN-PENDING` |
| CFG-K8S-008 | Startup/readiness/liveness probe có đúng semantics; functional canary nằm ngoài probe. | S/P (K8s) | Platform/SRE | Probe config + failure test | RUNTIME · Ch.12 [S-083] | `RUNTIME-PENDING` |
| CFG-K8S-009 | Resource request/limit, termination grace, preStop và rollout strategy dựa trên load/drain test. | S/P (K8s) | Platform | Load/drain evidence | RUNTIME · Ch.12 | `RUNTIME-PENDING` |
| CFG-K8S-010 | PDB, anti-affinity/topology spread và zone/node placement không vượt replica/quorum thực. | P (K8s) | Platform | Scheduling/PDB config + disruption test | RUNTIME · Ch.12 [S-082] | `RUNTIME-PENDING` |
| CFG-K8S-011 | Ingress/Gateway giữ route, SSE/WebSocket, body/timeout và plugin-hook policy của baseline. | S/P (K8s) | Platform/Network | Route tests + rendered config | RUNTIME · Ch.12 [S-085] | `RUNTIME-PENDING` |
| CFG-K8S-012 | NetworkPolicy default-deny và allowlist DNS/edge/state/provider hoạt động với CNI mục tiêu. | S/P (K8s) | Network/Security | Connectivity matrix test | RUNTIME · Ch.12/13 | `RUNTIME-PENDING` |
| CFG-K8S-013 | Secret encryption-at-rest/RBAC/namespace/service-account scope và runtime delivery được review. | S/P (K8s) | Security/Platform | RBAC/IAM + access test | RUNTIME · Ch.12 [S-084] | `RUNTIME-PENDING` |
| CFG-K8S-014 | Pod/container security context, capability, filesystem, hostPath/privileged exception và image policy đạt. | S/P (K8s) | Security | Policy report + negative deploy test | RUNTIME · Ch.12/13 | `RUNTIME-PENDING` |
| CFG-K8S-015 | PostgreSQL, Redis, vector và shared object/plugin storage có HA/backup/failover owner; StatefulSet không bị coi tự động là HA. | P (K8s) | Platform/Data | Dependency design + failure/restore tests | RUNTIME · Ch.12 [S-080] | `RUNTIME-PENDING` |
| CFG-K8S-016 | Node/zone drain, replica loss, metric loss, dependency failover và restore đạt SLO/RPO/RTO. | P (K8s) | SRE | Ch.12/15 test evidence | RUNTIME · Ch.12/15 | `RUNTIME-PENDING` |
| CFG-K8S-017 | Plugin daemon CE dùng `Recreate`/no-overlap strategy; rollout chứng minh tối đa một daemon active và hai chiều API ↔ daemon vẫn đúng auth sau recovery. | S/P (K8s) | Platform/Integration | Rendered strategy + Pod UID/timeline + invoke/callback test IDs | RUNTIME · Ch.12/13 | `RUNTIME-PENDING` |

## Security

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-SEC-001 | Data classification bao phủ prompt/response, conversation log, file, knowledge, embedding/vector, secret và backup. | D/S/P | Security/Data | Classification record | DESIGN · Ch.13/15 | `DESIGN-PENDING` |
| CFG-SEC-002 | Workspace/tenant model, built-in role, least privilege và edition limitation được ghi; không hứa granular RBAC nếu edition không có. | S/P | Security/App | Access matrix + edition evidence | RUNTIME · Ch.13 [S-017] | `RUNTIME-PENDING` |
| CFG-SEC-003 | Joiner/mover/leaver, break-glass, admin review và credential revoke đã test. | S/P | Security | IAM lifecycle evidence | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-SEC-004 | SSO/OAuth/SAML/SCIM claim chỉ được bật khi edition/artifact/version và negative path đã xác nhận. | Conditional | Security | Edition config + auth tests | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-SEC-005 | Threat model bao phủ public API/MCP/trigger/file, plugin/tool, model/provider, RAG, sandbox và observability export. | S/P | Security/App | Threat model + owner actions | DESIGN · Ch.13/14 | `DESIGN-PENDING` |
| CFG-SEC-006 | Prompt, retrieved content, tool output và file được xử lý là untrusted data, không phải authorization instruction. | D/S/P | App/Security | App tests + policy | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-SEC-007 | Plugin/tool/MCP credential scope, manifest permission, provenance/signature và downstream authorization đạt. | D/S/P | Security/App | Inventory + invocation/negative tests | RUNTIME · Ch.13 [S-016][S-031] | `RUNTIME-PENDING` |
| CFG-SEC-008 | Sandbox/plugin isolation, filesystem/network limit và SSRF control đã negative-test trên artifact thật. | S/P | Security/Platform | Isolation test IDs | RUNTIME · Ch.13 | `RUNTIME-PENDING` |
| CFG-SEC-009 | Encryption at rest/in transit, key ownership/rotation và data deletion/retention/legal-hold policy được chốt. | P | Security/Privacy | Policy + runtime verification | RUNTIME · Ch.13/15 | `RUNTIME-PENDING` |
| CFG-SEC-010 | Log/trace/export không chứa secret; prompt/response/PII có opt-in, redaction, ACL và retention. | D/S/P | Security/SRE | Redaction/ACL/retention tests | RUNTIME · Ch.13 [S-073] | `RUNTIME-PENDING` |
| CFG-SEC-011 | Third-party telemetry/provider data region, training/retention, DPA/license và subprocessor được duyệt. | Conditional | Privacy/Legal | Approval IDs + provider record | DESIGN · Ch.13/14 | `DESIGN-PENDING` |
| CFG-SEC-012 | Vulnerability/CVE/SBOM/image/plugin update process có owner, SLA, canary và rollback. | S/P | Security/Release | Policy + recent drill/change | RUNTIME · Ch.13/16 | `RUNTIME-PENDING` |
| CFG-SEC-013 | Private vulnerability reporting route theo Dify security policy được đưa vào incident runbook. | D/S/P | Security | Runbook link + tabletop | DESIGN · Ch.13/15 [S-078] | `DESIGN-PENDING` |
| CFG-SEC-014 | Security exception có scope, compensating control, approver, expiry và retest date. | D/S/P | Security | Exception register | DESIGN · Ch.13/16 | `DESIGN-PENDING` |

## Model providers

### Provider/model onboarding

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-MDL-001 | Integration pattern được ghi: native plugin, compatible gateway, self-host vLLM/Ollama hoặc provider-specific path. | D/S/P | AI Platform | Provider decision record | DESIGN · Ch.14 | `DESIGN-PENDING` |
| CFG-MDL-002 | Provider/plugin/serving image/model revision và endpoint schema được pin, truy nguyên được provenance. | D/S/P | AI Platform | Provider lock manifest | SOURCE · Ch.14 [S-065][S-087]–[S-094] | `SOURCE-PENDING` |
| CFG-MDL-003 | Credential alias/owner/scope/secret version/rotation/revoke và workspace role access được test; không lưu key. | D/S/P | AI Platform/Security | Redacted secret metadata + access test | RUNTIME · Ch.14 [S-071] | `RUNTIME-PENDING` |
| CFG-MDL-004 | Data classification, region, retention/training, DPA/license và provider allowlist được duyệt. | S/P | Privacy/Legal | Provider approval record | DESIGN · Ch.14 | `DESIGN-PENDING` |
| CFG-MDL-005 | DNS, route, firewall, TLS/CA, proxy và egress từ plugin runtime tới endpoint đạt. | D/S/P | Network/AI Platform | Connectivity/TLS evidence | RUNTIME · Ch.14 | `RUNTIME-PENDING` |
| CFG-MDL-006 | Base URL, served model ID, chat/completion mode và parameter mapping được ghi bằng request/response đã redact. | D/S/P | AI Platform | Mapping artifact + invoke ID | RUNTIME · Ch.14 | `RUNTIME-PENDING` |
| CFG-MDL-007 | Context/output limit và sampling parameter không vượt server/model capability; boundary tests đạt. | S/P | AI Platform/App | Boundary test results | RUNTIME · Ch.14 | `RUNTIME-PENDING` |
| CFG-MDL-008 | Blocking và streaming gồm terminal/usage/cancel/mid-stream error được test end-to-end. | D/S/P | AI Platform/App | Capability test IDs | RUNTIME · Ch.14 | `RUNTIME-PENDING` |
| CFG-MDL-009 | Tool calling/structured output/multimodal chỉ được bật sau positive, malformed và unsupported tests. | Conditional | AI Platform/App | Capability contract + tests | RUNTIME · Ch.14 [S-066][S-094] | `RUNTIME-PENDING` |
| CFG-MDL-010 | Timeout, bounded retry/backoff, rate limit/quota và partial-stream duplicate policy được chốt. | S/P | AI Platform/App | Failure test + policy | RUNTIME · Ch.14 [S-060] | `RUNTIME-PENDING` |
| CFG-MDL-011 | Credential round robin, endpoint load balancing và cross-model fallback được phân biệt, có policy/capability parity. | Conditional | AI Platform | LB/fallback test evidence | RUNTIME · Ch.14 [S-072] | `RUNTIME-PENDING` |
| CFG-MDL-012 | Managed cost/quota hoặc self-host capacity/GPU/queue/cold-start/replica recovery có budget và alert. | S/P | AI Platform/FinOps | Load/cost/alert evidence | RUNTIME · Ch.14 | `RUNTIME-PENDING` |
| CFG-MDL-013 | Dify run ID, provider/model/plugin/server request ID, latency/error/usage/cost được correlate mà không log key/PII. | S/P | AI Platform/SRE | Trace correlation + redaction test | RUNTIME · Ch.14 | `RUNTIME-PENDING` |
| CFG-MDL-014 | Provider/plugin/server/model/CA/credential canary và rollback/rotation rehearsal đạt. | P | AI Platform/Security | Rehearsal evidence | RUNTIME · Ch.14/16 | `RUNTIME-PENDING` |

### RAG, embedding và rerank

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-RAG-001 | Knowledge source owner, classification, retention/deletion và allowed environment được ghi. | D/S/P | Data owner | Dataset registry | DESIGN · Ch.13/14 | `DESIGN-PENDING` |
| CFG-RAG-002 | Embedding provider/model/revision/dimension và index/chunking config được pin cho từng dataset. | D/S/P | Data/RAG | Index manifest | CONFIG · Ch.14 [S-050] | `CONFIG-PENDING` |
| CFG-RAG-003 | Query dùng cùng vector space/model revision với index; không dùng cross-model fallback mù. | D/S/P | Data/RAG | Dimension/model checks + query test | RUNTIME · Ch.14 | `RUNTIME-PENDING` |
| CFG-RAG-004 | Rerank endpoint/model/top-N/threshold/modality khớp embedding và use case. | Conditional | Data/RAG | Rerank config + quality test | RUNTIME · Ch.14 [S-050] | `RUNTIME-PENDING` |
| CFG-RAG-005 | Vector auth/filter/search parity, backup hoặc rebuild path và recovery owner được xác nhận. | S/P | Data/RAG | Backend test + recovery decision | RUNTIME · Ch.12/15 | `RUNTIME-PENDING` |
| CFG-RAG-006 | Golden query set, expected document/citation và quality threshold được version hóa. | S/P | Data/App | Golden-set version + results | RUNTIME · Ch.14/15 | `RUNTIME-PENDING` |
| CFG-RAG-007 | Ingest/index worker queue, batch/input limit, provider quota/cost và full-corpus duration nằm trong capacity/RTO. | S/P | Data/SRE | Full-size load/reindex evidence | RUNTIME · Ch.14/15 | `RUNTIME-PENDING` |
| CFG-RAG-008 | Model/vector/chunking change có reindex, canary, cutover, rollback và old-index retention plan. | S/P | Data/RAG | Migration plan + rehearsal | RUNTIME · Ch.14/15 [S-056] | `RUNTIME-PENDING` |
| CFG-RAG-009 | Restore/rebuild xong phải chạy golden retrieval, không chỉ so collection/object count. | P | Data/App | Restore drill query results | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-RAG-010 | Knowledge data và vector/log export không bị coi là đã nằm trong DSL backup. | D/S/P | App/Data | Recovery inventory | CONFIG · Ch.15/16 [S-045] | `CONFIG-PENDING` |

## Operations và DR

### Observability, SLO, retention và capacity

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-OBS-001 | SLI/SLO/error-budget định nghĩa query, window, numerator/denominator, maintenance exclusion và owner. | P | Service owner/SRE | Signed SLO record | DESIGN · Ch.15 | `DESIGN-PENDING` |
| CFG-OBS-002 | Dashboard bao phủ edge/API, workflow/model, worker/queue, knowledge/vector, DB/Redis/storage, plugin và backup. | S/P | SRE | Dashboard version + screenshots/queries | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-OBS-003 | Alert có threshold/burn policy, on-call route, severity, runbook, dedupe và silence expiry. | S/P | SRE | Alert-fire/recovery test | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-OBS-004 | Synthetic suite có edge/API, queued task, workflow/model, retrieval và plugin/provider path. | S/P | SRE/App | Synthetic run IDs | RUNTIME · Ch.11/14/15 | `RUNTIME-PENDING` |
| CFG-OBS-005 | Log rotation/retention/backpressure/ACL và PII/prompt/secret redaction được test. | D/S/P | SRE/Security | Retention config + redaction test | RUNTIME · Ch.13/15 [S-073] | `RUNTIME-PENDING` |
| CFG-OBS-006 | External tracing/telemetry exporter có region, retention, failure behavior và egress approval. | Conditional | SRE/Privacy | Export config + outage/privacy test | RUNTIME · Ch.13/14 | `RUNTIME-PENDING` |
| CFG-OBS-007 | Backup age, checksum/replication, restore-drill age, WAL/archive và certificate/secret expiry có signal. | P | SRE | Alert tests | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-OBS-008 | Capacity baseline/forecast bao phủ request/concurrency/token, queue age, DB connection, storage/vector/Redis growth và provider quota. | S/P | SRE/AI/Data | Capacity model | DESIGN · Ch.14/15 | `DESIGN-PENDING` |
| CFG-OBS-009 | Load test gồm streaming, workflow dài, indexing, plugin/model call và backup IO; bottleneck/headroom được ghi. | S/P | SRE | Load profile + metrics | RUNTIME · Ch.14/15 | `RUNTIME-PENDING` |
| CFG-OBS-010 | Missing metrics hoặc observability outage không bị diễn giải thành healthy; có safe behavior và alert. | P | SRE | Telemetry failure test | RUNTIME · Ch.12/15 | `RUNTIME-PENDING` |

### Backup, restore, incident và disaster recovery

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-BKP-001 | RACI và on-call/escalation cho service, DB, storage/vector, Security, app/data và incident commander có tên thật. | P | Service owner | RACI/on-call record | DESIGN · Ch.15 | `DESIGN-PENDING` |
| CFG-BKP-002 | `RPO_service`, `RTO_service` và target theo DB/storage/vector/config/queue được business phê duyệt. | P | Service owner | Signed recovery record | DESIGN · Ch.15 | `DESIGN-PENDING` |
| CFG-BKP-003 | Recovery inventory bao phủ main/plugin DB, app/plugin storage, vector, Redis decision, config/secret/cert và release artifact. | S/P | SRE/DBA/Data | Recovery inventory | CONFIG · Ch.15 | `CONFIG-PENDING` |
| CFG-BKP-004 | Backup tạo common recovery-point ID và ghi writer-freeze/snapshot coordination; không gọi backup rời rạc là atomic. | S/P | SRE/DBA | Recovery manifest | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-BKP-005 | PostgreSQL main/plugin DB và global object có dump hoặc base+WAL/PITR phù hợp target. | S/P | DBA | Backup/PITR metadata + checks | RUNTIME · Ch.15 [S-095]–[S-099] | `RUNTIME-PENDING` |
| CFG-BKP-006 | App/object và plugin storage có version/snapshot/checksum, encryption và restore mapping. | S/P | Storage/Platform | Artifact IDs + checksums | RUNTIME · Ch.15 [S-102] | `RUNTIME-PENDING` |
| CFG-BKP-007 | Vector có native backup đã test hoặc rebuild manifest/full-corpus RTO; đúng engine/version/module. | S/P | Data/RAG | Backup/rebuild evidence | RUNTIME · Ch.15 [S-101] | `RUNTIME-PENDING` |
| CFG-BKP-008 | Redis strategy là clean-and-reconcile hoặc tested RDB/AOF; duplicate/replay/stale-state test có kết quả. | S/P | Platform/App | Decision + failure tests | RUNTIME · Ch.15 [S-100] | `RUNTIME-PENDING` |
| CFG-BKP-009 | Config/secret/cert backup lưu reference/version, không plaintext trong evidence; break-glass decrypt đạt. | P | Security | Version IDs + access drill | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-BKP-010 | Backup được mã hóa, immutable/offsite, checksum/replication verified và retention/deletion/legal hold đồng bộ. | P | Security/SRE | Vault policy + verification | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-BKP-011 | Restore drill dùng recovery point thực trên môi trường cô lập và đạt data/functional/negative-side-effect suite. | P | SRE/App/Data | Restore evidence package | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-BKP-012 | Observed RPO/RTO được đo từ declare tới full acceptance; vượt target được ghi là failed drill. | P | Service owner/SRE | Drill timeline + sign-off | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-BKP-013 | Upgrade có pre-change recovery point đã restore-test; migration/backfill và restore-based rollback đã rehearsal. | P | Release/DBA | Upgrade/rollback evidence | RUNTIME · Ch.15/16 [S-001] | `RUNTIME-PENDING` |
| CFG-BKP-014 | DR target có artifact, capacity, network/DNS/TLS, KMS/secret và dependency compatibility ở failure domain khác. | P | SRE/Platform | DR readiness manifest | DESIGN · Ch.15 | `DESIGN-PENDING` |
| CFG-BKP-015 | Failover fence old primary trước target write; DNS cutover, scheduler/side effect và split-brain test đạt. | P | Incident commander | DR exercise timeline | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-BKP-016 | Failback là change riêng, resync từ source of truth mới, có recovery point/reconciliation/sign-off. | P | SRE/DBA | Failback rehearsal | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-BKP-017 | Incident severity, IC/technical/comms/scribe role, change freeze, evidence preservation và update cadence đã tabletop. | S/P | Incident commander | Tabletop evidence/PIR actions | RUNTIME · Ch.15 | `RUNTIME-PENDING` |
| CFG-BKP-018 | Evidence package có version/digest/config hash/RPID/test expected-actual/timestamp/reviewer và không lộ secret/PII. | S/P | SRE/Release | Evidence-index audit | RUNTIME · Ch.15/16 | `RUNTIME-PENDING` |

## Release

### CI/CD, IaC, promotion và evidence

| ID | Control cần review | Env | Owner | Evidence tối thiểu | Cơ sở/chương | Trạng thái template |
|---|---|---|---|---|---|---|
| CFG-REL-001 | CI/CD runner trust boundary, toolchain, identity, network và patch ownership được review. | D/S/P | Release/Security | Runner architecture + inventory | DESIGN · Ch.16 | `DESIGN-PENDING` |
| CFG-REL-002 | Third-party workflow/action/module reference được pin full commit/digest và có minimal permission. | D/S/P | Release/Security | Dependency lock + permission diff | CONFIG · Ch.16 [S-103] | `CONFIG-PENDING` |
| CFG-REL-003 | Build/ingest identity tách deploy identity; production deploy không có quyền sửa source/build image. | S/P | Security/Release | IAM policy + negative access test | RUNTIME · Ch.16 | `RUNTIME-PENDING` |
| CFG-REL-004 | PR gate validate syntax/schema/duplicate key, secret scan, image/env/port/volume/permission/migration diff. | D/S/P | Release | CI check results | RUNTIME · Ch.16 | `RUNTIME-PENDING` |
| CFG-REL-005 | Compose/Kubernetes render và policy checks dùng tool version đã khóa; output nhạy cảm không lưu công khai. | D/S/P | Platform/Release | CI logs + rendered hash | RUNTIME · Ch.16 [S-046] | `RUNTIME-PENDING` |
| CFG-REL-006 | Release bundle khóa source/docs/plugin/image digest, manifest hash, config schema/ref, DSL/dependency, migration và evidence. | S/P | Release | Signed release manifest | CONFIG · Ch.16 | `CONFIG-PENDING` |
| CFG-REL-007 | Upstream image được mirror/scan/SBOM/attest/sign hoặc custom build có reproducible inputs và provenance. | S/P | Release/Security | Artifact verification record | RUNTIME · Ch.16 [S-104][S-105] | `RUNTIME-PENDING` |
| CFG-REL-008 | Base + environment overlay chỉ khác domain/resource/replica/secret reference/policy có chủ đích; drift bị detect. | D/S/P | Platform | Overlay diff + drift report | RUNTIME · Ch.16 | `RUNTIME-PENDING` |
| CFG-REL-009 | DSL không chứa secret/plain endpoint trái policy; dependency manifest và contract tests đạt ở staging. | S/P | App owner | DSL scan/hash + test IDs | RUNTIME · Ch.16 [S-045] | `RUNTIME-PENDING` |
| CFG-REL-010 | Dev chạy static/unit/contract phù hợp; không dùng production secret/data. | D | App/Release | Test report + secret/data proof | RUNTIME · Ch.16 | `RUNTIME-PENDING` |
| CFG-REL-011 | Staging deploy đúng production-candidate digest/config schema và chạy integration/security/provider/RAG/failure tests. | S | Release/QA | Staging evidence index | RUNTIME · Ch.11–16 | `RUNTIME-PENDING` |
| CFG-REL-012 | Production approval yêu cầu đúng owner: Platform, Security, DBA/Data, App, Operations và Privacy/Legal khi áp dụng. | P | Release approver | Approval record | DESIGN · Ch.16 | `DESIGN-PENDING` |
| CFG-REL-013 | Mỗi staging/production có recovery point riêng trước migration; atomic environment lock, singleton migration/backfill rồi mới rollout long-lived service với migration disabled. | S/P | Release/DBA | Per-environment recovery ID + lock/fencing + Job/command/DB revision logs | RUNTIME · Ch.12/15/16 [S-001][S-013] | `RUNTIME-PENDING` |
| CFG-REL-014 | Production dùng cùng digest staging nhưng lock/recovery/migration evidence riêng; rollout có readiness/drain và không mở side effect trước smoke gate. | P | Release/SRE | Digest compare + production lock/RPID + rollout timeline | RUNTIME · Ch.12/16 | `RUNTIME-PENDING` |
| CFG-REL-015 | Post-deploy smoke bao phủ auth/API, queued task, workflow/model, retrieval, plugin, file và SLO watch. | S/P | SRE/App | Smoke IDs + observation window | RUNTIME · Ch.11/14/15 | `RUNTIME-PENDING` |
| CFG-REL-016 | Rollback/roll-forward decision window, authority và trigger metric được định nghĩa; schema change dùng restore rehearsal. | P | Release/Service owner | Rollback decision + drill | RUNTIME · Ch.15/16 | `RUNTIME-PENDING` |
| CFG-REL-017 | Drift detection so actual với signed rendered manifest; reconciliation không overwrite state/secret ngoài approval. | S/P | Platform | Drift/reconcile test | RUNTIME · Ch.16 | `RUNTIME-PENDING` |
| CFG-REL-018 | Evidence store có retention, immutability, ACL, redaction và link từ release/incident; không lưu secret/dump thường. | S/P | Release/Security | Evidence-store audit | RUNTIME · Ch.15/16 | `RUNTIME-PENDING` |
| CFG-REL-019 | Promotion dừng khi item critical còn pending/fail hoặc risk acceptance hết hạn; không bypass bằng manual rerun không audit. | P | Release approver | Gate policy + negative test | RUNTIME · Ch.16 | `RUNTIME-PENDING` |
| CFG-REL-020 | Sau release, baseline/config/evidence index/change log và action từ incident/drill được cập nhật có owner/deadline. | S/P | Release/Service owner | Closed change + action register | RUNTIME · Ch.15/16 | `RUNTIME-PENDING` |

### Crosswalk test suite → control/evidence

Các matrix `SEC-*`, `HA-*` và `CI-*` ghi trực tiếp accountable owner, CFG control và evidence bắt buộc tại Chương 13, 12 và 16. Matrix `OPS-*` ở Chương 15 dùng RACI chi tiết của chương; crosswalk tối thiểu dưới đây ngăn test ID bị tách khỏi control/evidence khi đưa vào evidence index.

| Test ID | CFG control chính | Accountable owner | Evidence anchor tối thiểu |
|---|---|---|---|
| OPS-01–02 | CFG-OBS-002–004 | Service owner/SRE | Alert timeline, SLI query, queued synthetic/task IDs và recovery result |
| OPS-03–05 | CFG-BKP-005/011/012 | DBA | Dump/PITR metadata, restore logs, DB checks và observed RPO/RTO |
| OPS-06–08 | CFG-BKP-006/007/011/012 | Storage/Data owner | Object/vector backup hoặc rebuild IDs, checksums, golden retrieval và duration |
| OPS-09–10 | CFG-BKP-008 | Platform/App owner | Redis decision, key-class inventory, task/downstream replay audit |
| OPS-11–12 | CFG-BKP-003–012 | Service owner/SRE/Security | Full recovery manifest, secret version IDs, acceptance IDs và sign-off |
| OPS-13–15 | CFG-BKP-013, CFG-REL-013/016 | Release/DBA | Lock/migration/backfill logs, schema head, RPID và rollback/restore evidence |
| OPS-16–18 | CFG-BKP-014–016 | Incident commander/SRE | DR timeline, fencing proof, DNS/write audit và RPO/RTO result |
| OPS-19 | CFG-OBS-008/009 | SRE | Load profile, capacity/backup metrics, bottleneck và updated forecast |
| OPS-20 | CFG-BKP-010 | Security/SRE | Credential revoke/rotate timeline, access audit và backup integrity check |
| OPS-21 | CFG-RUN-010, CFG-BKP-011 | App/Security | Network/audit evidence chứng minh không có production side effect |
| OPS-22 | CFG-BKP-017 | Incident commander | Tabletop timeline, role/comms evidence và PIR actions có owner/deadline |

### Final sign-off summary

| Gate | Điều kiện ký duyệt | Approver | Kết quả template |
|---|---|---|---|
| Dev ready | Baseline/config/secret isolation/static smoke đạt; không có production secret/data. | Dev environment owner | `PENDING` |
| Staging ready | Cùng release candidate, production-like render, provider/RAG/security/integration và failure tests đạt. | Platform + App + Security | `PENDING` |
| Production change ready | Artifact immutable, approval, recovery point, migration/rollback, capacity/SLO và evidence đạt. | Release approver + Service owner | `PENDING` |
| Production operational ready | Restore/DR, on-call/incident, observability/retention và RPO/RTO drill đạt. | Service owner + SRE + DBA/Data + Security | `PENDING` |

Phụ lục này không bổ sung nguồn mới. Các source ID được tái sử dụng từ Chương 11–16; nếu baseline hoặc chapter thay đổi, owner của chapter phải review lại các control liên quan trước lần release kế tiếp.
