# Copyright (c) 2010-2019 Novell, Inc.
# Licensed under the terms of the MIT license.

#
# Texts and links
#

When(/^I follow "(.*?)" link$/) do |host|
  system_name = get_system_name(host)
  step %(I follow "#{system_name}")
end

Then(/^I should see a "(.*)" text in the content area$/) do |txt|
  within('#spacewalk-content') do
    raise "Text #{txt} not found" unless page.has_content?(txt)
  end
end

Then(/^I should not see a "(.*)" text in the content area$/) do |txt|
  within('#spacewalk-content') do
    raise "Text #{txt} found" unless page.has_no_content?(txt)
  end
end

When(/^I click on "([^"]+)" in row "([^"]+)"$/) do |link, item|
  within(:xpath, "//tr[td[contains(.,'#{item}')]]") do
    click_link_or_button_and_wait(link)
  end
end

Then(/^the current path is "([^"]*)"$/) do |arg1|
  raise "Path #{current_path} different than #{arg1}" unless current_path == arg1
end

When(/^I wait until I see "([^"]*)" text$/) do |text|
  raise "Text #{text} not found" unless page.has_text?(text, wait: DEFAULT_TIMEOUT)
end

When(/^I wait until I do not see "([^"]*)" text$/) do |text|
  raise "Text #{text} found" unless page.has_no_text?(text, wait: DEFAULT_TIMEOUT)
end

When(/^I wait at most (\d+) seconds until I see "([^"]*)" text$/) do |seconds, text|
  raise "Text #{text} not found" unless page.has_content?(text, wait: seconds.to_i)
end

When(/^I wait until I see "([^"]*)" text or "([^"]*)" text$/) do |text1, text2|
  raise "Text #{text1} or #{text2} not found" unless page.has_content?(text1, wait: DEFAULT_TIMEOUT) || page.has_content?(text2, wait: DEFAULT_TIMEOUT)
end

When(/^I wait until I see "([^"]*)" text, refreshing the page$/) do |text|
  text.gsub! '$PRODUCT', $product # TODO: Rid of this substitution, using another step
  repeat_until_timeout(message: "Couldn't find text '#{text}'") do
    break if page.has_content?(text)
    page.evaluate_script 'window.location.reload()'
  end
end

When(/^I wait at most (\d+) seconds until the event is completed, refreshing the page$/) do |timeout|
  repeat_until_timeout(timeout: timeout.to_i, message: 'Event not yet completed') do
    break if page.has_content?("This action's status is: Completed.")
    raise 'Event failed' if page.has_content?("This action's status is: Failed.")
    page.evaluate_script 'window.location.reload()'
  end
end

When(/^I wait until I see the name of "([^"]*)", refreshing the page$/) do |host|
  system_name = get_system_name(host)
  step %(I wait until I see "#{system_name}" text, refreshing the page)
end

When(/^I wait until I do not see "([^"]*)" text, refreshing the page$/) do |text|
  repeat_until_timeout(message: "Text '#{text}' is still visible") do
    break unless page.has_content?(text)
    page.evaluate_script 'window.location.reload()'
  end
end

When(/^I wait until I do not see the name of "([^"]*)", refreshing the page$/) do |host|
  system_name = get_system_name(host)
  step %(I wait until I do not see "#{system_name}" text, refreshing the page)
end

Then(/^I wait until I see the (VNC|spice) graphical console$/) do |type|
  repeat_until_timeout(message: "The #{type} graphical console didn't load") do
    break unless page.has_xpath?('.//canvas')
  end
end

When(/^I close the window$/) do
  page.evaluate_script 'window.close();'
end

#
# Check a checkbox of the given id
#
When(/^I check "([^"]*)"$/) do |arg1|
  check(arg1)
end

When(/^I uncheck "([^"]*)"$/) do |arg1|
  uncheck(arg1)
end

When(/^I check "([^"]*)" if not checked$/) do |arg1|
  check(arg1) unless has_checked_field?(arg1)
end

