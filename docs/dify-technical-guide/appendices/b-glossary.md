# B. Glossary

> **Version áp dụng:** Dify Community Edition `1.15.0`  
> **Ngày kiểm chứng:** `2026-07-16`  
> **Trạng thái xác minh:** `Official-source verified`; editorial review pending  
> **Reviewer:** Technical/editorial review pending

## Mục tiêu

Phụ lục này chuẩn hóa thuật ngữ dùng xuyên suốt bộ tài liệu. Khi UI, source, tài liệu Dify và cách gọi nội bộ khác nhau, ưu tiên tên kỹ thuật đúng baseline, ghi alias một lần và không tự hợp nhất các khái niệm có ranh giới runtime khác nhau.

## Quy ước thuật ngữ

- Giữ nguyên tên product/runtime/resource trong code font, ví dụ `api`, `web`, `worker`, `plugin_daemon`.
- Lần đầu dùng từ tiếng Anh chuyên ngành, có thể thêm giải thích tiếng Việt; sau đó dùng một thuật ngữ nhất quán.
- “Frontend” không đồng nghĩa “API”; `web` và `api` là hai runtime boundary riêng.
- “Workflow” viết hoa chỉ app type Dify; “workflow” viết thường có thể chỉ quy trình nói chung.
- “Knowledge” là capability/object trong Dify; “RAG” là mẫu pipeline rộng hơn gồm cả ingestion, retrieval, context và generation.
- “Citation” được dịch là dẫn nguồn/provenance; không gọi là bằng chứng câu trả lời đúng.
- “Credential load balancing” chỉ rotation giữa credential của cùng provider/model/type trong baseline; không gọi là cross-model fallback. [S-071][S-072]
- “Community”, “Enterprise” và “Cloud” là edition/deployment offering khác nhau; feature phải gắn nguồn, version/ngày truy cập và entitlement caveat.
- Các nhãn xác minh (`Official-source verified`, `Config validated`, `Design reviewed`, `RUNTIME-PENDING`, `RUNTIME-VALIDATED`) mô tả mức evidence, không mô tả độ quan trọng.
- Tài liệu workspace có chỗ dùng tên role “Normal” và chỗ UI có thể hiện “Member”; cho đến khi runtime đối chiếu, tài liệu dùng “Member/Normal” và giữ gap G-011. [S-017]

## Thuật ngữ

### Platform, runtime và application

| Thuật ngữ | Định nghĩa dùng trong tài liệu | Không nên hiểu là |
|---|---|---|
| Dify | Nền tảng xây dựng/vận hành ứng dụng LLM gồm workflow, RAG, Agent, model management, plugin, observability và API. [S-003] | Một model, vector database hoặc system of record. |
| Workspace | Ranh giới tổ chức tài nguyên/người dùng trong Dify. Community default có một workspace; multi-workspace là edition-sensitive. [S-028] | Tenant isolation đã được chứng minh cho mọi mô hình SaaS. |
| App | Một ứng dụng Dify có cấu hình, graph/prompt/model và delivery surface. | Toàn bộ Dify instance. |
| Workflow | App/graph hướng tác vụ, có start/end và luồng node xác định; có thể chạy blocking/streaming tùy API path. [S-040] | Mọi background job Celery. |
| Chatflow | App/graph hội thoại với User Input/Answer và session interaction. [S-040] | Agent app mặc định. |
| Agent app | Application surface dùng strategy/tool loop để giải quyết task động. [S-058] | Mọi workflow có một Agent node. |
| Node | Đơn vị xử lý trong graph, có input/output/error behavior. | Process/container riêng. |
| DSL | Artifact YAML export/import cho app configuration/graph; có giới hạn về secret/data/API key/log. [S-045] | Full environment backup hoặc IaC cho hạ tầng. |
| Run | Một lần thực thi app/workflow/graph, có status, timing và node evidence. | Một deployment/release. |
| Debug run | Lần chạy trong builder/debug context, xem qua Run History. [S-074] | Live-user conversation log. |
| Published app | Phiên bản/app surface đã publish cho user/API. | Artifact rollback đã tự động version đầy đủ. |
| Blocking response | Caller giữ request đến khi có kết quả hoàn chỉnh. | Luôn chạy trong worker. |
| Streaming response | Kết quả được gửi dần theo event/chunk; Workflow/Chatflow streaming baseline dùng queued worker + Redis event path. [S-034][S-035][S-036][S-037] | WebSocket cho collaboration. |
| `web` | Frontend runtime/image riêng. | Backend API server. |
| `api` | Backend/control-plane và inline execution runtime. | Tất cả job bất đồng bộ. |
| `api_websocket` | Service WebSocket cho collaboration trong default profile. | Streaming model response path nói chung. |
| `worker` | Celery consumer xử lý queue nền/queued execution. | Scheduler phát task định kỳ. |
| `worker_beat` | Celery Beat/scheduled-task producer; singleton semantics được giữ bảo thủ khi chưa có leader-election evidence. | Worker có thể scale ngang tùy ý. |
| `plugin_daemon` | Runtime quản lý/cài/chạy plugin và là đường dispatch model plugin trong baseline. [S-032][S-038] | Chỉ Marketplace UI. |
| `sandbox` | Service thực thi code trong Dify baseline. | Security boundary tuyệt đối nếu chưa threat-test. |
| `ssrf_proxy` | Proxy Squid cho các outbound path được cấu hình đi qua nó. | Bằng chứng mọi egress đều bị chặn/ép proxy. |

