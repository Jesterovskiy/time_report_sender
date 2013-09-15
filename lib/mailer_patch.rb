require_dependency 'mailer'

# Patches Redmine's Mailer dynamically.
module MailerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)
    base.send(:include, ActivitiesHelper)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      helper :activities
      include ActivitiesHelper
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    DAYS_BACK = 1
    WITH_SUBPROJECTS = true

    def send_time_report(email)
      @user = User.find(1)
      @project = Project.find(Setting.plugin_time_report_sender['project_id'])
      @days = Setting.plugin_time_report_sender['days_back'].to_i || DAYS_BACK
      @date_to ||= Date.today + 1
      @date_from = @date_to - @days
      @with_subprojects = Setting.plugin_time_report_sender['include_subprojects'] || WITH_SUBPROJECTS
      @author = nil

      activity = Redmine::Activity::Fetcher.new(@user, :project => @project,
                                                       :with_subprojects => @with_subprojects,
                                                       :author => @author)
      #@activity.scope_select {|t| !params["show_#{t}"].nil?}
      #@activity.scope = (@author.nil? ? :default : :all) if @activity.scope.empty?
      activity.scope = :all

      events = activity.events(@date_from, @date_to)
      @events_by_day = events.group_by {|event| @user.time_to_date(event.event_datetime)}

      mail :to => email, :subject => "#{@project.name} report"
    end
  end
end

# Add module to Mailer
Mailer.send(:include, MailerPatch)
