class SpentTime < TimeEntry
  unloadable

  enum review: [:approved, :rejected, :not_reviewed]
  scope :approved, -> (project) {where(review: SpentTime.reviews[:approved], project_id: project)}
  scope :rejected, -> (project) {where(review: SpentTime.reviews[:rejected], project_id: project)}
  scope :not_reviewed, -> (project) {where(review: [SpentTime.reviews[:not_reviewed], nil], project_id: project)}

  class << self
    def check_permission(usr, prj, ability)
      if usr.admin
        true
      elsif !usr.members.blank?
        permissions = usr.members.find_by(project_id: prj).roles.map(&:permissions).flatten
        permissions.include?(ability) ? true : false
      else
        false
      end
    end

    def filter(project, member, time_from, time_to, status)
      users = search_member_by_name member
      time_to = time_to.present? ? time_to : Time.now
      status = if status == "2"
        status = [status, nil]
      else
        status.present? ? status.to_i : SpentTime.reviews.values
      end

      spent_times = SpentTime.where(project_id: project.id, user_id: users.ids, review: status)

      if spent_times.blank?
        []
      else
        spent_times.where("created_on > ? AND created_on < ? OR DATE(created_on) = ?", time_from, time_to, time_to)
      end
    end

    private

    def search_member_by_name name
      arr_words = name.to_s.strip.split
      arr_words.map! { |word| "firstname LIKE '%#{word}%' OR lastname LIKE '%#{word}%'" }
      sql = arr_words.join(" OR ")
      User.where(sql)
    end
  end



  def editable_by?(usr)
    (usr == user && usr.allowed_to?(:edit_own_time_sheets, project) && self.review != "approved") || usr.allowed_to?(:edit_time_sheets, project)
  end

  def reviewable_by?(usr)
    usr.allowed_to?(:review_time_sheets, project)
  end
end
