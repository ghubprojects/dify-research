# Releases

Thư mục này quản lý hai lớp bàn giao:

1. **Core guide — `Review-ready`:** bản hướng dẫn final về nội dung; có thể giữ `RUNTIME-PENDING`, gap deployment-specific và trường template `TBD-by-owner` hợp lệ.
2. **Deployment qualification — `Deployment-validated`:** hồ sơ cho một topology/use case cụ thể, gồm runtime evidence, organization input và approval thực tế.

Tên `dify-research-final.md` biểu thị bản ghép final của core guide, không mặc nhiên biểu thị một deployment đã được production-validated.

## Trạng thái hiện tại

Chưa sinh `dify-research-final.md`. Nguồn chuẩn hiện là 20 file chương và các phụ lục trong `docs/dify-technical-guide/`; working draft `0.3.4`, static QA và version-drift check ngày `2026-07-20` đã hoàn tất. Baseline vẫn là `1.15.0`; stable `1.16.0` được theo dõi tại G-053 và chưa được rebaseline.

Deterministic assembly preview và local Mermaid render đã đạt; chưa sinh file final trong repository. Internal specialist/editorial/novice desk cross-review đã hoàn tất tại V-017–V-019. Core guide còn một authoring blocker lớn: Chương 12 mới là Kubernetes design contract, chưa có deployable Community chart/manifest artifact. Ngoài ra còn chờ target-wiki conformance nếu renderer khác, designated-owner sign-off và formal target-reader walkthrough. Runtime lab và organization-specific input vẫn chặn trạng thái `Deployment-validated`. `DOC-G3-L` package đã `Review-ready`; Legal/Procurement determination thực tế vẫn phụ thuộc target use case, edition và contract.

## Quy ước đầu ra

- Tên bản ghép chuẩn: `dify-research-final.md`.
- Nguồn chuẩn: các file theo chương trong `docs/dify-technical-guide/`.
- Thứ tự nguồn: `release-manifest.txt`; build bằng `scripts/build-release.ps1`, kiểm tra bằng `scripts/validate-markdown.ps1` và `scripts/render-mermaid.ps1`.
- Không chỉnh sửa trực tiếp bản ghép.
- Ghi version tài liệu, Dify baseline, ngày build, commit/source snapshot, release class và deployment-validation status trong metadata phát hành.

## Core guide checklist — `Review-ready`

- [ ] Chapter content đạt `Review-ready`.
- [ ] Deployable Kubernetes/Helm reference artifact có provenance, owner và render validation.
- [x] Citation và source link hợp lệ trên source snapshot hiện tại.
- [x] Version drift đã kiểm tra; `1.16.0` được ghi nhận, baseline decision và impact gap đã đăng ký.
- [x] 29/29 Mermaid render thành công bằng CLI `11.16.0` + Edge `150.0.4078.65`.
- [ ] Conformance trên renderer/plugin wiki đích hoàn tất nếu khác CLI đã kiểm tra.
- [x] Link nội bộ và TOC hợp lệ trên source snapshot hiện tại.
- [x] Deterministic assembly preview đạt: 26 nguồn, 1 H1, anchor unique, link được rewrite và hash lặp lại giống nhau.
- [x] Không còn authoring placeholder; `TBD-by-owner` hợp lệ được giữ trong template.
- [x] Validation label phản ánh đúng evidence hiện có.
- [x] `DOC-G3-L` package có exact source, question set, risk và caveat.
- [x] Internal specialist/editorial/novice-role desk cross-review hoàn tất.
- [ ] Designated specialist/editorial owners và formal target reader sign-off.
- [x] Change log đã cập nhật tới `0.3.4`.

## Deployment qualification checklist — `Deployment-validated`

- [ ] Target topology, edition, provider, workload, SLO, RPO/RTO và data policy đã khóa.
- [ ] Mọi input `TBD-by-owner` áp dụng đã thành value/range hoặc explicit `N/A` có approval.
- [ ] Compose/Kubernetes/provider, security-control, backup/restore, upgrade/rollback và failure test áp dụng đã có runtime evidence.
- [ ] Legal/Security/Procurement và operational owners đã phê duyệt đúng target deployment.
- [ ] Evidence bundle ghi release identity, config hash, image digest, test result, owner và thời điểm kiểm chứng.
