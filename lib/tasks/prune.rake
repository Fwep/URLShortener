namespace :prune do
  task prune_urls: :environment do
    puts "Pruning old URLs"
    ShortenedUrl.prune(10)
  end
end