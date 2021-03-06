class SiteController < ApplicationController
  def index
    @adv = Advertise.find( :all, :order => "updated_at DESC" , :limit => 2)
    @events = Event.where(published: 'published').limit(6).order("like_count DESC")
    @news = News.find( :all, :order => "created_at DESC" , :limit => 4)
  end

  def result
   @search = Sunspot.search Place, News, Event do 
      fulltext params[:search]
     end
   @result = @search.results
   @events = Event.all.limit(2).order("RANDOM()")
  end

  def contact_us
    @events = Event.all.limit(2).order("RANDOM()")
  end
end
