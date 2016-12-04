class SpentTimesController < ApplicationController
  unloadable
  before_filter :find_project_by_project_id
  before_filter :authorize
  before_filter :check_permision_spentime, only: [:edit, :update, :destroy]

  def index
    params[:open_filter] = true if params[:commit].present?
    @spent_times = if params[:member_name].present? || params[:time_from].present? || params[:time_to].present? || params[:review_status].present?
       SpentTime.filter(@project, params[:member_name], params[:time_from], params[:time_to], params[:review_status])
    else
      SpentTime.all.where(project_id: @project)
    end

    @time_sheet_approved = SpentTime.approved @project
    @time_sheet_rejected = SpentTime.rejected @project
    @time_sheet_not_reviewed = SpentTime.not_reviewed @project
    # binding.pry
    unless @spent_times.present?
      flash.now[:warning] = t "plg_mng_timesheets.no_data"
      return
    end
  end

  def edit
  end

  def update
    if @spent_time.update(spent_time_params)
      redirect_to project_spent_times_path(@project)
    else
      render :edit
    end
  end

  def approve_multiple
    if params[:ids]
      time_entries = SpentTime.where(id: params[:ids])
      results = []

      time_entries.each do |entry|
        results << approve_multiple_time_sheet(entry) if entry.review != "approved"
      end

      if results.include?(false)
        flash[:error] = t "plg_mng_timesheets.approve_not_successfully"
      else
        flash[:notice] = t "plg_mng_timesheets.approved_successfully"
      end

    else
      flash[:error] = t "plg_mng_timesheets.approve_not_successfully"
    end

    redirect_to project_spent_times_path(@project)
  end

  def approve
    if params[:entry].present?
      time_entry = SpentTime.find(params[:entry])
      time_entry.review = SpentTime.reviews[:approved]
      time_entry.reason = ""

      if time_entry.save!
        flash[:notice] = t "plg_mng_timesheets.approved_successfully"
      else
        flash[:error] = t "plg_mng_timesheets.approve_not_successfully"
      end
    else
      flash[:error] = t "plg_mng_timesheets.approve_not_successfully"
    end

    redirect_to project_spent_times_path(@project)
  end

  def reject
    if params[:entry].present? && params[:reason].present?
      time_entry = SpentTime.find(params[:entry])
      time_entry.review = SpentTime.reviews[:rejected]
      time_entry.reason = params[:reason]

      if time_entry.save!
        flash[:notice] = t "plg_mng_timesheets.rejected_successfully"
      else
        flash[:error] = t "plg_mng_timesheets.reject_not_successful"
      end
    else
      flash[:error] = t "plg_mng_timesheets.reject_not_successful"
    end

    redirect_to project_spent_times_path(@project)
  end

  def destroy
    @spent_time = SpentTime.find(params[:id])

    @spent_time.destroy
    redirect_to project_spent_times_path(@project), notice: t("plg_mng_timesheets.timesheet_destroy_successfully")
  end

  private

  def spent_time_params
    params[:spent_time][:activity_id] = TimeEntryActivity.find_by(name: params[:spent_time][:activity_id]).id

    params.require(:spent_time).permit(:spent_on, :hours, :comments, :activity_id)
  end

  def approve_multiple_time_sheet time_sheet
    time_sheet.review = SpentTime.reviews[:approved]
    time_sheet.reason = ""
    if time_sheet.save
      true
    else
      false
    end
  end

  def check_permision_spentime
    @spent_time = SpentTime.find(params[:id])

    unless @spent_time.editable_by?(User.current)
      return render_404
    end
  end
end