When(/^I select "([^"]*)" from "([^"]*)"$/) do |arg1, arg2|
  select(arg1, from: arg2)
end

When(/^I select "([^"]*)" from drop-down in table line with "([^"]*)"$/) do |value, line|
  select = find(:xpath, ".//div[@class='table-responsive']/table/tbody/tr[contains(td,'#{line}')]//select")
  select(value, from: select[:id])
end

When(/^I choose radio button "([^"]*)" for child channel "([^"]*)"$/) do |radio, channel|
  label = find(:xpath, "//dt[contains(.//div, '#{channel}')]//label[text()='#{radio}']")
  choose(label[:for])
end

When(/^I choose "([^"]*)"$/) do |arg1|
  find(:xpath, "//input[@type='radio' and @value='#{arg1}']").set(true)
end

#
# Enter a text into a textfield
#
When(/^I enter "([^"]*)" as "([^"]*)"$/) do |arg1, arg2|
  fill_in arg2, with: arg1
end

When(/^I enter "(.*?)" as "(.*?)" in the content area$/) do |arg1, arg2|
  within(:xpath, '//section') do
    fill_in arg2, with: arg1
  end
end

#
# Click on a button
#
When(/^I click on "([^"]*)"$/) do |text|
  click_button_and_wait(text, match: :first)
end

#
# Click on a button which appears inside of <div> with
# the given "id"
When(/^I click on "([^"]*)" in element "([^"]*)"$/) do |text, element_id|
  within(:xpath, "//div[@id=\"#{element_id}\"]") do
    click_button_and_wait(text, match: :first)
  end
end

#
# Click on a button and confirm in alert box
When(/^I click on "([^"]*)" and confirm$/) do |text|
  accept_alert do
    step %(I click on "#{text}")
  end
end

#
# Click on a link
#
When(/^I follow "([^"]*)"$/) do |text|
  click_link_and_wait(text)
end

#
# Click on the first link
#
When(/^I follow first "([^"]*)"$/) do |text|
  click_link_and_wait(text, match: :first)
end

#
# Click on the terminal
#
When(/^I follow "([^"]*)" terminal$/) do |host|
  domain = get_branch_prefix_from_yaml(@retail_config)
  if !host.include? 'pxeboot'
    step %(I follow "#{domain}.#{host}")
  else
    step %(I follow "#{host}.#{domain}")
  end
end

#
# Click on a link which appears inside of <div> with
# the given "id"
When(/^I follow "([^"]*)" in element "([^"]*)"$/) do |arg1, arg2|
  within(:xpath, "//div[@id=\"#{arg2}\"]") do
    step %(I follow "#{arg1}")
  end
end

When(/^I want to add a new credential$/) do
  raise 'xpath: i.fa-plus-circle not found' unless find('i.fa-plus-circle').click
end

When(/^I follow "([^"]*)" in the (.+)$/) do |arg1, arg2|
  tag = case arg2
        when /tab bar|tabs/ then 'header'
        when /content area/ then 'section'
        else raise "Unknown element with description '#{arg2}'"
        end
  within(:xpath, "//#{tag}") do
    step %(I follow "#{arg1}")
  end
end

When(/^I follow first "([^"]*)" in the (.+)$/) do |arg1, arg2|
  tag = case arg2
        when /tab bar|tabs/ then 'header'
        when /content area/ then 'section'
        else raise "Unknown element with description '#{arg2}'"
        end
  within(:xpath, "//#{tag}") do
    step "I follow first \"#{arg1}\""
  end
end

#
# Click on a link which appears inside of <div> with
# the given "class"
When(/^I follow "([^"]*)" in class "([^"]*)"$/) do |arg1, arg2|
  within(:xpath, "//div[@class=\"#{arg2}\"]") do
    step "I follow \"#{arg1}\""
  end
end

When(/^I follow "([^"]*)" on "(.*?)" row$/) do |text, host|
  system_name = get_system_name(host)
  xpath_query = "//tr[td[contains(.,'#{system_name}')]]//a[contains(., '#{text}')]"
  raise "xpath: #{xpath_query} not found" unless find_and_wait_click(:xpath, xpath_query).click
end

When(/^I enter "(.*?)" in the editor$/) do |arg1|
  page.execute_script("ace.edit('contents-editor').insert('#{arg1}')")
end

#
# Menu links
#

