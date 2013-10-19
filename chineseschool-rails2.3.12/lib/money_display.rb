class MoneyDisplay

  extend ActionView::Helpers::NumberHelper

  def self.display_price(price)
    if price < 0
      '-&nbsp;' + number_to_currency(- price)
    else
      number_to_currency price
    end
  end
end
