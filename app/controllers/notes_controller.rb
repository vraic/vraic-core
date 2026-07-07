class NotesController < ApplicationController
  before_action :require_account!
  before_action :set_notable

  def create
    @note = @notable.staff_notes.build(note_params)
    @note.user = Current.user
    @note.account = Current.account

    authorize @note

    if @note.save
      redirect_to @notable, notice: "Note was successfully created."
    else
      redirect_to @notable, alert: "Note could not be created: #{@note.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_notable
    if params[:order_id]
      @notable = Order.find(params[:order_id])
    end
  end

  def note_params
    params.require(:note).permit(:content)
  end
end
