# Patches to the Redmine core.
require 'redmine'
require 'mailer_patch'
ActionDispatch::Callbacks.to_prepare do
  Mailer.send(:include, MailerPatch) unless Mailer.included_modules.include? MailerPatch
end

Redmine::Plugin.register :time_report_sender do
  name 'Time Report Sender plugin'
  author 'Aleksey Dashkevich'
  description 'This is a plugin for sending time reports'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings :default => {'empty' => true}, :partial => 'settings/time_report_sender'
end
