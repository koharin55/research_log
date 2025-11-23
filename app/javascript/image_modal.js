// 画像サムネイルをクリックしたときにモーダルで大きく表示する
(() => {
  const getParts = () => {
    const modal = document.querySelector("[data-image-modal]");
    if (!modal) return {};

    return {
      modal,
      backdrop: modal.querySelector(".image-modal-backdrop"),
      closeBtn: modal.querySelector(".image-modal-close"),
      imgEl: modal.querySelector(".image-modal-image"),
    };
  };

  const open = (url) => {
    if (!url) return;

    const { modal, imgEl } = getParts();
    if (!modal || !imgEl) return;

    imgEl.src = url;
    modal.removeAttribute("hidden");
    document.body.classList.add("is-modal-open");
  };

  const close = () => {
    const { modal, imgEl } = getParts();
    if (!modal || !imgEl) return;

    modal.setAttribute("hidden", "hidden");
    imgEl.src = "";
    document.body.classList.remove("is-modal-open");
  };

  const clickHandler = (e) => {
    // サムネイルクリック → モーダルを開く
    const thumb = e.target.closest(".js-log-image");
    if (thumb) {
      e.preventDefault();
      const url = thumb.dataset.fullUrl;
      open(url);
      return;
    }

    const { backdrop, closeBtn } = getParts();

    // バックドロップ or ×ボタン → 閉じる
    if (
      (backdrop && e.target === backdrop) ||
      (closeBtn && (e.target === closeBtn || e.target.closest(".image-modal-close")))
    ) {
      e.preventDefault();
      close();
    }
  };

  const keydownHandler = (e) => {
    if (e.key === "Escape") {
      const { modal } = getParts();
      if (modal && !modal.hasAttribute("hidden")) {
        close();
      }
    }
  };

  const setup = () => {
    // すでにセットアップ済みなら何もしない（Turbo対応）
    if (window.__imageModalSetupDone) return;
    window.__imageModalSetupDone = true;

    document.addEventListener("click", clickHandler);
    document.addEventListener("keydown", keydownHandler);
  };

  // Turbo / 通常どちらでも一度だけセットアップ
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setup);
  } else {
    setup();
  }
  document.addEventListener("turbo:load", setup);
})();
