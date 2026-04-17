require "test_helper"

class OcrPromptPatternTest < ActiveSupport::TestCase
  test "valid pattern" do
    pattern = OcrPromptPattern.new(name: "Test", prompt: "Test prompt")
    assert pattern.valid?
  end

  test "requires name" do
    pattern = OcrPromptPattern.new(prompt: "Test prompt")
    assert_not pattern.valid?
    assert_includes pattern.errors[:name], "can't be blank"
  end

  test "requires prompt" do
    pattern = OcrPromptPattern.new(name: "Test")
    assert_not pattern.valid?
    assert_includes pattern.errors[:prompt], "can't be blank"
  end

  test "name must be unique" do
    existing = ocr_prompt_patterns(:default_pattern)
    pattern = OcrPromptPattern.new(name: existing.name, prompt: "Test")
    assert_not pattern.valid?
    assert_includes pattern.errors[:name], "has already been taken"
  end

  test "ordered scope returns patterns by position" do
    patterns = OcrPromptPattern.ordered
    assert_equal patterns.first.position, patterns.map(&:position).min
  end

  test "default_or_first returns default pattern" do
    default = ocr_prompt_patterns(:default_pattern)
    assert_equal default, OcrPromptPattern.default_or_first
  end

  test "default_or_first returns first when no default" do
    OcrPromptPattern.update_all(is_default: false)
    first = OcrPromptPattern.ordered.first
    assert_equal first, OcrPromptPattern.default_or_first
  end

  test "set_as_default! sets pattern as default and clears others" do
    default = ocr_prompt_patterns(:default_pattern)
    other = ocr_prompt_patterns(:detailed_pattern)

    assert default.is_default?
    assert_not other.is_default?

    other.set_as_default!

    default.reload
    other.reload

    assert_not default.is_default?
    assert other.is_default?
  end
end
