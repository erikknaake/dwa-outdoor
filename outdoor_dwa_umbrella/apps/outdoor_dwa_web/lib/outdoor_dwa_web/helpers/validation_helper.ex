defmodule OutdoorDwaWeb.ValidationHelper do
  def submit_button_css_classes(is_disabled) do
    "button button--primary " <>
      case is_disabled do
        true -> "button--disabled"
        false -> ""
      end
  end
end
