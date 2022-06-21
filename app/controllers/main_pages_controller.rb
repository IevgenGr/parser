# frozen_string_literal: true
class MainPagesController < ApplicationController

  def index
    parameters = params.permit(params.keys).to_h.map { |e, _i| e.to_i }.select(&:positive?)
    cookies[:filter_sources] = parameters
    @articles = Article.all
    @articles = @articles.where('created_at::date = ?', params[:date]) if params[:date].present?
    @articles = @articles.where({ source_id: parameters }) if parameters.size.positive?
    @pagy, @articles = pagy(@articles, items: 10)
    @articles = sort @articles
    respond_to do |format|
      format.js
      format.html
    end
  end

  def test_form
    @articles = Article.all
  end

  def reset
    redirect_to '/'
  end

  def parse
    parse_nytimes if params[:NYT].present?
    parse_wsj if params[:WSJ].present?
    parse_bloomberg if params[:Bloomberg].present?
    parse_economist if params[:The_Economist].present?
    redirect_to '/'
  end

  def parse_economist
    init_mechanize
    page = @agent.get('https://www.economist.com/search?q=ukraine&sort=date')
    page.css('a._search-result').each do |link|
     s = (link.css('span._headline').text).split('|')[0]
     s2 = link.css('img._image')[0]['src']
     s3 = s2
     @article = Article.create(link: link[:href], headline: s, snippet: link.css('p._snippet').text.split('...')[1],
                               date: Time.now, source_id: Source.find_by(name: 'The_Economist').id, image: s3)
     @article.save
   end
  end

  def parse_nytimes
    init_mechanize
    page = @agent.get('https://www.nytimes.com/search?dropmab=false&query=ukraine&sort=newest')
    page.css('div.css-1kl114x').each do |link|
      p parse_link = "https://www.nytimes.com#{link.css('.css-e1lvw9 a')[0]['href']}"
      image_link = link.css('.css-rq4mmj[src]')
      image_link = image_link.map { |element| element['src'] }.join
      @article = Article.create(link: parse_link, headline: link.css('p').text, snippet: link.css('h4').text,
                                date: Time.now, source_id: Source.find_by(name: 'NYT').id, image: image_link)
      @article.save
    end
  end

  def parse_bloomberg
    init_mechanize
    page = @agent.get('https://www.bloomberg.com/search?query=Ukraine#')
    page.css('.storyItem__4d5aa17d67').each do |link|
      p '777'
      p link.css('a.headline__96ba1917df').text
      parse_link = link.css('a.headline__96ba1917df')[0]['href']
      p link.css('a.summary__f7259c7b77').text
      unless link.css('img.thumbnail__55f7ac7947').to_s == ''
        image_link = link.css('img.thumbnail__55f7ac7947')[0]['src']
      end
      image_link = '' if link.css('img.thumbnail__55f7ac7947').to_s == ''
      @article = Article.create(link: parse_link, headline: link.css('a.headline__96ba1917df').text,
                                snippet: link.css('a.summary__f7259c7b77').text, date: Time.now,
                                source_id: Source.find_by(name: 'Bloomberg').id, image: image_link)
      @article.save
      p '__________________________________________'
    end
  end

  def parse_wsj
    init_mechanize
    page = @agent.get('https://www.wsj.com/search?query=Ukraine')
    page.search('div.WSJTheme--search-result--2NFlrTX7').each do |link|
      p '777'
      p link.search('span.WSJTheme--headlineText--He1ANr9C').text
      # parse_link = link.search('a.WSJTheme--headline--unZqjb45 undefined WSJTheme--heading-3--2z_phq5h typography--serif-display--ZXeuhS5E')[0]['href']
      p link.css('span.WSJTheme--summaryText--2LRaCWgJ').text
      unless link.css('img.WSJTheme--lazy-load').to_s == ''
        p image_link = link.css('img.WSJTheme--lazy-load-wrapper--1TOawUTd ')[0]['src']
      end
      image_link = '' if link.css('img.WSJTheme--lazy-load-wrapper--1TOawUTd').to_s == ''
      # @article = Article.create(link: parse_link, headline: link.css('a.headline__96ba1917df').text,
      #                           snippet: link.css('a.summary__f7259c7b77').text, date: Time.now, source_id: Source.find_by(name: 'Bloomberg').id, image: image_link)
      # @article.save
      p '__________________________________________'
    end
  end

  def show; end

  def article_params
    params.require(:article).permit(:link, :headline, :snippet, :date, :image)
  end

  def sort(articles)
    if params[:sort_option] == 'ASC'
      articles.order(created_at: :ASC)
    else
      articles.order(created_at: :desc)
    end
  end
end

def init_mechanize
  @agent = Mechanize.new
  @agent.user_agent_alias = Option.first.agent
end