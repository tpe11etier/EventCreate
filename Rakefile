desc "List available tasks"
task :default do
	sh %{ rake -T }
end

desc "Make ConnectivityTest_EP.exe executable"
task :exe do
	sh %{ ocra ConnectivityTest_EP.rb }
	sh %{ RD /S /Q dist && MD dist }
	sh %{ cp config.yml ConnectivityTest_EP.exe README dist }
end