# Menu path link
When(/^I follow the left menu "([^"]*)"$/) do |menu_path|
  # split menu levels separated by '>' character
  menu_levels = menu_path.split('>').map(&:strip)

  # define reusable patterns
  prefix_path = "//aside/div[@id='nav']/nav"
  link_path = "/ul/li/div/a[contains(.,'%s')]"
  parent_wrapper_path = '/parent::div'
  parent_level_path = '/parent::li'

  # point the target to the nav menu
  target_link_path = prefix_path

  menu_levels.each_with_index do |menu_level, index|
    # append the current target link and replace the placeholder with the current level value
    target_link_path += (link_path % menu_level)
    # if this is the last element of the path
    break if index == (menu_levels.count - 1)
    # open the submenu if needed
    unless find(:xpath, target_link_path + parent_wrapper_path + parent_level_path)[:class].include?('open')
      find(:xpath, target_link_path + parent_wrapper_path).click
    end
    # point the target to the current menu level
    target_link_path += parent_wrapper_path + parent_level_path
  end
  # finally go to the target page
  find_and_wait_click(:xpath, target_link_path).click
end

#
# End of Menu links
#

Given(/^I am not authorized$/) do
  visit Capybara.app_host
  raise "Button 'Sign In' not visible" unless find_button('Sign In').visible?
end

When(/^I go to the home page$/) do
  visit Capybara.app_host
end

Given(/^I access the host the first time$/) do
  visit Capybara.app_host
  raise "Text 'Create #{product} Administrator' not found" unless page.has_content?("Create #{product} Administrator")
end

# Admin Page steps
Given(/^I am on the Admin page$/) do
  steps %(
    When I am authorized as "admin" with password "admin"
    When I follow the left menu "Admin > Setup Wizard"
    )
end

When(/^I am on the Organizations page$/) do
  steps %(
    When I am authorized as "admin" with password "admin"
    When I follow the left menu "Admin > Organizations"
    )
end

# access the multi-clients/minions
Given(/^I am on the Systems overview page of this "([^"]*)"$/) do |host|
  system_name = get_system_name(host)
  steps %(
    Given I am on the Systems page
    When I follow "#{system_name}"
  )
end

Given(/^I am on the "([^"]*)" page of this "([^"]*)"$/) do |page, host|
  steps %(
    Given I am on the Systems overview page of this "#{host}"
    And I follow "#{page}" in the content area
  )
end

When(/^I enter the hostname of "([^"]*)" as "([^"]*)"$/) do |host, hostname|
  system_name = get_system_name(host)
  puts "The hostname of #{host} is #{system_name}"
  step %(I enter "#{system_name}" as "#{hostname}")
end

When(/^I select the hostname of "([^"]*)" from "([^"]*)"$/) do |host, hostname|
  case host
  when 'proxy'
    # don't select anything if not in the list
    next if $proxy.nil?
    step %(I select "#{$proxy.full_hostname}" from "#{hostname}")
  when 'sle-minion'
    step %(I select "#{$minion.full_hostname}" from "#{hostname}")
  end
end

When(/^I follow this "([^"]*)" link$/) do |host|
  system_name = get_system_name(host)
  step %(I follow "#{system_name}")
end

When(/^I check the "([^"]*)" client$/) do |host|
  system_name = get_system_name(host)
  step %(I check "#{system_name}" in the list)
end

When(/^I uncheck the "([^"]*)" client$/) do |host|
  system_name = get_system_name(host)
  step %(I uncheck "#{system_name}" in the list)
end

Given(/^I am on the groups page$/) do
  steps %(
    Given I am on the Systems page
    When I follow the left menu "Systems >System Groups"
    )
end

Given(/^I am on the active Users page$/) do
  steps %(
    Given I am authorized as "admin" with password "admin"
    When I follow the left menu "Users > User List > Active"
    )
end

