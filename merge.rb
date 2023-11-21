#!/usr/bin/env ruby

require 'yaml'
require 'time'

due = ARGV.shift

clean = ARGV.shift

def clock_timer(due, timer, biggest_timer)
  return timer.to_s if timer < 0
  return timer.to_s unless due
  serve_dt = Time.parse(due)
  step_dt = serve_dt - (biggest_timer - timer) * 60
  step_dt.strftime('%R')
end

recipes = Dir.glob('recipes/*.yaml').map do |x|
  [
    x.split('/').last.split('.').first,
    YAML.safe_load(File.read(x))
  ]
end

steps = []

biggest_timer = recipes.map { |_, x| x['steps'].keys.max }.max
longest_name = recipes.map { |x, _| x.size }.max

recipes.each do |name, data|
  recipe_biggest_timer = data['steps'].keys.max
  data['steps'].each do |timer, text|
    adj_timer = timer < 0 ? timer : biggest_timer - (recipe_biggest_timer - timer)
    steps << [adj_timer, name, text]
  end
end

steps.sort_by!(&:first)

if clean
  puts steps.map { |x| x.join(" -- ") }
  exit
end

steps.each do |timer, name, text|
  chunks = text.scan(/.{1,80}/)
  puts "#{clock_timer(due, timer, biggest_timer).ljust(5)} -- #{name.ljust(longest_name)} -- #{chunks.first}"
  next unless chunks.size > 1
  chunks[1..-1].each { |x| puts ' ' * (5 + 8 + longest_name) + x }
end
