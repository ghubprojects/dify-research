# Releases

Thư mục này dành cho bản ghép phát hành sau khi toàn bộ review gate và Definition of Done tương ứng đã đạt.

## Trạng thái hiện tại

Chưa sinh `dify-research-final.md`. Nguồn chuẩn hiện là 20 file chương và các phụ lục trong `docs/dify-technical-guide/`; draft vòng 1 và static QA đã hoàn tất, nhưng runtime validation, Mermaid render, input `TBD-by-owner` của mô hình chi phí và specialist/Legal/editorial sign-off chưa đạt. Tạo bản ghép lúc này sẽ làm mờ các gate còn mở.

## Quy ước đầu ra

- Tên bản ghép chuẩn: `dify-research-final.md`.
- Nguồn chuẩn: các file theo chương trong `docs/dify-technical-guide/`.
- Không chỉnh sửa trực tiếp bản ghép.
- Ghi version tài liệu, Dify baseline, ngày build và commit/source snapshot trong metadata phát hành.

## Release checklist

- [ ] Chapter status đạt điều kiện phát hành.
- [x] Citation và source link hợp lệ trên source snapshot hiện tại.
- [ ] Mermaid render thành công.
- [x] Link nội bộ và TOC hợp lệ trên source snapshot hiện tại.
- [ ] Không còn placeholder trong nội dung phát hành.
- [x] Validation label phản ánh đúng evidence hiện có.
- [x] Change log đã cập nhật tới `0.3.0`.
