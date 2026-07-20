# A. So sánh nhanh

> **Version áp dụng:** Dify Community `1.15.0 @ 3aa26fb…`; các lựa chọn khác theo official current docs tại ngày truy cập
> **Ngày kiểm chứng:** `2026-07-16`
> **Trạng thái xác minh:** `Official-source verified` + `Design reviewed` qua cross-review nội bộ; benchmark chéo sản phẩm vẫn `RUNTIME-PENDING`
> **Reviewer:** Enterprise Architecture, AI Engineering, Integration Platform, Security và Procurement review pending

## Mục tiêu và phạm vi

Phụ lục này chỉ giúp tạo **shortlist**, không chọn một “công cụ tốt nhất” và không thay một workstream so sánh sản phẩm. Dify được pin ở `1.15.0`; Flowise, n8n, LangChain và LangGraph dùng official current docs truy cập `2026-07-16`, chưa phải release baseline để triển khai.

Đọc theo center of gravity: Dify/Flowise là visual AI application platform; n8n là workflow automation; LangChain/LangGraph là code framework/runtime. Các lựa chọn có thể cùng tồn tại, nhưng phải có một owner cho orchestration, state, retry và audit boundary.

## Ma trận so sánh

| Lựa chọn | Abstraction chính | Đội phải sở hữu | Điểm mạnh chính | Đưa vào shortlist khi | Cần xác minh |
|---|---|---|---|---|---|
| **Dify** | Visual AI application platform: Application, Workflow/Chatflow, Agent, Knowledge và plugin | AI application + Platform/SRE + Security/RAG | Product surface thống nhất để xây, quản lý và phát hành LLM app qua web/API [S-003][S-016][S-040][S-048][S-057] | Cần low-code product surface chung thay vì tự xây application plumbing | Baseline `1.15.0`; HA/Kubernetes và Enterprise controls là scope riêng [S-005][S-008][S-017][S-019] |
| **Flowise** | Visual builder cho Assistant, Chatflow và Agentflow | AI application team + platform owner | RAG/agent/tool composition cùng API, CLI, SDK và embedded chat surface [S-111] | Cần visual component-level AI flow gần Dify nhưng abstraction khác | Pin release; persistence, queue/HA, retention và edition-specific governance [S-111] |
| **n8n** | Workflow automation dựa trên trigger/node, có AI capability | Integration/automation team | API, webhook, data mapping và quy trình nghiệp vụ; AI là một phần của workflow [S-112][S-113] | Integration và business process là lõi, LLM chỉ là một hoặc vài bước | Pin release/plan; queue/multi-main, product-facing chat UI và governance [S-112][S-114] |
| **LangChain** | Code-first agent framework và integration abstractions | Software/application team | Model, tool, retrieval và middleware abstractions cho custom application [S-115][S-116] | Cần tự xây application/agent bằng code và sở hữu API/UI/runtime | Pin Python/TypeScript package; IAM, persistence, deployment và observability thuộc application stack [S-115] |
| **LangGraph** | Low-level stateful-agent orchestration bằng graph/state | Distributed-systems/application team | Durable execution, checkpoint, pause/resume và human-in-the-loop [S-117][S-118] | Agent chạy dài hoặc cần state/recovery/control flow chi tiết | Persistent backend, retention, replay/idempotency, IAM và companion-product boundary [S-117][S-118] |

## Cách dùng bảng

- Không chấm điểm tổng hợp trước khi use case khóa trọng số time-to-market, extensibility, deterministic control, integration breadth và operating burden.
- Feature xuất hiện trong docs không phải bằng chứng runtime, production readiness hoặc entitlement trên topology/plan của tổ chức.
- Nếu có từ hai candidate trở lên, chạy cùng một thin-slice gồm retrieval có citation, một integration/tool đã kiểm soát, endpoint publish, trace/log, timeout/restart và rollback/restore; so evidence thay vì demo happy path.

## Giới hạn

- Không so sánh giá, benchmark latency/quality, số connector, certification, license hoặc feature entitlement theo plan.
- Chỉ Dify được pin release; mọi candidate được chọn phải có baseline, owner và security/operations review riêng.
- LangChain và LangGraph có thể bổ sung cho nhau; LangSmith/Studio không mặc định nằm trong phạm vi OSS.
- “Có RAG”, “có agent” hoặc “self-hosted” không tự chứng minh governance, authorization, HA, backup/restore hay compliance.
- Workspace chưa có hands-on POC chéo sản phẩm; mọi kết luận performance, recovery, migration, UX và operating effort vẫn `RUNTIME-PENDING`.
