(() => {
  const root = document.documentElement;
  const MODE_KEY = "theme-mode";  // 'ライト' | 'ダーク' | '自動'
  const THEME_KEY = "theme";      // 'ライト' | 'ダーク' （'自動'時は未使用）
  const mq = window.matchMedia("(prefers-color-scheme: dark)");

  const buttons = () =>
    document.querySelectorAll(".theme-switch [data-mode]");

  const reflectUI = () => {
    const mode = localStorage.getItem(MODE_KEY) || "auto";
    buttons().forEach((btn) => {
      btn.setAttribute("aria-pressed", btn.dataset.mode === mode ? "true" : "false");
    });
  };

  const apply = (mode) => {
    if (mode === "light" || mode === "dark") {
      root.setAttribute("data-theme", mode);
      localStorage.setItem(THEME_KEY, mode);
      localStorage.setItem(MODE_KEY, mode);
    } else {
      const dark = mq.matches;
      root.setAttribute("data-theme", dark ? "dark" : "light");
      localStorage.setItem(MODE_KEY, "auto");
      localStorage.removeItem(THEME_KEY);
    }
    reflectUI();
  };

  // 初期設定
  const init = () => {
    const savedMode = localStorage.getItem(MODE_KEY) || "auto";
    if (savedMode === "light" || savedMode === "dark") {
      apply(savedMode);
    } else {
      apply("auto");
    }

    // ボタンクリック
    document.addEventListener("click", (e) => {
      const btn = e.target.closest(".theme-switch [data-mode]");
      if (!btn) return;
      e.preventDefault();
      apply(btn.dataset.mode);
    });

    // OS側の設定変更（autoのときだけ追従）
    mq.addEventListener?.("change", () => {
      if ((localStorage.getItem(MODE_KEY) || "auto") === "auto") {
        apply("auto");
      }
    });
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