Then(/^Table row for "([^"]*)" should contain "([^"]*)"$/) do |arg1, arg2|
  xpath_query = "//div[@class=\"table-responsive\"]/table/tbody/tr[.//a[contains(.,'#{arg1}')]]"
  within(:xpath, xpath_query) do
    raise "xpath: #{xpath_query} has no content #{arg2}" unless has_content?(arg2)
  end
end

When(/^I wait until table row for "([^"]*)" contains button "([^"]*)"$/) do |text, button|
  xpath_query = "//tr[td[contains(., '#{text}')]]/td/descendant::*[self::a or self::button][@title='#{button}']"
  raise "xpath: #{xpath_query} not found" unless find(:xpath, xpath_query, wait: DEFAULT_TIMEOUT)
end

When(/^I wait until table row contains a "([^"]*)" text$/) do |text|
  xpath_query = "//div[@class=\"table-responsive\"]/table/tbody/tr[.//td[contains(.,'#{text}')]]"
  raise "xpath: #{xpath_query} not found" unless find(:xpath, xpath_query, wait: DEFAULT_TIMEOUT)
end

# login, logout steps

Given(/^I am authorized as "([^"]*)" with password "([^"]*)"$/) do |user, passwd|
  visit Capybara.app_host
  next if page.all(:xpath, "//header//span[text()='#{user}']").any?

  find(:xpath, "//header//i[@class='fa fa-sign-out']").click if page.all(:xpath, "//header//i[@class='fa fa-sign-out']").any?

  fill_in 'username', with: user
  fill_in 'password', with: passwd
  click_button('Sign In')

  step %(I should be logged in)
end

Given(/^I am authorized$/) do
  step %(I am authorized as "testing" with password "testing")
end

When(/^I sign out$/) do
  find(:xpath, "//a[@href='/rhn/Logout.do']").click
end

Then(/^I should not be authorized$/) do
  raise 'User is authorized' if all(:xpath, "//a[@href='/rhn/Logout.do']").any?
end

Then(/^I should be logged in$/) do
  raise 'User is not logged in' unless find(:xpath, "//a[@href='/rhn/Logout.do']").visible?
end

Then(/^I am logged in$/) do
  raise 'User is not logged in' unless find(:xpath, "//a[@href='/rhn/Logout.do']").visible?
  raise 'The welcome meesage is not shown' unless page.has_content?("You have just created your first #{product} user. To finalize your installation please use the Setup Wizard")
end

Given(/^I am on the patches page$/) do
  step %(I am authorized)
  visit("https://#{$server.full_hostname}/rhn/errata/RelevantErrata.do")
end

Then(/^I should see an update in the list$/) do
  xpath_query = '//div[@class="table-responsive"]/table/tbody/tr/td/a'
  raise "xpath: #{xpath_query} not found" unless all(:xpath, xpath_query).any?
end

When(/^I check test channel$/) do
  step %(I check "Test Base Channel" in the list)
end

When(/^I check "([^"]*)" patch$/) do |arg1|
  step %(I check "#{arg1}" in the list)
end

When(/^I am on System Set Manager Overview$/) do
  visit("https://#{$server.full_hostname}/rhn/ssm/index.do")
end

When(/^I am on Autoinstallation Overview page$/) do
  visit("https://#{$server.full_hostname}/rhn/kickstart/KickstartOverview.do")
end

When(/^I am on the System Manager System Overview page$/) do
  visit("https://#{$server.full_hostname}/rhn/systems/ssm/ListSystems.do")
end

When(/^I am on the Create Autoinstallation Profile page$/) do
  visit("https://#{$server.full_hostname}/rhn/kickstart/AdvancedModeCreate.do")
end

When(/^I am on the System Overview page$/) do
  visit("https://#{$server.full_hostname}/rhn/systems/Overview.do")
end

Then(/^I reload the page$/) do
  visit current_url
end

Then(/^I should see something$/) do
  steps %(
    Given I should see a "Sign In" text
    And I should see a "About" text
    )
end

Then(/^I should see "([^"]*)" systems selected for SSM$/) do |arg|
  within(:xpath, '//span[@id="spacewalk-set-system_list-counter"]') do
    raise "There are not #{arg} systems selected" unless has_content?(arg)
  end
end

#
# Test for a text in the whole page
#
Then(/^I should see a "([^"]*)" text$/) do |text|
  text.gsub! '$PRODUCT', $product # TODO: Rid of this substitution, using another step
  raise "Text #{text} not found" unless page.has_content?(text)
end

Then(/^I should see a "([^"]*)" text or "([^"]*)" text$/) do |text1, text2|
  raise "Text #{text1} and #{text2} are not found" unless page.has_content?(text1) || page.has_content?(text2)
end

#
# Test for text in a snippet textarea
#
Then(/^I should see "([^"]*)" in the textarea$/) do |arg1|
  within('textarea') do
    raise "Text #{arg1} not found" unless page.has_content?(arg1)
  end
