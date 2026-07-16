# A. So sánh nhanh

> **Version áp dụng:** Dify Community `1.15.0 @ 3aa26fb…`; các lựa chọn khác theo official current docs tại ngày truy cập  
> **Ngày kiểm chứng:** `2026-07-16`  
> **Trạng thái xác minh:** `Official-source verified` + `Design reviewed`; chưa có benchmark chéo sản phẩm (`RUNTIME-PENDING`)  
> **Reviewer:** Enterprise Architecture, AI Engineering, Integration Platform, Security và Procurement review pending

## Mục tiêu

Phụ lục này giúp đội kiến trúc tạo **shortlist**, không chọn một “công cụ tốt nhất”. Kết quả cần làm rõ ba câu hỏi:

- Bài toán cần một visual AI application platform, một workflow-automation platform hay một code framework/runtime?
- Đội nào sở hữu application lifecycle, state, API/UI, vận hành và governance?
- Candidate nào đáng đưa vào PoC cùng một thin-slice scenario trước khi quyết định?

Các công cụ có thể cùng xuất hiện trong một kiến trúc. Ví dụ, n8n có thể điều phối quy trình nghiệp vụ gọi một AI application; LangChain hoặc LangGraph có thể triển khai custom service đứng sau API. Vì vậy bảng không giả định năm lựa chọn loại trừ lẫn nhau.

## Phạm vi so sánh

- **Dify:** baseline chính xác `1.15.0`, dùng source và deployment artifact đã pin trong tài liệu này.
- **Flowise, n8n, LangChain, LangGraph:** official current docs được truy cập ngày `2026-07-16`; chưa pin một release để triển khai.
- So sánh ở mức **center of gravity**: abstraction chính, deployment/ownership, RAG/agent/integration, UI/API, state/operations, governance và skill cần có.
- Không so sánh giá, benchmark latency/quality, số lượng connector, security certification, license hoặc feature entitlement theo plan. Các mục đó cần workstream Procurement, Legal và Security riêng.
- Không coi một feature được liệt kê trong docs là bằng chứng production readiness trên topology của tổ chức.

Ba nhóm dùng để đọc bảng:

1. **Visual AI application platform — Dify, Flowise:** product surface tập trung vào xây dựng và phát hành ứng dụng/flow AI.
2. **Workflow automation — n8n:** product surface tập trung vào trigger, dữ liệu và tích hợp quy trình nghiệp vụ; AI là một nhóm capability trong workflow.
3. **Code framework/runtime — LangChain, LangGraph:** dependency được nhúng vào application code; đội phát triển sở hữu phần lớn API/UI, deployment và control plane. LangChain cung cấp agent harness và integration abstractions ở mức cao hơn; LangGraph tập trung vào orchestration có state ở mức thấp hơn. [S-115][S-117]

## Tiêu chí

- **Deployment:** cloud/self-host/package, topology chính và phần hạ tầng đội nội bộ phải sở hữu.
- **Primary abstraction:** app/flow, automation workflow, agent harness hay state graph.
- **RAG, agent và integration:** capability có sẵn ở product surface hay phải ghép bằng code.
- **UI/API:** ai xây builder, end-user surface và application API.
- **State và operations:** execution history, memory/checkpoint, scaling, observability, retention và recovery.
- **Governance:** workspace/project, credential, IAM, audit, policy và mức phụ thuộc edition/product khác.
- **Skill và ownership:** low-code builder, integration engineer, application engineer hay distributed-systems engineer.
- **Shortlist trigger:** điều kiện kiến trúc khiến candidate đáng được PoC; đây không phải kết luận mua hoặc triển khai.

Không chấm điểm tổng hợp. Trọng số giữa time-to-market, extensibility, deterministic control, integration breadth và operating burden phải được chốt từ use case trước; một tổng điểm chưa có trọng số sẽ tạo độ chính xác giả.

## Ma trận so sánh

