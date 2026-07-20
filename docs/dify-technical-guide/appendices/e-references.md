# E. References

> **Version áp dụng:** Dify Community `1.15.0`  
> **Ngày kiểm chứng:** `2026-07-16`  
> **Version-drift check:** `2026-07-20`; ghi nhận `1.16.0`, không đổi baseline
>
> **Trạng thái xác minh:** `Official-source verified — vòng 1`  
> **Reviewer:** Chờ technical/editorial review

## Quy ước mã nguồn

- Citation dùng dạng `[S-###]` ngay sau claim.
- Nguồn nhạy version phải trỏ tag/commit immutable khi có thể.
- `Ngày truy cập` là bắt buộc cho pricing/marketing/Cloud pages không versioned.
- Danh mục đầy đủ, owner, trạng thái và claim mapping nằm tại `docs/working/source-register.md`.

## Nguồn chính thức của Dify

- [S-001 — Dify 1.15.0 Release Note](https://github.com/langgenius/dify/releases/tag/1.15.0)
- [S-002 — Baseline commit 3aa26fb…](https://github.com/langgenius/dify/commit/3aa26fb6374bbd47e5469f7d7cc25f3e0075a60c)
- [S-003 — Dify README tại tag 1.15.0](https://github.com/langgenius/dify/blob/1.15.0/README.md)
- [S-004 — Dify LICENSE tại tag 1.15.0](https://github.com/langgenius/dify/blob/1.15.0/LICENSE)
- [S-005 — Docker Compose tại tag 1.15.0](https://github.com/langgenius/dify/blob/1.15.0/docker/docker-compose.yaml)
- [S-006 — Docker `.env.example` tại tag 1.15.0](https://github.com/langgenius/dify/blob/1.15.0/docker/.env.example)
- [S-007 — Deploy with Docker Compose](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/deploy/quick-start/docker-compose.mdx)
- [S-008 — Self-host deployment overview](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/deploy/overview.mdx)
- [S-009 — Environment variables](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/deploy/configuration/environments.mdx)
- [S-010 — Nginx route template](https://github.com/langgenius/dify/blob/1.15.0/docker/nginx/conf.d/default.conf.template)
- [S-011 — Celery extension](https://github.com/langgenius/dify/blob/1.15.0/api/extensions/ext_celery.py)
- [S-012 — Document indexing task](https://github.com/langgenius/dify/blob/1.15.0/api/tasks/document_indexing_task.py)
- [S-013 — API/worker/beat entrypoint](https://github.com/langgenius/dify/blob/1.15.0/api/docker/entrypoint.sh)
- [S-014 — Dify as MCP client](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/tools.mdx)
- [S-119 — Dify MCP Tool Core Source](https://github.com/langgenius/dify/blob/1.15.0/api/core/tools/mcp_tool/tool.py)
- [S-120 — Dify MCP Client Core Source](https://github.com/langgenius/dify/blob/1.15.0/api/core/mcp/mcp_client.py)
- [S-121 — Dify 1.16.0 Release Note](https://github.com/langgenius/dify/releases/tag/1.16.0) — nguồn drift sau baseline; chưa dùng thay procedure `1.15.0`.
- [S-122 — Dify 1.16.0 Version Bump Commit](https://github.com/langgenius/dify/commit/5c6372d2f76d240265b92fd27c16bc772ffcb107)
- [S-123 — Dify Tool Plugin Walkthrough](https://docs.dify.ai/en/develop-plugin/dev-guides-and-walkthroughs/tool-plugin) — current docs; pin CLI/SDK trước khi áp dụng cho baseline.
- [S-015 — Publish as MCP server](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/publish/publish-mcp.mdx)
- [S-016 — Integrations and plugins](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/plugins.mdx)
- [S-017 — Workspace roles](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/team-members-management.mdx)
- [S-018 — Dify Pricing](https://dify.ai/pricing)
- [S-019 — Dify Enterprise](https://dify.ai/dify-enterprise)
- [S-020 — Dify documentation repository](https://github.com/langgenius/dify-docs)
- [S-021 — Docker deployment README](https://github.com/langgenius/dify/blob/1.15.0/docker/README.md)
- [S-022 — Enterprise Helm values generator](https://github.com/langgenius/dify-ee-helm-chart-values-generator) — candidate evidence; không phải Community chart.
- [S-023 — Enterprise OpenShift Helm charts](https://github.com/langgenius/dify-enterprise-openshift-helm-charts) — candidate evidence; không dùng làm Community default.
- [S-024 — Dify 1.15.0 release API metadata](https://api.github.com/repos/langgenius/dify/releases/tags/1.15.0)
- [S-025 — Dify Docs release branch metadata](https://api.github.com/repos/langgenius/dify-docs/branches/release%2F1.15.0)
- [S-026 — Workflow Start Node](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/nodes/start.mdx)
- [S-027 — Personal Settings](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/personal-account-management.mdx)
- [S-028 — Workspace Overview](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/readme.mdx)
- [S-029 — Plugin Introduction](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/develop-plugin/getting-started/getting-started-dify-plugin.mdx)
- [S-030 — Choose Plugin Type](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/develop-plugin/getting-started/choose-plugin-type.mdx)
- [S-031 — Plugin Manifest Schema](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/develop-plugin/features-and-specs/plugin-types/plugin-info-by-manifest.mdx)
- [S-032 — Plugin Daemon README 0.6.3](https://github.com/langgenius/dify-plugin-daemon/blob/0.6.3/README.md)
- [S-033 — Plugin Daemon 0.6.3 commit](https://github.com/langgenius/dify-plugin-daemon/commit/54432d8a0a77dc6a29bc608918590a977ed46cf7)
- [S-034 — Application Generate Service](https://github.com/langgenius/dify/blob/1.15.0/api/services/app_generate_service.py)
- [S-035 — Workflow Execute Task](https://github.com/langgenius/dify/blob/1.15.0/api/tasks/app_generate/workflow_execute_task.py)
- [S-036 — Message-based App Generator](https://github.com/langgenius/dify/blob/1.15.0/api/core/app/apps/message_based_app_generator.py)
- [S-037 — Streaming Utilities](https://github.com/langgenius/dify/blob/1.15.0/api/core/app/apps/streaming_utils.py)
- [S-038 — Plugin Model Implementation](https://github.com/langgenius/dify/blob/1.15.0/api/core/plugin/impl/model.py)
- [S-039 — Redis Extension](https://github.com/langgenius/dify/blob/1.15.0/api/extensions/ext_redis.py)
- [S-040 — Workflow and Chatflow](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/build/workflow-chatflow.mdx)
- [S-041 — Orchestration Logic](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/build/orchestrate-node.mdx)
- [S-042 — Handle Errors](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/build/predefined-error-handling-logic.mdx)
- [S-043 — If-Else Node](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/nodes/ifelse.mdx)
- [S-044 — HTTP Request Node](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/nodes/http-request.mdx)
- [S-045 — Manage Apps and DSL](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/app-management.mdx)

## Nguồn chính thức của dependency/provider

- [S-046 — Docker Compose Config CLI Reference](https://docs.docker.com/reference/cli/docker/compose/config/)
- [S-047 — Docker Compose Down CLI Reference](https://docs.docker.com/reference/cli/docker/compose/down/)
- [S-103 — GitHub Actions Secure Use Reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [S-104 — GitHub Artifact Attestations](https://docs.github.com/en/actions/concepts/security/artifact-attestations)
- [S-105 — Docker Image Digests](https://docs.docker.com/dhi/core-concepts/digests/)

## FinOps và cost allocation

- [S-106 — FinOps Unit Economics](https://www.finops.org/framework/capabilities/unit-economics/)
- [S-107 — FOCUS Specification 1.4](https://focus.finops.org/focus-specification/v1-4/)
- [S-108 — OpenCost Specification](https://opencost.io/docs/specification/)
- [S-109 — NVIDIA DCGM Exporter](https://docs.nvidia.com/datacenter/dcgm/latest/gpu-telemetry/dcgm-exporter.html)

## Observability và LLMOps

- [S-073 — Application Conversation Logs](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/monitor/logs.mdx)
- [S-074 — Workflow Run History](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/debug/history-and-logs.mdx)
- [S-075 — Langfuse Integration](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/monitor/integrations/integrate-langfuse.mdx)
- [S-076 — Opik Integration](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/monitor/integrations/integrate-opik.mdx)
- [S-077 — W&B Weave Integration](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/monitor/integrations/integrate-weave.mdx)
- [S-078 — Dify Security Policy](https://github.com/langgenius/dify/blob/1.15.0/SECURITY.md)

## RAG và model management

- [S-048 — Knowledge Overview](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/knowledge/readme.mdx)
- [S-049 — Knowledge Pipeline Orchestration](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/knowledge/knowledge-pipeline/knowledge-pipeline-orchestration.mdx)
- [S-050 — Index Method and Retrieval Settings](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/knowledge/create-knowledge/setting-indexing-methods.mdx)
- [S-051 — Knowledge Retrieval Node](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/nodes/knowledge-retrieval.mdx)
- [S-052 — Integrate Knowledge within Apps](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/knowledge/integrate-knowledge-within-application.mdx)
- [S-053 — Test Knowledge Retrieval](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/knowledge/test-retrieval.mdx)
- [S-054 — Indexing Runner](https://github.com/langgenius/dify/blob/1.15.0/api/core/indexing_runner.py)
- [S-055 — Dataset Retrieval](https://github.com/langgenius/dify/blob/1.15.0/api/core/rag/retrieval/dataset_retrieval.py)
- [S-056 — Vector Factory](https://github.com/langgenius/dify/blob/1.15.0/api/core/rag/datasource/vdb/vector_factory.py)
- [S-065 — Model Providers](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/workspace/model-providers.mdx)
- [S-066 — LLM Node](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/nodes/llm.mdx)
- [S-069 — Model Plugin Design Rules](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/develop-plugin/features-and-specs/plugin-types/model-designing-rules.mdx)
- [S-071 — Provider Configuration Source](https://github.com/langgenius/dify/blob/1.15.0/api/core/entities/provider_configuration.py)
- [S-072 — Model Manager Source](https://github.com/langgenius/dify/blob/1.15.0/api/core/model_manager.py)

## Agent

- [S-057 — Agent Node](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/nodes/agent.mdx)
- [S-058 — Agent App](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/build/agent.mdx)
- [S-059 — Tool Node](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/nodes/tools.mdx)
- [S-060 — Node and System Error Types](https://github.com/langgenius/dify-docs/blob/57a492d8063d1583c582b4c0444fb838c6dd3027/en/self-host/use-dify/debug/error-type.mdx)
- [S-061 — Agent Chat App Runner](https://github.com/langgenius/dify/blob/1.15.0/api/core/app/apps/agent_chat/app_runner.py)
- [S-062 — Function Calling Agent Runner](https://github.com/langgenius/dify/blob/1.15.0/api/core/agent/fc_agent_runner.py)
- [S-063 — ReAct/CoT Agent Runner](https://github.com/langgenius/dify/blob/1.15.0/api/core/agent/cot_agent_runner.py)
- [S-064 — Workflow Agent Node v1](https://github.com/langgenius/dify/blob/1.15.0/api/core/workflow/nodes/agent/agent_node.py)

## Kubernetes và HA

- [S-079 — Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [S-080 — Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [S-081 — Kubernetes Horizontal Pod Autoscaling](https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/)
- [S-082 — Kubernetes Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)
- [S-083 — Kubernetes Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [S-084 — Kubernetes Secrets Good Practices](https://kubernetes.io/docs/concepts/security/secrets-good-practices/)
- [S-085 — Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [S-086 — Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)

## Model provider và self-host serving

- [S-087 — OpenAI-API-compatible Plugin README Snapshot](https://github.com/langgenius/dify-official-plugins/blob/6b04cde85d43dbde06f0c40cce1d245677c04d53/models/openai_api_compatible/README.md)
- [S-088 — OpenAI-API-compatible Provider Schema Snapshot](https://github.com/langgenius/dify-official-plugins/blob/6b04cde85d43dbde06f0c40cce1d245677c04d53/models/openai_api_compatible/provider/openai_api_compatible.yaml)
- [S-089 — Ollama Plugin README Snapshot](https://github.com/langgenius/dify-official-plugins/blob/6b04cde85d43dbde06f0c40cce1d245677c04d53/models/ollama/README.md)
- [S-090 — Ollama Provider Schema Snapshot](https://github.com/langgenius/dify-official-plugins/blob/6b04cde85d43dbde06f0c40cce1d245677c04d53/models/ollama/provider/ollama.yaml)
- [S-091 — Ollama OpenAI Compatibility](https://docs.ollama.com/api/openai-compatibility)
- [S-092 — Ollama FAQ](https://docs.ollama.com/faq)
- [S-093 — vLLM OpenAI-compatible Server](https://docs.vllm.ai/en/stable/serving/openai_compatible_server/)
- [S-094 — vLLM Tool Calling](https://docs.vllm.ai/en/stable/features/tool_calling/)
- [S-124 — Claude API Overview](https://platform.claude.com/docs/en/api/overview)
- [S-125 — Azure OpenAI REST API Reference](https://learn.microsoft.com/en-us/azure/foundry/openai/reference)
- [S-126 — Amazon Bedrock InvokeModel API](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InvokeModel.html)

## LLMOps bổ sung

- [S-127 — Arize Phoenix Overview](https://arize.com/docs/phoenix) — Phoenix nhận trace qua OTLP/OpenTelemetry; không phải bằng chứng có native Dify integration.

## Operations, backup và DR

- [S-095 — PostgreSQL 15 Backup and Restore](https://www.postgresql.org/docs/15/backup.html)
- [S-096 — PostgreSQL 15 `pg_dump`](https://www.postgresql.org/docs/15/app-pgdump.html)
- [S-097 — PostgreSQL 15 `pg_restore`](https://www.postgresql.org/docs/15/app-pgrestore.html)
- [S-098 — PostgreSQL 15 Continuous Archiving and PITR](https://www.postgresql.org/docs/15/continuous-archiving.html)
- [S-099 — PostgreSQL 15 `pg_basebackup`](https://www.postgresql.org/docs/15/app-pgbasebackup.html)
- [S-100 — Redis Persistence](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/)
- [S-101 — Weaviate Backups](https://docs.weaviate.io/deploy/configuration/backups)
- [S-102 — Docker Volumes: Backup, Restore or Migrate](https://docs.docker.com/engine/storage/volumes/#back-up-restore-or-migrate-data-volumes)

## Nguồn so sánh current

- [S-111 — Flowise Introduction](https://docs.flowiseai.com/)
- [S-112 — n8n Documentation Welcome](https://docs.n8n.io/)
- [S-113 — n8n Advanced AI](https://docs.n8n.io/advanced-ai/)
- [S-114 — n8n Queue Mode](https://docs.n8n.io/hosting/scaling/queue-mode/)
- [S-115 — LangChain Overview](https://docs.langchain.com/oss/python/langchain/overview)
- [S-116 — LangChain Retrieval](https://docs.langchain.com/oss/python/langchain/retrieval)
- [S-117 — LangGraph Overview](https://docs.langchain.com/oss/python/langgraph/overview)
- [S-118 — LangGraph Persistence](https://docs.langchain.com/oss/python/langgraph/persistence)

Các nguồn dependency/provider không versioned phải ghi ngày truy cập; trước final cần recheck option/semantics nếu toolchain thay đổi.

## Nguồn thứ cấp

Chưa có nguồn thứ cấp nào được chấp nhận làm evidence cho claim Tier 1.

## Release notes và version drift

- Baseline product: `1.15.0 @ 3aa26fb6374bbd47e5469f7d7cc25f3e0075a60c`.
- Baseline docs: `release/1.15.0 @ 57a492d8063d1583c582b4c0444fb838c6dd3027`.
- Drift check đã chạy ngày `2026-07-20` và phát hiện `1.16.0`; lặp lại tại `DOC-G5` nếu ngày phát hành final muộn hơn, ghi delta và không tự động đổi baseline giữa vòng viết.
