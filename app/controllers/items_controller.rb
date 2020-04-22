class ItemsController < ApplicationController

  def index
    @items = Item.found
  end

  def all
    @items = Item.all
  end

  def param_search
    @items = Item.query_params(params)
  end

  def show
    @items =Item.claimed
  end

  def new

<<<<<<< HEAD
  end

  def create
    @Item = Item.new()
    @Item.itemDate = Time.now();
    @Item.itemFoundAt = Time.now();
    @Item.itemLocation = params[:itemLocation].to_i;
    @Item.itemType = params[:itemType];
    @Item.itemDescription= params[:itemDescription];
    @Item.itemLastModified=Time.now();
    @Item.itemStatus = 1;
    @Item.itemEnteredBy = "unknown";
    @Item.itemImage = "none";
    @Item.itemObsolete = 0;
    @Item.itemUpdatedBy = "??????";
    @Item.itemFoundBy = params[:itemFoundBy] || 'anonymous';
    @Item.libID = 115;
    @Item.created_at =Time.now();
    @Item.updated_at = Time.now();


    if @Item.save!
      @items = @Item
       redirect_to :action => 'index'
    else
       @items = Item.all
       render :action => 'index'
    end
  end

=======
  end

  def create
    @Item = Item.new()
    @Item.itemDate = Time.now();
    @Item.itemFoundAt = Time.now();
    @Item.itemLocation = params[:itemLocation].to_i;
    @Item.itemType = params[:itemType];
    @Item.itemDescription= params[:itemDescription];
    @Item.itemLastModified=Time.now();
    @Item.itemStatus = 1;
    @Item.itemEnteredBy = "unknown";
    @Item.itemImage = "none";
    @Item.itemObsolete = 0;
    @Item.itemUpdatedBy = "??????";
    @Item.itemFoundBy = params[:itemFoundBy] || 'anonymous';
    @Item.libID = 115;
    @Item.created_at =Time.now();
    @Item.updated_at = Time.now();


    if @Item.save!
      @items = @Item
       redirect_to :action => 'index'
    else
       @items = Item.all
       render :action => 'index'
    end
  end

>>>>>>> Adding basic CRUD features to insert and search on keywords
  def item_params
    params.permit(:itemLocation, :itemType, :itemDescription)
 end

  def edit
  end

  def update
  end

  def delete
  end

  def destroy
  end
end