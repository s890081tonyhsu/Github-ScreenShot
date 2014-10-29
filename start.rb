require 'selenium-webdriver'
require 'zhconv'
require 'json'

def init_Browser_ff
	data = JSON.parse(File.open("arguments.json", "r").read)
	Selenium::WebDriver::Firefox::Binary.path = data["firefox"]["binary"]
	profile = Selenium::WebDriver::Firefox::Profile.new
	download_path = Dir.pwd + "/downloaded"
	profile['browser.download.dir'] = download_path.gsub("/", "\\")
	profile['browser.download.folderList'] = 2
	profile['browser.helperApps.neverAsk.saveToDisk'] = "text/plain"
	profile["browser.altClickSave"] = true
	
	driver = Selenium::WebDriver.for :firefox, :profile => profile
	driver.manage.window.maximize
	return driver	
end

def read_List
	name = Array.new
	account = Array.new
	githubList = File.readlines('Github-List.md')
	# name: ####\s(\S*)
	# account: github.com\/(\w*)
	githubList.each do |line|
		if /####\s([^\n\r]*)/ =~ line
			name.push(/####\s(\S*)/.match(line)[1])
		end

		if /github\.com\/(\S*)/ =~ line
			account.push(/github\.com\/(\S*)/.match(line)[1])
		end
	end
	return Hash[account.zip name]
end

def snap_GithubProfile(browser, account)
	path = './screenshot/GithubProfile/' + account + '.png'
	browser.navigate.to "https://github.com/" + account
	browser.save_screenshot(path)
	return path
end

def snap_GithubIO(browser, account)
	path = './screenshot/GithubIO/' + account + '.png'
	browser.navigate.to "http://"+ account +".github.io/"
	sleep 3
	browser.save_screenshot(path)
	return path
end

def main
	browser = init_Browser_ff()
	list = read_List
	markdown = File.open("Github-ScreenShot.md", "w:UTF-8")
	markdown.write("Github ScreenShot\n==========\n\n")
	
	list.each do |account, name|
		markdown.write(name + "\n----------")
		markdown.write("\n![GithubProfile](" + snap_GithubProfile(browser, account) +")\n")
		markdown.write("\n![GithubIO](" + snap_GithubIO(browser, account) +")\n")
	end
	markdown.close
end

main()
