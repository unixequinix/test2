class Admins::Events::CommentsController < Admins::Events::BaseController
  def create
    @comment = @commentable.comments.build(permitted_params)
    @comment.admin = current_admin
    @comment.save
    redirect_to [:admins, current_event, @commentable], notice: I18n.t("alerts.created")
  end

  private

  def permitted_params
    params.require(:comment).permit(:body)
  end
end
