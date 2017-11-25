require_relative 'lib/build_monitor'

USAGE = <<USAGE.strip.freeze
  Usage: buildmon [-u user] [-r repo]
USAGE

HELP = <<HELP.freeze
  -h, --help              show this help
  -r, --repo <name>       project to monitor
  -u, --user <name>       user to monitor
HELP

args = {}
next_arg = nil

ARGV.each do |arg|
  case arg
  when '-h', '--help' then args[:help] = true
  when '-u', '--user' then next_arg = :user
  when '-r', '--repo' then next_arg = :repo
  else
    if next_arg
      args[next_arg] = arg
    else
      args[:help] = true
    end
  end
end

if args[:help]
  puts USAGE
  puts HELP
else
  BuildMonitor.new(args).run
end
