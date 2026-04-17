require "test_helper"

module Admin
  class OcrPromptPatternsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
      @pattern = ocr_prompt_patterns(:default_pattern)
    end

    test "index requires admin" do
      sign_in @user
      get admin_ocr_prompt_patterns_path
      assert_redirected_to root_path
    end

    test "index lists patterns" do
      sign_in @admin
      get admin_ocr_prompt_patterns_path
      assert_response :success
      assert_select "table"
    end

    test "new shows form" do
      sign_in @admin
      get new_admin_ocr_prompt_pattern_path
      assert_response :success
      assert_select "form"
    end

    test "create creates pattern" do
      sign_in @admin
      assert_difference "OcrPromptPattern.count", 1 do
        post admin_ocr_prompt_patterns_path, params: {
          ocr_prompt_pattern: {
            name: "新しいパターン",
            prompt: "新しいプロンプト",
            position: 10
          }
        }
      end
      assert_redirected_to admin_ocr_prompt_patterns_path
    end

    test "create with invalid params shows errors" do
      sign_in @admin
      assert_no_difference "OcrPromptPattern.count" do
        post admin_ocr_prompt_patterns_path, params: {
          ocr_prompt_pattern: { name: "", prompt: "" }
        }
      end
      assert_response :unprocessable_entity
    end

    test "edit shows form" do
      sign_in @admin
      get edit_admin_ocr_prompt_pattern_path(@pattern)
      assert_response :success
      assert_select "form"
    end

    test "update updates pattern" do
      sign_in @admin
      patch admin_ocr_prompt_pattern_path(@pattern), params: {
        ocr_prompt_pattern: { name: "更新された名前" }
      }
      assert_redirected_to admin_ocr_prompt_patterns_path
      @pattern.reload
      assert_equal "更新された名前", @pattern.name
    end

    test "destroy deletes pattern" do
      sign_in @admin
      assert_difference "OcrPromptPattern.count", -1 do
        delete admin_ocr_prompt_pattern_path(@pattern)
      end
      assert_redirected_to admin_ocr_prompt_patterns_path
    end

    test "set_default sets pattern as default" do
      sign_in @admin
      other = ocr_prompt_patterns(:detailed_pattern)
      assert_not other.is_default?

      patch set_default_admin_ocr_prompt_pattern_path(other)
      assert_redirected_to admin_ocr_prompt_patterns_path

      other.reload
      assert other.is_default?
    end
  end
end
