Spree::Admin::LineItemsController.class_eval do
  prepend_before_filter :load_order, except: :index
  around_filter :apply_with_lock, only: [:create, :update, :destroy]

  respond_to :json

  # TODO make updating line items faster by creating a bulk update method

  def index
    respond_to do |format|
      format.json do
        order_params = params[:q].andand.delete :order
        orders = OpenFoodNetwork::Permissions.new(spree_current_user).editable_orders.ransack(order_params).result
        line_items = OpenFoodNetwork::Permissions.new(spree_current_user).editable_line_items.where(order_id: orders).ransack(params[:q])
        render_as_json line_items.result.reorder('order_id ASC, id ASC')
      end
    end
  end

  def create
    variant = Spree::Variant.find(params[:line_item][:variant_id])
    OpenFoodNetwork::ScopeVariantToHub.new(@order.distributor).scope(variant)

    @line_item = @order.add_variant(variant, params[:line_item][:quantity].to_i)

    if @order.save
      @order.update_distribution_charge!

      respond_with(@line_item) do |format|
        format.html { render :partial => 'spree/admin/orders/form', :locals => { :order => @order.reload } }
        format.json do
          if request.referrer == main_app.admin_pos_url
            line_item = Api::Admin::ForPos::LineItemSerializer.new(@line_item.reload).serializable_hash
            order = Api::Admin::ForPos::OrderSerializer.new(@order.reload).serializable_hash
            render json: { line_item: line_item, order: order }
          else
            render_as_json @line_item.reload
          end
        end
      end
    else
      respond_with(@line_item) do |format|
        format.js { render :action => 'create', :locals => { :order => @order.reload } }
      end
    end
  end

  def update
    if @line_item.update_attributes(params[:line_item])
      @order.update_distribution_charge! # Added this line to update enterprise fees

      respond_with(@line_item) do |format|
        format.html { render :partial => 'spree/admin/orders/form', :locals => { :order => @order.reload } }
      end
    else
      respond_with(@line_item) do |format|
        format.html { render :partial => 'spree/admin/orders/form', :locals => { :order => @order.reload } }
      end
    end
  end

  def destroy
    @line_item.destroy
    @order.update_distribution_charge! # Added this line to update enterprise fees

    respond_with(@line_item) do |format|
      format.html { redirect_to edit_admin_order_path(@order) }
      format.js { @order.reload }
      format.json {
        if request.referrer == main_app.admin_pos_url
          render json: @order.reload, serializer: Api::Admin::ForPos::OrderSerializer
        else
          render json: @order.reload, serializer: Api::Admin::OrderSerializer
        end
      }
    end
  end


  private

  def load_order
    @order = Spree::Order.find_by_number!(params[:order_id])
    authorize! :update, @order
  end

  def apply_with_lock
    authorize! :read, @order
    @order.with_lock do
      yield
    end
  end
end
