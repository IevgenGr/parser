class ArticlesController < ApplicationController

  def create
    @article = Article.create(article_params)
    if @article.save
      flash[:success] = 'Article added.'
    else
      flash[:error] = @source.errors.full_messages
      @article.errors.full_messages
    end
  end

  def article_params
    params.require(:article).permit(:link, :headline, :snippet, :date)
  end

  def delete_all
    Article.all.each do |article|
      article.destroy
    end
    redirect_to root_path
  end



end
