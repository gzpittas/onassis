class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :youtube_url
      t.string :vimeo_url
      t.string :other_url
      t.string :video_type
      t.string :duration
      t.date :publication_date
      t.string :source
      t.string :creator
      t.text :notes

      t.timestamps
    end
  end
end
