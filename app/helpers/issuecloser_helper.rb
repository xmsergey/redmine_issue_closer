module IssuecloserHelper

  def gather_issues
    @issues_all_count = Issue.count
    @issues_to_change = Issue.where(status_id: plugin_settings['issues_status_from'])
                          .where(project_id: plugin_settings['project_id'])
                          .where('updated_on < ?', plugin_settings['auto_close_after_days'].to_i.days.ago)
                          .order(:created_on)

    @issues_to_change_count = @issues_to_change.count
    @issues_to_change_paginated = @issues_to_change.page(params[:page])
    @issues_new_status = IssueStatus.find(plugin_settings['issues_status_to'])
  end

  def update_status
    return unless params[:id] && params[:new_status]

    if Issue.update(params[:id], status_id: params[:new_status])
      flash[:success] = 'Status have been changed'
    else
      flash[:danger] = 'Status haven\'t been changed'
    end
  end

  private

  def plugin_settings
    params['settings']['projects'].first
  end

end