end

#
# Test for a text in the whole page using regexp
#
Then(/^I should see a text like "([^"]*)"$/) do |title|
  raise "Text #{title} not found" unless page.has_content?(Regexp.new(title))
end

#
# Test for a text not allowed in the whole page
#
Then(/^I should not see a "([^"]*)" text$/) do |text|
  raise "#{text} found on the page! FAIL" unless page.has_no_content?(text)
end

#
# Test for a visible link in the whole page
#
Then(/^I should see a "([^"]*)" link$/) do |text|
  raise "Link #{text} is not visible" unless has_link?(text)
end

#
# Validate link is gone
#
Then(/^I should not see a "([^"]*)" link$/) do |arg1|
  raise "Link #{arg1} is present" unless has_no_link?(arg1)
end

Then(/^I should see a "([^"]*)" button$/) do |arg1|
  raise "Link #{arg1} is not visible" unless find_button(arg1).visible?
end

Then(/^I should see a "(.*?)" link in the text$/) do |linktext, text|
  within(:xpath, "//p/strong[contains(normalize-space(string(.)), '#{text}')]") do
    assert all(:xpath, "//a[text() = '#{linktext}']").any?
  end
end

#
# Test for a visible link inside of a <div> with the attribute
# "class" or "id" of the given name
#
Then(/^I should see a "([^"]*)" link in element "([^"]*)"$/) do |link, element|
  within(:xpath, "//div[@id=\"#{element}\" or @class=\"#{element}\"]") do
    raise "Link #{link} not visible" unless find_link(link).visible?
  end
end

Then(/^I should not see a "([^"]*)" link in element "([^"]*)"$/) do |link, element|
  within(:xpath, "//div[@id=\"#{element}\" or @class=\"#{element}\"]") do
    raise "Link #{link} is present" unless has_no_link?(link)
  end
end

Then(/^I should see a "([^"]*)" text in element "([^"]*)"$/) do |text, element|
  within(:xpath, "//div[@id=\"#{element}\" or @class=\"#{element}\"]") do
    raise "Text #{text} not found in #{element}" unless has_content?(text)
  end
end

Then(/^I should not see a "([^"]*)" text in element "([^"]*)"$/) do |text, element|
  within(:xpath, "//div[@id=\"#{element}\" or @class=\"#{element}\"]") do
    raise "Text #{text} found in #{element}" if has_content?(text)
  end
end

Then(/^I should see a "([^"]*)" or "([^"]*)" text in element "([^"]*)"$/) do |text1, text2, element|
  within(:xpath, "//div[@id=\"#{element}\" or @class=\"#{element}\"]") do
    raise "Texts #{text1} and #{text2} not found in #{element}" unless has_content?(text1) || has_content?(text2)
  end
end

