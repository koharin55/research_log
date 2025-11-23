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
    const existingInThisForm = input.files ? Array.from(input.files) : [];

    // 既にDBに保存されている枚数（編集時）
    const existingSavedCount = parseInt(
      form.dataset.existingImagesCount || "0",
      10
    );

    const currentTotal = existingSavedCount + existingInThisForm.length;
    const remaining = MAX_IMAGES - currentTotal;

    if (remaining <= 0) {
      alert("画像は合計5枚までです。不要な画像を削除してから追加してください。");
      return;
    }

    const filesToAdd = imageFiles.slice(0, remaining);

    // 既にこのフォームで選択済みのファイル + 追加分
    [...existingInThisForm, ...filesToAdd].forEach((file) => {
      dt.items.add(file);
    });

    input.files = dt.files;

    // ヒント文言を更新
    const hint = form.querySelector(".paste-hint");
    if (hint) {
      hint.textContent = `現在 ${existingSavedCount + input.files.length}枚の画像が選択されています（保存するとアップロードされます）`;
    }

    if (imageFiles.length > remaining) {
      alert("選択された画像の一部は5枚上限のため追加されませんでした。");
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
