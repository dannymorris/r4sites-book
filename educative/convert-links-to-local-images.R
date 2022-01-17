
library(stringr) 
library(dplyr)
library(purrr)

# read unformatted manuscript lines
manu <- readLines("educative/raw_manuscript.md")

# pattern to find imgur images
pattern <- "http[s]?://i\\.imgur\\.com/(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+.png"

# extract imgur image paths
imgur_paths <- str_extract_all(manu, pattern)

# convert web links to images to local image files
replaced_images <- map(manu, function(i) {
  
  # get imgur paths on web
  imgur_paths <- str_extract_all(i, pattern) %>% unlist()
  
  # extract image unique ID
  imgur_names <- str_split(imgur_paths, "/") %>% 
    map(., function(i) i[4]) %>%
    unlist()
  
  # for each image, download and rename using unique ID
  map2(imgur_paths, imgur_names, function(p, nm) {
    download.file(
      url = p,
      destfile = paste0("educative/images/", nm)
    )
  })
  
  # replace link in original text with path to local image
  if (length(imgur_paths >= 1)) {
    for (x in seq(1, length(imgur_paths))) {
      i <- str_replace(
        string = i,
        pattern = imgur_paths[x],
        replacement = paste0("images/", imgur_names[x])
      )
    }
  }
  
  # replace target_blank with empty
  i <- str_replace_all(
    string = i,
    pattern = "\\{target=\"blank\"\\}",
    replacement = ""
  )
  
  # replace [Image] with ![Image] to indicate local file
  i <- str_replace_all(
    string = i,
    pattern = "\\[Image\\]|\\(\\[Image\\]",
    replacement = "![Image]"
  )
  
  # replace .png)) with .png)
  i <- str_replace_all(
    string = i,
    pattern = "\\.png\\)\\)",
    replacement = ".png)"
  )
  
  return(i)
})

# write output
writeLines(
  text = unlist(replaced_images),
  con = "educative/formatted_manuscript.md"
)


