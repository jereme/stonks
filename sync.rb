#!/usr/bin/ruby
require 'redis'
require 'rspotify'
require 'slack-notifier'
require 'time'

execution_interval  = ENV['EXECUTION_INTERVAL']
spotify_client_id   = ENV['SPOTIFY_CLIENT_ID']
spotify_secret      = ENV['SPOTIFY_SECRET']
spotify_playlist    = ENV['SPOTIFY_PLAYLIST']
spotify_username    = ENV['SPOTIFY_USERNAME']
redistogo_url       = ENV['REDISTOGO_URL']
slack_url           = ENV['SLACK_URL']

RSpotify.authenticate(spotify_client_id, spotify_secret)
puts ENV.inspect
def get_spotify_user(id)
  RSpotify::User.find(id)
end

def get_new_tracks(spotify_username, spotify_playlist, since_time)
  playlist = RSpotify::Playlist.find(spotify_username, spotify_playlist)
  
  new_tracks = Array.new

  if playlist
    playlist.tracks.each do |track|
      track_info = Hash.new
      added_by = playlist.tracks_added_by[track.id]
      
      added_by_user = get_spotify_user(added_by.id)
      
      added_at = playlist.tracks_added_at[track.id]
      track_info[:playlist_name] = playlist.name
      track_info[:playlist_uri] = playlist.uri
      track_info[:url] = track.external_urls['spotify']
      
      if !added_by_user.nil?
        track_info[:added_by] = added_by_user.display_name.nil? ? added_by_user.id : added_by_user.display_name
        track_info[:added_by_uri] = added_by_user.uri
      end
      
      track_info[:added_at] = added_at
      if since_time.nil? or since_time < track_info[:added_at]
        new_tracks << track_info
      end
    end  
  end
  return new_tracks
end

def is_numeric(string)
  !!(string =~ /^\d+$/)
end

def post_track(slack_notifier, track)
  post_string = ""
  
  if track[:added_by].nil? and !is_numeric(track[:added_by])
    post_string = sprintf("New track added to <%s|%s>: <%s|(link)>", track[:playlist_uri], track[:playlist_name], track[:url])
  else
    post_string = sprintf("New track added to <%s|%s> by <%s|%s>: <%s|(link)>", track[:playlist_uri], track[:playlist_name], track[:added_by_uri], track[:added_by], track[:url])
  end
puts post_string  
  # slack_notifier.ping post_string
end

def post_new_tracks(slack_notifier, new_tracks)
  if new_tracks.is_a?(Array) and !new_tracks.empty?
    new_tracks.each do |track|
      post_track(slack_notifier, track)
    end
  end
end

redis = Redis.new(:url => ENV['REDISTOGO_URL'])
slack_notifier = Slack::Notifier.new slack_url, :username => 'Spotify SOTD', :icon_url => 'http://i.imgur.com/CujKStk.png'
last_updated_string = redis.get('last_updated')
last_updated = last_updated_string.empty? ? nil : Time.parse(last_updated_string)

loop do
  # Get current UTC time
  current_time = Time.now.utc

  begin
    # Scan the playlist for new tracks
    new_tracks = get_new_tracks(spotify_username, spotify_playlist, last_updated)
  
    # If we have new tracks post them
    if !new_tracks.empty?
      post_new_tracks(slack_notifier, new_tracks)
    end
  rescue
    puts "Failed to get update"
  end

  # Persist the last updated timestamp
  last_updated = current_time
  redis.set('last_updated', last_updated)
  
  puts sprintf("Last checked at %s", last_updated.to_s)
  sleep execution_interval.to_i
end
