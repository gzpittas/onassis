namespace :data do
  desc "Migrate existing single-source entries to multi-source system"
  task migrate_sources: :environment do
    migrated = 0

    Entry.where.not(source_id: nil).find_each do |entry|
      next if entry.entry_sources.exists?(source_id: entry.source_id)

      entry.entry_sources.create!(
        source_id: entry.source_id,
        page_reference: entry.page_reference
      )
      puts "Migrated: #{entry.title}"
      migrated += 1
    end

    puts "Migration complete! Migrated #{migrated} entries."
  end
end
