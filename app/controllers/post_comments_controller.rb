class PostCommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @post_comment = current_user.post_comment.new(post_comment_params)
    @post_comment.book_id = @book.id
    if @post_comment.save
      redirect_to book_path(@book)
    else
      @book_new = Book.new
      render 'books/show'
    end
  end

  def destroy
    PostComment.find(params[:id]).destroy
    redirect_to request.referer
  end

  private

  def post_comment_params
    params.require(:post_comment).permit(:comment)
  end

end