Then(/^I should see a "([^"]*)" link in the table (.*) column$/) do |link, column|
  idx = %w[first second third fourth].index(column)
  unless idx
    # try column by name
    # unquote if neeeded
    colname = column.gsub(/\A['"]+|['"]+\Z/, '')
    cols = page.all(:xpath, '//table//thead/tr[1]/th').map(&:text)
    idx = cols.index(colname)
  end
  raise("Unknown column '#{column}'") unless idx
  # find(:xpath, "//table//thead//tr/td[#{idx + 1}]/a[text()='#{link}']")
  raise unless all(:xpath, "//table//tr/td[#{idx + 1}]//a[text()='#{link}']").any?
end

When(/^I wait until the table contains "FINISHED" or "SKIPPED" followed by "FINISHED" in its first rows$/) do
  # this step is used for long operations like refreshing caches, repositories, etc.
  # therefore we use a non-standard timeout
  repeat_until_timeout(timeout: 800, message: 'Task does not look FINISHED yet') do
    visit current_url
    # get all texts in the table column under the "Status" header
    status_tds = "//tr/td[count(//th[contains(*/text(), 'Status')]/preceding-sibling::*) + 1]"
    statuses = page.all(:xpath, status_tds).map(&:text)

    # get all texts in the table column under the "Start time" header
    start_time_tds = "//tr/td[count(//th[contains(*/text(), 'Start Time')]/preceding-sibling::*) + 1]"
    start_times = page.all(:xpath, start_time_tds).map(&:text)

    # disregard any number of initial unimportant rows, that is:
    #  - INTERRUPTED rows with no start time (expected when Taskomatic had been restarted)
    #  - SKIPPED rows (expected when Taskomatic triggers the same task concurrently)
    first_non_skipped = statuses.zip(start_times).drop_while do |status, start_time|
      (status == 'INTERRUPTED' && start_time.empty?) || status == 'SKIPPED'
    end.first.first

    # halt in case we are done, or if an error is detected
    break if first_non_skipped == 'FINISHED'
    raise('Taskomatic task was INTERRUPTED') if first_non_skipped == 'INTERRUPTED'

    # otherwise either no row is shown yet, or the task is still RUNNING
    # continue waiting
    sleep 1
  end
end

Then(/^I should see a "([^"]*)" link in the (left menu|tab bar|tabs|content area)$/) do |arg1, arg2|
  tag = case arg2
        when /left menu/ then 'aside'
        when /tab bar|tabs/ then 'header'
        when /content area/ then 'section'
        else raise "Unknown element with description '#{arg2}'"
        end
  within(:xpath, "//#{tag}") do
    step "I should see a \"#{arg1}\" link"
  end
end

Then(/^I should not see a "([^"]*)" link in the (.+)$/) do |arg1, arg2|
  tag = case arg2
        when /left menu/ then 'aside'
        when /tab bar|tabs/ then 'header'
        when /content area/ then 'section'
        else raise "Unknown element with description '#{arg2}'"
        end
  within(:xpath, "//#{tag}") do
    step "I should not see a \"#{arg1}\" link"
  end
end

Then(/^I should see a "([^"]*)" link in row ([0-9]+) of the content menu$/) do |arg1, arg2|
  within(:xpath, '//section') do
    within(:xpath, "//div[@class=\"spacewalk-content-nav\"]/ul[#{arg2}]") do
      step %(I should see a "#{arg1}" link)
    end
  end
end

Then(/^I should see a "([^"]*)" link in list "([^"]*)"$/) do |arg1, arg2|
  within(:xpath, "//ul[@id=\"#{arg2}\" or @class=\"#{arg2}\"]") do
    raise "Link #{arg1} not visible" unless find_link(arg1).visible?
  end
end

Then(/^I should see a "([^"]*)" button in "([^"]*)" form$/) do |arg1, arg2|
  within(:xpath, "//form[@id='#{arg2}' or @name=\"#{arg2}\"]") do
    raise "Button #{arg1} not found" unless find_button(arg1)
  end
end

Then(/^I select the "([^"]*)" repo$/) do |repo|
  repo = find(:xpath, "//a[contains(.,'#{repo}')]/../..//*[@type='checkbox']", match: :first)
  repo.set(true) unless repo.nil?
end

Then(/^I check the row with the "([^"]*)" link$/) do |arg1|
  within(:xpath, "//a[text()='#{arg1}']/../..") do
    find('input[type=checkbox]', match: :first).set(true)
  end
end

Then(/^I check the row with the "([^"]*)" text$/) do |text|
  within(:xpath, "//tr[td[contains(., '#{text}')]]") do
    find('input[type=checkbox]', match: :first).set(true)
  end
end

Then(/^I check the row with the "([^"]*)" hostname$/) do |host|
  system_name = get_system_name(host)
  within(:xpath, "//tr[td[contains(., '#{system_name}')]]") do
    find('input[type=checkbox]', match: :first).set(true)
  end
end

#
# Test if an option is selected
#
Then(/^option "([^"]*)" is selected as "([^"]*)"$/) do |arg1, arg2|
  raise "#{arg1} is not selected as #{arg2}" unless has_select?(arg2, selected: arg1)
end

#
# Test if a radio button is checked
#
Then(/^radio button "([^"]*)" is checked$/) do |arg1|
  raise "#{arg1} is unchecked" unless has_checked_field?(arg1)
end

#
# Test if a checkbox is checked
#
Then(/^I should see "([^"]*)" as checked$/) do |arg1|
  raise "#{arg1} is unchecked" unless has_checked_field?(arg1)
