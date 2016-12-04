Redmine::Plugin.register :redmine_timesheet_management do
  name 'Manage Time Sheets plugin'
  author 'Duyet Nguyen'
  description 'This is a plugin for Redmine to manage timesheet'
  version '0.0.1'
  url 'https://github.com/duet-ngyen/remine_plugin_timesheet_management'
  author_url 'http://duyetblog.com/about'

  permission :view_time_sheets, { :spent_times => :index }
  permission :edit_time_sheets, { :spent_times => [:edit, :update, :destroy] }
  permission :edit_own_time_sheets, { :spent_times => [:edit, :update, :destroy] }
  permission :review_time_sheets, { :spent_times => [:approve, :approve_multiple, :reject] }
  menu :project_menu, :spent_times, { :controller => 'spent_times', :action => 'index' }, :caption => 'Timesheet Management', :after => :activity, :param => :project_id
end
