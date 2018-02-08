class RunsController < ApplicationController
  include DataPro
  before_action :set_run, only: [:show, :edit, :update, :destroy]

  # GET /runs
  # GET /runs.json
  def index
    @runs = Run.all
  end

  # GET /runs/1
  # GET /runs/1.json
  def show
  end

  # GET /runs/new
  def new
    @run = Run.new
    
    # Update Tickers
    @pair_names = []
    @tickers    = []
    Pair.active.order(:name).each do |pair|
      pair_name = pair.name
      @pair_names[pair.id] = pair_name
#      @pair_names << pair_name
      @tickers << get_ticker(pair_name)
    end 

    @run.pair = Pair.active.order(:name).first
    @run.last = @tickers.first.first.last['last']
    if @run.kind == 'ask'
      @run.stop_loss = @run.last * (1. - @run.overlay * 2 / 100.0)
    else
      @run.stop_loss = @run.last * (1. + @run.overlay * 2 / 100.0)
    end
#    puts @run.inspect
    gon.pair_names = @pair_names
    gon.tickers    = @tickers#.to_json
    puts "gon.tickers:  #{gon.tickers}"
  end

  # GET /runs/1/edit
  def edit
  end

  # POST /runs
  # POST /runs.json
  def create
    @run = Run.new(run_params)

    respond_to do |format|
      if @run.save
        format.html { redirect_to @run, notice: 'Run was successfully created.' }
        format.json { render :show, status: :created, location: @run }
      else
        format.html { render :new }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /runs/1
  # PATCH/PUT /runs/1.json
  def update
    respond_to do |format|
      if @run.update(run_params)
        format.html { redirect_to @run, notice: 'Run was successfully updated.' }
        format.json { render :show, status: :ok, location: @run }
      else
        format.html { render :edit }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /runs/1
  # DELETE /runs/1.json
  def destroy
    @run.destroy
    respond_to do |format|
      format.html { redirect_to runs_url, notice: 'Run was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_run
      @run = Run.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def run_params
      params.require(:run).permit(:pair_id, :kind, :depo, :last, :start, :overlay, :martingale, :orders, :profit, :scale, :stop_loss, :status)
    end
end
