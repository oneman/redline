#!/usr/bin/ruby

# ruby redline version alpha 1
# a green icon shows up in your system tray.
# it turns red when more than the set percentage of aggregate cpu is being used by some program
# and puts the offending program names in the tooltip so you can deal with it
# drr 2009 
#
# license gpl3 / give me some money 


require 'gtk2'

redline_percentage = 90
yellowline_percentage = 80

yellowline_enable = true

tooltip_setting = "I turn red when some program is using more than #{redline_percentage}% of any cpu or aggregate of cpus."
puts tooltip_setting

#get_cpu_info = "ps -e -o pcpu,cpu,nice,state,cputime,args --sort pcpu | sed '/^ 0.0 /d'"
get_cpu_info = "nice top -b -n 1"

$icon = Gtk::StatusIcon.new
$icon.icon_name = 'gdu-smart-healthy'
$icon.tooltip = tooltip_setting
#$icon.signal_connect('activate') { some_window }

timeout = Gtk::timeout_add(3000) { 

program_cpu_usage_info = `#{get_cpu_info}`

bad_programs = ""
mean_programs = ""

for line in program_cpu_usage_info.lines

 if line.split(" ")[0].to_i > 0 && line.split(" ")[8].to_i > redline_percentage
  bad_programs = bad_programs + line + "\n"
 end

 if line.split(" ")[0].to_i > 0 && line.split(" ")[8].to_i > yellowline_percentage
  mean_programs = mean_programs + line + "\n"
 end
end

if bad_programs != ""
 $icon.icon_name = 'gdu-smart-failing'
 $icon.tooltip = bad_programs
else
 if yellowline_enable && mean_programs != ""
  $icon.icon_name = 'gdu-smart-threshold'
  $icon.tooltip = mean_programs
 else
  if $icon.icon_name != 'gdu-smart-healthy'
   $icon.icon_name = 'gdu-smart-healthy'
   $icon.tooltip = 'Just fine now.'
  end
 end
end


true
}

Gtk.main
