class BackfillEntryEventParts < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE entries
      SET event_year = CAST(strftime('%Y', event_date) AS integer),
          event_month = CAST(strftime('%m', event_date) AS integer),
          event_day = CAST(strftime('%d', event_date) AS integer)
      WHERE event_date IS NOT NULL
        AND (event_year IS NULL OR event_month IS NULL OR event_day IS NULL);
    SQL

    execute <<~SQL
      UPDATE entries
      SET end_year = CAST(strftime('%Y', end_date) AS integer),
          end_month = CAST(strftime('%m', end_date) AS integer),
          end_day = CAST(strftime('%d', end_date) AS integer)
      WHERE end_date IS NOT NULL
        AND (end_year IS NULL OR end_month IS NULL OR end_day IS NULL);
    SQL
  end

  def down
    # No-op: data backfill is intentionally one-way.
  end
end
