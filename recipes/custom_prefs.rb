say_wizard "Please input all necessary preferences"

ask_pref(:company_name, 'What is the Company Name?')
ask_pref(:company_domain, 'What is the site domain? (ex: google.com)')

ask_pref(:mixpanel_token_production, 'Mixpanel Token (Production)')
ask_pref(:mixpanel_token_staging, 'Mixpanel Token (Staging)')
ask_pref(:mixpanel_token_dev, 'Mixpanel Token (Development)')
ask_pref(:ga_property, 'Google Analytics Property ID')

ask_pref(:new_relic_license_key, 'New Relic License Key (sandbox)')
ask_pref(:honeybadger_api_key, 'Honeybadger Project API Key')
ask_pref(:hipchat_api_key, 'Hipchat Notification API Key')
ask_pref(:hipchat_room, 'Hipchat Room')

__END__

name: custom_prefs
description: 'Extra preferences that require user input'
author: wireframe
category: other
