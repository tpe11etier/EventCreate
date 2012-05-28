desc "List available tasks"
task :default do
	sh %{ rake -T }
end

desc "Make eventcreate.exe executable"
task :exe do
	sh %{ ocra eventcreate.rb }
	sh %{ RD /S /Q dist && MD dist }
	sh %{ cp config.yml eventcreate.exe README dist } 
end
