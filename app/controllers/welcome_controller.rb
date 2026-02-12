class WelcomeController < ApplicationController
  # GET /welcome
  def index
    @widgets = Widget.order(created_at: :desc).limit(5)
    @widget_count = Widget.count
    @total_stock = Widget.sum(:stock) || 0
  end
end
