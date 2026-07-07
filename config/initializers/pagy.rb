# Pagy initializer
# See https://ddnexus.github.io/pagy/docs/configuration

# Default number of items per page
Pagy::OPTIONS[:limit] = 20

# Use Rails I18n
Pagy.translate_with_the_slower_i18n_gem!

# Tailwind implementation for Pagy 43.5.6
class Pagy
  module NumericHelpers
    def tailwind_series_nav(**options)
      a_lambda = a_lambda(**options)

      # Previous button
      prev_page = self.previous
      html = if prev_page
               a_lambda.(prev_page, I18n.translate("pagy.previous"),
                         classes: "relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0",
                         aria_label: I18n.translate("pagy.aria_label.previous"))
      else
               %(<span class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 cursor-default" aria-disabled="true">#{I18n.translate('pagy.previous')}</span>)
      end

      series(**options).each do |item|
        html << case item
        when Integer
                  a_lambda.(item, classes: "relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0")
        when String
                  %(<span aria-current="page" class="relative z-10 inline-flex items-center bg-indigo-600 px-4 py-2 text-sm font-semibold text-white focus:z-20 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">#{page_label(item)}</span>)
        when :gap
                  %(<span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300 focus:outline-offset-0">#{I18n.translate('pagy.gap')}</span>)
        end
      end

      # Next button
      next_page = self.next
      html << if next_page
                a_lambda.(next_page, I18n.translate("pagy.next"),
                          classes: "relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0",
                          aria_label: I18n.translate("pagy.aria_label.next"))
      else
                %(<span class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 cursor-default" aria-disabled="true">#{I18n.translate('pagy.next')}</span>)
      end

      wrap_series_nav(html, "pagy-tailwind series-nav isolate inline-flex -space-x-px rounded-md shadow-sm", **options)
    end
  end
end
