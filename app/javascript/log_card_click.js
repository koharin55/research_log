(() => {
  const interactiveSelector =
    "a, button, input, select, textarea, [role='button'], [data-stop-card-click]";

  const isInteractive = (el) => el.closest(interactiveSelector);

  const visit = (card) => {
    const url = card?.dataset?.logUrl;
    if (!url) return;
    if (window.Turbo) {
      window.Turbo.visit(url);
    } else {
      window.location.href = url;
    }
  };

  const handleClick = (e) => {
    const card = e.target.closest(".log-card[data-log-url]");
    if (!card) return;
    if (isInteractive(e.target)) return;
    visit(card);
  };

  const handleKeydown = (e) => {
    const card = e.target.closest(".log-card[data-log-url]");
    if (!card) return;
    if (isInteractive(e.target)) return;
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      visit(card);
    }
  };

  let listenersAdded = false;
  const setup = () => {
    if (listenersAdded) return;
    listenersAdded = true;
    document.addEventListener("click", handleClick);
    document.addEventListener("keydown", handleKeydown);
  };

  const init = () => {
    if (document.querySelector(".log-card[data-log-url]")) {
      setup();
    }
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }

  document.addEventListener("turbo:load", init);
})();
