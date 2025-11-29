import { Controller } from "@hotwired/stimulus";

// カテゴリ一覧の「編集」リンクで左ペインにインライン編集フォームを開く
export default class extends Controller {
  static targets = ["panel", "form", "input", "caption"];

  start(event) {
    event.preventDefault();
    const url = event.params.url;
    const name = event.params.name;

    if (!url) return;

    this.formTarget.action = url;
    this.inputTarget.value = name || "";
    this.captionTarget.textContent = `編集中: ${name || "カテゴリ"}`;

    this.panelTarget.classList.remove("is-hidden");
    this.inputTarget.focus();
    this.inputTarget.select();
  }

  cancel(event) {
    event.preventDefault();
    this.formTarget.action = "#";
    this.inputTarget.value = "";
    this.captionTarget.textContent = "編集したいカテゴリの「編集」をクリックしてください。";
    this.panelTarget.classList.add("is-hidden");
  }
}
