##
# Package for managing and registering settings.
#
# ## Controllers
#
# * {Settings::Controller::Settings}
#
# ## Models
#
# * {Settings::Model::Setting}
#
# ## Generic Modules & Classes
#
# * {Settings::Setting}
# * {Settings::SettingsGroup}
# * {Settings::SingletonMethods}
#
module Settings
  #:nodoc:
  module Controller
    ##
    # Controller for managing settings. Settings are used to store the name of
    # the website, what anti spam system to use and so on. These settings can be
    # managed via the admin interface rather than having to edit configuration
    # files. Settings can be managed by going to ``/admin/settings``. This page
    # shows an overview of all the available settings organized in a number of
    # groups where each group is placed under it's own tab. An example of this
    # overview can be seen in the image below.
    #
    # ![General](../../images/settings/overview_general.png)
    # ![Security](../../images/settings/overview_security.png)
    # ![User Settings](../../images/settings/overview_user.png)
    #
    # Out of the box Zen ships with the following settings:
    #
    # <table class="table full">
    #     <thead>
    #         <tr>
    #             <th class="field_name">Field</th>
    #             <th>Description</th>
    #         </tr>
    #     </thead>
    #     <tbody>
    #         <tr>
    #             <td>Website name</td>
    #             <td>The name of the website.</td>
    #         </tr>
    #         <tr>
    #             <td>Website description</td>
    #             <td>A description of the website.</td>
    #         </tr>
    #         <tr>
    #             <td>Language</td>
    #             <td>The language to use for the backend.</td>
    #         </tr>
    #         <tr>
    #             <td>Frontend Language</td>
    #             <td>The language to use for the frontend of the website.</td>
    #         </tr>
    #         <tr>
    #             <td>Theme</td>
    #             <td>The theme to use for the website.</td>
    #         </tr>
    #         <tr>
    #             <td>Date format</td>
    #             <td>
    #                 The date format to use for dates displayed in the backend.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Enable anti-spam</td>
    #             <td>
    #                 When set comments will be validated before they're saved.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Anti-spam system</td>
    #             <td>
    #                 The system to use for validating comments. Out of the box
    #                 Zen only supports Defensio.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Defensio key</td>
    #             <td>The API key to use for the Defensio API.</td>
    #         </tr>
    #         <tr>
    #             <td>Allow Registration</td>
    #             <td>
    #                 When set users are allowed to register user accounts.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Revision amount</td>
    #             <td>
    #                 The maximum amount of revisions to keep for each section
    #                 entry. After this limit has been exceeded the oldest
    #                 revision will be removed.
    #             </td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # ## Used Permissions
    #
    # This controller uses the following permissions:
    #
    # * show_setting
    # * edit_setting
    #
    # ## Events
    #
    # Unlike other controllers events in this controller do not receive an
    # instance of a model. Instead they'll receive an instance of
    # {Settings::Plugin::SettingBase}. In order to update the value of a setting
    # you'll simply call ``#value=()`` and specify a new value.
    #
    # @example Trimming the value of a setting
    #  Zen::Event(:after_edit_setting) do |setting|
    #    if setting.name == 'website_name'
    #      setting.value = setting.value.strip
    #    end
    #  end
    #
    # @since  0.1
    # @map    /admin/settings
    # @event  after_edit_setting
    #
    class Settings < Zen::Controller::AdminController
      map   '/admin/settings'
      title 'settings.titles.%s'

      csrf_protection  :save
      load_asset_group :tabs

      ##
      # Show all settings and allow the user to change them.
      #
      # @since      0.1
      # @permission show_setting
      #
      def index
        authorize_user!(:show_setting)

        set_breadcrumbs(lang('settings.titles.index'))

        @settings_ordered = {}
        @groups           = ::Settings::SettingsGroup::REGISTERED

        # Organize the settings so that each item is a child
        # item of it's group.
        ::Settings::Setting::REGISTERED.each do |name, setting|
          if !@settings_ordered.key?(setting.group)
            @settings_ordered[setting.group] = []
          end

          @settings_ordered[setting.group].push(setting)
        end
      end

      ##
      # Updates all the settings in both the database and the cache
      # (Ramaze::Cache.settings).
      #
      # @since      0.1
      # @permission edit_setting
      # @event      after_edit_setting
      #
      def save
        authorize_user!(:edit_setting)

        post = request.params
        post.delete('csrf_token')
        post.delete('id')

        success = lang('settings.success.save')
        error   = lang('settings.errors.save')

        # Update all settings
        post.each do |key, value|
          setting = get_setting(key)

          begin
            setting.value = value
          rescue => e
            Ramaze::Log.error(e)
            message(:error, error)

            flash[:form_errors] = setting.errors
            redirect_referrer
          end

          Zen::Event.call(:after_edit_setting, setting)
        end

        message(:success, success)
        redirect_referrer
      end
    end # Settings
  end # Controller
end # Settings
