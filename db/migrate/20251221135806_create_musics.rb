class CreateMusics < ActiveRecord::Migration[8.0]
  def change
    create_table :musics do |t|
      t.string :title
      t.string :artist
      t.string :composer
      t.string :spotify_url
      t.string :youtube_url
      t.string :apple_music_url
      t.string :genre
      t.string :era
      t.string :mood
      t.string :usage_type
      t.text :notes

      t.timestamps
    end
  end
end
