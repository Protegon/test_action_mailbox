class TicketsController < ApplicationController
  def index
    @tickets = Ticket.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @tickets }
    end
  end

  def show
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @ticket }
    end
  end
end
