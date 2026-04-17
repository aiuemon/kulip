module Admin
  class OcrPromptPatternsController < BaseController
    before_action :set_ocr_prompt_pattern, only: %i[edit update destroy set_default]

    def index
      @ocr_prompt_patterns = OcrPromptPattern.ordered
    end

    def new
      @ocr_prompt_pattern = OcrPromptPattern.new
    end

    def create
      @ocr_prompt_pattern = OcrPromptPattern.new(ocr_prompt_pattern_params)

      if @ocr_prompt_pattern.save
        redirect_to admin_ocr_prompt_patterns_path, notice: "プロンプトパターンを作成しました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @ocr_prompt_pattern.update(ocr_prompt_pattern_params)
        redirect_to admin_ocr_prompt_patterns_path, notice: "プロンプトパターンを更新しました。"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @ocr_prompt_pattern.destroy
      redirect_to admin_ocr_prompt_patterns_path, notice: "プロンプトパターンを削除しました。"
    end

    def set_default
      @ocr_prompt_pattern.set_as_default!
      redirect_to admin_ocr_prompt_patterns_path, notice: "「#{@ocr_prompt_pattern.name}」をデフォルトに設定しました。"
    end

    private

    def set_ocr_prompt_pattern
      @ocr_prompt_pattern = OcrPromptPattern.find(params[:id])
    end

    def ocr_prompt_pattern_params
      params.require(:ocr_prompt_pattern).permit(:name, :prompt, :position)
    end
  end
end