| Lựa chọn | Nhóm / trọng tâm | Deployment | Primary abstraction | RAG, agent và integration | UI / API | State và operations | Governance | Skill và ownership | Đưa vào shortlist khi |
|---|---|---|---|---|---|---|---|---|---|
| **Dify** | Visual AI application platform | Cloud hoặc self-host. Baseline guide dùng stack Compose nhiều service tại `1.15.0`; deployment HA/Kubernetes và feature Enterprise phải đánh giá như scope riêng. [S-003][S-005][S-008][S-019] | Application, Chatflow/Workflow và Agent trên visual canvas; model, knowledge và plugin là resource của platform. [S-003][S-040] | Knowledge/RAG, agent node/app và plugin/tool integration nằm trong product surface. [S-016][S-048][S-057] | Builder UI; app có thể được phát hành thành web/API theo app type và config. | Platform lưu conversation/workflow run và application logs; đội vận hành sở hữu API, worker, plugin runtime, database, Redis, storage và vector backend. [S-005][S-073] | Community có built-in workspace roles; SSO, custom RBAC, audit và các control khác là edition-sensitive. [S-017][S-019] | AI application builder cộng với platform operations; vẫn cần RAG/model/evaluation và security engineering. | Cần một product surface thống nhất để team tạo, quản lý và phát hành LLM app/RAG/agent mà không tự xây toàn bộ application plumbing. |
| **Flowise** | Visual generative-AI development platform | Official docs nêu self-host và air-gapped options; exact artifact, database/queue topology và HA của version chọn phải được xác minh. [S-111] | Ba visual builder: Assistant, Chatflow và Agentflow. | Docs mô tả RAG/indexing, retriever/reranker, tool, single/multi-agent và catalog integration trong visual flows. [S-111] | Visual builder cùng API, CLI, SDK và embedded chatbot surfaces được tài liệu hóa. [S-111] | Docs liệt kê memory, execution logs, tracing, evaluations và horizontal/vertical scaling; retention, failure semantics và production topology vẫn cần PoC. [S-111] | Docs liệt kê team/workspace, RBAC, SSO, encrypted credential và secret-manager controls; phải map từng control sang edition/version thực tế. [S-111] | Visual flow builder; developer cần thiết khi dùng custom code/component và khi productionize persistence, security, scale. | Cần visual AI flows/agents với component-level composition và muốn đánh giá một product surface gần Dify nhưng có abstraction Assistant/Chatflow/Agentflow riêng. |
| **n8n** | Workflow automation kết hợp AI capability | Cloud, npm, Docker và self-host được tài liệu hóa. Queue mode tách main/worker qua Redis và database; multi-main là edition-sensitive. [S-112][S-114] | Trigger/node-based workflow nối application API và biến đổi dữ liệu; business automation là center of gravity. [S-112] | Advanced AI dùng cluster nodes và có chat, RAG, LangChain concepts, tools và AI workflow templates; AI nằm trong workflow automation rộng hơn. [S-113] | Visual workflow canvas, triggers/webhooks, API-oriented nodes và custom nodes; product-facing chat UI không nên được giả định tương đương một AI application platform nếu chưa PoC. [S-112][S-113] | State chủ yếu theo workflow execution; queue mode scale worker qua Redis/database. Không suy execution history này tương đương checkpoint/state-machine semantics của LangGraph. [S-114] | Projects, roles, credential sharing, source control và execution-data controls phụ thuộc edition/config; phải đánh giá trên plan cụ thể thay vì suy từ docs navigation. | Integration/automation engineer mạnh về API, webhook, data mapping, credential và operations; bổ sung AI/RAG skill khi workflow dùng LLM. | Trigger, SaaS/internal-system integration và business process là lõi; AI chỉ là một hoặc vài bước trong automation end-to-end. |
| **LangChain** | Code-first agent framework / integration abstractions | Thư viện được nhúng vào Python application; team sở hữu service runtime, API, data và deployment. LangSmith là platform riêng cần đánh giá riêng nếu dùng cho observability/deployment. [S-115] | `create_agent` harness cấu thành từ model, tools, prompt và middleware. [S-115] | Model/tool integrations và retrieval building blocks gồm loader, splitter, embedding, vector store, retriever; docs tách 2-step, agentic và hybrid RAG. [S-115][S-116] | OSS scope là code-first; application team xây hoặc chọn API/UI. Không tính LangSmith/Agent Chat UI như capability mặc định của library. | Agent harness dùng LangGraph bên dưới; memory, middleware, retry và observability phụ thuộc composition/runtime được chọn. Production SLO, scaling và persistence vẫn do application stack sở hữu. [S-115] | IAM, tenancy, secret, policy, audit và retention thuộc application/platform của tổ chức; LangSmith, nếu dùng, là một governance surface bổ sung chứ không phải thuộc tính mặc định của OSS library. | Software engineer Python, LLM integration, testing/evaluation, API và production engineering; nếu chọn TypeScript phải baseline package/API riêng. | Cần custom application/agent bằng code, muốn abstraction chung cho model/tool/retrieval nhưng không muốn bị ràng buộc vào một visual application platform. |
| **LangGraph** | Low-level stateful-agent orchestration framework/runtime | Thư viện/runtime có thể dùng độc lập hoặc cùng LangChain; team tự đóng gói service. LangSmith Deployment/Studio là companion product, không đồng nhất với OSS runtime. [S-117] | Explicit graph với node, edge và state; trọng tâm là long-running, stateful orchestration. [S-117] | Agent control flow là first-class; model/tool integration thường dùng LangChain nhưng không bắt buộc. RAG ingestion/retrieval vẫn là application composition, không phải turnkey visual knowledge lifecycle. [S-117] | Code-first Graph/Functional APIs; Studio, Agent Chat UI và LangSmith là companion surfaces. Product API/UI vẫn cần owner rõ. [S-117] | Checkpointer lưu thread state; Store giữ data cross-thread. Persistence hỗ trợ resume, human-in-the-loop và fault tolerance; production phải chọn persistent backend, retention và recovery, vì in-memory saver mất state khi restart. [S-118] | Team sở hữu state schema, thread identity, checkpoint retention, replay/idempotency, IAM và audit. Nếu dùng LangSmith, đánh giá data boundary và control riêng. | Kỹ sư Python có kinh nghiệm state machine, concurrency, persistence, idempotency và distributed-system operations; nếu chọn TypeScript phải baseline package/API riêng. | Agent phải chạy dài, pause/resume, human approval, recover từ checkpoint hoặc cần deterministic/agentic graph control chi tiết hơn agent harness cấp cao. |

