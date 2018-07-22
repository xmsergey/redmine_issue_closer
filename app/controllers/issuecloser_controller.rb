class IssuecloserController < AdminController
  unloadable

  def index
    
    @issues = []
    @to={}
    @days={}
    
    IssueStatus.all.each do |status|
      
      to_status = Setting.plugin_issuecloser["from_#{status.id}"].to_i
      
      if to_status!=0
        
        days = Setting.plugin_issuecloser["days_#{status.id}"].to_i
        days = days==0 ? Setting.plugin_issuecloser["auto_close_after_days"].to_i : days
        
        @to[status.id] = to_status
        @days[status.id] = days
        
        if params.has_key?(:id) && params[:issue_action]=='change' && (Issue.find(params[:id]).status_id==status.id)
          Issue.find(params[:id]).update(status_id: to_status)
        end      
        
        @issues << Issue.where('status_id=?', status.id).where("updated_on < ?", days.days.ago).order(:created_on)
      end
      
    end
    
    @issues=@issues.flatten
    @issues_all_c=Issue.all.count
    @issues_to_change_c=@issues.count
    
    @issues=Kaminari.paginate_array(@issues).page(params[:page])
    
  end

end
