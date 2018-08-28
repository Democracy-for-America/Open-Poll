module ApplicationHelper
  def embed_videos text
    text.to_s.gsub(/https?\:\/\/(www\.)?youtube.com\/watch\?v=([a-zA-Z0-9]+)/, '<div style="text-align: center;"><iframe width="560" height="315" style="max-width: 100%;" src="https://www.youtube.com/embed/\2" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe></div>').html_safe
  end
end
