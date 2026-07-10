class OrdersController < ApplicationController
  before_action :set_company, only: %i[index create]
  before_action :set_order, only: %i[show update destroy]

  def index
    render json: @company.orders
  end

  def show
    render json: @order
  end

  def create
    order = @company.orders.new(order_params)
    order.source = :web

    if order.save
      render json: order, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:customer_name, :customer_email, :item_description, :quantity, :total, :status)
  end
end