end

#
# Test if a checkbox is unchecked
#
Then(/^I should see "([^"]*)" as unchecked$/) do |arg1|
  raise "#{arg1} is checked" unless has_unchecked_field?(arg1)
end

#
# Test if a checkbox is disabled
#
Then(/^the "([^\"]*)" checkbox should be disabled$/) do |arg1|
  page.has_css?("##{arg1}[disabled]")
end

Then(/^the "([^\"]*)" field should be disabled$/) do |arg1|
  page.has_css?("##{arg1}[disabled]")
end

Then(/^I should see "([^"]*)" in field "([^"]*)"$/) do |arg1, arg2|
  raise "Field #{arg2} with #{arg1} value not found" unless page.has_field?(arg2, with: arg1)
end

Then(/^I should see a "([^"]*)" element in "([^"]*)" form$/) do |arg1, arg2|
  within(:xpath, "//form[@id=\"#{arg2}\"] | //form[@name=\"#{arg2}\"]") do
    raise "Field #{arg1} not found" unless find_field(arg1, match: :first).visible?
  end
end

Then(/^I should see a "([^"]*)" editor in "([^"]*)" form$/) do |arg1, arg2|
  within(:xpath, "//form[@id=\"#{arg2}\"] | //form[@name=\"#{arg2}\"]") do
    raise "xpath: textarea##{arg1} not found" unless find("textarea##{arg1}", visible: false)
    raise "css: ##{arg1}-editor not found" unless page.has_css?("##{arg1}-editor")
  end
end

Then(/^I should see a Sign Out link$/) do
  raise unless all(:xpath, "//a[@href='/rhn/Logout.do']").any?
end

When(/^I check "([^"]*)" in the list$/) do |text|
  within(:xpath, '//section') do
    # use div/div/div for cve audit which has two tables
    top_level_xpath_query = "//div[@class=\"table-responsive\"]/table/tbody/tr[.//td[contains(.,'#{text}')]]"
    row = find(:xpath, top_level_xpath_query, match: :first)
    raise "xpath: #{top_level_xpath_query} not found" if row.nil?

    row.find(:xpath, './/input[@type="checkbox"]', match: :first).set(true)
  end
end

When(/^I uncheck "([^"]*)" in the list$/) do |text|
  within(:xpath, '//section') do
    # use div/div/div for cve audit which has two tables
    top_level_xpath_query = "//div[@class='table-responsive']/table/tbody/tr[.//td[contains(.,'#{text}')] and .//input[@type='checkbox' and @checked]]"
    row = find(:xpath, top_level_xpath_query, match: :first)
    raise "xpath: #{top_level_xpath_query} not found" if row.nil?

    row.find(:xpath, './/input[@type="checkbox"]', match: :first).set(false)
  end
end

Then(/^I should see (\d+) "([^"]*)" fields in "([^"]*)" form$/) do |count, name, id|
  within(:xpath, "//form[@id=\"#{id}\" or  @name=\"#{id}\"]") do
    raise "#{id} form has not #{count} fields with name #{name}" unless has_field?(name, count: count.to_i)
  end
end

# Click on a button in a modal window with a specific title
When(/^I click on "([^"]*)" in "([^"]*)" modal$/) do |btn, title|
  path = "//*[contains(@class, \"modal-title\") and text() = \"#{title}\"]" \
    '/ancestor::div[contains(@class, "modal-dialog")]'

  # We wait until the element becomes visible, because
  # the fade out animation might still be in progress
  repeat_until_timeout(message: "Couldn't find the #{title} modal") do
    break if find(:xpath, path)
  end

  within(:xpath, path) do
    find(:xpath, ".//button[@title = \"#{btn}\"]").click
  end
end

# Image-specific steps
When(/^I enter "([^"]*)" relative to profiles as "([^"]*)"$/) do |path, field|
  step %(I enter "#{$git_profiles}/#{path}" as "#{field}")
end

When(/^I enter uri, username and password for portus$/) do
  step %(I enter "#{ENV['PORTUS_URI']}" as "uri")
  step %(I enter "#{ENV['PORTUS_USER']}" as "username")
  step %(I enter "#{ENV['PORTUS_PASS']}" as "password")
end
