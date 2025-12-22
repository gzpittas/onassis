namespace :images do
  desc "Pre-generate all image variants for faster page loads"
  task preprocess_variants: :environment do
    puts "Pre-generating image variants..."

    total = Image.count
    processed = 0

    Image.find_each do |image|
      next unless image.file.attached?

      begin
        # Generate each variant
        image.file.variant(:thumbnail).processed
        image.file.variant(:card).processed
        image.file.variant(:card_wide).processed
        image.file.variant(:picker).processed
        image.file.variant(:picker_wide).processed
        image.file.variant(:small).processed
        image.file.variant(:timeline).processed
        image.file.variant(:medium).processed

        processed += 1
        print "\rProcessed #{processed}/#{total} images"
      rescue => e
        puts "\nError processing image #{image.id}: #{e.message}"
      end
    end

    puts "\nDone! Processed #{processed} images."
  end
end