### Workflow, RAG, Agent và integration

| Thuật ngữ | Định nghĩa dùng trong tài liệu | Caveat |
|---|---|---|
| Visual orchestration | Biểu diễn graph/node/branch bằng UI. | UI dễ dùng không loại bỏ versioning, test và review. |
| Error branch | Nhánh xử lý lỗi explicit của node hỗ trợ cơ chế này. [S-042] | Không tự bảo đảm retry/idempotency. |
| Retry | Thực hiện lại operation sau lỗi theo policy. | Có thể tạo duplicate side effect nếu thiếu idempotency. |
| Knowledge | Tập dữ liệu/tài liệu được ingest và dùng cho retrieval trong Dify. [S-048] | Authorization system độc lập. |
| Knowledge pipeline | Chuỗi source/extract/transform/chunk/index/test/publish. [S-049] | Chỉ bước embedding. |
| Document | Đơn vị tài liệu/source trong knowledge base. | Luôn tương ứng một file vật lý. |
| Segment/chunk | Đoạn nội dung dùng để index/retrieve; cấu trúc có thể là General, Parent-child hoặc Q&A theo path. [S-049] | Một kích thước tối ưu chung. |
| Embedding | Biểu diễn nội dung/query thành vector để similarity retrieval. | Cùng dimension/model đồng nghĩa cùng quality. |
| Vector store/database | Backend lưu/tìm vector index. | Source of truth duy nhất cho document lifecycle. |
| Retrieval | Chọn đoạn liên quan cho query bằng keyword/vector/hybrid và filter/rerank tùy config. [S-050][S-051] | Generation/câu trả lời cuối. |
| Rerank | Xếp hạng lại candidate bằng model/strategy bổ sung. | Luôn cải thiện quality hoặc miễn phí latency. |
| Metadata filter | Lọc candidate theo metadata. | Authorization boundary nếu chưa có negative test. |
| Citation | Metadata/dẫn nguồn gắn output về retrieved source. | Proof rằng mọi claim được source hỗ trợ. |
| Golden set | Bộ input có expected behavior/passage/rubric dùng đánh giá. | Một vài prompt demo được chọn sau khi thấy kết quả. |
| Agent | Cơ chế dùng model để lựa chọn/lặp tool hoặc reasoning step trong budget. | Quyền tự động thực hiện mọi business action. |
| Function Calling | Strategy/model interaction tạo structured tool call. [S-057][S-062] | Correct tool selection hoặc authorization. |
| ReAct | Pattern Reason + Act/Observation theo loop/parser. [S-057][S-063] | Chain-of-thought phải được log/công khai. |
| Tool | Capability callable bởi workflow/Agent, có schema/config và credential khi downstream cần authentication. [S-059] | Trusted code/data mặc định. |
| Tool credential | Credential workspace/tool dùng để gọi downstream. | End-user delegated authority. |
| Maximum iterations | Giới hạn số vòng Agent. | Total timeout, token/cost cap hoặc kill switch hoàn chỉnh. |
| Memory | Context/history được đưa lại cho model theo application path. | Persistent business memory có lifecycle/ACL mặc định. |
| Prompt injection | Untrusted instruction cố thay đổi hành vi/policy của model/app. | Chỉ đến từ user; document/tool output cũng có thể là nguồn. |
| MCP client | Dify kết nối/call MCP server qua transport/auth được hỗ trợ. [S-014] | Mọi transport của MCP spec. |
| MCP server | Dify publish eligible application thành MCP endpoint; riêng Workflow phải bắt đầu bằng User Input, không phải trigger. [S-015][S-026] | Mọi app/workflow/trigger tự động đủ điều kiện. |
| Plugin | Gói mở rộng model/tool/agent strategy/extension/datasource/trigger. [S-029][S-030] | Được sandbox/isolate đầy đủ chỉ vì manifest có permission. |

