class RunsController < ApplicationController
  include DataPro
  include OrdersPro
  
  before_action :set_run, only: [:show, :edit, :update, :destroy]

  def cancel_run
    
  end
  
  # Cancel all Run's non-closed yet Orders 
  def cancel_orders
    run           = Run.find(params['id'])
    orders_active = run.orders.active
    
    if orders_active.present?
      orders_active.each do |order|
        cancel_order order
    end

    # Need to create Fix Order
    fix_order            = Order.new
    fix_order.run_id     = run.id
    fix_order.amount     = 0.0
    fix_order.wavg_price = nil
    fix_order.fix_price  = nil
    
    # Canceled or executed partly order - gets its Fix
    orders_canc_or_exec_part = run.orders.canc_or_exec_part
    if orders_canc_or_exec_part.present?
      canc_order = orders_canc_or_exec_part.first

      fix_order.price  = canc_order.fix_price
      fix_order.amount = canc_order.amount
    end

      
#      amount = order_exec_part * 

      
      place_fixed_order 
    end
     
    if order_exec_part.nil?
      order_last_exec = orders.find_by("status = ?", 'executed').order(:id).last
      if order_last_exec.nil?
        
      end
    end
    orders.reverse.each_with_index do |order, index|
      if order.status == 'executed' || order.status == 'cxnd_or_exec_part'
      end
    end
    
  end
  
  # GET /runs
  # GET /runs.json
  def index
    @runs = Run.all
  end

  # GET /runs/1
  # GET /runs/1.json
  def show
    @orders = @run.orders
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

  # GET /runs/1/edit
  def edit
  end

  # POST /runs
  # POST /runs.json
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

  # PATCH/PUT /runs/1
  # PATCH/PUT /runs/1.json
  def update
    respond_to do |format|
      if @run.update(run_params)
        flash[:success] = 'Run was successfully updated'
        format.html { redirect_to @run }
#        format.html { redirect_to @run, notice: 'Run was successfully updated.' } - obsolete
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
      flash[:alert] = 'Run was successfully destroyed'
      format.html { redirect_to runs_url }
      format.json { head :no_content }
    end
  end

  # NB! Trade API method 'Trade' accepts *THREE* decimal digits for *price* only: round(3) to be applied!
  def place_orders
    flash[:danger] = []
    run  = Run.find(params['id'])
    type = (run.kind == 'ask') ? 'sell' : 'buy'
    
    run.orders.each do |order|
      response = ZtBtce.trade pair: run.pair.name, type: type, rate: order.price.round(3), amount: order.amount

      if response['success'] == 0                       # Error
        order.status = 'rejected'
        order.error  = response['error']
        order.save
        flash[:danger] << "Order #{order.id}: #{order.error}"
      else                                            # Order has been placed
        order.ex_id = response['return']['order_id']
        
        if order.ex_id == 0                          # Order was fully 'matched'
          order.status = 'executed'
        elsif
          order.status = 'active'
        end
        
        order.error = nil
        order.save
      end
    end
    if flash[:danger].empty?
      run.status = 'active'
      run.save!
      flash[:success] = "Well done"
    end
    redirect_to run
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
