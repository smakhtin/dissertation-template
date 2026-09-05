-- Lua filter to convert images with height=100% to full-page images

local function escape_latex(text)
  if not text or text == "" then
    return ""
  end

  local escaped = text
  escaped = escaped:gsub("\\", "\\textbackslash{}")
  escaped = escaped:gsub("([{}$&#_%%])", "\\%1")
  escaped = escaped:gsub("~", "\\textasciitilde{}")
  escaped = escaped:gsub("%^", "\\textasciicircum{}")
  return escaped
end

local function fullpage_latex(src, caption)
  local safe_caption = escape_latex(caption)
  if safe_caption == "" then
    return string.format("\\fullpageimage{%s}", src)
  end
  return string.format("\\fullpageimage[%s]{%s}", safe_caption, src)
end

function Para(elem)
  -- Check if this paragraph contains only an image with height=100%
  if #elem.content == 1 and elem.content[1].t == "Image" then
    local img = elem.content[1]
    if img.attributes.height == "100%" then
      -- Create raw LaTeX for full-page image as a block
      local caption = pandoc.utils.stringify(img.caption)
      local latex = fullpage_latex(img.src, caption)
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
        local caption = ""
        if elem.caption then
          caption = pandoc.utils.stringify(elem.caption)
        else
          caption = pandoc.utils.stringify(img.caption)
        end
        local latex = fullpage_latex(img.src, caption)
        return pandoc.RawBlock('latex', latex)
      end
    end
  end
  return elem
end

function Pandoc(doc)
  local blocks = {}
  local flush_after_heading = false

  for index, block in ipairs(doc.blocks) do
    table.insert(blocks, block)

    if flush_after_heading then
      table.insert(blocks, pandoc.RawBlock("latex", "\\fullpageimageflushnote{}"))
      flush_after_heading = false
    end

    local is_fullpage_image = block.t == "RawBlock"
      and block.format == "latex"
      and block.text:match("^\\fullpageimage")
    local next_block = doc.blocks[index + 1]

    if is_fullpage_image and next_block then
      if next_block.t == "Header" then
        flush_after_heading = true
      else
        table.insert(blocks, pandoc.RawBlock("latex", "\\fullpageimageflushnote{}"))
      end
    end
  end

  doc.blocks = pandoc.Blocks(blocks)
  return doc
end
