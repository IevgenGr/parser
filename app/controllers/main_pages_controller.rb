class MainPagesController < ApplicationController


  def index
    order_options_save = ['DESK' => 'Sort by Date High to Low', 'ASC' => 'Sort by Date Low to High']
    p parameters = params.permit(params.keys).to_h.map{ |e, i| e.to_i }.select{|e| e > 0}
    cookies[:filter_and_order_status] = parameters
    cookies[:date] = params[:date]
    p order_options_save
    cookies[:sort_status] = order_options_save[0][params[:sort_option]] if params[:sort_option].present?
    @articles = Article.all
    @articles = @articles.where("created_at::date = ?", params[:date]) if params[:date].present?
    @articles = @articles.where({ source_id: parameters}) if parameters.size > 0
    @pagy, @articles = pagy(@articles, items: 10)
    @articles = sort @articles
  end

  def reset
    cookies.delete :date
    cookies.delete :filter_and_order_status
    cookies.delete :sort_status
    redirect_to '/'
  end


  def parse
    parse_nytimes if params[:NYT].present?
    parse_bloomberg if params[:Bloomberg].present?
    parse_economist if  params[:The_Economist].present?
    redirect_to '/'
  end

    def parse_economist
      agent = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      page = agent.get('https://www.economist.com/search?q=ukraine&sort=date')
      @articles = Article.all
      @arr = Array.new
      page.css('a._search-result').each do |link|
        @arr.push(link[:href])
        s = (link.css('span._headline').text).split('|')[0]
        s2 = link.css('img._image')[0]["src"]
        s3 = s2
        @arr.push(link.css('p._snippet').text)
        @article = Article.create(link: link[:href], headline: s, snippet: link.css('p._snippet').text.split('...')[1] ,date: Time.now, source_id: Source.find_by(name: "The_Economist").id, image: s3 )
        @article.save
        p @article.errors.full_messages
        p @article
        p '7777'
      end
      end

      def parse_nytimes
        agent = Mechanize.new
        agent.user_agent_alias = 'Linux Mozilla'
        page = agent.get('https://www.nytimes.com/search?dropmab=false&query=ukraine&sort=newest')
        @articles = Article.all
        @arr = Array.new
        page.css('div.css-1kl114x').each do |link|
          p parse_link =  'https://www.nytimes.com' + link.css('.css-e1lvw9 a')[0]['href']
          p link.css('h4').text
          p link.css('p').text
          image_link = link.css('.css-rq4mmj[src]')
          image_link = image_link.map {|element| element["src"]}.join
          p @source1 = Source.find_by(name: "NYT")
          p "-+-+-+-"
          @article = Article.create(link: parse_link, headline: link.css('p').text, snippet: link.css('h4').text ,date: Time.now, source_id: Source.find_by(name: "NYT").id, image: image_link )
          @article.save
          p '__________________________________________'
        end
      end

  def parse_bloomberg
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Mozilla'
    page = agent.get('https://www.bloomberg.com/search?query=Ukraine#')
    @articles = Article.all
    @arr = Array.new
     page.css('.storyItem__4d5aa17d67').each do |link|
      p '777'
      p link.css('a.headline__96ba1917df').text
      parse_link = link.css('a.headline__96ba1917df')[0]['href']
      p link.css('a.summary__f7259c7b77').text
      image_link = link.css('img.thumbnail__55f7ac7947')[0]['src'] unless link.css('img.thumbnail__55f7ac7947').to_s == ""
      image_link = "" if link.css('img.thumbnail__55f7ac7947').to_s == ""
      @article = Article.create(link: parse_link, headline: link.css('a.headline__96ba1917df').text, snippet: link.css('a.summary__f7259c7b77').text ,date: Time.now, source_id: Source.find_by(name: "Bloomberg").id, image: image_link )
      @article.save
      p '__________________________________________'
    end
  end

  def show;  end



  def article_params
    params.require(:article).permit(:link, :headline, :snippet, :date, :image )
  end

  def sort(articles)
    if params[:sort_option] == 'ASC'
      articles.order(created_at: :ASC)
    else
      articles.order(created_at: :desc)
    end
  end


end
