module BlogsHelper
  #Renders the posts depending on post type. Used in the show blog page
  def post_renderer(post)
    post_type = post["type"]
    case post_type
    when 'photo'
      short_url_block(post){ content_tag :img, nil, src: post["photos"][0]["alt_sizes"][2]["url"] }
    when 'text'
      if post["title"].present? 
        short_url_block(post){ post["title"] }
      else
        short_url_block(post){"link to text post"}
      end
    when 'video'
      if post["thumbnail_url"].present?
        short_url_block(post){ content_tag :img, nil, src: post["thumbnail_url"] }
      else
        short_url_block(post){ "link to video post" }
      end
    when 'audio'
      if post["thumbnail_url"].present?
        short_url_block(post){ content_tag :img, nil, src: post["album_art"] }
      else
        short_url_block(post){ "link to audio post" }
      end
    when 'quote'
      short_url_block(post){ post["text"] }
    when 'link'
      short_url_block(post){ post["title"] }
    when 'chat'
      if post["title"].present?
        short_url_block(post){ content_tag :h5, post["title"] }
      else
        short_url_block(post){ "link to chat post" }
      end
    when 'answer'
      short_url_block(post){ content_tag :h5, post["question"] }
    end
  end

  def short_url_block (post)
    content_tag :a, href: post["short_url"], target: "_blank" do 
      yield
    end
  end
end
