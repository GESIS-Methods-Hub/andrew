function Para(element)
    if element.content[1].tag == 'Link' and element.content[1].content[1].tag == 'Image' and string.find(element.content[1].content[1].src, "badge")  then
        return pandoc.Para{}
    end

    return element
end