Quy tắc shortlist thực dụng:

- Bắt đầu từ **Dify/Flowise** nếu deliverable là một AI application do nhiều vai trò cùng cấu hình trên visual product surface.
- Bắt đầu từ **n8n** nếu deliverable là quy trình nghiệp vụ nhiều trigger/integration, trong đó LLM là một capability.
- Bắt đầu từ **LangChain** nếu deliverable là custom software và team muốn agent/retrieval abstractions bằng code.
- Thêm **LangGraph** khi state, pause/resume, human-in-the-loop hoặc long-running orchestration là yêu cầu kiến trúc, không chỉ khi muốn “agent phức tạp hơn”.
- Cho phép shortlist kết hợp, nhưng phải chỉ định một owner cho orchestration boundary để tránh retry, state và audit bị nhân đôi.

## Giới hạn và caveats

- Chỉ Dify được pin ở `1.15.0`. [S-111]–[S-118] là current web docs tại `2026-07-16` và có thể thay đổi mà không đi cùng release của tài liệu này.
- Flowise và n8n feature availability có thể phụ thuộc version, plan hoặc Enterprise edition. Dòng trong bảng là điểm bắt đầu để verify, không phải entitlement matrix.
- [S-115]–[S-118] dùng Python documentation surface. TypeScript package/API, companion products và managed deployment có thể khác; phải lập baseline riêng nếu chọn chúng.
- LangChain và LangGraph là các lớp có thể bổ sung cho nhau. So sánh chúng như hai sản phẩm thay thế hoàn toàn sẽ làm sai abstraction boundary.
- “Có RAG” không chứng minh ingestion governance, authorization, retrieval quality hoặc citation correctness; “có agent” không chứng minh tool safety, deterministic recovery hoặc cost bound.
- “Self-hosted” không tự chứng minh HA, air gap, data residency, backup/restore, upgrade safety hoặc compliance. Mỗi candidate phải qua architecture/security/operations review.
- Không có benchmark hoặc hands-on PoC chéo sản phẩm trong workspace. Latency, throughput, failure recovery, migration, UX và operating effort đều `RUNTIME-PENDING`.

