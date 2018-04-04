class RunsController < ApplicationController
  include DataPro
  include OrdersPro
  include AccountPro
  
  before_action :set_run, only: [:show, :edit, :update, :destroy, :cancel, :check_fix_orders, :check_orders, :place_orders]

  ################################################################################
  #   Run cancelation:
  #     - cancels all active Orders
  #     - cancels active Fix Order if exists
  #     - cancels the run
  #   No new Fix Order is screated
  ################################################################################
  def cancel
    flash[:danger] = []
    
    # Cancel orders
    @run.orders.each do |order|
      error_msg = cancel_order order
      flash[:danger] << error_msg if error_msg.present?
 
      error_msg = check_order order                     # Check final Order status now
      flash[:danger] << error_msg if error_msg.present?
    end
    
    # Cancel Fix Order
    if flash[:danger].empty?
      active_fix_order = @run.orders.executed.last.fix_order
      
      if active_fix_order.present? and active_fix_order.active?
        error_msg = cancel_order active_fix_order
        flash[:danger] << error_msg if error_msg.present?

        error_msg = check_fix_order active_fix_order      # Check final Fix Order status now
        flash[:danger] << error_msg if error_msg.present?
      end
    end

    # Cancel Run
    if flash[:danger].empty?
      @run.update! status: 'canceled'
      
      flash.discard
      flash[:success] = "Well done! Runs has been canceled"
    end

    redirect_to @run    
  end

  
  def check_orders
    flash[:danger] = []
    
    @run.orders.each do |order|
      error_msg = check_order order
      flash[:danger] << error_msg if error_msg.present?
    end
    
    if flash[:danger].empty?
      flash.discard
      flash[:success] = "Well done! Orders have been checked"
    end

    redirect_to @run
  end
  
  def check_fix_orders
    flash[:danger] = []
    
    @run.orders.each do |order|
      fix_order = order.fix_order
      if fix_order.present?
        error_msg = check_fix_order fix_order
        flash[:danger] << error_msg if error_msg.present?
      end
      
      if flash[:danger].empty?
        flash.discard
        flash[:success] = "Well done! Fix Orders have been checked"
      end
      
      redirect_to @run
    end
  end

  def create
    @run = Run.new(run_params)
    
    respond_to do |format|
      if @run.save
        create_orders @run
        flash[:success] = 'Run was successfully created'
        format.html { redirect_to @run }
        format.json { render :show, status: :created, location: @run }
      else
        format.html { render :new }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @run.destroy
    respond_to do |format|
      flash[:alert] = 'Run was successfully destroyed'
      format.html { redirect_to runs_url }
      format.json { head :no_content }
    end
  end
  
  def edit
  end

  def index
    @runs = Run.all
  end

  def new
    @run = Run.new
    @account_data  = get_account_data
    
    # Update Tickers
    @pair_names = []
    @tickers    = []
    
    Pair.active.order(:name).each do |pair|
      pair_name = pair.name
      @pair_names[pair.id] = pair_name
      @tickers << get_ticker(pair_name)#[pair_name]
    end
    
    # Data for JS functions
    objects = []              # array of ticker SINGLE hashes
    @tickers.each do |ticker|
      object = {}
      object['pair'] = ticker.first.first
      object.merge! ticker.first.last
      objects << object
    end

    @run.pair = Pair.active.order(:name).first
    objects.each do |object|
      @run.last = object['last'] if object['pair'] == @run.pair.name
    end
    if @run.kind == 'ask'
      @run.stop_loss = @run.last * (1. - @run.overlay * 2 / 100.0)
    else
      @run.stop_loss = @run.last * (1. + @run.overlay * 2 / 100.0)
    end

    gon.pair_names = @pair_names
    gon.objects    = objects   
  end

  ##############################################################################
  # Places just created fix_order
  # It must be ONE such a created order (all others should be canceled before)
  ##############################################################################
  def place_fix_order
    run       = Run.find(params['id'])
    fix_order = FixOrder.created.first
    
    error_msg      = place_order fix_order, true
    flash[:danger] = error_msg if error_msg.present?

    if flash[:danger].empty?
      flash.discard
      flash[:success] = "Well done! Fix Order #{fix_order.id} (#{fix_order.x_id}) has been placed"
    end
    
    redirect_to run
  end

  ##############################################################################
  # Places created Run orders
  ##############################################################################
  def place_orders
    flash[:danger] = []
    
    @run.orders.each do |order|
      error_msg = place_order order
      flash[:danger] << error_msg if error_msg.present?
    end
    
    if flash[:danger].empty?
      @run.update! status: 'active'
      
      flash.discard
      flash[:success] = "Well done! Orders have been placed"
    end
    
    redirect_to @run
  end
  
  def show
    @account_data  = get_account_data
#    @active_orders = ZtBtce.active_orders
    
    @orders     = @run.orders
    @fix_orders = []
    
    @orders.each do |order|
      fix_order    = order.fix_order
      @fix_orders << fix_order if fix_order.present?
    end
  end
  
  def update
    respond_to do |format|
      if @run.update(run_params)
        flash[:success] = 'Run was successfully updated'
        format.html { redirect_to @run }
#       format.html { redirect_to @run, notice: 'Run was successfully updated.' } - obsolete
        format.json { render :show, status: :ok, location: @run }
      else
        format.html { render :edit }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_run
      @run = Run.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def run_params
      params.require(:run).permit(:pair_id, :kind, :depo, :last, :indent, :overlay, :martingale, :orders_number, :profit, :scale, :stop_loss, :status)
    end
end
