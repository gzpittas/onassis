# Seed data for Onassis Timeline

# Sources
brady_book = Source.find_or_create_by!(title: "Onassis: An Extravagant Life") do |s|
  s.author = "Frank Brady"
  s.source_type = "book"
  s.publisher = "Prentice Hall"
  s.publication_date = Date.new(1977, 1, 1)
  s.notes = "Comprehensive biography covering Onassis's entire life. Generally well-researched."
end

evans_book = Source.find_or_create_by!(title: "Ari: The Life and Times of Aristotle Socrates Onassis") do |s|
  s.author = "Peter Evans"
  s.source_type = "book"
  s.publisher = "Summit Books"
  s.publication_date = Date.new(1986, 1, 1)
  s.notes = "Detailed account with insider access. Some claims disputed by family."
end

# Characters
tina = Character.find_or_create_by!(name: "Tina Livanos") do |c|
  c.birth_date = Date.new(1929, 3, 19)
  c.death_date = Date.new(1974, 10, 10)
  c.relationship = "romantic"
  c.nationality = "Greek"
  c.occupation = "Socialite"
  c.bio = "First wife of Aristotle Onassis. Daughter of shipping magnate Stavros Livanos. Later married Marquess of Blandford and then Stavros Niarchos."
end

jackie = Character.find_or_create_by!(name: "Jacqueline Kennedy") do |c|
  c.birth_date = Date.new(1929, 7, 28)
  c.death_date = Date.new(1994, 5, 19)
  c.relationship = "romantic"
  c.nationality = "American"
  c.occupation = "First Lady, Editor"
  c.bio = "Second wife of Aristotle Onassis. Widow of President John F. Kennedy. One of the most famous women of the 20th century."
end

maria = Character.find_or_create_by!(name: "Maria Callas") do |c|
  c.birth_date = Date.new(1923, 12, 2)
  c.death_date = Date.new(1977, 9, 16)
  c.relationship = "romantic"
  c.nationality = "Greek-American"
  c.occupation = "Opera Singer"
  c.bio = "The most renowned opera soprano of the 20th century. Had a long affair with Onassis that ended when he married Jackie Kennedy."
end

alexander = Character.find_or_create_by!(name: "Alexander Onassis") do |c|
  c.birth_date = Date.new(1948, 4, 30)
  c.death_date = Date.new(1973, 1, 23)
  c.relationship = "family"
  c.nationality = "Greek"
  c.occupation = "Businessman, Pilot"
  c.bio = "Only son of Aristotle Onassis. Died in a plane crash at age 24. His death devastated Onassis."
end

christina = Character.find_or_create_by!(name: "Christina Onassis") do |c|
  c.birth_date = Date.new(1950, 12, 11)
  c.death_date = Date.new(1988, 11, 19)
  c.relationship = "family"
  c.nationality = "Greek"
  c.occupation = "Shipping Heiress"
  c.bio = "Only daughter of Aristotle Onassis. Inherited his empire after his death. Had a troubled life marked by failed marriages."
end

niarchos = Character.find_or_create_by!(name: "Stavros Niarchos") do |c|
  c.birth_date = Date.new(1909, 7, 3)
  c.death_date = Date.new(1996, 4, 16)
  c.relationship = "rival"
  c.nationality = "Greek"
  c.occupation = "Shipping Magnate"
  c.bio = "Onassis's greatest business rival. Later married Tina Livanos (Onassis's ex-wife) and her sister Eugenie."
end

churchill = Character.find_or_create_by!(name: "Winston Churchill") do |c|
  c.birth_date = Date.new(1874, 11, 30)
  c.death_date = Date.new(1965, 1, 24)
  c.relationship = "social"
  c.nationality = "British"
  c.occupation = "Prime Minister"
  c.bio = "Former British Prime Minister. Close friend of Onassis who frequently hosted him on the Christina."
end

# Timeline Entries
Entry.find_or_create_by!(title: "Birth of Aristotle Onassis") do |e|
  e.event_date = Date.new(1906, 1, 15)
  e.location = "Smyrna, Ottoman Empire"
  e.entry_type = "birth"
  e.description = "Aristotle Socrates Onassis was born in Smyrna (now Izmir, Turkey) to a prosperous Greek family in the tobacco trade."
  e.significance = "The beginning of one of the most remarkable rags-to-riches stories of the 20th century."
  e.source = brady_book
  e.page_reference = "1-5"
  e.verified = true
end

Entry.find_or_create_by!(title: "Flight from Smyrna") do |e|
  e.event_date = Date.new(1922, 9, 13)
  e.location = "Smyrna, Ottoman Empire"
  e.entry_type = "travel"
  e.description = "The Onassis family fled during the destruction of Smyrna by Turkish forces. The family lost everything and Aristotle's uncles were executed."
  e.significance = "Traumatic event that shaped Onassis's worldview and drive for success. Key dramatic material for early seasons."
  e.source = brady_book
  e.page_reference = "12-18"
  e.verified = true
end