Trước quyết định cuối, chạy cùng một thin-slice fixture trên shortlist: ingest một corpus nhỏ; thực hiện retrieval có citation; gọi một tool có side effect qua approval; tích hợp một business API; publish một endpoint; quan sát trace/log; inject timeout/restart; export/version artifact; và chứng minh rollback/restore. So sánh evidence, không so sánh demo happy path.

## Nguồn tham khảo

### Dify baseline đã pin

- [S-003] [Dify README tại tag 1.15.0](https://github.com/langgenius/dify/blob/1.15.0/README.md) — positioning, application surface và self-host quick start.
- [S-005] [Dify Docker Compose tại tag 1.15.0](https://github.com/langgenius/dify/blob/1.15.0/docker/docker-compose.yaml) — multi-service deployment topology.
- [S-008] [Dify deployment overview tại docs snapshot `57a492d…`](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/deploy/overview.mdx).
- [S-016] [Dify integrations and plugins tại docs snapshot `57a492d…`](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/plugins.mdx).
- [S-017] [Dify team-member management tại docs snapshot `57a492d…`](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/team-members-management.mdx).
- [S-019] [Dify Enterprise](https://dify.ai/dify-enterprise) — public edition-level capability page; implementation detail vẫn cần Enterprise artifact/docs.
- [S-040] [Dify Workflow and Chatflow tại docs snapshot `57a492d…`](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/build/workflow-chatflow.mdx).
- [S-048] [Dify Knowledge overview tại docs snapshot `57a492d…`](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/knowledge/readme.mdx).
- [S-057] [Dify Agent node tại docs snapshot `57a492d…`](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/nodes/agent.mdx).
- [S-073] [Dify application logs tại docs snapshot `57a492d…`](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/monitor/logs.mdx).

### Nguồn so sánh current, truy cập `2026-07-16`

- [S-111] [Flowise official documentation — Introduction](https://docs.flowiseai.com/) — Assistant/Chatflow/Agentflow, RAG/agent, API surfaces, operations và listed governance capabilities.
- [S-112] [n8n official documentation — Welcome](https://docs.n8n.io/) — workflow-automation positioning, integration và Cloud/npm/Docker/self-host paths.
- [S-113] [n8n official documentation — Advanced AI](https://docs.n8n.io/advanced-ai/) — AI workflow, RAG/LangChain concepts, cluster nodes và chat surface.
- [S-114] [n8n official documentation — Queue mode](https://docs.n8n.io/hosting/scaling/queue-mode/) — main/worker, Redis/database, scaling và multi-main caveat.
- [S-115] [LangChain official documentation — Overview](https://docs.langchain.com/oss/python/langchain/overview) — `create_agent`, model/tool/middleware abstraction và relation với LangGraph/LangSmith.
- [S-116] [LangChain official documentation — Retrieval](https://docs.langchain.com/oss/python/langchain/retrieval) — retrieval building blocks và RAG architectures.
- [S-117] [LangGraph official documentation — Overview](https://docs.langchain.com/oss/python/langgraph/overview) — low-level stateful orchestration, durable execution và product boundaries.
- [S-118] [LangGraph official documentation — Persistence](https://docs.langchain.com/oss/python/langgraph/persistence) — checkpointer/store, thread state, resume và production persistence caveats.