### Model, provider và quality

| Thuật ngữ | Định nghĩa dùng trong tài liệu | Caveat |
|---|---|---|
| Model provider | Integration/plugin cung cấp model type, credential, endpoint và capability schema. [S-065][S-069] | Một model cụ thể. |
| LLM | Large Language Model dùng text/chat/reasoning/generation. | Luôn hỗ trợ tool/structured/vision/streaming giống nhau. |
| Text embedding model | Model tạo vector cho text/document/query. | Có thể đổi in-place mà không reindex. |
| Rerank model | Model chấm/xếp lại candidate retrieval. | Fallback an toàn qua model khác không cần evaluate. |
| Speech/vision model | Model cho ASR/TTS/vision tùy provider/plugin capability. | Có trong mọi provider baseline. |
| OpenAI-compatible | Endpoint implement một phần contract tương thích OpenAI. [S-091][S-093] | Chứng nhận tương thích toàn bộ endpoint/parameter/behavior. |
| External model API | Serving do provider ngoài vận hành, Dify gọi qua network. | Không có data egress/residency/quota risk. |
| Self-host model | Model serving do tổ chức vận hành, ví dụ Ollama/vLLM. | Miễn phí hoặc tự động HA/secure. |
| Credential load balancing | Round-robin/cooldown giữa credential của cùng provider/model/type trong Dify source path. [S-071][S-072] | Fallback sang model/provider khác. |
| Alternative-model fallback | Chuyển sang model khác khi node/provider lỗi theo app config. [S-066] | Output schema/quality/cost tương đương mà không test. |
| Structured output | Output theo schema/format khai báo. | Semantic correctness. |
| Conformance test | Bộ test chứng minh endpoint/model đáp ứng capability/parameter/error contract cần dùng. | Benchmark chất lượng business đầy đủ. |
| Groundedness | Mức câu trả lời được hỗ trợ bởi context/source đã cung cấp. | Factual correctness tuyệt đối ngoài corpus. |
| Hallucination | Output model không được hỗ trợ hoặc sai so với ground-truth/context. | Một lỗi có thể loại bỏ hoàn toàn bằng prompt. |

### Deployment, operations và delivery

