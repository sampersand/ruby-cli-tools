#!/Users/sampersand/.rvm/rubies/default/bin/ruby
require 'set'
require 'digest'
require 'optparse'

invert = false
digest = Digest::MD5
$\ ||= $/ # Output separator defaults to input separator as we `chomp!` the input line

OptParse.new do |opts|
	opts.on('Only output input files that are unique')
		.on('-h', '--help', 'Print this'){ puts opts; exit }
		.on('-i', '--invert', 'Display duplicates'){ invert = true }
		.on(      '--md5', 'Uniqueness by MD5 (default)'){ digest = proc{ Digest::MD5.file(_1).digest } }
		.on(      '--sha256', 'Uniqueness by SHA256'){ digest = proc{ Digest::SHA256.file(_1).digest } }
		.on(      '--basename', 'Uniqueness by basename'){ digest = proc{ File.basename(_1).hash } }
		.on('-0', '--sep[=\0]', 'Set both input and output seperator'){ $\ = $/ = _1 || "\0" }
		.on(      '--isep[=\0]', "Change input seperator (default=#{$/.inspect})"){  $/ = _1 || "\0" }
		.on(      '--osep[=\0]', "Change output seperator (default=#{$\.inspect})"){ $\ = _1 || "\0" }
end.parse!

FILES = Set.new

while gets
	$_.chomp! # remove line ending in case $/ and $\ differ.
	begin
		# invert is always true/false, both of which convert the RHS of `^` to a boolean. `As Set::add?`
		# returns `nil` when the digest already exists, we can use `^` as a slightly faster alternative 
		# to `invert == !!Files.add?(...)`
		print if invert ^ FILES.add?(digest.call($_))
	rescue
		# warn on errors, but keep going.
		warn "#{File.basename $0}: #$!"
	end
end