// フォーム上で Ctrl+V された画像を file input に追加する
(() => {
  const MAX_IMAGES = 5;

  const handlePaste = (e) => {
    const form = e.target.closest(".js-log-form");
    if (!form) return; // ログフォーム以外のペーストは無視

    const clipboard = e.clipboardData || window.clipboardData;
    if (!clipboard || !clipboard.files || clipboard.files.length === 0) return;

    const imageFiles = Array.from(clipboard.files).filter((f) =>
      f.type.startsWith("image/")
    );
    if (imageFiles.length === 0) return;

    e.preventDefault(); // ブラウザのデフォルト貼り付けを止める

    const input =
      form.querySelector('input[type="file"][name="log[images][]"]') ||
      form.querySelector('input[type="file"][name="log[images]"]');

    if (!input) return;

    const dt = new DataTransfer();

    // 既に選択されているファイルを保持
    const existing = input.files ? Array.from(input.files) : [];

    // 既存 + 新規 から最大5枚まで追加
    [...existing, ...imageFiles].slice(0, MAX_IMAGES).forEach((file) => {
      dt.items.add(file);
    });

    input.files = dt.files;

    // ヒント文言を更新
    const hint = form.querySelector(".paste-hint");
    if (hint) {
      hint.textContent = `現在 ${input.files.length}枚の画像が選択されています（保存するとアップロードされます）`;
    }
  };

  const init = () => {
    document.addEventListener("paste", handlePaste);
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
