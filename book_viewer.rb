require 'tilt/erubis'
require "sinatra"
require "sinatra/reloader" if development?

before do
	@contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, "<strong>#{term}</strong>")
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  num = params[:number].to_i
  @chapter_title = @contents[num - 1]

  redirect "/" unless (1..@contents.size).cover?(num)

  @title = "Chapter #{num}: #{@chapter_title}"
  @chapter = File.read("data/chp#{num}.txt")

  erb :chapter
end

# Calls the block for each chapter, passing that chapter's number, name, and
# contents.
def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end



# --------- My latest own solution ---------------- #
# require 'tilt/erubis'
# require "sinatra"
# require "sinatra/reloader" if development?

# helpers do
#   def paragraphs(string)
#     string.split("\n\n").map.with_index {|line, index| "<p id=#{index}>#{line}</p>"}.join('')
#   end

#   def embolden(text, term)
#     text.gsub(term, %(<strong>#{term}</strong>))
#   end
# end

# before do
#   @title = "The Adventures of Sherlock Holmes"
#   @toc = File.readlines("data/toc.txt")
# end

# not_found do
#   redirect "/"
# end

# def each_chapter
#   @toc.each_with_index do |title, index|
#     chapter_number = index + 1
#     content = File.read("data/chp#{chapter_number}.txt")
#   yield chapter_number, title, content
#   end
# end

# def chapters_matching(query)
#   return nil if (query.nil? || query.strip.empty?)
#   results = []

#   each_chapter do |number, title, contents|
#     if contents.include?(query.strip)
#       matches = {}
#       contents.split("\n\n").each_with_index do |content, index|
#         matches[index] = content if content.include?(query)
#       end
#       results << {number: number, title: title, paragraphs: matches}
#     end
#   end
#   results
# end

# get "/" do
#   erb :home
# end

# get "/chapters/:chapter_number" do
#   @chapter_number = params[:chapter_number].to_i
#   redirect "/" unless (1..@toc.size).cover? @chapter_number

#   @chapter_title = @toc[@chapter_number - 1]
#   @chapter_content = File.read("data/chp#{@chapter_number}.txt")
#   erb :chapter
# end

# get "/search" do
#   @results = chapters_matching(params[:query])
#   erb :search
# end