| Thuật ngữ | Định nghĩa dùng trong tài liệu | Caveat |
|---|---|---|
| Baseline | Bộ version/commit/config/source được khóa làm đối tượng tài liệu. | Latest tại mọi thời điểm. |
| Artifact | File/image/manifest/DSL/bundle được build hoặc promote. | Source branch chưa khóa. |
| Image tag | Tên/version label có thể bị tái trỏ tùy registry/publisher. | Nội dung immutable. |
| Image digest | SHA-256 content identifier dùng khóa image artifact. [S-105] | Bản vá bảo mật tự động. |
| Release bundle | Bộ commit, digest, rendered manifest, config schema, DSL/dependency và evidence được promote cùng nhau. | Một image tag. |
| Infrastructure as Code | Hạ tầng/config non-secret được khai báo, version và review như code. | Lưu secret plaintext trong Git. |
| GitOps | Controller reconcile desired state từ repository/artifact. | Tự giải quyết migration/backup/approval. |
| Compose profile | Cơ chế chọn service group trong Docker Compose; default Dify bật PostgreSQL, Weaviate và collaboration. [S-006] | Mọi backend cùng chạy đồng thời. |
| Deployment | Kubernetes controller thường dùng cho stateless replica/rollout. [S-079] | Dify release bundle hoặc database HA. |
| StatefulSet | Kubernetes controller cho stable identity/storage/order. [S-080] | Database/vector replication tự động. |
| Job | Kubernetes one-off completion workload; dùng làm migration pattern trong reference design. [S-086] | Bằng chứng migration idempotent/reversible. |
| HPA | Horizontal Pod Autoscaler theo resource/custom/external metric. [S-081] | Capacity/SLO guarantee. |
| PDB | PodDisruptionBudget điều tiết voluntary disruption. [S-082] | Bảo vệ node crash, dependency outage hoặc mọi involuntary failure. |
| Readiness probe | Tín hiệu pod có nên nhận traffic. [S-083] | Full business-path health. |
| Liveness probe | Tín hiệu container cần restart. [S-083] | Dependency readiness. |
| Startup probe | Cho phép ứng dụng khởi động chậm trước khi liveness/readiness áp dụng. [S-083] | Migration controller. |
| HA | High Availability: thiết kế giảm downtime qua redundancy/failure-domain/control đã test. | Có nhiều pod là đủ. |
| SPOF | Single Point of Failure. | Mọi singleton đều có cùng impact; phải xét recovery/control. |
| SLI | Chỉ số đo service behavior, ví dụ successful request ratio/p95. | Mục tiêu cam kết. |
| SLO | Mục tiêu nội bộ cho SLI trong cửa sổ thời gian. | Hợp đồng pháp lý với khách hàng. |
| SLA | Cam kết dịch vụ/hợp đồng, có thể kèm hậu quả. | Dashboard threshold nội bộ. |
| RPO | Recovery Point Objective: mức mất dữ liệu tối đa mục tiêu theo thời gian. | Backup frequency duy nhất. |
| RTO | Recovery Time Objective: thời gian khôi phục mục tiêu. | Kết quả DR đã chứng minh nếu chưa drill. |
| DR | Disaster Recovery: people/process/technology để khôi phục sau thảm họa. | Chỉ có backup copy. |
| PITR | Point-in-Time Recovery bằng base backup + WAL/recovery target trong PostgreSQL. [S-098] | Cross-store Dify recovery point. |
| Quiesce | Tạm chặn/ổn định write/queue để tạo consistency boundary. | Dify official API đã xác minh; hiện là design gap. |
| Idempotency | Cùng logical request lặp lại không tạo side effect ngoài một kết quả đã định. | Exactly-once transport. |
| Correlation ID | ID nối request, run, queue/tool/provider/trace evidence. | Lý do lưu toàn bộ prompt/data nhạy cảm. |
| Drift | Live state khác desired/release state đã version hóa. | Mọi khác biệt đều nên tự động overwrite mà không review. |
| SBOM | Software Bill of Materials: inventory component/dependency của artifact. | Chứng nhận artifact an toàn. |
| Artifact attestation | Signed provenance statement nối artifact với build/source/workflow identity. [S-104] | Vulnerability scan hoặc security guarantee. |

### Nhãn xác minh

| Nhãn | Ý nghĩa |
|---|---|
| `Official-source verified` | Claim đã đối chiếu nguồn chính thức/version phù hợp. |
| `Config validated` | Config đã parse/render/static-check nhưng chưa chạy full system. |
| `Design reviewed` | Kiến trúc/procedure đã review logic, chưa có runtime evidence đầy đủ. |
| `RUNTIME-VALIDATED` | Procedure đã chạy end-to-end trong môi trường đại diện và có expected/actual evidence. |
| `Requires Legal confirmation` | Exact text/evidence sẵn sàng nhưng kết luận applicability phải do Legal. |
| `RUNTIME-PENDING` | Test/command được mô tả nhưng chưa thực thi trong lab hiện tại. |
| Gap | Khoảng trống evidence/decision có owner và hành động đóng. |
| Hard gate | Điều kiện bắt buộc; không được bù bằng điểm cao ở metric khác. |

## Từ viết tắt

