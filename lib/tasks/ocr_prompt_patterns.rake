namespace :ocr_prompt_patterns do
  desc "デフォルトの OCR プロンプトパターンを登録する"
  task seed: :environment do
    patterns = [
      {
        position: 1,
        name: "JSON出力",
        prompt: "この画像のテキストを文字起こししてください。見出し、段落、箇条書きなどをLLMの能力で解釈し、JSON 形式で正確に構造化して出力してください。",
        is_default: true
      },
      {
        position: 2,
        name: "Markdown出力",
        prompt: "この画像のテキストを文字起こししてください。見出し、段落、箇条書きなどをLLMの能力で解釈し、Markdown形式で美しく構造化して出力してください。",
        is_default: false
      }
    ]

    patterns.each do |attrs|
      pattern = OcrPromptPattern.find_or_initialize_by(name: attrs[:name])
      pattern.assign_attributes(attrs)
      if pattern.save
        puts "#{pattern.new_record? ? '作成' : '更新'}: #{pattern.name}"
      else
        puts "エラー: #{pattern.name} - #{pattern.errors.full_messages.join(', ')}"
      end
    end

    puts "完了: #{OcrPromptPattern.count} 件のパターンが登録されています"
  end
end
