class RowsController < ApplicationController
  before_action :set_row, only: %i[ show edit update destroy ]

  # GET /rows or /rows.json
  def index
    STDERR.puts "IN DEX"
    @rows = Row.all
  end

  # GET /rows/1 or /rows/1.json
  def show
  end

  # GET /rows/new
  def new
    @row = Row.new
  end

  # GET /rows/1/edit
  def edit
  end

  # POST /rows or /rows.json
  def create
    @row = Row.new(row_params)

    respond_to do |format|
      if @row.save
        format.html { redirect_to @row, notice: "Row was successfully created." }
        format.json { render :show, status: :created, location: @row }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @row.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rows/1 or /rows/1.json
  def update
    respond_to do |format|
      if @row.update(row_params)
        format.html { redirect_to @row, notice: "Row was successfully updated." }
        format.json { render :show, status: :ok, location: @row }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @row.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rows/1 or /rows/1.json
  def destroy
    @row.destroy!

    respond_to do |format|
      format.html { redirect_to rows_path, status: :see_other, notice: "Row was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_row
      @row = Row.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def row_params
      params.fetch(:row, {})
    end
end