| Viết tắt | Viết đầy đủ | Nghĩa trong tài liệu |
|---|---|---|
| AI | Artificial Intelligence | Trí tuệ nhân tạo. |
| API | Application Programming Interface | Giao diện machine-to-machine; không đồng nhất với Dify console API. |
| ASR | Automatic Speech Recognition | Chuyển giọng nói thành văn bản. |
| AZ | Availability Zone | Failure domain hạ tầng. |
| BaaS | Backend-as-a-Service | Trong tài liệu: AI backend capability cho consumer khác. |
| CA | Certificate Authority | Nguồn tin cậy chứng thư TLS. |
| CD | Continuous Delivery/Deployment | Promotion/deploy automation theo gate. |
| CI | Continuous Integration | Build/static/test/policy automation. |
| CNI | Container Network Interface | Network plugin Kubernetes. |
| CSI | Container Storage Interface | Storage driver Kubernetes. |
| CSP | Content Security Policy | Browser content policy. |
| DPA | Data Processing Agreement | Thỏa thuận xử lý dữ liệu với provider. |
| DR | Disaster Recovery | Khôi phục thảm họa. |
| GPU | Graphics Processing Unit | Tài nguyên tăng tốc model serving. |
| HA | High Availability | Tính sẵn sàng cao. |
| HPA | Horizontal Pod Autoscaler | Autoscaler workload Kubernetes. |
| IaC | Infrastructure as Code | Hạ tầng khai báo/version hóa. |
| KMS | Key Management Service | Quản lý khóa mã hóa. |
| LLM | Large Language Model | Mô hình ngôn ngữ lớn. |
| LLMOps | LLM Operations | Vận hành/evaluation/observability ứng dụng LLM. |
| MCP | Model Context Protocol | Protocol tích hợp tool/context; Dify có client/server surface. |
| MTTR | Mean Time to Restore/Recover/Repair | Phải ghi rõ biến thể được dùng trong SLO. |
| OIDC | OpenID Connect | Identity federation protocol; entitlement Dify phải xác minh riêng. |
| OTLP | OpenTelemetry Protocol | Protocol export telemetry. |
| PDB | PodDisruptionBudget | Kubernetes voluntary-disruption budget. |
| PII | Personally Identifiable Information | Dữ liệu nhận diện cá nhân. |
| PITR | Point-in-Time Recovery | Khôi phục PostgreSQL về thời điểm mục tiêu. |
| POC | Proof of Concept | Thử nghiệm feasibility/value trên lát cắt hẹp. |
| RAG | Retrieval-Augmented Generation | Generation được bổ sung context qua retrieval. |
| RBAC | Role-Based Access Control | Phân quyền theo role; built-in/fine-grained khác edition. |
| RPO | Recovery Point Objective | Mục tiêu điểm dữ liệu khôi phục. |
| RTO | Recovery Time Objective | Mục tiêu thời gian khôi phục. |
| SBOM | Software Bill of Materials | Danh mục component/dependency. |
| SIEM | Security Information and Event Management | Thu thập/phân tích security events. |
| SLA | Service Level Agreement | Cam kết mức dịch vụ. |
| SLI | Service Level Indicator | Chỉ số mức dịch vụ. |
| SLO | Service Level Objective | Mục tiêu mức dịch vụ. |
| SPOF | Single Point of Failure | Điểm lỗi đơn. |
| SSO | Single Sign-On | Đăng nhập liên kết; capability/edition cần xác minh. |
| SSRF | Server-Side Request Forgery | Lạm dụng server thực hiện request ngoài ý muốn. |
| TLS | Transport Layer Security | Mã hóa/xác thực kênh truyền. |
| TTS | Text-to-Speech | Chuyển văn bản thành giọng nói. |
| WAL | Write-Ahead Log | Log nền cho PostgreSQL recovery/PITR. |
| WAF | Web Application Firewall | Control tại edge HTTP. |

## Nguồn tham khảo

- [S-003] Dify README tại tag `1.15.0`: platform positioning và core capabilities.
- [S-005] Docker Compose tại tag `1.15.0`: service/runtime naming.
- [S-006] `.env.example` tại tag `1.15.0`: profile và configuration terminology.
- [S-014][S-015][S-026] MCP client/server và eligible workflow terminology.
- [S-017][S-028] Workspace và role terminology/edition caveat.
- [S-029][S-030][S-032][S-038] Plugin categories, daemon và model dispatch.
- [S-034]–[S-037] Inline/queued/streaming execution paths.
- [S-040][S-042][S-045] Workflow/Chatflow/error/DSL terminology.
- [S-048]–[S-051][S-055][S-056] Knowledge, chunk, retrieval, citation và vector terminology.
- [S-057]–[S-063] Agent, tool, Function Calling và ReAct terminology.
- [S-065][S-066][S-069][S-071][S-072] Model/provider/credential/fallback terminology.
- [S-073][S-074] Logs, Run History và evidence boundary.
- [S-079]–[S-086] Kubernetes workload/autoscaling/disruption/probe terminology.
- [S-091][S-093] “OpenAI-compatible” provider terminology.
- [S-098] PostgreSQL PITR terminology.
- [S-104][S-105] Artifact attestation và image digest terminology.
