class PagesController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization

  def consent_sample
  end

  def contact_us
  end

  def privacy
  end
end
