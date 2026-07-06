module ApplicationHelper
  def enum_options_for_select(instance, enum)
    options_for_select(enum_collection(instance, enum), instance.send(enum))
  end

  def enum_collection(instance, enum)
    instance.class.send(enum.to_s.pluralize).keys.to_a.map { |key| [ key.humanize, key ] }
  end

  def nav_item_active?(item)
    case item
    when :dashboard
      controller_name == "pages" && ["home", "dashboard"].include?(action_name)
    when :customers
      controller_name == "customers"
    when :settings
      ["accounts", "account_users", "users"].include?(controller_name)
    else
      false
    end
  end

  def nav_link_classes(item_key, extra_classes = nil)
    active = nav_item_active?(item_key)
    base_classes = ["group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold", extra_classes].compact.join(" ")
    
    if active
      "#{base_classes} bg-gray-50 text-indigo-600 dark:bg-white/5 dark:text-white"
    else
      "#{base_classes} text-gray-700 hover:text-indigo-600 hover:bg-gray-50 dark:text-gray-400 dark:hover:text-white dark:hover:bg-white/5"
    end
  end

  def nav_icon_classes(item_key, extra_classes = nil)
    active = nav_item_active?(item_key)
    base_classes = ["size-6 shrink-0", extra_classes].compact.join(" ")
    
    if active
      "#{base_classes} text-indigo-600 dark:text-white"
    else
      "#{base_classes} text-gray-400 group-hover:text-indigo-600 dark:group-hover:text-white"
    end
  end
end
