class Admins::CommentsController < Admins::BaseController
  before_action :authenticate_admin!

  def create
    @comment = @commentable.comments.build(permitted_params)
    @comment.admin = current_admin
    @comment.save
    redirect_to [:admins, @commentable], notice: I18n.t('alerts.created')
  end

  private

    def permitted_params
      params.require(:comment).permit(:body)
    end
end