require 'capybara-screenshot/rspec'
require 'capybara/rails'
require 'capybara/rspec'

DEFAULT_MAX_WAIT_TIME = (ENV['CI'].to_i == 1) ? 5 : 3

# --------------------------------------------------------------------------------
# register drivers for capybara
if ENV['WITH_MOBILE_DRIVER'].to_i == 1
  CAPYBARA_WINDOW_SIZE = [375, 812].freeze
else
  CAPYBARA_WINDOW_SIZE = [1600, 1000].freeze
end

[:selenium_desktop, :selenium_mobile].each do |driver|
  Capybara.register_driver driver do |app|
    opts = Selenium::WebDriver::Chrome::Options.new(
      args: [
      '--disable-gpu',
      '--disable-popup-blocking',
      '--disable-site-isolation-trials',
      '--disable-smooth-scrolling',
      '--kiosk-printing',
      '--disable-infobars',
      '--no-sandbox',
      '--guest', # Do not show "save password", "save iban/cc details" etc
      'test-type',
      '--goog=chromeOptions',
      '--w3c=false',
      '--force-device-scale-factor=1', # Force the browser's scale factor to prevent inconsistencies on high-res devices
      '--high-dpi-support=1',
      '--disable-search-engine-choice-screen',
      "window-size=#{CAPYBARA_WINDOW_SIZE.join(',')}"
      ] + (ENV['IN_BROWSER'].present? ? [] : ['--headless=new'])) # new headless mode!: https://developer.chrome.com/articles/new-headless/
    if ENV['WITH_MOBILE_DRIVER'].to_i == 1
      opts.add_argument("--user-agent='Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3'")
      opts.add_emulation(device_name: 'iPhone X')
    end
    Capybara::Selenium::Driver.new(app, browser: :chrome, options:  opts)
  end
end

Capybara.javascript_driver = ENV['WITH_MOBILE_DRIVER'].to_i == 1 ? :selenium_mobile : :selenium_desktop

# setup screenshots
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{Capybara.javascript_driver == :selenium_mobile ? 'mobile' : ''}"
end
# keep only the screenshots from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run

# NOTE if our drivers are not called `:selenium`, screenshots must be configured manually
# https://github.com/mattheworiordan/capybara-screenshot/issues/211
[:selenium_desktop, :selenium_mobile].each do |driver|
  Capybara::Screenshot.register_driver(driver) do |driver_inner, path|
    driver_inner.browser.save_screenshot(path)
  end
end

# Setup capybara for integration testing & e2e testing (feature a.k.a. system specs)
Capybara.configure do |config|
  #app_url = '%s://%s' % [ cc.hostnames.default_protocol, cc.hostnames.hostname ]
  #config.app_host = app_url
  config.default_max_wait_time = DEFAULT_MAX_WAIT_TIME # can be increased for easier debugging
  config.server = :puma, { Silent: true }
  #config.server_port = cc.hostnames.port
  config.always_include_port    = true

  # Let capybara see hidden fields in order to
  # get the specs working.
  config.ignore_hidden_elements = false

  # Let capybara see aria labels
  config.enable_aria_label = true

  # Click associated label if input is hidden to support our generic-custom-radio
  config.automatic_label_click = true

  # find input fields by aria-labels
  config.enable_aria_label = true

  # click on input fields, or buttons by data-testid
  config.test_id = 'data-testid'

  config.save_path = 'screenshots'
end

