require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  @chapter_title = @contents[number-1]

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number} : #{@chapter_title}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  all_chapters = get_chapters
  @search_query = params[:query]

  if @search_query
    @matching_chapters = all_chapters.select do |chapter_number, chapter|
      chapter[:content].any? {|line_number, line| line.include?(@search_query) }
    end
  end

  erb :search
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(chapter)
    chapter.split("\n\n").map.with_index do |line, index|
      "<p id='#{index+1}'>#{line}</p>"
    end.join
  end

  def highlight_text(line)
    line.gsub(@search_query, "<strong>#{@search_query}</strong>")
  end
end

def get_chapters
  number_of_chapters = @contents.size

  (1..number_of_chapters).each_with_object({}) do |current_number, hsh|
    chapters = {}
    File.read("data/chp#{current_number}.txt").split("\n\n").each_with_index do |line, index|
      chapters[index+1] = line
    end

    hsh[current_number] = {
      title: @contents[current_number-1],
      content: chapters
    }
  end
end

# def get_title(chapter_number)
#   @contents[chapter_number-1]
# end

# def get_query(chapter)
#   chapter.select { |line| line.include?(@search_query) }
# end
