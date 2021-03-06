require 'redmine'

Redmine::Plugin.register :redmine_ldap_ou_to_group do
  name 'Redmine LDAP Organiztion Unit to Group Plugin'
  author 'Yi Zhang'
  description 'This is a plugin to help sync ldap ou to redmine group'
  version '0.2'
  requires_redmine :version_or_higher => '2.0.0'
  url 'https://github.com/yzhanginwa/redmine_ldap_ou_to_group'
end

RedmineApp::Application.config.after_initialize do
  require_dependency 'ldap_ou_to_group'
  AuthSourceLdap.send(:include, LdapOuToGroup)
end

