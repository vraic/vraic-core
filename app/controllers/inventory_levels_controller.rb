class InventoryLevelsController < ApplicationController
  before_action :set_inventory_level, only: %i[ show edit update destroy ]
  before_action :set_inventory_item, only: %i[ create transfer ]

  # GET /inventory_levels or /inventory_levels.json
  def index
    @inventory_levels = policy_scope(InventoryLevel)
  end

  # GET /inventory_levels/1 or /inventory_levels/1.json
  def show
    authorize @inventory_level
  end

  # GET /inventory_levels/new
  def new
    @inventory_level = InventoryLevel.new
    authorize @inventory_level
  end

  # GET /inventory_levels/1/edit
  def edit
    authorize @inventory_level
  end

  # POST /inventory_levels or /inventory_levels.json
  def create
    @inventory_level = @inventory_item.inventory_levels.find_or_initialize_by(location_id: params[:location_id])
    @inventory_level.quantity = params[:quantity]
    authorize @inventory_level

    respond_to do |format|
      if @inventory_level.save
        format.html { redirect_to @inventory_item, notice: "Stock was successfully adjusted." }
        format.json { render :show, status: :created, location: @inventory_level }
      else
        format.html { redirect_to @inventory_item, alert: "Failed to adjust stock: #{@inventory_level.errors.full_messages.join(', ')}", status: :unprocessable_content }
        format.json { render json: @inventory_level.errors, status: :unprocessable_content }
      end
    end
  end

  def transfer
    from_location = Location.find(params[:from_location_id])
    to_location = Location.find(params[:to_location_id])
    quantity = params[:transfer_quantity].to_i

    InventoryLevel.transaction do
      from_level = @inventory_item.inventory_levels.find_by(location: from_location)

      if from_level.nil? || from_level.quantity < quantity
        redirect_to @inventory_item, alert: "Insufficient stock at #{from_location.name}."
        return
      end

      to_level = @inventory_item.inventory_levels.find_or_initialize_by(location: to_location)
      authorize to_level, :create?

      from_level.update!(quantity: from_level.quantity - quantity)
      to_level.update!(quantity: (to_level.quantity || 0) + quantity)
    end

    redirect_to @inventory_item, notice: "Successfully transferred stock."
  rescue => e
    redirect_to @inventory_item, alert: "Transfer failed: #{e.message}"
  end

  # PATCH/PUT /inventory_levels/1 or /inventory_levels/1.json
  def update
    authorize @inventory_level
    respond_to do |format|
      if @inventory_level.update(inventory_level_params)
        format.html { redirect_to @inventory_level.inventory_item, notice: "Stock was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @inventory_level }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @inventory_level.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /inventory_levels/1 or /inventory_levels/1.json
  def destroy
    authorize @inventory_level
    @inventory_level.destroy!

    respond_to do |format|
      format.html { redirect_to @inventory_level.inventory_item, notice: "Inventory level was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_level
      @inventory_level = InventoryLevel.find(params.expect(:id))
    end

    def set_inventory_item
      @inventory_item = InventoryItem.find(params[:inventory_item_id])
    end

    # Only allow a list of trusted parameters through.
    def inventory_level_params
      params.expect(inventory_level: [ :inventory_item_id, :location_id, :quantity ])
    end
end
