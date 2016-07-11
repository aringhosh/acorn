source <- GET("https://www.instagram.com/p/BHt_EZVBdC5") # normal
source <- GET("https://www.instagram.com/p/BHSBpF0BSU-/") # video

r <- content(source, "text")
spilit <- strsplit(r, "<script type=\"text/javascript\">window._sharedData =")
data <- spilit[[1]][2] #get second element
s <- strsplit(data, "</script")
data <- s[[1]][1]
data <- substr(data, 1, str_length(data)-1) #remove the trailing ;
df <- fromJSON(data)

#details for reach
#username <- df$entry_data$PostPage$media$owner$username
#source <- GET("https://www.instagram.com/carinkilbyclark")
#followed_by <- df$entry_data$ProfilePage$user$followed_by$count

comment_count <- df$entry_data$PostPage$media$comments$count
likes_count <- df$entry_data$PostPage$media$likes$count

#video
is_video <- df$entry_data$PostPage$media$is_video
video_views <- df$entry_data$PostPage$media$video_views