Entry.find_or_create_by!(title: "Arrival in Buenos Aires") do |e|
  e.event_date = Date.new(1923, 9, 21)
  e.location = "Buenos Aires, Argentina"
  e.entry_type = "travel"
  e.description = "Young Aristotle arrived in Argentina with almost nothing and began working as a telephone operator while building his business empire."
  e.significance = "The immigrant story - arriving with nothing and building an empire. Classic American Dream narrative despite being set in Argentina."
  e.source = brady_book
  e.page_reference = "25-30"
  e.verified = true
end

Entry.find_or_create_by!(title: "Marriage to Tina Livanos") do |e|
  e.event_date = Date.new(1946, 12, 28)
  e.location = "New York City, USA"
  e.entry_type = "marriage"
  e.description = "Onassis married Athina 'Tina' Livanos, daughter of shipping magnate Stavros Livanos. She was 17, he was 40."
  e.significance = "Marriage into Greek shipping aristocracy. The age difference and arranged nature provides dramatic tension."
  e.source = evans_book
  e.page_reference = "89-95"
  e.verified = true
  e.characters = [tina]
end

Entry.find_or_create_by!(title: "Birth of Alexander Onassis") do |e|
  e.event_date = Date.new(1948, 4, 30)
  e.location = "New York City, USA"
  e.entry_type = "birth"
  e.description = "Alexander Onassis, the only son and heir of Aristotle Onassis, was born."
  e.significance = "Introduction of Alexander - his eventual death will be the tragedy that breaks Onassis."
  e.source = brady_book
  e.page_reference = "102"
  e.verified = true
  e.characters = [tina, alexander]
end

Entry.find_or_create_by!(title: "Purchase of Monte Carlo Casino") do |e|
  e.event_date = Date.new(1953, 1, 15)
  e.location = "Monaco"
  e.entry_type = "acquisition"
  e.description = "Onassis acquired controlling interest in the Societe des Bains de Mer, which controlled the Monte Carlo Casino and much of Monaco."
  e.significance = "Onassis essentially bought Monaco. Great visual storytelling opportunity."
  e.source = brady_book
  e.page_reference = "156-165"
  e.verified = true
end

Entry.find_or_create_by!(title: "Beginning of affair with Maria Callas") do |e|
  e.event_date = Date.new(1959, 7, 1)
  e.location = "Mediterranean Sea (aboard Christina)"
  e.entry_type = "scandal"
  e.description = "During a cruise on the yacht Christina, Onassis began his famous affair with opera star Maria Callas. Both were married at the time."
  e.significance = "The great love story of Onassis's life. Callas eventually gave up her career for him."
  e.source = evans_book
  e.page_reference = "201-215"
  e.verified = true
  e.characters = [maria, tina, churchill]
end

Entry.find_or_create_by!(title: "Divorce from Tina") do |e|
  e.event_date = Date.new(1960, 6, 1)
  e.location = "New York City, USA"
  e.entry_type = "divorce"
  e.description = "Tina Livanos divorced Aristotle Onassis, citing his affair with Maria Callas."
  e.significance = "End of the first marriage. Sets up the rivalry dynamics and custody issues."
  e.source = brady_book
  e.page_reference = "220-225"
  e.verified = true
  e.characters = [tina, maria]
end

Entry.find_or_create_by!(title: "Marriage to Jacqueline Kennedy") do |e|
  e.event_date = Date.new(1968, 10, 20)
  e.location = "Skorpios, Greece"
  e.entry_type = "marriage"
  e.description = "Aristotle Onassis married Jacqueline Kennedy, widow of President John F. Kennedy, in a private ceremony on his island."
  e.significance = "The marriage that shocked the world. Endless dramatic potential - the contrast between Jackie and Maria, the Kennedy family's opposition."
  e.source = evans_book
  e.page_reference = "312-330"
  e.verified = true
  e.characters = [jackie, maria, christina, alexander]
end

Entry.find_or_create_by!(title: "Death of Alexander Onassis") do |e|
  e.event_date = Date.new(1973, 1, 22)
  e.location = "Athens, Greece"
  e.entry_type = "death"
  e.description = "Alexander Onassis died when his plane crashed shortly after takeoff from Athens airport. He was 24 years old."
  e.significance = "The tragedy that destroyed Onassis. He never recovered from his son's death."
  e.source = brady_book
  e.page_reference = "401-415"
  e.verified = true
  e.characters = [alexander, christina, jackie]
end

Entry.find_or_create_by!(title: "Death of Aristotle Onassis") do |e|
  e.event_date = Date.new(1975, 3, 15)
  e.location = "Paris, France"
  e.entry_type = "death"
  e.description = "Aristotle Onassis died at the American Hospital in Paris of respiratory failure, following complications from myasthenia gravis."
  e.significance = "The end of an era. His death at 69 came after years of declining health following Alexander's death."
  e.source = brady_book
  e.page_reference = "445-450"
  e.verified = true
  e.characters = [christina, jackie]
end

puts "Seed data created successfully!"
puts "- #{Source.count} sources"
puts "- #{Character.count} characters"
puts "- #{Entry.count} timeline entries"
