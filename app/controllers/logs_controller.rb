class LogsController < ApplicationController
  before_action :set_log, only: %i[show edit update destroy toggle_pin increment_copy_count]

  # GET /logs
  # メイン画面：検索・フィルタ・ピン留め・詳細表示
  def index
    @categories      = current_user.categories.order(:name)
    @tag_suggestions = Tag.order(:name) # まずは全タグでOK（必要があれば user スコープに変える）

    base = current_user.logs
                       .includes(:category, :tags)
    base = apply_filters(base)

    @pinned_logs = base.where(pinned: true)
    @other_logs  = base.where(pinned: false)

    @selected_log =
      if params[:selected_id].present?
        base.find_by(id: params[:selected_id])
      else
        @pinned_logs.first || @other_logs.first
      end
  end

  # GET /logs/new
  def new
    @log = current_user.logs.new
  end

  # POST /logs
  def create
    @log = current_user.logs.new(log_params)

    if @log.save
      assign_tags(@log)
      redirect_to logs_path(selected_id: @log.id), notice: "ログを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /logs/:id/edit
  def edit
  end

  # PATCH/PUT /logs/:id
  def update
    if @log.update(log_params)
      assign_tags(@log)
      redirect_to logs_path(selected_id: @log.id), notice: "ログを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /logs/:id
  def destroy
    @log.destroy
    redirect_to logs_path, notice: "ログを削除しました。"
  end

  # PATCH /logs/:id/toggle_pin
  def toggle_pin
    @log.update(pinned: !@log.pinned)
    redirect_to logs_path(selected_id: @log.id), notice: (@log.pinned? ? "ピン留めしました。" : "ピン留めを外しました。")
  end

  # POST /logs/:id/increment_copy_count
  # CopyボタンのJSから叩く想定（レスポンスはステータスのみ）
  def increment_copy_count
    @log.increment!(:copy_count)
    head :ok
  end

  private

  def set_log
    @log = current_user.logs.find(params[:id])
  end

  # 検索・フィルタ・ソートの適用
  def apply_filters(scope)
    # キーワード検索（タイトル/本文/コード）
    if params[:q].present?
      q = "%#{params[:q]}%"
      scope = scope.where("title LIKE :q OR body LIKE :q OR code LIKE :q", q: q)
    end

    # カテゴリフィルタ
    if params[:category_id].present?
      scope = scope.where(category_id: params[:category_id])
    end

    # タグで絞り込み（単一タグ想定。拡張はあとでOK）
    if params[:tag].present?
      scope = scope.joins(:tags).where(tags: { name: params[:tag] }).distinct
    end

    # ソート
    case params[:sort]
    when "used"
      scope.order(copy_count: :desc)
    else
      scope.order(updated_at: :desc)
    end
  end

  # ストロングパラメーター
  def log_params
    params.require(:log).permit(
      :title,
      :body,
      :code,
      :category_id,
      images: [] # ActiveStorage
    )
  end

  # タグの紐付け（フォームから tag_names を "Ruby, Rails, scope" みたいな形式で受け取る想定）
  def assign_tags(log)
    return unless params[:tag_names].present?

    names = params[:tag_names]
              .split(",")
              .map(&:strip)
              .reject(&:blank?)

    tags = names.map { |name| Tag.find_or_create_by(name: name) }
    log.tags = tags
  end
end
