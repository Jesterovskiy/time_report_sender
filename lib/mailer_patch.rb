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
      set_language_if_valid "ru"
      @user = User.where(login: 'admin').first
      @project = Project.find(Setting.plugin_time_report_sender['project_id'])
      @days = Setting.plugin_time_report_sender['days_back'].to_i || DAYS_BACK
      @date_to ||= Date.tomorrow
      @date_from = @date_to - @days - 1
      @with_subprojects = Setting.plugin_time_report_sender['include_subprojects'] || WITH_SUBPROJECTS

      activity = Redmine::Activity::Fetcher.new(@user, :project => @project,
                                                       :with_subprojects => @with_subprojects,
                                                       :author => nil)
      activity.scope = ["time_entries"]

      events = activity.events(@date_from, @date_to)
      @events_by_day = events.group_by {|event| @user.time_to_date(event.event_datetime)}
      @hours = 0
      events.each {|e| @hours = @hours + e.hours if e.hours && (e.spent_on == Date.yesterday)}

      mail :to => email, :subject => "Отчет по проекту #{@project.name} за #{format_date(@date_from)}."
    end
  end
end

# Add module to Mailer
Mailer.send(:include, MailerPatch)
