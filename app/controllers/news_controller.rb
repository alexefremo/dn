class NewsController < ApplicationController
  before_action :set_news, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, only: [:new, :edit, :destroy]

  before_filter :authorize_admin, only: [:show, :edit, :update, :destroy]

  def authorize_admin
    unless current_user.right == "administrator" 
      redirect_to root_path, :notice => 'You are not authorized'
    end
  end


  # GET /news
  # GET /news.json
  def index
    @news = News.order("created_at").page(params[:page]).per(4)
    @places = Place.all.limit(2).order("RANDOM()")
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find_by_slug!(params[:id])
    @places = Place.all.limit(2).order("RANDOM()")
  end

  # GET /news/new
  def new
    @news = News.new
  end

  # GET /news/1/edit
  def edit
  end

  # POST /news
  # POST /news.json
  def create
    @news = News.new(news_params)
    @news.user_id = current_user.id
    respond_to do |format|
      if @news.save
        format.html { redirect_to manage_content_path, notice: 'News was successfully created.' }
        format.json { render action: 'show', status: :created, location: @news }
      else
        format.html { render action: 'new' }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news/1
  # PATCH/PUT /news/1.json
  def update
    respond_to do |format|
      if @news.update(news_params)
        format.html { redirect_to manage_content_path, notice: 'News was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news.destroy
    respond_to do |format|
      format.html { redirect_to manage_content_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_news
      @news = News.find_by_slug!(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def news_params
      params.require(:news).permit(:title, :content, :user_id)
    end
end
