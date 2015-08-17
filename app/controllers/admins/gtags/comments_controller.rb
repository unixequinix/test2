class Admins::Gtags::CommentsController < Admins::CommentsController
  before_action :set_commentable

  private

    def set_commentable
      @commentable = Gtag.find(params[:gtag_id])
    end
end