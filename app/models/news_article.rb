class NewsArticle < ActiveRecord::Base
  def self.latest
    first(:conditions => { :published => true, :deleted => false }, :order => "release_date desc")
  end
end