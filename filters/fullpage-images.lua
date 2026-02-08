-- Lua filter to convert images with height=100% to full-page images

function Para(elem)
  -- Check if this paragraph contains only an image with height=100%
  if #elem.content == 1 and elem.content[1].t == "Image" then
    local img = elem.content[1]
    if img.attributes.height == "100%" then
      -- Create raw LaTeX for full-page image as a block
      local latex = string.format("\\fullpageimage{%s}", img.src)
      return pandoc.RawBlock('latex', latex)
    end
  end
  return elem
end

function Figure(elem)
  -- Check if this figure contains an image with height=100%
  if elem.content and elem.content[1] and elem.content[1].t == "Plain" then
    local plain = elem.content[1]
    if #plain.content == 1 and plain.content[1].t == "Image" then
      local img = plain.content[1]
      if img.attributes.height == "100%" then
        -- Create raw LaTeX for full-page image as a block
        local latex = string.format("\\fullpageimage{%s}", img.src)
        return pandoc.RawBlock('latex', latex)
      end
    end
  end
  return elem
end
