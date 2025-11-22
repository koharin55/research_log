(() => {
  const copy = async (button) => {
    const codeEl = button.closest(".code-block")?.querySelector("pre code");
    if (!codeEl) return;

    const text = codeEl.innerText;
    try {
      await navigator.clipboard.writeText(text);
      button.textContent = "Copied!";
      setTimeout(() => (button.textContent = "Copy"), 1500);
    } catch (e) {
      console.error(e);
    }

    // 使用回数カウント
    const logId = button.dataset.logId;
    if (logId) {
      fetch(`/logs/${logId}/increment_copy_count`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document
            .querySelector("meta[name='csrf-token']")
            .getAttribute("content"),
        },
      }).catch((e) => console.error(e));
    }
  };

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".js-copy-code");
    if (!btn) return;
    e.preventDefault();
    copy(btn);
  });
})();
