(() => {
  const root = document.documentElement;
  const MODE_KEY = "theme-mode";  // 'light' | 'dark' | 'auto'
  const THEME_KEY = "theme";      // 'light' | 'dark' （'auto'時は未使用）
  const mq = window.matchMedia("(prefers-color-scheme: dark)");

  // .theme-switch 内の data-mode ボタンたち
  const buttons = () =>
    document.querySelectorAll(".theme-switch [data-mode]");

  // 現在のモード（localStorage 上の値）に合わせてボタンの aria-pressed を整える
  const reflectUI = () => {
    const mode = localStorage.getItem(MODE_KEY) || "auto";
    buttons().forEach((btn) => {
      btn.setAttribute(
        "aria-pressed",
        btn.dataset.mode === mode ? "true" : "false"
      );
    });
  };

  // 実際にテーマを適用する
  const apply = (mode) => {
    if (mode === "light" || mode === "dark") {
      root.setAttribute("data-theme", mode);
      localStorage.setItem(THEME_KEY, mode);
      localStorage.setItem(MODE_KEY, mode);
    } else {
      // auto: OS の設定に追従
      const dark = mq.matches;
      root.setAttribute("data-theme", dark ? "dark" : "light");
      localStorage.setItem(MODE_KEY, "auto");
      localStorage.removeItem(THEME_KEY);
    }
    reflectUI();
  };

  let listenersSetup = false;

  const setupListeners = () => {
    if (listenersSetup) return;
    listenersSetup = true;

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

  // 初期設定（ページ読み込み / Turbo遷移ごとに呼ぶ）
  const init = () => {
    const savedMode = localStorage.getItem(MODE_KEY) || "auto";
    if (savedMode === "light" || savedMode === "dark") {
      apply(savedMode);
    } else {
      apply("auto");
    }

    setupListeners();
  };

  // 初回ページロード
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }

  // Turbo で他画面 → 戻ってきたとき用
  document.addEventListener("turbo:load", init);
})();